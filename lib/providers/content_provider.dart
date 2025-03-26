import 'package:flutter/material.dart';
import 'package:untitled3/models/trip_model.dart';
import 'package:untitled3/models/service_model.dart';
import 'package:untitled3/services/content_service.dart';
import 'dart:io';

class ContentProvider with ChangeNotifier {
  final ContentService _contentService = ContentService();

  Future<void> addTrip(Trip trip) async {
    await _contentService.addTrip(trip);
    notifyListeners();
  }

  Future<void> addService(Service service) async {
    await _contentService.addService(service);
    notifyListeners();
  }

  Future<String> uploadImage(String postId, File image, {bool isMain = false}) async {
    return await _contentService.uploadImage(postId, image, isMain: isMain);
  }

  String generateId() {
    return _contentService.generateId();
  }
}