import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manuel_route_builder/configs/manuel_route_builder_config.dart';
import 'package:manuel_route_builder/screens/manual_route_creation/widgets/bottom_sheet_content.dart';
import 'package:manuel_route_builder/screens/manual_route_creation/widgets/step_indicator.dart';
import '../../models/route_point.dart';
import '../../services/route_builder_service.dart';
import '../../utils/free_draw_painter.dart';
import '../route_result_screen/route_result_screen.dart';
import 'manual_route_creation_controller.dart';

typedef ScaffoldBuilder = Widget Function(
  BuildContext context,
  PreferredSizeWidget appBar,
  Widget stepIndicator,
  Widget body,
);

/// A screen that lets the user select an area on the map and a
/// starting point, then builds an optimized route through all
/// [RoutePoint]s within that area.
///
/// Two area selection modes are available:
/// - **Circle** — tap to place a center point, adjust radius with slider.
/// - **Free draw** — drag finger across the map to draw a polygon.
///
/// ```dart
/// ManualRouteCreationScreen(
///   allPoints: myPoints,
///   onGetCurrentLocation: () async {
///     final pos = await Geolocator.getCurrentPosition();
///     return LatLng(pos.latitude, pos.longitude);
///   },
///   onRouteSaved: (route, startPoint) {
///     print('${route.length} stops saved');
///   },
/// )
/// ```
class ManualRouteCreationScreen extends StatefulWidget {
  final List<RoutePoint> allPoints;
  final Future<LatLng?> Function()? onGetCurrentLocation;
  final Color primaryColor;
  final Color successColor;
  final double startPointThresholdMeters;
  final Widget Function(BuildContext, RoutePoint, int)? routeResultItemBuilder;
  final void Function(List<RoutePoint> route, LatLng startPoint)? onRouteSaved;
  final ScaffoldBuilder? scaffoldBuilder;

  const ManualRouteCreationScreen({
    super.key,
    required this.allPoints,
    this.onGetCurrentLocation,
    this.primaryColor = const Color(0xFF534AB7),
    this.successColor = const Color(0xFF1D9E75),
    this.startPointThresholdMeters = 2000,
    this.routeResultItemBuilder,
    this.onRouteSaved,
    this.scaffoldBuilder,
  });

  @override
  State<ManualRouteCreationScreen> createState() => _ManualRouteCreationScreenState();
}

class _ManualRouteCreationScreenState extends State<ManualRouteCreationScreen> {
  late final ManualRouteCreationController _controller;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _controller = ManualRouteCreationController(
      allPoints: widget.allPoints,
      startPointThresholdMeters: widget.startPointThresholdMeters,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final stepIndicator = StepIndicator(currentStep: _controller.step, activeColor: Colors.white, doneColor: widget.successColor);

    final appBar = AppBar(
      title: Text(ManuelRouteBuilderConfig.l10n.generatedManuelRoute),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(32), child: stepIndicator),
    ) as PreferredSizeWidget;

    final body = _buildBody();

    if (widget.scaffoldBuilder != null) {
      return widget.scaffoldBuilder!(context, appBar, stepIndicator, body);
    }
    return Scaffold(appBar: appBar, body: body);
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Positioned.fill(
          child: _buildMap(),
        ),
        if (_controller.isSelectingStart)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SelectingBanner(color: widget.primaryColor),
          ),
        DraggableScrollableSheet(
          initialChildSize: 0.30,
          minChildSize: 0.15,
          maxChildSize: 0.5,
          // snap: true,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: BottomSheetContent(
                step: _controller.step,
                selectionMode: _controller.selectionMode,
                hasCircle: _controller.circleCenter != null,
                hasStartPoint: _controller.startPoint != null,
                isDrawingMode: _controller.isFreeDrawing,
                pointCount: _controller.pointsInZone.length,
                radius: _controller.radiusMeters,
                primaryColor: widget.primaryColor,
                successColor: widget.successColor,
                onRadiusChanged: _controller.onRadiusChanged,
                onNextStep: _controller.goToNextStep,
                onUseCurrentLoc: _useCurrentLocation,
                onSelectOnMap: _controller.enableMapStartSelection,
                onBuildRoute: _buildAndShowRoute,
                onSelectCircleMode: _controller.selectCircleMode,
                onSelectFreeDrawMode: _controller.selectFreeDrawMode,
                onResetMode: _controller.resetSelectionMode,
                onResetFreeDraw: _controller.resetFreeDraw,
              ),
            ),
          ),
        ),
        if (_controller.isLoading) _LoadingOverlay(color: widget.primaryColor),
      ],
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          scrollGesturesEnabled: !_controller.isFreeDrawing,
          zoomGesturesEnabled: !_controller.isFreeDrawing,
          rotateGesturesEnabled: !_controller.isFreeDrawing,
          tiltGesturesEnabled: !_controller.isFreeDrawing,
          initialCameraPosition: RouteBuilderService.computeInitialCamera(widget.allPoints),
          onMapCreated: _onMapCreated,
          markers: _markers,
          polygons: _controller.getPolygons(widget.primaryColor),
          circles: _controller.getCircles(widget.primaryColor),
          onTap: _controller.onMapTap,
        ),
        if (_controller.isFreeDrawing)
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: (details) => _controller.addScreenPoint(details.localPosition),
              onPanEnd: (_) => _controller.finalizeFreeDraw(_mapController!, MediaQuery.of(context).devicePixelRatio),
              child: CustomPaint(
                painter: FreeDrawPainter(
                  points: _controller.screenPoints,
                  color: widget.primaryColor,
                ),
                size: Size.infinite,
              ),
            ),
          ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitAllPoints();
  }

  void _fitAllPoints() {
    if (widget.allPoints.isEmpty || _mapController == null) return;
    final bounds = RouteBuilderService.computeBounds(widget.allPoints);
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80.0));
  }

  Future<void> _useCurrentLocation() async {
    final pos = await widget.onGetCurrentLocation?.call();
    if (pos != null) _controller.setStartPoint(pos);
  }

  Future<void> _buildAndShowRoute() async {
    if (_controller.isLoading) return;
    final route = await _controller.buildRoute();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RouteResultScreen(
          route: route,
          startPoint: _controller.startPoint!,
          showStartPoint: _controller.shouldShowStartPoint(route),
          primaryColor: widget.primaryColor,
          successColor: widget.successColor,
          itemBuilder: widget.routeResultItemBuilder,
          onSaved: widget.onRouteSaved,
          scaffoldBuilder: widget.scaffoldBuilder,
        ),
      ),
    );
  }

  Set<Marker> get _markers {
    return {
      for (final p in widget.allPoints)
        Marker(
          markerId: MarkerId(p.id),
          position: p.location,
          icon: _controller.isInZone(p)
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      if (_controller.startPoint != null)
        Marker(
          markerId: const MarkerId('start'),
          position: _controller.startPoint!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SelectingBanner extends StatelessWidget {
  final Color color;
  const _SelectingBanner({required this.color});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            ManuelRouteBuilderConfig.l10n.touchTheMapForStartingPoint,
            style: TextStyle(color: Colors.white, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final Color color;
  const _LoadingOverlay({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: color),
              const SizedBox(height: 12),
              Text(
                ManuelRouteBuilderConfig.l10n.routeGenerating,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
