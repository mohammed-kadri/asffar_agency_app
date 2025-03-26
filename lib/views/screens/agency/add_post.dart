import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:untitled3/models/trip_model.dart';
import 'package:untitled3/models/service_model.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/providers/content_provider.dart';
import 'package:untitled3/services/auth_service.dart';

import '../../../theme/app_theme.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool isTrip = true;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _departDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _hotelNameController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _availablePlacesController =
      TextEditingController();
  final TextEditingController _serviceTextFieldController =
      TextEditingController();
  List<String> _texts = [];
  List<File> _images = [];
  File? _mainImage;
  String? _destinations;
  String? _familiale;
  String? _serviceDropdown1;
  String? _serviceDropdown2;
  String? _serviceDropdown3;

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickMainImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mainImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickSecondaryImages() async {
    const int maxImages = 5;
    final remainingImages = maxImages - _images.length;

    if (_images.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can only upload a maximum of $maxImages images.',
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      if (pickedFiles.length > remainingImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only select up to $remainingImages more images.',
              style: TextStyle(
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<void> _submitTrip() async {
    if (_mainImage == null) {
      // Show error message if main image is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('pleaseSelectMainImage'),
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postId = contentProvider.generateId();

    // Upload main image
    final mainImageUrl =
        await contentProvider.uploadImage(postId, _mainImage!, isMain: true);

    // Upload secondary images
    final secondaryImageUrls = await Future.wait(
        _images.map((image) => contentProvider.uploadImage(postId, image)));

    final trip = Trip(
      id: postId,
      agencyId: authProvider.user?.id ?? '', // Replace with actual agency ID
      destination: _destinationController.text,
      period: _periodController.text,
      price: int.parse(_priceController.text.trim()),
      departDate: DateFormat('yyyy-MM-dd').parse(_departDateController.text),
      returnDate: DateFormat('yyyy-MM-dd').parse(_returnDateController.text),
      family: _familiale == 'Yes',
      availablePlaces: _availablePlacesController.text,
      hotelName: _hotelNameController.text,
      places: _texts,
      description: _descriptionController.text,
      postedDate: DateTime.now(),
      mainImageUrl: mainImageUrl,
      secondaryImageUrls: secondaryImageUrls,
    );

    await contentProvider.addTrip(trip);
  }

  Future<void> _submitService() async {
    if (_mainImage == null) {
      // Show error message if main image is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('pleaseSelectMainImage'),
            style: TextStyle(
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final postId = contentProvider.generateId();

    // Upload main image
    final mainImageUrl =
        await contentProvider.uploadImage(postId, _mainImage!, isMain: true);

    // Upload secondary images
    final secondaryImageUrls = await Future.wait(
        _images.map((image) => contentProvider.uploadImage(postId, image)));

    final service = Service(
      id: postId,
      agencyId:
          authService.currentUser?.uid ?? '', // Replace with actual agency ID
      type: _serviceDropdown1 ?? '',
      country: _serviceDropdown2 ?? '',
      price: int.parse(_priceController.text.trim()),
      postedDate: DateTime.now(),
      description: _descriptionController.text,
      numberOfPeople: _serviceDropdown1 == 'planeticket'
          ? int.parse(_serviceTextFieldController.text)
          : null,
      destination: _serviceDropdown1 == 'planeticket'
          ? _destinationController.text
          : null,
      date: _serviceDropdown1 == 'planeticket'
          ? DateFormat('yyyy-MM-dd').parse(_departDateController.text)
          : null,
      mainImageUrl: mainImageUrl,
      secondaryImageUrls: secondaryImageUrls,
    );

    await contentProvider.addService(service);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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
          'إضافة منشور',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        if(isTrip==false) {
                          _images=[];
                          _mainImage=null;
                        }
                        isTrip = true;
                      });
                    },
                    child: Container(
                      width: (screenWidth - 50 - 10) / 2,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: !isTrip
                              ? Color(0xFF313131).withOpacity(0.25)
                              : AppTheme.lightTheme.colorScheme.primary,
                          width: !isTrip ? 1 : 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.routing_2,
                            size: 75,
                            color: !isTrip
                                ? Color(0xFF313131).withOpacity(0.25)
                                : AppTheme.lightTheme.colorScheme.primary,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "رحلة",
                            style: TextStyle(
                                fontSize: 19,
                                color: !isTrip
                                    ? Color(0xFF313131).withOpacity(0.25)
                                    : AppTheme.lightTheme.colorScheme.primary,
                                fontWeight:
                                    !isTrip ? FontWeight.w600 : FontWeight.w900,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        if(isTrip==true) {
                          _images=[];
                          _mainImage=null;
                        }
                        isTrip = false;
                      });
                    },
                    child: Container(
                      width: (screenWidth - 50 - 10) / 2,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isTrip
                              ? Color(0xFF313131).withOpacity(0.25)
                              : AppTheme.lightTheme.colorScheme.primary,
                          width: isTrip ? 1 : 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.briefcase,
                            size: 70,
                            color: isTrip
                                ? Color(0xFF313131).withOpacity(0.25)
                                : AppTheme.lightTheme.colorScheme.primary,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "خدمة",
                            style: TextStyle(
                                fontSize: 19,
                                color: isTrip
                                    ? Color(0xFF313131).withOpacity(0.25)
                                    : AppTheme.lightTheme.colorScheme.primary,
                                fontWeight:
                                    isTrip ? FontWeight.w600 : FontWeight.w900,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily),
                          )
                        ],
                      ),
                    ),
                  ),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     setState(() {
                  //       isTrip = true;
                  //     });
                  //   },
                  //   child: Text('Trip'),
                  // ),
                  // SizedBox(width: 10),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     setState(() {
                  //       isTrip = false;
                  //     });
                  //   },
                  //   child: Text('Service'),
                  // ),
                ],
              ),
              SizedBox(height: 10),
              if (isTrip) ...[
                // TextField(
                //   controller: _destinationController,
                //   decoration: InputDecoration(
                //       alignLabelWithHint:
                //           true, // Aligns with the hint text if multiline
                //       border: UnderlineInputBorder(
                //         borderSide:
                //             BorderSide(color: Color(0xFF313131).withAlpha(200)),
                //       ),
                //       labelStyle: TextStyle(),
                //       // labelText: 'Enter additional information',
                //       label: Align(
                //         alignment: Alignment.centerRight,
                //         child: Text(
                //           "أدخل معلومات إضافية إذا أردت",
                //           // textDirection: TextDirection.rtl,
                //           textAlign: TextAlign.right,
                //           style: TextStyle(
                //               fontSize: 17,
                //               fontFamily: AppTheme
                //                   .lightTheme.textTheme.bodyMedium!.fontFamily),
                //         ),
                //       )
                //   ),
                // ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _destinations,
                  onChanged: (value) {
                    setState(() {
                      _destinations = value;
                    });
                  },
                  items: ['ؤي', 'ربvي', 'ثس']
                      .map((destination) => DropdownMenuItem(
                            value: destination,
                            // alignment: AlignmentDirectional.centerEnd,
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  destination,
                                  // textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium!.fontFamily,
                                      color: Color(0xFF313131).withAlpha(100),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    suffixIcon: Icon(Iconsax.arrow_down5),

                    // labelText: 'الوجهة',
                    label: Text(
                      "الوجهة",
                      // textDirection: TextDirection.rtl,
                      // textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF313131).withAlpha(100),
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily),
                    ),

                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF313131).withAlpha(200)),
                    ),
                  ),
                  icon: SizedBox.shrink(), // icon: Icon(Iconsax.location),
                  // alignment: Alignment.centerLeft,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // prefixIcon: Icon(Iconsax.arrow_down5),
                          // labelText: 'الوجهة',
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "السعر (بالدينار)",
                              // textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF313131).withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        // controller: _priceController,
                        decoration: InputDecoration(
                          // prefixIcon: Icon(Iconsax.arrow_down5),
                          // labelText: 'الوجهة',
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "المدة (باليوم)",
                              // textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF313131).withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _returnDateController,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Iconsax.calendar,
                            color: Color(0xFF313131).withOpacity(0.3),
                          ),
                          // labelText: 'الوجهة',
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "تاريخ الإنطلاق",
                              // textDirection: TextDirection.rtl,
                              // textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF313131).withOpacity(0.1),
                            ),
                          ),
                        ),
                        onTap: () => _pickDate(_departDateController),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _departDateController,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Iconsax.calendar,
                            color: Color(0xFF313131).withOpacity(0.3),
                          ),
                          // labelText: 'الوجهة',
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "تاريخ العودة",
                              // textDirection: TextDirection.rtl,
                              // textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF313131).withOpacity(0.1),
                            ),
                          ),
                        ),
                        onTap: () => _pickDate(_returnDateController),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        icon: SizedBox(),
                        value: _familiale,
                        onChanged: (value) {
                          setState(() {
                            _familiale = value;
                          });
                        },
                        items: ['نعم', 'لا']
                            .map((familiale) => DropdownMenuItem(
                                  value: familiale,
                                  child: Text(
                                    familiale,
                                    style: TextStyle(
                                        fontFamily: AppTheme.lightTheme
                                            .textTheme.bodyMedium!.fontFamily,
                                        color: Color(0xFF313131).withAlpha(100),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17),
                                  ),
                                ))
                            .toList(),
                        decoration: InputDecoration(
                          suffixIcon: Icon(Iconsax.arrow_down5),
                          label: Text(
                            "عائلي",
                            style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFF313131).withAlpha(100),
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF313131).withAlpha(200)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _availablePlacesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "عدد الأماكن (إختباري)",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF313131).withAlpha(200)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _hotelNameController,
                  decoration: InputDecoration(
                    label: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "اسم الفندق (إختباري)",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF313131).withAlpha(100),
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily),
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF313131).withAlpha(200)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "أماكن الزيارة",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF313131).withAlpha(200)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          setState(() {
                            _texts.add(_textController.text);
                            _textController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Column(
                  children: _texts
                      .map((text) => Row(
                            children: [
                              Expanded(child: Text(text)),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    _texts.remove(text);
                                  });
                                },
                              ),
                            ],
                          ))
                      .toList(),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    label: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الوصف",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF313131).withAlpha(100),
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily),
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF313131).withAlpha(200)),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    // ElevatedButton(
                    //   onPressed: _pickMainImage,
                    //   child: Text('Add Main Image'),
                    // ),
                    // if (_mainImage != null)
                    //   Image.file(_mainImage!, width: 100, height: 100),
                    // SizedBox(height: 10),
                    // ElevatedButton(
                    //   onPressed: _pickSecondaryImages,
                    //   child: Text('Add Secondary Images'),
                    // ),
                    InkWell(
                        onTap: _pickMainImage,
                        child: Container(
                          width: (screenWidth * 0.55) - 25,
                          height: 45,
                          // color: Colors.white,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme!.primary,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                "الصورة الرئيسية",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  // height: 2,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                  color:
                                      AppTheme.lightTheme.colorScheme!.primary,
                                  backgroundColor: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: _pickSecondaryImages,
                        child: Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                "الصور الإضافية",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  // height: 2,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                  color: Color(0xFF313131).withOpacity(0.5),
                                  backgroundColor: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          width: (screenWidth * 0.45) - 25,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: Color(0xFF313131).withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(height: 15),
                if (_mainImage != null) ...[
                  Column(
                    children: [
                      Text(
                        "الصورة الرئيسية",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF313131).withAlpha(200),
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_mainImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _mainImage = null;
                          });
                        },
                        child: Text(
                          'حذف',
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
                _images.length != 0
                    ? Column(
                      children: [
                        Text(
                            "الصور الإضافية",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF313131).withAlpha(200),
                              fontWeight: FontWeight.w700,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                            ),
                          ),
                        SizedBox(height: 5,)
                      ],
                    )
                    : SizedBox.shrink(),
                Wrap(
                  children: _images
                      .map((image) => Column(
                            children: [
                              Image.file(image, width: 100, height: 100),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _images.remove(image);
                                    });
                                  },
                                  child: Text(
                                    'حذف',
                                    style: TextStyle(
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium!.fontFamily,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                            ],
                          ))
                      .toList(),
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  icon: SizedBox(),
                  value: _serviceDropdown1,
                  onChanged: (value) {
                    setState(() {
                      _serviceDropdown1 = value;
                    });
                  },
                  items: ['visa rdv', 'visa', 'planeticket']
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(
                              option,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17),
                            ),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.arrow_down5),
                    icon: SizedBox(),
                    // labelText: 'الوجهة',
                    label: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "نوع الخدمة",
                        // textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF313131).withAlpha(100),
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily),
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF313131).withAlpha(200)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  icon: SizedBox(),
                  value: _serviceDropdown2,
                  onChanged: (value) {
                    setState(() {
                      _serviceDropdown2 = value;
                    });
                  },
                  items: ['Country 1', 'Country 2', 'Country 3']
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(
                              option,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17),
                            ),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.arrow_down5),
                    icon: SizedBox(),
                    // labelText: 'الوجهة',
                    label: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "البلد",
                        // textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF313131).withAlpha(100),
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily),
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF313131).withAlpha(200)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // prefixIcon: Icon(Iconsax.arrow_down5),
                          // labelText: 'الوجهة',
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "السعر (بالدينار)",
                              // textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF313131).withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _serviceDropdown3,
                        icon: SizedBox(),
                        onChanged: (value) {
                          setState(() {
                            _serviceDropdown3 = value;
                          });
                        },
                        items: ['Option 1', 'Option 2', 'Option 3']
                            .map((option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                    option,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontFamily: AppTheme.lightTheme
                                            .textTheme.bodyMedium!.fontFamily,
                                        color: Color(0xFF313131).withAlpha(100),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17),
                                  ),
                                ))
                            .toList(),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Iconsax.arrow_down5),
                          icon: SizedBox(),
                          // labelText: 'الوجهة',
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "النوع",
                              // textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily),
                            ),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF313131).withAlpha(200)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    label: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الوصف",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF313131).withAlpha(100),
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily),
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF313131).withAlpha(200)),
                    ),
                  ),
                  maxLines: 3,
                ),
                // ElevatedButton(
                //   onPressed: _pickMainImage,
                //   child: Text('Add Main Image'),
                // ),
                // if (_mainImage != null)
                //   Image.file(_mainImage!, width: 100, height: 100),
                // SizedBox(height: 10),
                // ElevatedButton(
                //   onPressed: _pickSecondaryImages,
                //   child: Text('Add Secondary Images'),
                // ),
                SizedBox(height: 15),
                Row(
                  children: [
                    // ElevatedButton(
                    //   onPressed: _pickMainImage,
                    //   child: Text('Add Main Image'),
                    // ),
                    // if (_mainImage != null)
                    //   Image.file(_mainImage!, width: 100, height: 100),
                    // SizedBox(height: 10),
                    // ElevatedButton(
                    //   onPressed: _pickSecondaryImages,
                    //   child: Text('Add Secondary Images'),
                    // ),


                    InkWell(
                        onTap: _pickMainImage,
                        child: Container(
                          width: (screenWidth * 0.55) - 25,
                          height: 45,
                          // color: Colors.white,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme!.primary,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                "الصورة الرئيسية",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  // height: 2,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                  color:
                                      AppTheme.lightTheme.colorScheme!.primary,
                                  backgroundColor: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: _pickSecondaryImages,
                        child: Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                "الصور الإضافية",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  // height: 2,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                  color: Color(0xFF313131).withOpacity(0.5),
                                  backgroundColor: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          width: (screenWidth * 0.45) - 25,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: Color(0xFF313131).withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(height: 15),
                if (_mainImage != null) ...[
                  Text(
                    "الصورة الرئيسية",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF313131).withAlpha(200),
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme
                          .lightTheme.textTheme.bodyMedium!.fontFamily,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_mainImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _mainImage = null;
                          });
                        },
                        child: Text(
                          'حذف',
                          style: TextStyle(
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],

                _images.length != 0
                    ? Column(
                  children: [
                    Text(
                      "الصور الإضافية",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF313131).withAlpha(200),
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                      ),
                    ),
                    SizedBox(height: 5,)
                  ],
                )
                    : SizedBox.shrink(),

                Wrap(
                  children: _images
                      .map((image) => Column(
                            children: [
                              Image.file(image, width: 100, height: 100),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _images.remove(image);
                                    });
                                  },
                                  child: Text(
                                    'حذف',
                                    style: TextStyle(
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium!.fontFamily,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                            ],
                          ))
                      .toList(),
                ),
              ],
              SizedBox(height: 20),
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        if (isTrip) {
                          _submitTrip();
                        } else {
                          _submitService();
                        }
                      },
                      child: Container(
                        width: screenWidth - 40,
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme!.primary,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "نشر",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                // height: 2,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
