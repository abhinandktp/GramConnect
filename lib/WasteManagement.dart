import 'package:flutter/material.dart';
import 'package:gram_connect/WasteBinMapPage.dart';
import 'package:gram_connect/WasteComplaintPage.dart';

class WasteManagement extends StatelessWidget {

  const WasteManagement({Key? key}) : super(key: key);

  // Helper function to show a SnackBar message, consistent with other pages
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue, // Blue snackbar to match theme
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme colors defined in main.dart
    final Color primaryColor = Colors.green; // This will be green
    final Color accentColor = Colors.blue; // Using explicit blue for consistent accent

    return Scaffold(
      backgroundColor: Colors.blue[50], // Light blue background to match other pages
      appBar: AppBar(
        title: const Text('Waste Management', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor, // Green app bar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Back button
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Small heading for the cards
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 20.0),
              child: Text(
                'Waste Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Blue heading
                ),
              ),
            ),
            // Bin Location Card
            _buildServiceCard(
              context,
              icon: Icons.location_on,
              title: 'Bin Location',
              description: 'Find nearby waste collection bins on the map.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WasteBinMapPage(),
                  ),
                );
              },
              iconColor: primaryColor, // Green icon
              buttonColor: primaryColor, // Green button
            ),
            const SizedBox(height: 20),
            // Complaint Registration Card
            _buildServiceCard(
              context,
              icon: Icons.assignment_late,
              title: 'Complaint Registration',
              description: 'Report issues related to waste collection or disposal.',
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => WasteComplaintApp(phoneNumber: '',),
                ),
                );
              },
              iconColor: accentColor, // Blue icon
              buttonColor: accentColor, // Blue button
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a consistent service card
  Widget _buildServiceCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
        required Color iconColor,
        required Color buttonColor,
      }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 50, color: iconColor),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(title.contains('Bin') ? 'View Map' : 'Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
