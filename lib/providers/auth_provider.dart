import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/models/user_model.dart';
import 'package:untitled3/theme/app_theme.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> login(String email, String password, String expectedUserType,
      BuildContext context) async {
    User? firebaseUser =
        await _authService.login(email, password, expectedUserType, context);
    if (firebaseUser != null) {
      DocumentSnapshot userDoc =
          await _authService.getUserData(firebaseUser.uid, expectedUserType);
      _user =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', expectedUserType);
    }
    notifyListeners();
  }

  Future<void> register(
      String email,
      String ownerName,
      String agencyName,
      String phone,
      String password,
      String userType,
      BuildContext context) async {
    User? firebaseUser = await _authService.register(
        email, ownerName, agencyName, phone, password, userType, context);
    if (firebaseUser != null) {
      _user = UserModel(
        id: firebaseUser.uid,
        email: email,
        phone: phone,
        userType: userType,
        emailVerified: false,
        phoneVerified: false,
        documentsAccepted: false,
        submittedDocuments: false,
        accountVerified: false,
        profilePictureUrl: '',
        agencyName: agencyName,
        ownerName: ownerName,
        travelerFirstName: '',
        travelerLastName: '',
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', userType);
    }
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await _authService.signOut(context);
    _user = null;
    notifyListeners();
  }

  Future<void> verifyEmail(BuildContext context) async {
    await _authService.verifyEmail(context);
    notifyListeners();
  }

  Future<void> checkEmailVerification(BuildContext context) async {
    // Call AuthService and wait for the result
    bool isEmailVerified = await _authService.checkEmailVerification(context);

    // Update the user data only if the email was verified
    if (isEmailVerified && _user != null) {
      _user = _user!.copyWith(emailVerified: true);
      print('Email verified: ${_user!.emailVerified}');
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_user != null) {
      await _authService.updateUserData(_user!.id, data);
      _user = _user!.copyWithFromMap(data);
      notifyListeners();
    }
  }

  Future<void> checkAuthState() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc = await _authService.getUserData(
          firebaseUser.uid, 'Agency'); // Adjust userType as needed
      _user =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
    }
    notifyListeners();
  }

  Future<String?> pickImage() async {
    return await _authService.pickImage();
  }

  Future<String> uploadImage(String filePath, String userId, String fileName,
      String folderName) async {
    return await _authService.uploadImage(
        filePath, userId, fileName, folderName);
  }

  Future<void> submitDocuments(String userId, List<String> imageUrls,
      String documentsVerificationNote) async {
    await _authService.submitDocuments(
        userId, imageUrls, documentsVerificationNote);
    if (_user != null) {
      _user = _user!.copyWith(submittedDocuments: true);
      await updateUserData({'submittedDocuments': true});
      notifyListeners();
    }
  }

  Future<void> uploadProfilePicture(BuildContext context) async {
    String? imagePath = await pickAndCropImage();
    if (imagePath != null && _user != null) {
      String imageUrl = await uploadImage(imagePath, _user!.id,
          'profile_picture.jpg', 'agencies_profile_pictures');
      await updateUserData({'profilePictureUrl': imageUrl});
      _user = _user!.copyWith(profilePictureUrl: imageUrl);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'تم تحديث الصورة الشخصية بنجاح',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<String?> pickAndCropImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            activeControlsWidgetColor: AppTheme.lightTheme.colorScheme.primary,
            toolbarTitle: 'Cropper',
            toolbarColor: AppTheme.lightTheme.colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );
      return croppedFile?.path;
    }
    return null;
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Add this line

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> updateUserField(String key, dynamic value) async {
    if (_user != null) {
      _user = _user!.copyWithFromMap({key: value});
      notifyListeners();
    }
  }
}
