import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/app_localizations.dart';

import '../../../providers/auth_provider.dart';

class AgencyProfile extends StatefulWidget {
  @override
  State<AgencyProfile> createState() => _AgencyProfileState();
}

class _AgencyProfileState extends State<AgencyProfile> {
  bool isTrips = true;

  @override
  Widget build(BuildContext context) {
    final userId =
        Provider.of<AuthService>(context, listen: false).currentUser!.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('agencies')
                        .doc(userId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return Center(
                            child: Text(AppLocalizations.of(context)!
                                .translate('noDataFound')));
                      }

                      final agencyData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final hasBlueBadge = agencyData['hasBlueBadge'] ?? false;
                      final agencyName = agencyData['agencyName'] ?? '';
                      final profileImageUrl =
                          agencyData['profilePictureUrl'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // CircleAvatar(
                            //   radius: 50,
                            //   backgroundImage: profileImageUrl.isNotEmpty
                            //       ? NetworkImage(
                            //           profileImageUrl,
                            //         )
                            //       : AssetImage(
                            //               'assets/images/img_person_placeholder.jpg')
                            //           as ImageProvider,
                            // ),
                            ClipOval(
                              child: Image.network(
                                profileImageUrl,
                                height: 100,
                                width: 100,
                                loadingBuilder: (BuildContext ctx, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress != null) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.grey[600],
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return child;
                                },
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  agencyName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                  ),
                                ),
                                if (hasBlueBadge)
                                  Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/agency_edit_profile');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                        overlayColor: Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            side: BorderSide(
                                                color: Color(0xFF313131)
                                                    .withOpacity(0.2))),
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('editAgencyInfo'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF313131)
                                                .withAlpha(200),
                                            fontFamily: AppTheme
                                                .lightTheme
                                                .textTheme
                                                .bodyMedium!
                                                .fontFamily,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  AnimatedButtonBar(
                    elevation: 0.0,
                    radius: 5.0,
                    padding: const EdgeInsets.only(
                        top: 5.0, bottom: 0, left: 16, right: 16),
                    invertedSelection: true,
                    backgroundColor: Color(0xFFFAFAFA),
                    foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                    children: [
                      ButtonBarEntry(
                          onTap: () {
                            setState(() {
                              isTrips = true;
                            });
                          },
                          child: Text(
                            'Trips',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 16,
                              // color: Color(0xFF313131).withOpacity(0.3),
                              // fontWeight: _selectedPeriod == 2 ? FontWeight.w700:  FontWeight.w400,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                            ),
                          )),
                      ButtonBarEntry(
                          onTap: () {
                            setState(() {
                              isTrips = false;
                            });
                          },
                          child: Text(
                            'Services',
                            style: TextStyle(
                              fontSize: 16,
                              // fontWeight: FontWeight.w600,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                            ),
                          )),
                    ],
                  ),
                  isTrips
                      ? TripsTab(userId: userId)
                      : ServicesTab(userId: userId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TripsTab extends StatefulWidget {
  final String userId;

  TripsTab({required this.userId});

  @override
  _TripsTabState createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.translate('trips')),
    );
  }
}

class ServicesTab extends StatefulWidget {
  final String userId;

  ServicesTab({required this.userId});

  @override
  _ServicesTabState createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.translate('services')),
    );
  }
}

class ChangeAgencyInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)!.translate('changeAgencyInfos')),
      ),
      body: Center(
        child: Text(
            AppLocalizations.of(context)!.translate('changeAgencyInfosPage')),
      ),
    );
  }
}