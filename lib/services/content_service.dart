import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:untitled3/models/trip_model.dart';
import 'package:untitled3/models/service_model.dart';
import 'dart:io';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).set(trip.toMap());
    print("**************************************************************************");
    print(trip.toMap().toString());
    print("**************************************************************************");
  }

  Future<void> addService(Service service) async {
    await _firestore.collection('services').doc(service.id).set(service.toMap());
  }

  Future<String> uploadImage(String postId, File image, {bool isMain = false}) async {
    String fileName = isMain ? 'main.jpg' : Uuid().v4();
    Reference ref = _storage.ref().child('posts/$postId/$fileName');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  String generateId() {
    return Uuid().v4();
  }
}