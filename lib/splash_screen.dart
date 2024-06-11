import 'package:flutter/material.dart';
import 'home_page.dart'; // Assuming your main app widget is in main.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,  // Ensure the container fills the width
        height: double.infinity, // Ensure the container fills the height
        child: Image.asset(
          'assets/images/splash_screen.png',
          fit: BoxFit.fill,  // Image will fill the entire container area
        ),
      ),
    );
  }
}
