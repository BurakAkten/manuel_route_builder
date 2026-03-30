import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import '../../enums/selection_mode.dart';
import '../../models/route_point.dart';
import '../../services/route_builder_service.dart';

class ManualRouteCreationController extends ChangeNotifier {
  final List<RoutePoint> allPoints;
  final double startPointThresholdMeters;

  ManualRouteCreationController({
    required this.allPoints,
    this.startPointThresholdMeters = 2000,
  });

  // ── Step & mode ───────────────────────────────────────────────────

  int step = 0;
  SelectionMode selectionMode = SelectionMode.none;

  // ── Circle mode ───────────────────────────────────────────────────

  LatLng? circleCenter;
  double radiusMeters = 500;

  // ── Free draw mode ────────────────────────────────────────────────

  bool isFreeDrawing = false;
  List<Offset> screenPoints = [];
  List<LatLng> freeDrawPoints = [];

  // ── Common ────────────────────────────────────────────────────────

  LatLng? startPoint;
  bool isSelectingStart = false;
  bool isLoading = false;
  List<RoutePoint> pointsInZone = [];

  // ── Mode selection ────────────────────────────────────────────────

  void selectCircleMode() {
    selectionMode = SelectionMode.circle;
    _clearFreeDraw();
    notifyListeners();
  }

  void selectFreeDrawMode() {
    selectionMode = SelectionMode.freeDraw;
    circleCenter = null;
    pointsInZone = [];
    isFreeDrawing = true;
    screenPoints.clear();
    freeDrawPoints.clear();
    notifyListeners();
  }

  void resetSelectionMode() {
    selectionMode = SelectionMode.none;
    circleCenter = null;
    pointsInZone = [];
    _clearFreeDraw();
    notifyListeners();
  }

  void resetFreeDraw() {
    pointsInZone = [];
    _clearFreeDraw();
    notifyListeners();
  }

  void _clearFreeDraw() {
    isFreeDrawing = false;
    screenPoints.clear();
    freeDrawPoints.clear();
  }

  // ── Circle handlers ───────────────────────────────────────────────

  void onRadiusChanged(double v) {
    radiusMeters = v;
    if (circleCenter != null) {
      pointsInZone = RouteBuilderService.filterInCircle(allPoints, circleCenter!, v);
    }
    notifyListeners();
  }

  // ── Free draw handlers ────────────────────────────────────────────

  void addScreenPoint(Offset point) {
    screenPoints.add(point);
    notifyListeners();
  }

  Future<void> finalizeFreeDraw(GoogleMapController mapController) async {
    if (screenPoints.length < 5) {
      screenPoints.clear();
      isFreeDrawing = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    final convertedPoints = <LatLng>[];
    for (final point in screenPoints) {
      final latLng = await mapController.getLatLng(
        ScreenCoordinate(x: point.dx.toInt(), y: point.dy.toInt()),
      );
      convertedPoints.add(latLng);
    }

    freeDrawPoints = convertedPoints;
    if (freeDrawPoints.isNotEmpty) {
      freeDrawPoints.add(freeDrawPoints.first);
    }

    final polygonForToolkit = freeDrawPoints.map((p) => mp.LatLng(p.latitude, p.longitude)).toList();

    pointsInZone = allPoints.where((p) {
      return mp.PolygonUtil.containsLocation(
        mp.LatLng(p.location.latitude, p.location.longitude),
        polygonForToolkit,
        false,
      );
    }).toList();

    screenPoints.clear();
    isFreeDrawing = false;
    isLoading = false;
    notifyListeners();
  }

  // ── Map tap ───────────────────────────────────────────────────────

  void onMapTap(LatLng pos) {
    if (isFreeDrawing) return;

    if (step == 0 && selectionMode == SelectionMode.circle) {
      freeDrawPoints.clear();
      circleCenter = pos;
      pointsInZone = RouteBuilderService.filterInCircle(allPoints, pos, radiusMeters);
      notifyListeners();
      return;
    }

    if (step == 1 && isSelectingStart) {
      startPoint = pos;
      isSelectingStart = false;
      notifyListeners();
    }
  }

  // ── Navigation ────────────────────────────────────────────────────

  void goToNextStep() {
    step = 1;
    notifyListeners();
  }

  void setStartPoint(LatLng pos) {
    startPoint = pos;
    notifyListeners();
  }

  void enableMapStartSelection() {
    isSelectingStart = true;
    notifyListeners();
  }

  // ── Route ─────────────────────────────────────────────────────────

  Future<List<RoutePoint>> buildRoute() async {
    isLoading = true;
    notifyListeners();
    try {
      return await Future.microtask(() => RouteBuilderService.buildNearestNeighborRoute(pointsInZone, startPoint!));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool shouldShowStartPoint(List<RoutePoint> route) {
    if (route.isEmpty || startPoint == null) return false;
    final bounds = RouteBuilderService.computeBounds(route);
    final routeCenter = LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );
    return RouteBuilderService.haversineDistance(routeCenter, startPoint!) < startPointThresholdMeters;
  }

  // ── Helpers ───────────────────────────────────────────────────────

  bool isInZone(RoutePoint p) => pointsInZone.contains(p);

  bool get canProceedToNextStep => (circleCenter != null || freeDrawPoints.isNotEmpty) && pointsInZone.isNotEmpty;

  bool get hasArea => circleCenter != null || freeDrawPoints.isNotEmpty;

  Set<Polygon> getPolygons(Color primaryColor) => freeDrawPoints.isNotEmpty
      ? {
          Polygon(
            polygonId: const PolygonId('free_draw_zone'),
            points: freeDrawPoints,
            fillColor: primaryColor.withOpacity(0.2),
            strokeColor: primaryColor,
            strokeWidth: 2,
          ),
        }
      : {};

  Set<Circle> getCircles(Color primaryColor) => circleCenter != null
      ? {
          Circle(
            circleId: const CircleId('zone'),
            center: circleCenter!,
            radius: radiusMeters,
            fillColor: primaryColor.withOpacity(0.15),
            strokeColor: primaryColor,
            strokeWidth: 2,
          ),
        }
      : {};
}
