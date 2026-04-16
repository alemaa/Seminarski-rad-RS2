import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import '../models/cafe.dart';
import '../providers/cafe_provider.dart';

class NearbyCafesScreen extends StatefulWidget {
  const NearbyCafesScreen({super.key});

  @override
  State<NearbyCafesScreen> createState() => _NearbyCafesScreenState();
}

class _NearbyCafesScreenState extends State<NearbyCafesScreen> {
  bool _isLoading = true;
  String? _error;
  List<Cafe> _cafes = [];
  Position? _currentPosition;
  String _locationName = "Unknown location";

  @override
  void initState() {
    super.initState();
    _loadNearbyCafes();
  }

  Future<void> _loadNearbyCafes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          "Location permission permanently denied. Enable it in device settings.",
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String locationName = "Unknown location";

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final city = place.locality?.trim().isNotEmpty == true
              ? place.locality!
              : place.subAdministrativeArea?.trim().isNotEmpty == true
                  ? place.subAdministrativeArea!
                  : place.administrativeArea?.trim().isNotEmpty == true
                      ? place.administrativeArea!
                      : "";

          final country =
              place.country?.trim().isNotEmpty == true ? place.country! : "";

          locationName = city.isNotEmpty && country.isNotEmpty
              ? "$city, $country"
              : city.isNotEmpty
                  ? city
                  : country.isNotEmpty
                      ? country
                      : "Unknown location";
        }
      } catch (e) {
        print("Reverse geocoding error: $e");
        locationName = "Unknown location";
      }

      final provider = context.read<CafeProvider>();
      final cafes = await provider.getNearby(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _locationName = locationName;
        _cafes = cafes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _openMap(Cafe cafe) async {
    if (cafe.latitude == null || cafe.longitude == null) return;

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${cafe.latitude},${cafe.longitude}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildCafeCard(Cafe cafe) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cafe.name ?? "Unknown cafe",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 18, color: Color(0xFF6F4E37)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${cafe.address ?? ""}, ${cafe.cityName ?? ""}",
                    style: const TextStyle(color: Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (cafe.workingHours != null && cafe.workingHours!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 18, color: Color(0xFF6F4E37)),
                  const SizedBox(width: 6),
                  Text(
                    cafe.workingHours!,
                    style: const TextStyle(color: Color(0xFF5D4037)),
                  ),
                ],
              ),
            if (cafe.phoneNumber != null && cafe.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18, color: Color(0xFF6F4E37)),
                  const SizedBox(width: 6),
                  Text(
                    cafe.phoneNumber!,
                    style: const TextStyle(color: Color(0xFF5D4037)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1E3D6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cafe.distanceKm != null
                        ? "${cafe.distanceKm!.toStringAsFixed(2)} km away"
                        : "Distance unavailable",
                    style: const TextStyle(
                      color: Color(0xFF6F4E37),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6F4E37),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _openMap(cafe),
                  icon: const Icon(Icons.map),
                  label: const Text("Open map"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F4E37),
        title: const Text(
          "Nearby Cafes",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearbyCafes,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Find cafes that use CafeEase near your location.",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 12),
            if (_currentPosition != null)
              Text(
                "Your location: $_locationName",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6D4C41),
                ),
              ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: CircularProgressIndicator(),
              ))
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_cafes.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "No cafes found near your location.",
                  style: TextStyle(color: Color(0xFF5D4037)),
                ),
              )
            else
              ..._cafes.map(_buildCafeCard),
          ],
        ),
      ),
    );
  }
}
