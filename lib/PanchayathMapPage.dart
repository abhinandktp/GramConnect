import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class PanchayathMapPage extends StatefulWidget {
  final String phoneNumber; // ✅ passed from HomeScreen

  const PanchayathMapPage({super.key, required this.phoneNumber});

  @override
  State<PanchayathMapPage> createState() => _PanchayathMapPageState();
}

class _PanchayathMapPageState extends State<PanchayathMapPage> {
  final MapController mapController = MapController();

  LatLng? userLocation;
  Map<String, LatLng> panchayathLocations = {};
  List<String> filteredPanchayaths = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPanchayathLocations();
    _getUserLocation();
  }

  /// ✅ Fetch Panchayath coordinates from Firebase
  Future<void> _fetchPanchayathLocations() async {
    final ref = FirebaseDatabase.instance.ref("panchayath");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;

      setState(() {
        panchayathLocations = data.map((key, value) {
          final lat = (value["latitude"] as num).toDouble();
          final lng = (value["longitude"] as num).toDouble();
          return MapEntry(key, LatLng(lat, lng));
        });
        filteredPanchayaths = panchayathLocations.keys.toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// ✅ Get user’s current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permissions are permanently denied"),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  /// ✅ Search panchayath names
  void _searchPanchayath(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPanchayaths = panchayathLocations.keys.toList();
      } else {
        filteredPanchayaths = panchayathLocations.keys
            .where((p) => p.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Panchayath Locations",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// ✅ Map
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: userLocation ?? LatLng(11.25, 75.78),
              zoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  /// ✅ Panchayath markers
                  ...panchayathLocations.entries.map((entry) {
                    return Marker(
                      point: entry.value,
                      width: 80,
                      height: 80,
                      builder: (ctx) => const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    );
                  }),

                  /// ✅ User marker
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 80,
                      height: 80,
                      builder: (ctx) => const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          /// ✅ Search Box
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                onChanged: _searchPanchayath,
                decoration: const InputDecoration(
                  hintText: "Search Panchayath...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),

      /// ✅ Focus on user button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          if (userLocation == null) {
            await _getUserLocation(); // retry fetch
          }
          if (userLocation != null) {
            mapController.move(userLocation!, 14);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User location is not available")),
            );
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
