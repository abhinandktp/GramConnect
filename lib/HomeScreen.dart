import 'package:flutter/material.dart';
import 'package:gram_connect/ComplaintsPage.dart';
import 'package:gram_connect/CorporationMapPage.dart';
import 'package:gram_connect/MuncipalityMapPage.dart';
import 'package:gram_connect/PostOfficeMapPage.dart';
import 'package:gram_connect/ToiletMapPage.dart';
import 'package:gram_connect/VillageMapPage.dart';
import 'package:gram_connect/VillageTourPage.dart';
import 'package:gram_connect/WasteManagement.dart';
import 'FoodManagementPage.dart';
import 'PanchayathMapPage.dart';

class HomeScreen extends StatelessWidget {
  // Added fields to receive user data from the LoginPage
  final String userName;
  final String phoneNumber;
  final String villageName;

  const HomeScreen({
    Key? key,
    required this.userName,
    required this.phoneNumber,
    required this.villageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Light blue background color
      appBar: AppBar(
        title: const Text(
          'GramConnect',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Topmost rounded rectangle box with user avatar, name, and village name
              _buildUserProfileCard(context),
              const SizedBox(height: 20),

              // Small heading for horizontal buttons
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 10.0),
                child: Text(
                  'Local Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),

              // 2. Single row card buttons (Local Services)
              _buildHorizontalButtons(context),
              const SizedBox(height: 25),

              // Small heading for feature grid
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 10.0),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),

              // 3. Grid feature cards
              _buildFeatureGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildUserProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(width: 15),
          // User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                villageName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalButtons(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {'icon': Icons.local_post_office, 'text': 'Post Office'},
      {'icon': Icons.wc, 'text': 'Public Toilet'},
      {'icon': Icons.home, 'text': 'Village'},
      {'icon': Icons.account_balance, 'text': 'Panchayath'},
      {'icon': Icons.location_city, 'text': 'Municipality'},
      {'icon': Icons.apartment, 'text': 'Corporation'},
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final service = categories[index]['text'];
          final icon = categories[index]['icon'];

          return Padding(
            padding: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 10),
            child: _buildCategoryCard(
              context,
              icon: icon,
              text: service,
              onTap: () {
                if (service == "Panchayath") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PanchayathMapPage(
                        phoneNumber: phoneNumber, // logged-in user's village
                      ),
                    ),
                  );
                }
                if (service == "Post Office") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostOfficeMapPage(
                        phoneNumber: phoneNumber, // logged-in user's village
                      ),
                    ),
                  );
                }
                if (service == "Public Toilet") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ToiletMapPage(
                        phoneNumber: phoneNumber, // logged-in user's village
                      ),
                    ),
                  );
                }
                if (service == "Village") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VillageMapPage(
                        phoneNumber: phoneNumber, // logged-in user's village
                      ),
                    ),
                  );
                }
                if (service == "Municipality") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MuncipalityMapPage(
                        phoneNumber: phoneNumber, // logged-in user's village
                      ),
                    ),
                  );
                }
                if (service == "Corporation") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CorporationMapPage(
                        phoneNumber: phoneNumber, // logged-in user's village
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    List<Map<String, dynamic>> featureCards = [
      {'icon': Icons.fastfood, 'text': 'Food Management'},
      {'icon': Icons.delete, 'text': 'Waste Management'},
      {'icon': Icons.map, 'text': 'Village / City Tour'},
      {'icon': Icons.feedback, 'text': 'Complaints'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.0,
      children: List.generate(featureCards.length, (index) {
        final service = featureCards[index]['text'];
        final icon = featureCards[index]['icon'];

        return _buildFeatureCard(
          context,
          icon: icon,
          text: service,
          onTap: () {
            if (service == "Food Management") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodManagementApp(
                    phoneNumber: phoneNumber, // logged-in user's village
                  ),
                ),
              );
            }
            if (service == "Village / City Tour") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VillageTourPage(),
                ),
              );
            }
            if (service == "Complaints") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComplaintsPage(),
                ),
              );
            }
            if (service == "Waste Management") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WasteManagement(),
                ),
              );
            }
            _showSnackbar(context, '$service clicked!');
          },
        );
      }),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
