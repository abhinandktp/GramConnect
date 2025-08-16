import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gram_connect/SplashScreen.dart'; // Import your SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase before running the app
    final FirebaseApp app = await Firebase.initializeApp();
    print('Successfully initialized ${app.options.projectId}');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GramConnect',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        // You might want to define your inputDecorationTheme here for consistency across your app
        // For example (matching the blue/green theme from LoginPage/RegistrationPage):
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.green, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}
