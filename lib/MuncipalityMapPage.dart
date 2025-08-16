import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class MuncipalityMapPage extends StatefulWidget {
  final String phoneNumber;

  const MuncipalityMapPage({super.key, required this.phoneNumber});

  @override
  State<MuncipalityMapPage> createState() => _MuncipalityMapPageState();
}

class _MuncipalityMapPageState extends State<MuncipalityMapPage> {
  final MapController mapController = MapController();

  LatLng? userLocation;
  Map<String, LatLng> muncipalityLocations = {};
  List<String> filteredMuncipalities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMuncipalityLocations();
    _getUserLocation();
  }

  /// ✅ Fetch muncipality data from Firebase
  Future<void> _fetchMuncipalityLocations() async {
    final ref = FirebaseDatabase.instance.ref("muncipality"); // Firebase node
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;

      setState(() {
        muncipalityLocations = data.map((key, value) {
          final lat = (value["latitude"] as num).toDouble();
          final lng = (value["longitude"] as num).toDouble();
          return MapEntry(key, LatLng(lat, lng));
        });
        filteredMuncipalities = muncipalityLocations.keys.toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// ✅ Get user current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  /// ✅ Search muncipalities
  void _searchMuncipality(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMuncipalities = muncipalityLocations.keys.toList();
      } else {
        filteredMuncipalities = muncipalityLocations.keys
            .where((m) => m.toLowerCase().contains(query.toLowerCase()))
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
        title: const Text("Muncipality Locations",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
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
                  ...muncipalityLocations.entries.map((entry) {
                    return Marker(
                      point: entry.value,
                      width: 80,
                      height: 80,
                      builder: (ctx) => const Icon(
                        Icons.account_balance, // 🏛️ Muncipality Icon
                        color: Colors.purple,
                        size: 40,
                      ),
                    );
                  }),
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
          /// 🔍 Search box
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
                      color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                ],
              ),
              child: TextField(
                onChanged: _searchMuncipality,
                decoration: const InputDecoration(
                  hintText: "Search Muncipality...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          if (userLocation == null) await _getUserLocation();
          if (userLocation != null) {
            mapController.move(userLocation!, 14);
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
