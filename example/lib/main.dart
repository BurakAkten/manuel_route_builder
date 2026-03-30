import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manuel_route_builder/manuel_route_builder.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Manuel Route Builder Example',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Sample points spread around a city center
  static final List<RoutePoint> _samplePoints = [
    RoutePoint(
        id: '1',
        title: 'Coffee Shop',
        location: const LatLng(41.0150, 28.9780)),
    RoutePoint(
        id: '2',
        title: 'Supermarket',
        location: const LatLng(41.0165, 28.9795)),
    RoutePoint(
        id: '3', title: 'Pharmacy', location: const LatLng(41.0140, 28.9810)),
    RoutePoint(
        id: '4', title: 'Bakery', location: const LatLng(41.0175, 28.9760)),
    RoutePoint(
        id: '5',
        title: 'Convenience Store',
        location: const LatLng(41.0130, 28.9750)),
    RoutePoint(
        id: '6',
        title: 'Greengrocer',
        location: const LatLng(41.0185, 28.9820)),
    RoutePoint(
        id: '7', title: 'Butcher', location: const LatLng(41.0120, 28.9800)),
    RoutePoint(
        id: '8', title: 'Barber', location: const LatLng(41.0160, 28.9740)),
    RoutePoint(
        id: '9',
        title: 'Post Office',
        location: const LatLng(41.0195, 28.9770)),
    RoutePoint(
        id: '10', title: 'Bank', location: const LatLng(41.0110, 28.9830)),
    RoutePoint(
        id: '11', title: 'Bookstore', location: const LatLng(41.0170, 28.9840)),
    RoutePoint(
        id: '12',
        title: 'Hardware Store',
        location: const LatLng(41.0145, 28.9760)),
  ];

  Future<LatLng?> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        title: const Text('Manuel Route Builder'),
        backgroundColor: const Color(0xFF534AB7),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Example App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This example shows how to integrate manuel_route_builder '
              'into your Flutter app. Tap the button below to open the '
              'route creation screen with 12 sample points.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5F5E5A),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            const _InfoCard(
              icon: Icons.radio_button_checked,
              title: 'Circle selection',
              description: 'Tap on the map to place a circle, then adjust '
                  'the radius with the slider.',
            ),
            const SizedBox(height: 12),
            const _InfoCard(
              icon: Icons.gesture,
              title: 'Free-draw selection',
              description: 'Draw a custom polygon by dragging your finger '
                  'across the map.',
            ),
            const SizedBox(height: 12),
            const _InfoCard(
              icon: Icons.route,
              title: 'Automatic routing',
              description: 'Points inside the selected area are ordered '
                  'using the nearest neighbor algorithm.',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text(
                  'Create Manual Route',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF534AB7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _openRouteBuilder(context),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openRouteBuilder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManualRouteCreationScreen(
          allPoints: _samplePoints,
          onGetCurrentLocation: _getCurrentLocation,
          onRouteSaved: (List<RoutePoint> route, LatLng startPoint) {
            Navigator.pop(context);
            _showSavedSnackbar(context, route);
          },
        ),
      ),
    );
  }

  void _showSavedSnackbar(BuildContext context, List<RoutePoint> route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Route saved — ${route.length} stops: '
          '${route.map((p) => p.title).join(', ')}',
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0DDD6), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF534AB7), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888780),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
