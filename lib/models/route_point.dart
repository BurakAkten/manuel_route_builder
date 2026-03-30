import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A point to be displayed and visited on the route map.
///
/// Use [extra] to carry fields from your own data model alongside
/// the route point without losing them after routing is complete.
///
/// ```dart
/// RoutePoint(
///   id: '1',
///   title: 'Coffee Shop',
///   location: LatLng(41.01, 28.97),
///   extra: {'originalModel': myPoint},
/// )
/// ```
class RoutePoint {
  /// Unique identifier for this point.
  final String id;

  /// Display name shown on the map marker and the result list.
  final String title;

  /// Geographic coordinates of this point.
  final LatLng location;

  /// Optional extra data from your own model.
  ///
  /// Useful for retrieving the original object after routing:
  /// ```dart
  /// final original = point.extra['originalModel'] as MyPoint;
  /// ```
  final Map<String, dynamic> extra;

  const RoutePoint({
    required this.id,
    required this.title,
    required this.location,
    this.extra = const {},
  });
}
