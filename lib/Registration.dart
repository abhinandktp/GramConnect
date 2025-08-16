import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase Core is imported

// The RegistrationPage is a StatefulWidget to manage its form state and controllers.
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // GlobalKey to uniquely identify the Form and enable validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text input fields on the registration form.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  // Realtime Database instance.
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks.
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _villageController.dispose();
    super.dispose();
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

  // Handles the registration logic, storing user data in Realtime Database.
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final String phoneNumber = _phoneController.text.trim();
      final String password = _passwordController.text.trim();
      final String village = _villageController.text.trim();

      try {
        // Check if phone number already exists in Realtime Database.
        // Use the phone number as a unique key for each user.
        DataSnapshot existingUserSnapshot = await _database.ref('users').child(phoneNumber).get();

        if (existingUserSnapshot.exists) {
          _showSnackbar('Phone number already registered. Please login.', Colors.red);
        } else {
          // If phone number does not exist, proceed with registration.
          await _database.ref('users').child(phoneNumber).set({
            'name': name,
            'password': password, // WARNING: Store hashed passwords in production!
            'village': village,
            'createdAt': ServerValue.timestamp, // Server-side timestamp for creation.
          });

          _showSnackbar('Registration successful! Please login.', Colors.blue);
          // Navigate back to the login page after successful registration.
          Navigator.pop(context); // Go back to the previous screen (LoginPage).
        }
      } catch (e) {
        _showSnackbar('Registration failed: ${e.toString()}', Colors.red);
        print('Registration error: $e'); // Log the error for debugging.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Light blue background matching Loginpage.
      appBar: AppBar(
        title: const Text(
          'Register to BharatConnect',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue, // Blue app bar.
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_alt_1, // Icon for registration.
                size: 100,
                color: Colors.green, // Green icon.
              ),
              const SizedBox(height: 20),
              const Text(
                'Create New Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Blue title.
                ),
              ),
              const SizedBox(height: 30),

              Form(
                key: _formKey, // Associate the form key for validation.
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: const BorderSide(color: Colors.green, width: 2.0)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your 10-digit phone number',
                        prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: const BorderSide(color: Colors.green, width: 2.0)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter a strong password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: const BorderSide(color: Colors.green, width: 2.0)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _villageController,
                      decoration: InputDecoration(
                        labelText: 'Village Name',
                        hintText: 'Enter your village name',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: const BorderSide(color: Colors.green, width: 2.0)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your village name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _registerUser, // Call the registration function.
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Green button.
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Register Account',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to the LoginPage.
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue, // Blue text.
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
