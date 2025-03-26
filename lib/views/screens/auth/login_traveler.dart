import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/providers/auth_provider.dart';

class LoginTraveler extends StatefulWidget {
  const LoginTraveler({super.key});

  @override
  State<LoginTraveler> createState() => _LoginTravelerState();
}

class _LoginTravelerState extends State<LoginTraveler> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traveler Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false).login(
                  _emailController.text,
                  _passwordController.text,
                  'Traveler',
                  context,
                );
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot_password');
              },
              child: Text('Forgot Password?'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register_traveler');
              },
              child: Text('Don\'t have an account? Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login_agency');
              },
              child: Text('Login as an Agency'),
            ),
          ],
        ),
      ),
    );
  }
}
