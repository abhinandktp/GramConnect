import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase Core is imported
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
import 'HomeScreen.dart'; // Your HomeScreen
import 'Registration.dart'; // Correctly import the Registration.dart file

// The LoginPage is now a StatefulWidget to manage state like text controllers and form keys.
class Loginpage extends StatefulWidget {
  const Loginpage({Key? key}) : super(key: key);

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  // GlobalKey to uniquely identify the Form and enable validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text input fields.
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Realtime Database instance
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree to prevent memory leaks.
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles the login logic using Firebase Realtime Database.
  void _login() async { // Make _login async
    if (_formKey.currentState!.validate()) {
      final String phoneNumber = _phoneController.text;
      final String password = _passwordController.text;

      try {
        // Reference to the specific user's data based on their phone number
        DatabaseReference userRef = _database.ref('users').child(phoneNumber);
        DataSnapshot snapshot = await userRef.get(); // Fetch the data once

        if (snapshot.exists) {
          // Check if the snapshot has data and it's a Map
          if (snapshot.value is Map) {
            Map<dynamic, dynamic> userData = snapshot.value as Map;
            if (userData['password'] == password) {
              _showSnackbar('Login Successful!', Colors.blue);
              // Extract user details from the fetched data
              final String fetchedName = userData['name'] as String;
              final String fetchedVillage = userData['village'] as String;

              // Navigate to the HomeScreen upon successful login, passing fetched user data.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    userName: fetchedName,
                    phoneNumber: phoneNumber, // Phone number is already known
                    villageName: fetchedVillage,
                  ),
                ),
              );
            } else {
              _showSnackbar('Invalid phone number or password.', Colors.red);
            }
          } else {
            _showSnackbar('User data format error.', Colors.red);
          }
        } else {
          _showSnackbar('Invalid phone number or password.', Colors.red);
        }
      } catch (e) {
        _showSnackbar('Error during login: ${e.toString()}', Colors.red);
        print('Login error: $e'); // Log the error for debugging
      }
    }
  }

  // Placeholder for forgot password functionality.
  void _forgotPassword() {
    _showSnackbar('Forgot password clicked!', Colors.grey);
    // TODO: Implement navigation to a forgot password screen or show a dialog.
  }

  // Handles new user registration, navigating to the RegistrationPage.
  void _registerNewUser() {
    Navigator.push(
      context,
      // CORRECTED: Assuming the class in Registration.dart is named 'RegistrationPage'
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );
  }

  // Helper function to show a SnackBar message.
  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Light blue background
      appBar: AppBar(
        title: const Text(
          'Login to GramConnect',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue, // Blue app bar
        elevation: 0, // No shadow for a modern flat look
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Icon(
                Icons.connect_without_contact, // Example icon
                size: 100,
                color: Colors.green, // Green icon
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Blue title
                ),
              ),
              const SizedBox(height: 30),

              // Form for user input.
              Form(
                key: _formKey, // Associate the form key.
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        prefixIcon: const Icon(Icons.phone, color: Colors.blue), // Blue icon
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
                          borderSide: const BorderSide(color: Colors.green, width: 2.0), // Green border when focused
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        // Basic validation for a 10-digit number.
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // Hide password input for security.
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue), // Blue icon
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
                          borderSide: const BorderSide(color: Colors.green, width: 2.0), // Green border when focused
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity, // Make button fill width
                      height: 55, // Fixed height for a comfortable tap target
                      child: ElevatedButton(
                        onPressed: _login, // Call the login function on press.
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Green button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // Rounded corners
                          ),
                          elevation: 5, // Add shadow for depth.
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword, // Call forgot password function.
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue, // Blue text
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: _registerNewUser, // Call register new user function.
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.green, // Green text
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
