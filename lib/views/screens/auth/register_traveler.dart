import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/providers/auth_provider.dart';

class RegisterTraveler extends StatefulWidget {
  const RegisterTraveler({super.key});

  @override
  State<RegisterTraveler> createState() => _RegisterTravelerState();
}

class _RegisterTravelerState extends State<RegisterTraveler> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traveler Registration'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false).register(
                  _emailController.text,
                  '',
                  '',
                  _phoneController.text,
                  _passwordController.text,
                  'Traveler',
                  context
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}