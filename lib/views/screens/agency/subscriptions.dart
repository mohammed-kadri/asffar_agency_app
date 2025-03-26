import 'dart:convert';
import 'dart:math';
import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/services/subscription_service.dart';

import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  var couponApplied = false;
  var usedCouponId = '';
  var _selectedPeriod = 0;
  var _selectedSybscriptionType;

  var paymentVerificationObject = null;
  var paymentVerificationSent;
  var paymentVerificationStatus;
  var paymentVerificationChecked = false;

  final TextEditingController _discountCodeController = TextEditingController();

  Map<String, dynamic> prices = {
    '1': {
      'starter': 0,
      'basic': 0,
      'silver': 0,
      'golden': 0,
    },
    '6': {
      'starter': 0,
      'basic': 0,
      'silver': 0,
      'golden': 0,
    },
    '12': {
      'starter': 0,
      'basic': 0,
      'silver': 0,
      'golden': 0,
    }
  };

  Map<String, dynamic> newPrices = {};

  @override
  void initState() {
    super.initState();
    _loadPrices();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    var user = Provider.of<AuthService>(context, listen: false).currentUser;
    final response = await http.get(Uri.parse(
        'https://checkpaymentverification-fnzltfhora-uc.a.run.app?userId=${user!.uid}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['exists']) {
        paymentVerificationObject = data['data'];
        final status = data['data']['status'];
        paymentVerificationStatus = status;
        if (status == 'approved') {
        } else if (status == 'pending') {}
      }
    }
    paymentVerificationChecked = true;
  }

  Future<void> _loadPrices() async {
    final subscriptionService = SubscriptionService();
    final loadedPrices = await subscriptionService.getSubscriptionPrices();
    if (loadedPrices != null) {
      setState(() {
        prices = loadedPrices;
      });
      print(prices);
    }
  }

  Future<void> _applyCoupon() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: _discountCodeController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot couponDoc = querySnapshot.docs.first;
        Timestamp endDate = couponDoc['endDate'];
        if (endDate.toDate().isAfter(DateTime.now())) {
          setState(() {
            newPrices = couponDoc['newPrices'];
            couponApplied = true;
            usedCouponId = couponDoc.id;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Coupon has expired',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid coupon code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print('Error applying coupon: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  String _getEndDate(DateTime startDate, int duration) {
    DateTime endDate;
    switch (duration) {
      case 1:
        endDate = startDate.add(Duration(days: 30));
        break;
      case 6:
        endDate = startDate.add(Duration(days: 180));
        break;
      case 12:
        endDate = startDate.add(Duration(days: 365));
        break;
      default:
        endDate = startDate;
    }
    return _formatDate(endDate);
  }

  @override
  Widget build(BuildContext context) {

    priceGetter(String duration, String subscriptionType) {
      if (!couponApplied) {
        if (duration == "0") {
          switch (subscriptionType) {
            case 'starter':
              return prices['1']['starter'] == 0
                  ? 'loading..'
                  : prices['1']['starter'];
              break;
            case 'basic':
              return prices['1']['basic'] == 0
                  ? 'loading..'
                  : prices['1']['basic'];
              break;
            case 'silver':
              return prices['1']['silver'] == 0
                  ? 'loading..'
                  : prices['1']['silver'];
              break;
            case 'golden':
              return prices['1']['golden'] == 0
                  ? 'loading..'
                  : prices['1']['golden'];
              break;
            default:
              return 0;
          }
        } else if (duration == "1") {
          switch (subscriptionType) {
            case 'starter':
              return prices['6']['starter'] == 0
                  ? 'loading..'
                  : prices['6']['starter'];
              break;
            case 'basic':
              return prices['6']['basic'] == 0
                  ? 'loading..'
                  : prices['6']['basic'];
              break;
            case 'silver':
              return prices['6']['silver'] == 0
                  ? 'loading..'
                  : prices['6']['silver'];
              break;
            case 'golden':
              return prices['6']['golden'] == 0
                  ? 'loading..'
                  : prices['6']['golden'];
              break;
            default:
              return 0;
          }
        } else if (duration == "2") {
          switch (subscriptionType) {
            case 'starter':
              return prices['12']['starter'] == 0
                  ? 'loading..'
                  : prices['12']['starter'];
              break;
            case 'basic':
              return prices['12']['basic'] == 0
                  ? 'loading..'
                  : prices['12']['basic'];
              break;
            case 'silver':
              return prices['12']['silver'] == 0
                  ? 'loading..'
                  : prices['12']['silver'];
              break;
            case 'golden':
              return prices['12']['golden'] == 0
                  ? 'loading..'
                  : prices['12']['golden'];
              break;
            default:
              return 0;
          }
        }
      } else {
        if (duration == "0") {
          switch (subscriptionType) {
            case 'starter':
              return prices['1']['starter'] == 0
                  ? 'loading..'
                  : prices['1']['starter'];
              break;
            case 'basic':
              return prices['1']['basic'] == 0
                  ? 'loading..'
                  : prices['1']['basic'];
              break;
            case 'silver':
              return prices['1']['silver'] == 0
                  ? 'loading..'
                  : prices['1']['silver'];
              break;
            case 'golden':
              return prices['1']['golden'] == 0
                  ? 'loading..'
                  : prices['1']['golden'];
              break;
            default:
              return 0;
          }
        } else if (duration == "1") {
          switch (subscriptionType) {
            case 'starter':
              return newPrices['6']['starter'] == 0
                  ? 'loading..'
                  : newPrices['6']['starter'];
              break;
            case 'basic':
              return newPrices['6']['basic'] == 0
                  ? 'loading..'
                  : newPrices['6']['basic'];
              break;
            case 'silver':
              return newPrices['6']['silver'] == 0
                  ? 'loading..'
                  : newPrices['6']['silver'];
              break;
            case 'golden':
              return newPrices['6']['golden'] == 0
                  ? 'loading..'
                  : prices['6']['golden'];
              break;
            default:
              return 0;
          }
        } else if (duration == "2") {
          switch (subscriptionType) {
            case 'starter':
              return newPrices['12']['starter'] == 0
                  ? 'loading..'
                  : newPrices['12']['starter'];
              break;
            case 'basic':
              return newPrices['12']['basic'] == 0
                  ? 'loading..'
                  : newPrices['12']['basic'];
              break;
            case 'silver':
              return newPrices['12']['silver'] == 0
                  ? 'loading..'
                  : newPrices['12']['silver'];
              break;
            case 'golden':
              return newPrices['12']['golden'] == 0
                  ? 'loading..'
                  : newPrices['12']['golden'];
              break;
            default:
              return 0;
          }
        }
      }
    }

    // Add these helper methods to your _SubscribePageState class:
    String _formatDateFromTimestamp(dynamic timestamp) {
      DateTime date;
      if (timestamp is Map) {
        // If it's coming from Cloud Functions, it will be a Map with _seconds
        date =
            DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
      } else {
        // Fallback to current date if timestamp is invalid
        date = DateTime.now();
      }
      return '${date.year}/${date.month}/${date.day}';
    }

    String _getEndDateFromTimestamp(dynamic timestamp, int duration) {
      DateTime startDate;
      if (timestamp is Map) {
        startDate =
            DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
      } else {
        startDate = DateTime.now();
      }

      DateTime endDate;
      switch (duration) {
        case 0:
          endDate = startDate.add(Duration(days: 30));
          break;
        case 1:
          endDate = startDate.add(Duration(days: 180));
          break;
        case 2:
          endDate = startDate.add(Duration(days: 365));
          break;
        default:
          endDate = startDate;
      }
      return '${endDate.year}/${endDate.month}/${endDate.day}';
    }

    List<Widget> testcard = [
      Transform.scale(
        scale: 0.9,
        child: GestureDetector(
          onTap: () {
            setState(() {
              print("it's working");
              _selectedSybscriptionType = 'starter';
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5, left: 0, right: 0),
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: _selectedSybscriptionType != 'starter'
                  ? Border.all(color: Color(0xFF141414).withOpacity(0.12))
                  : Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withAlpha(200),
                      width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 3,
                  offset: Offset(2, 3),
                )
              ],
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "STARTER",
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                      color: AppTheme.lightTheme.colorScheme.primary),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "إعلاناتي",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "10",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 19,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "تجديد الإعلانات",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "05",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "بروفايل الوكالة",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.tick_circle5,
                        color: Colors.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "الدردشة في التطبيق",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.close_circle5,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "توثيق الحساب",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.close_circle5,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "إشهارات داخل التطبيق",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.close_circle5,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(
                    color: Color(0xFF313131).withOpacity(0.1),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "السعر " +
                      priceGetter(_selectedPeriod.toString(), 'starter')
                          .toString() +
                      " دج",
                  // "${newPrices["starter"] == Null ? prices["starter"] : newPrices["starter"]} السعر دج",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF313131).withAlpha(250),
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Transform.scale(
        scale: 0.9,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedSybscriptionType = 'basic';
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5, left: 0, right: 0),
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: _selectedSybscriptionType != 'basic'
                  ? Border.all(color: Color(0xFF141414).withOpacity(0.12))
                  : Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withAlpha(200),
                      width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 3,
                  offset: Offset(2, 3),
                )
              ],
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "BASIC",
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                      color: AppTheme.lightTheme.colorScheme.primary),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "إعلاناتي",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "20",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "تجديد الإعلانات",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "10",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "بروفايل الوكالة",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.tick_circle5,
                        color: Colors.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "الدردشة في التطبيق",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.tick_circle5,
                        color: Colors.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "توثيق الحساب",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.close_circle5,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "إشهارات داخل التطبيق",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.close_circle5,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(
                    color: Color(0xFF313131).withOpacity(0.1),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "السعر " +
                      priceGetter(_selectedPeriod.toString(), 'basic')
                          .toString() +
                      " دج",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF313131).withAlpha(250),
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Transform.scale(
        scale: 0.9,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedSybscriptionType = 'silver';
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5, left: 0, right: 0),
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: _selectedSybscriptionType != 'silver'
                  ? Border.all(color: Color(0xFF141414).withOpacity(0.12))
                  : Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withAlpha(200),
                      width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 3,
                  offset: Offset(2, 3),
                )
              ],
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "SILVER",
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                      color: AppTheme.lightTheme.colorScheme.primary),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "إعلاناتي",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "10",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "تجديد الإعلانات",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "05",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "بروفايل الوكالة",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.tick_circle5,
                        color: Colors.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "الدردشة في التطبيق",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.close_circle5,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "توثيق الحساب",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.close_circle5,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "إشهارات داخل التطبيق",
                        style: TextStyle(
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Iconsax.close_circle5,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(
                    color: Color(0xFF313131).withOpacity(0.1),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "السعر " +
                      priceGetter(_selectedPeriod.toString(), 'silver')
                          .toString() +
                      " دج",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF313131).withAlpha(250),
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Transform.scale(
        scale: 0.9,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedSybscriptionType = 'golden';
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5, left: 0, right: 0),
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: _selectedSybscriptionType != 'golden'
                  ? Border.all(color: Colors.yellow.withOpacity(0.12))
                  : Border.all(color: Colors.yellow.withOpacity(0.8), width: 3),
              boxShadow: [
                BoxShadow(
                  color: _selectedSybscriptionType != 'golden'
                      ? Colors.yellow.shade800.withOpacity(0.3)
                      : Colors.transparent,
                  blurRadius: 1,
                  offset: Offset(2, 3),
                )
              ],
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Container(
                  width: 600,
                  height: 700,
                  // color: Colors.red,
                  child: Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.yellowAccent.withOpacity(0.1),
                    child: Container(
                      // width: 20,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "GOLDEN",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          color: Colors.yellow.shade600),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "إعلاناتي",
                            style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF313131).withAlpha(200),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "10",
                            style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w900,
                              color: Colors.yellow.shade500,
                              fontSize: 19,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "تجديد الإعلانات",
                            style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF313131).withAlpha(200),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "05",
                            style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w900,
                              color: Colors.yellow.shade500,
                              fontSize: 19,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "بروفايل الوكالة",
                            style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF313131).withAlpha(200),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Iconsax.tick_circle5,
                            color: Colors.green,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "الدردشة في التطبيق",
                            style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF313131).withAlpha(200),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Iconsax.tick_circle5,
                            color: Colors.green,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "توثيق الحساب",
                            style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF313131).withAlpha(200),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Iconsax.tick_circle5,
                            color: Colors.green,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "لا إشهارات داخل التطبيق",
                            style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF313131).withAlpha(200),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Iconsax.tick_circle5,
                            color: Colors.green,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        color: Color(0xFF313131).withOpacity(0.1),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "السعر " +
                          priceGetter(_selectedPeriod.toString(), 'golden')
                              .toString() +
                          " دج",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.yellow,
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: Color(0xFF313131).withOpacity(0.1),
                height: 1,
              )),
          centerTitle: true,
          title: Text(
            'الإشتراكات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          leading: IconButton(
            padding: const EdgeInsets.only(left: 12),
            splashRadius: 24,
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 22,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            // fit: FlexFit.loose,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20),
                  child: Row(children: [
                    Text(
                      "إختيار المدة الزمنية:",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontSize: 17,
                          color: Color(0xFF313131)),
                    )
                  ]),
                ),

                AnimatedButtonBar(
                  elevation: 0.0,
                  radius: 8.0,
                  padding: const EdgeInsets.only(
                      top: 5.0, bottom: 0, left: 16, right: 16),
                  invertedSelection: false,
                  backgroundColor: Color(0xFFFAFAFA),
                  foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                  children: [
                    ButtonBarEntry(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = 2;
                            //  _loadPrices();
                          });
                        },
                        child: Text(
                          'سنة',
                          // textDirection: TextDirection.rtl,
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
                            _selectedPeriod = 1;
                            //  _loadPrices();
                          });
                        },
                        child: Text(
                          '6 أشهر',
                          // textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                          ),
                        )),
                    ButtonBarEntry(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = 0;
                            //  _loadPrices();
                          });
                        },
                        child: Text(
                          'شهر',
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.w600,
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                          ),
                        )),
                  ],
                ),
                CarouselSlider(
                  items: testcard,
                  options: CarouselOptions(
                      // enlargeFactor: 1.2,
                      height: 350.0,
                      viewportFraction: 0.7,
                      pageSnapping: false,
                      padEnds: false,
                      enableInfiniteScroll: false,
                      disableCenter: true,
                      initialPage: 0
                      // reverse: true,
                      // enlargeCenterPage: true,
                      // padEnds: false,
                      // enableInfiniteScroll: false
                      ),
                ),
                const SizedBox(height: 0),
                paymentVerificationChecked == true
                    ? paymentVerificationObject == null
                        ? !couponApplied
                            ? Column(
                                children: [
                                  Card(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    elevation: 0.1,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: Color(0xFF141414)
                                              .withOpacity(0.12),
                                          width: 0.4),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          // Header text
                                          Text(
                                            'أدخل رمز التخفيض',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black87,
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 15),

                                          // Discount code text field
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: TextField(
                                              controller:
                                                  _discountCodeController,
                                              enableSuggestions: false,
                                              textAlign: TextAlign.center,
                                              decoration: const InputDecoration(
                                                hintText: '...',
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 15),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),

                                          // Apply button
                                          SizedBox(
                                            width: 200,
                                            child: OutlinedButton(
                                              onPressed: _applyCoupon,
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: Colors.blue),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                              ),
                                              child: Text(
                                                'تطبيق',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: AppTheme
                                                      .lightTheme
                                                      .textTheme
                                                      .bodyMedium!
                                                      .fontFamily,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Card(
                                    elevation: 0.2,
                                    color: Colors.white,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color:
                                            Color(0xFF141414).withOpacity(0.12),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 20),
                                      child: Center(
                                        child: Text(
                                          'شهر مجاني ابتداءً من 6 أشهر',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTheme
                                                .lightTheme
                                                .textTheme
                                                .bodyMedium!
                                                .fontFamily,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Second option card

                                  Card(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    color: Colors.white,
                                    elevation: 0.1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color:
                                            Color(0xFF141414).withOpacity(0.12),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 20),
                                      child: Center(
                                        child: Text(
                                          '3 أشهر مجانية ابتداءً من 12 شهر',
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTheme
                                                .lightTheme
                                                .textTheme
                                                .bodyMedium!
                                                .fontFamily,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // Bottom navigation buttons
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Row(
                                      children: [
                                        // Back button
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              // Handle back navigation
                                              Navigator.pop(context);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                  color: Colors.grey.shade400),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding: const EdgeInsets.only(
                                                  top: 17, bottom: 15),
                                            ),
                                            child: Text(
                                              'العودة',
                                              style: TextStyle(
                                                color: Color(0xFF313131)
                                                    .withAlpha(200),
                                                height: 1,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: AppTheme
                                                    .lightTheme
                                                    .textTheme
                                                    .bodyMedium!
                                                    .fontFamily,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        // Continue button
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final user =
                                                  Provider.of<AuthService>(
                                                          context,
                                                          listen: false)
                                                      .currentUser;

                                              if (user == null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "User not found",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily: AppTheme
                                                            .lightTheme
                                                            .textTheme
                                                            .bodyMedium!
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    duration:
                                                        Duration(seconds: 1),
                                                  ),
                                                );
                                                return;
                                              }

                                              final doc = await FirebaseFirestore
                                                  .instance
                                                  .collection(
                                                      'payment_verification')
                                                  .doc(user.uid)
                                                  .get();

                                              if (doc.exists) {
                                                final status = doc['status'];
                                                if (status == 'approved') {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "You already have a subscription in process",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: AppTheme
                                                              .lightTheme
                                                              .textTheme
                                                              .bodyMedium!
                                                              .fontFamily,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  );
                                                } else if (status ==
                                                    'pending') {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Your payment verification is still under process",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: AppTheme
                                                              .lightTheme
                                                              .textTheme
                                                              .bodyMedium!
                                                              .fontFamily,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                if (_selectedSybscriptionType !=
                                                        null &&
                                                    prices['1']['golden'] !=
                                                        0) {
                                                  if (couponApplied == true) {
                                                    Navigator.pushNamed(context,
                                                        '/subscription_guide',
                                                        arguments: {
                                                          'selectedPeriod':
                                                              _selectedPeriod,
                                                          'selectedSubscriptionType':
                                                              _selectedSybscriptionType,
                                                          'price': priceGetter(
                                                              _selectedPeriod
                                                                  .toString(),
                                                              _selectedSybscriptionType
                                                                  .toString()),
                                                          'couponId':
                                                              usedCouponId,
                                                        });
                                                  } else {
                                                    Navigator.pushNamed(context,
                                                        '/subscription_guide',
                                                        arguments: {
                                                          'selectedPeriod':
                                                              _selectedPeriod,
                                                          'selectedSubscriptionType':
                                                              _selectedSybscriptionType,
                                                          'price': priceGetter(
                                                              _selectedPeriod
                                                                  .toString(),
                                                              _selectedSybscriptionType
                                                                  .toString())
                                                        });
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Choose a subscription type first",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: AppTheme
                                                              .lightTheme
                                                              .textTheme
                                                              .bodyMedium!
                                                              .fontFamily,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding: const EdgeInsets.only(
                                                  top: 17, bottom: 15),
                                            ),
                                            child: Text(
                                              'واصل',
                                              style: TextStyle(
                                                color: Colors.white,
                                                height: 1,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: AppTheme
                                                    .lightTheme
                                                    .textTheme
                                                    .bodyMedium!
                                                    .fontFamily,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              )
                            : Container(
                                // elevation: 0,
                                // color: Colors.green,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(8),
                                //   side: BorderSide(
                                //     color: Color(0xFF141414).withOpacity(0.12),
                                //     width: 0.5,
                                //   ),
                                // ),

                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 0),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.green,
                                            highlightColor: Colors.lightGreen,
                                            child: Container(
                                              // width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 22.0),
                                            child: Text(
                                              'تم تفعيل الكوبون بنجاح',
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: AppTheme
                                                    .lightTheme
                                                    .textTheme
                                                    .bodyMedium!
                                                    .fontFamily,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              setState(() {
                                                couponApplied = false;
                                                usedCouponId = '';
                                              });
                                            },
                                            child: Icon(
                                              Iconsax.close_circle5,
                                              color: Colors.white,
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              )
                        : paymentVerificationStatus == 'pending' ||
                                paymentVerificationStatus == 'approved'
                            ? paymentVerificationStatus == 'pending'
                                ? Container(
                                    margin: EdgeInsets.all(20),
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Colors.blue.shade300
                                              .withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 150,
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.white,
                                              highlightColor: Colors
                                                  .blue.shade50
                                                  .withOpacity(0.1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "قيد المراجعة",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontFamily: AppTheme
                                                            .lightTheme
                                                            .textTheme
                                                            .bodyMedium!
                                                            .fontFamily,
                                                        color: Colors
                                                            .blue.shade400,
                                                      ),
                                                    ),
                                                    SpinKitPouringHourGlass(
                                                      color:
                                                          Colors.blue.shade300,
                                                      size: 30.0,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),
                                                Text(
                                                  "طلب التحقق من الدفع الخاص بك قيد المراجعة",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: AppTheme
                                                        .lightTheme
                                                        .textTheme
                                                        .bodyMedium!
                                                        .fontFamily,
                                                    color: Color(0xFF313131)
                                                        .withOpacity(0.7),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 0),
                                                // Row(
                                                //   mainAxisAlignment:
                                                //       MainAxisAlignment.center,
                                                //   children: [
                                                //     SpinKitThreeBounce(
                                                //       color:
                                                //           Colors.blue.shade300,
                                                //       size: 20.0,
                                                //     ),
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : // Replace the Text('approved') with:
                                Container(
                                    margin: EdgeInsets.all(20),
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Colors.yellow.shade600
                                              .withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height:
                                                300, // Increased height to accommodate new rows
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.white,
                                              highlightColor: Colors
                                                  .yellow.shade100
                                                  .withOpacity(0.1),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0, right: 20, left: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "الإشتراك الحالي",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontFamily: AppTheme
                                                            .lightTheme
                                                            .textTheme
                                                            .bodyMedium!
                                                            .fontFamily,
                                                        color: Colors
                                                            .yellow.shade700,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Iconsax.crown5,
                                                      color: Colors
                                                          .yellow.shade700,
                                                      size: 28,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),
                                                _buildSubscriptionDetailRow(
                                                  "نوع الإشتراك",
                                                  paymentVerificationObject[
                                                          'subscriptionType']
                                                      .toString()
                                                      .toUpperCase(),
                                                  Iconsax.wallet_check,
                                                ),
                                                SizedBox(height: 15),
                                                _buildSubscriptionDetailRow(
                                                  "المدة",
                                                  _getDurationText(
                                                      paymentVerificationObject[
                                                              'duration']
                                                          .toString()),
                                                  Iconsax.timer_1,
                                                ),
                                                SizedBox(height: 15),
                                                _buildSubscriptionDetailRow(
                                                  "السعر",
                                                  "${paymentVerificationObject['price']} دج",
                                                  Iconsax.money,
                                                ),
                                                SizedBox(height: 15),
                                                _buildSubscriptionDetailRow(
                                                  "تاريخ البداية",
                                                  _formatDateFromTimestamp(
                                                      paymentVerificationObject[
                                                          'submittingDate']),
                                                  Iconsax.calendar_1,
                                                ),
                                                SizedBox(height: 15),
                                                _buildSubscriptionDetailRow(
                                                  "تاريخ الإنتهاء",
                                                  _getEndDateFromTimestamp(
                                                      paymentVerificationObject[
                                                          'submittingDate'],
                                                      int.parse(
                                                          paymentVerificationObject[
                                                                  'duration']
                                                              .toString())),
                                                  Iconsax.calendar_1,
                                                ),
                                                SizedBox(height: 15),
                                                _buildSubscriptionDetailRow(
                                                  "الحالة",
                                                  "مفعل",
                                                  Icons
                                                      .check_circle_outline_rounded,
                                                  valueColor: Colors.green,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                            : Container(
                                margin: EdgeInsets.all(20),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color:
                                          Colors.red.shade300.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 200,
                                        child: Shimmer.fromColors(
                                          baseColor: Colors.white,
                                          highlightColor: Colors.red.shade50
                                              .withOpacity(0.1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "تم رفض الطلب",
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w900,
                                                    fontFamily: AppTheme
                                                        .lightTheme
                                                        .textTheme
                                                        .bodyMedium!
                                                        .fontFamily,
                                                    color: Colors.red.shade400,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.cancel_outlined,
                                                  color: Colors.red.shade400,
                                                  size: 28,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                paymentVerificationObject[
                                                        'adminFeedback'] ??
                                                    "لم يتم تقديم سبب الرفض",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: AppTheme
                                                      .lightTheme
                                                      .textTheme
                                                      .bodyMedium!
                                                      .fontFamily,
                                                  color: Colors.red.shade700,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    final user = Provider.of<
                                                                AuthService>(
                                                            context,
                                                            listen: false)
                                                        .currentUser;
                                                    if (user != null) {
                                                      // Delete document from Firestore
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'payment_verification')
                                                          .doc(user.uid)
                                                          .delete();

                                                      // Reset local state
                                                      setState(() {
                                                        paymentVerificationObject =
                                                            null;
                                                        paymentVerificationStatus =
                                                            null;
                                                      });

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'تم إلغاء طلب التحقق بنجاح',
                                                            style: TextStyle(
                                                              fontFamily: AppTheme
                                                                  .lightTheme
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .fontFamily,
                                                            ),
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    print(
                                                        'Error canceling verification: $e');
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'حدث خطأ أثناء إلغاء الطلب',
                                                          style: TextStyle(
                                                            fontFamily: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .fontFamily,
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade400,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text(
                                                  'إلغاء وإعادة المحاولة',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: AppTheme
                                                        .lightTheme
                                                        .textTheme
                                                        .bodyMedium!
                                                        .fontFamily,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                    : SpinKitWave(
                        color: AppTheme.lightTheme.primaryColor,
                        size: 30.0,
                      ),

                //      const Spacer(),
              ],
            ),
          ),
        ));
  }
}

Widget _buildSubscriptionDetailRow(String label, String value, IconData icon,
    {Color? valueColor}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Color(0xFF313131).withOpacity(0.7),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              color: Color(0xFF313131).withOpacity(0.7),
            ),
          ),
        ],
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          color: valueColor ?? Color(0xFF313131),
        ),
      ),
    ],
  );
}

String _getDurationText(String duration) {
  switch (duration) {
    case '1':
      return 'شهر';
    case '6':
      return '6 أشهر';
    case '12':
      return 'سنة';
    default:
      return duration;
  }
}
