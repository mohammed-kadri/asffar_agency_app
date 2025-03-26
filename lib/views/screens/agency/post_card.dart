import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final int price;
  final String agencyName;
  final String destination;
  final String date;
  final int availableSeats;
  final int duration;
  final String imageUrl;
  final String agencyImageUrl;
  final Map<String, dynamic> agencyData; // Add agencyData parameter

  const PostCard({
    Key? key,
    required this.price,
    required this.agencyName,
    required this.destination,
    required this.date,
    required this.availableSeats,
    required this.duration,
    required this.imageUrl,
    required this.agencyImageUrl,
    required this.agencyData, // Add agencyData parameter
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: double.infinity,
        height: 250,
        margin: EdgeInsets.only(bottom: 17),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(12),
            // ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 1,
                offset: Offset(1, 1),
              )
            ]),
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                'https://cdn.craft.cloud/101e4579-0e19-46b6-95c6-7eb27e4afc41/assets/uploads/pois/prague-czech-republic-frommers.jpg',
                height: 95,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
                top: 55,
                right: 20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          Colors.grey.withOpacity(0.5), // Color of the border
                      width: 0.8, // Border width
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(
                        MediaQuery.sizeOf(context)
                            .width)), // Same borderRadius as in ClipRRect
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(MediaQuery.sizeOf(context).width)),
                    child: Image.network(
                      '${widget.agencyData['profilePictureUrl']}',
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
            Positioned( 
              right: 115,
              top: 105,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.agencyData['agencyName']}',
                    softWrap: false,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily),
                  ),
                  // SizedBox(height: 4),
                  Text(
                    'الوجهة: قسنطينة، سطيف',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 160,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('التاريخ: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500)),
                      Text('15/01/2025',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF313131),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppTheme.lightTheme.textTheme
                                  .bodyMedium!.fontFamily)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('الأماكن المتبقية: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500)),
                      Text('12',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF313131),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppTheme.lightTheme.textTheme
                                  .bodyMedium!.fontFamily)),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 200,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('المدة (باليوم): ',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500)),
                      Text('5',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF313131),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppTheme.lightTheme.textTheme
                                  .bodyMedium!.fontFamily)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('السعر للشخص: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              color: Color(0xFF313131))),
                      Text('${widget.price.toString()} دج ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              color: Color(0xFF313131))),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
                left: 10,
                bottom: 10,
                child: InkWell(
                  onTap: () {}, // Your onPressed logic goes here
                  borderRadius: BorderRadius.circular(
                      4), // Set the border radius for the container
                  child: Container(
                    padding: EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 8,
                        bottom: 5), // Add padding inside the container
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius: BorderRadius.circular(
                          4), // Same border radius as the button
                      border: Border.all(color: Colors.green), // Border color
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ensures the row takes up only as much space as needed
                      children: [
                        Text(
                          'التفاصيل',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green, // Text color
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                          ),
                        ),
                        SizedBox(
                            width:
                                8), // Add space between the icon and the text

                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.green,
                          size: 11, // Icon color
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

Widget buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    ),
  );
}
