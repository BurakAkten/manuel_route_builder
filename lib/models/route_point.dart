import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePoint {
  final String id;
  final String title;
  final LatLng location;
  final Map<String, dynamic> extra;

  const RoutePoint({
    required this.id,
    required this.title,
    required this.location,
    this.extra = const {},
  });
}
