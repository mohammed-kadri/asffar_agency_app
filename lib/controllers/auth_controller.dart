import 'package:flutter/material.dart';
import 'package:untitled3/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> login(String email, String password) async {
    // Add your login logic here
    await _authService.login(email, password);
  }

  Future<void> register(String name, String email, String phone, String password) async {
    // Add your registration logic here
    await _authService.register(name, email, phone, password);
  }
}