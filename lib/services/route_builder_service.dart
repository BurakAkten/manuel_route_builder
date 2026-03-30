import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_point.dart';

/// Static utilities for route filtering and calculation.
///
/// All methods are static — no instantiation needed.
class RouteBuilderService {
  RouteBuilderService._();

  static const double _earthRadius = 6371000.0;
  static const CameraPosition _fallbackPosition =
      const CameraPosition(target: LatLng(41.0082, 28.9784), zoom: 13);

  /// Returns the haversine distance in metres between [a] and [b].
  static double haversineDistance(LatLng a, LatLng b) {
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final x = sinDLat * sinDLat +
        cos(_toRad(a.latitude)) * cos(_toRad(b.latitude)) * sinDLng * sinDLng;
    return _earthRadius * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// Returns all [points] whose distance from [center] is within
  /// [radiusMeters].
  static List<RoutePoint> filterInCircle(
    List<RoutePoint> points,
    LatLng center,
    double radiusMeters,
  ) {
    return points
        .where((p) => haversineDistance(center, p.location) <= radiusMeters)
        .toList();
  }

  /// Orders [points] by proximity starting from [startLocation]
  /// using the nearest neighbor greedy algorithm.
  ///
  /// Returns an empty list if [points] is empty.
  static List<RoutePoint> buildNearestNeighborRoute(
    List<RoutePoint> points,
    LatLng startLocation,
  ) {
    if (points.isEmpty) return [];

    final remaining = List<RoutePoint>.from(points);
    final route = <RoutePoint>[];
    var current = startLocation;

    while (remaining.isNotEmpty) {
      remaining.sort((a, b) => haversineDistance(current, a.location)
          .compareTo(haversineDistance(current, b.location)));
      final nearest = remaining.removeAt(0);
      route.add(nearest);
      current = nearest.location;
    }
    return route;
  }

  /// Returns a [LatLngBounds] that covers all [points].
  ///
  /// If [startPoint] is provided it is also included in the bounds.
  static LatLngBounds computeBounds(List<RoutePoint> points,
      {LatLng? startPoint}) {
    final latitudes = [
      ...points.map((p) => p.location.latitude),
      if (startPoint != null) startPoint.latitude,
    ];
    final longitudes = [
      ...points.map((p) => p.location.longitude),
      if (startPoint != null) startPoint.longitude,
    ];

    return LatLngBounds(
      southwest: LatLng(latitudes.reduce(min), longitudes.reduce(min)),
      northeast: LatLng(latitudes.reduce(max), longitudes.reduce(max)),
    );
  }

  /// Returns a [CameraPosition] centered on [points] with an
  /// appropriate zoom level based on how spread out the points are.
  ///
  /// Falls back to [fallback] if [points] is empty.
  static CameraPosition computeInitialCamera(List<RoutePoint> points,
      {CameraPosition fallback = _fallbackPosition}) {
    if (points.isEmpty) return fallback;

    final bounds = computeBounds(points);
    final centerLat =
        (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final centerLng =
        (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    final latSpan = bounds.northeast.latitude - bounds.southwest.latitude;
    final lngSpan = bounds.northeast.longitude - bounds.southwest.longitude;
    final maxSpan = latSpan > lngSpan ? latSpan : lngSpan;

    ///calculate the zoom value based on the max span (center of the points)
    final zoom = switch (maxSpan) {
      > 0.5 => 10.0,
      > 0.2 => 11.0,
      > 0.1 => 12.0,
      > 0.05 => 13.0,
      > 0.01 => 14.0,
      _ => 15.0,
    };

    return CameraPosition(target: LatLng(centerLat, centerLng), zoom: zoom);
  }
}
