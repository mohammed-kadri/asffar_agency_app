import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled3/theme/app_theme.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    try {
      await _auth
          .sendPasswordResetEmail(email: _emailController.text)
          .then((onValue) {
        Navigator.pop(context);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني..',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if(e.toString().contains('network-request-failed')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'الرجاء التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى..',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ));
      } else if(e.toString().contains('invalid-email')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'البريد الإلكتروني الذي أدخلته غير صحيح. الرجاء المحاولة مرة أخرى..',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen_width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              // Logo
              const SizedBox(height: 35),
              // Logo
              Image.asset(
                'assets/images/main_logo.jpg', // Make sure to add your logo to assets
                height: 40,
              ),
              const SizedBox(height: 80),
              // Arabic Text
              Text(
                'أدخل بريدك الإلكتروني لإعادة',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF313131).withAlpha(150),
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                ),
              ),
              Text(
                'تعيين كلمة المرور',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF313131).withAlpha(150),
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                ),
              ),
              const SizedBox(height: 40),
              // Email TextField
              // Email TextField
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF7B84FF).withOpacity(0.09),
                  borderRadius: BorderRadius.circular(screen_width),
                ),
                child: TextField(
                  controller: _emailController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'البريد الالكتروني',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                    ),
                    suffixIcon: Icon(Icons.email_outlined,
                        color: AppTheme.lightTheme.colorScheme.primary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Reset Password Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screen_width),
                    ),
                  ),
                  child: Text(
                    'غير كلمة المرور',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Back Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screen_width),
                      side: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withAlpha(100)),
                    ),
                  ),
                  child: Text(
                    'العودة',
                    style: TextStyle(
                      color: Color(0XFF313131).withAlpha(100),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
