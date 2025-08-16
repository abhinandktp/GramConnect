import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class WasteBinMapPage extends StatefulWidget {

  @override
  State<WasteBinMapPage> createState() => _WasteBinMapPageState();
}

class _WasteBinMapPageState extends State<WasteBinMapPage> {
  final MapController mapController = MapController();

  LatLng? userLocation;
  Map<String, LatLng> wasteBinLocations = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWasteBinLocations();
    _getUserLocation();
  }

  /// ✅ Fetch wastebin data from Firebase
  Future<void> _fetchWasteBinLocations() async {
    final ref = FirebaseDatabase.instance.ref("wastebin"); // Firebase node
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;

      setState(() {
        wasteBinLocations = data.map((key, value) {
          final lat = (value["latitude"] as num).toDouble();
          final lng = (value["longitude"] as num).toDouble();
          return MapEntry(key, LatLng(lat, lng));
        });
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
          "Waste Bin Locations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: userLocation ?? LatLng(11.25, 75.78),
          zoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              ...wasteBinLocations.entries.map((entry) {
                return Marker(
                  point: entry.value,
                  width: 80,
                  height: 80,
                  builder: (ctx) => const Icon(
                    Icons.delete, // 🗑️ Waste Bin Icon
                    color: Colors.red,
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
