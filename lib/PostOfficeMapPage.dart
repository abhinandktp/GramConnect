import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class PostOfficeMapPage extends StatefulWidget {
  final String phoneNumber;

  const PostOfficeMapPage({super.key, required this.phoneNumber});

  @override
  State<PostOfficeMapPage> createState() => _PostOfficeMapPageState();
}

class _PostOfficeMapPageState extends State<PostOfficeMapPage> {
  final MapController mapController = MapController();

  LatLng? userLocation;
  Map<String, LatLng> postOfficeLocations = {};
  List<String> filteredPostOffices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPostOfficeLocations();
    _getUserLocation();
  }

  Future<void> _fetchPostOfficeLocations() async {
    final ref = FirebaseDatabase.instance.ref("postoffice");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;

      setState(() {
        postOfficeLocations = data.map((key, value) {
          final lat = (value["latitude"] as num).toDouble();
          final lng = (value["longitude"] as num).toDouble();
          return MapEntry(key, LatLng(lat, lng));
        });
        filteredPostOffices = postOfficeLocations.keys.toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

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

  void _searchPostOffice(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPostOffices = postOfficeLocations.keys.toList();
      } else {
        filteredPostOffices = postOfficeLocations.keys
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
        title: const Text("Post Office Locations",
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
                  ...postOfficeLocations.entries.map((entry) {
                    return Marker(
                      point: entry.value,
                      width: 80,
                      height: 80,
                      builder: (ctx) => const Icon(
                        Icons.local_post_office,
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
                onChanged: _searchPostOffice,
                decoration: const InputDecoration(
                  hintText: "Search Post Office...",
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
