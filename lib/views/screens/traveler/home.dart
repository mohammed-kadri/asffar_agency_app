import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/services/auth_service.dart';

class HomeTraveler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traveler Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, Traveler!'),
      ),
    );
  }
}