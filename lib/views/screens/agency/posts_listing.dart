import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/views/screens/agency/post_card.dart';

import '../../../theme/app_theme.dart';

class PostsListing extends StatefulWidget {
  const PostsListing({super.key});

  @override
  State<PostsListing> createState() => _PostsListingState();
}

class _PostsListingState extends State<PostsListing> {
  Map<String, dynamic>? agencyData;
  var data;
  @override
  void initState() {
    super.initState();
    _fetchAgencyData();
  }

  Future<void> _fetchAgencyData() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('agencies')
            .doc(user.uid)
            .get();
        setState(() {
          agencyData = doc.data();
        });
      } catch (e) {
        print('Error fetching agency data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (agencyData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20, top: 18, bottom: 10),
              child: data != null
                  ? Text(
                      'منشوراتي:',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w600),
                    )
                  : SizedBox(),
            )
          ],
        ),
        Expanded(
          child: FirestorePagination(
            limit: 5, // Reduced from 420 to a more reasonable number
            viewType: ViewType.list,
            query: FirebaseFirestore.instance
                .collection('services')
                .where('agencyId',
                    isEqualTo: Provider.of<AuthService>(context, listen: false)
                        .currentUser!
                        .uid)
                .orderBy('postedDate', descending: true), // Add ordering
            bottomLoader: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.blue,
              ),
            ),
            itemBuilder: (context, documentSnapshots, index) {
              // Access the document snapshot correctly
              final doc = documentSnapshots[index];
              // Get the data as a Map
              data = doc.data() as Map<String, dynamic>?;

              if (data == null) return Container();

              return PostCard(
                price: data['price'] ?? 0,
                agencyName: data['agencyName'] ?? '',
                destination: data['destination'] ?? '',
                date: data['date'] ?? '',
                availableSeats: data['availableSeats'] ?? 0,
                duration: data['duration'] ?? 0,
                imageUrl: data['imageUrl'] ?? '',
                agencyImageUrl: data['agencyImageUrl'] ?? '',
                agencyData: agencyData ?? {}, // Pass agency data
              );
            },
            // Add empty state

            onEmpty: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/home_add_post.jpg',
                    width: MediaQuery.of(context).size.width * 0.75,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'لم تقم باضافة أي منشور بعد',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            // Add error handling
          ),
        ),
      ],
    );
  }
}
