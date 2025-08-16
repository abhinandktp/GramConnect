import 'package:flutter/material.dart';
import 'package:gram_connect/FoodManagementPage.dart';
import 'package:gram_connect/HomeScreen.dart';
import 'package:gram_connect/LoginPage.dart';
import 'package:gram_connect/FoodManagementPage.dart';
import 'package:gram_connect/PanchayathMapPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the LoginPage after a delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Loginpage()),
        // MaterialPageRoute(builder: (context) => PanchayathMapPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Light blue background from your theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.connect_without_contact, // Your chosen app icon
              size: 150, // Larger size for splash screen
              color: Colors.green, // Green color from your theme
            ),
            const SizedBox(height: 20),
            Text(
              'GramConnect', // Your desired text
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Blue color from your theme
              ),
            ),
            const SizedBox(height: 50),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // Green loading indicator
            ),
          ],
        ),
      ),
    );
  }
}
