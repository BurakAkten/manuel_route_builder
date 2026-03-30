import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manuel_route_builder/screens/route_result_screen/views/route_result_body.dart';
import '../../configs/manuel_route_builder_config.dart';
import '../../enums/marker_style.dart';
import '../../models/route_point.dart';
import '../../services/route_builder_service.dart';
import '../../utils/numbered_marker_painter.dart';

typedef ScaffoldBuilder = Widget Function(
  BuildContext context,
  PreferredSizeWidget appBar,
  Widget stepIndicator,
  Widget body,
);

/// Displays the calculated route on a map with numbered markers
/// and a scrollable list of stops.
///
/// Tapping a list item zooms the map to that stop and highlights
/// its marker in amber. The first stop uses a green marker, the
/// last stop uses a red marker with a flag icon.
///
/// Normally you don't need to instantiate this directly —
/// [ManualRouteCreationScreen] handles navigation automatically.
class RouteResultScreen extends StatefulWidget {
  final List<RoutePoint> route;
  final LatLng startPoint;
  final bool showStartPoint;
  final Color primaryColor;
  final Color successColor;
  final Widget Function(BuildContext, RoutePoint, int)? itemBuilder;
  final void Function(List<RoutePoint> route, LatLng startPoint)? onSaved;
  final ScaffoldBuilder? scaffoldBuilder;

  const RouteResultScreen({
    super.key,
    required this.route,
    required this.startPoint,
    this.showStartPoint = true,
    this.primaryColor = const Color(0xFF534AB7),
    this.successColor = const Color(0xFF1D9E75),
    this.itemBuilder,
    this.onSaved,
    this.scaffoldBuilder,
  });

  @override
  State<RouteResultScreen> createState() => _RouteResultScreenState();
}

class _RouteResultScreenState extends State<RouteResultScreen> {
  GoogleMapController? _mapController;
  Map<int, BitmapDescriptor> _numberedMarkers = {};
  Map<int, BitmapDescriptor> _focusedMarkers = {};
  int? _focusedIndex;

  @override
  void initState() {
    super.initState();
    _generateMarkers();
  }

  // ── Marker generation ─────────────────────────────────────────────
  Future<void> _generateMarkers() async {
    final normal = <int, BitmapDescriptor>{};
    final focused = <int, BitmapDescriptor>{};

    for (int i = 0; i < widget.route.length; i++) {
      final style = _getMarkerStyle(i);

      normal[i] = await NumberedMarkerPainter.create(
        number: i + 1,
        color: widget.primaryColor,
        style: style,
      );
      focused[i] = await NumberedMarkerPainter.create(
        number: i + 1,
        color: widget.primaryColor,
        style: style == MarkerStyle.last
            ? MarkerStyle.lastFocused
            : MarkerStyle.focused,
      );
    }

    if (mounted) {
      setState(() {
        _numberedMarkers = normal;
        _focusedMarkers = focused;
      });
    }
  }

  MarkerStyle _getMarkerStyle(int index) {
    if (index == 0) return MarkerStyle.first;
    if (index == widget.route.length - 1) return MarkerStyle.last;
    return MarkerStyle.normal;
  }

  void _handleFocusPoint(LatLng location, int index) {
    setState(() => _focusedIndex = index);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 17));
  }

  void _handleMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final bounds = RouteBuilderService.computeBounds(
      widget.route,
      startPoint: widget.showStartPoint ? widget.startPoint : null,
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80.0));
  }

  @override
  Widget build(BuildContext context) {
    final appBar =
        AppBar(title: Text(ManuelRouteBuilderConfig.l10n.generatedRoute))
            as PreferredSizeWidget;

    final body = RouteResultBody(
      route: widget.route,
      startPoint: widget.startPoint,
      showStartPoint: widget.showStartPoint,
      primaryColor: widget.primaryColor,
      successColor: widget.successColor,
      numberedMarkers: _numberedMarkers,
      focusedMarkers: _focusedMarkers,
      focusedIndex: _focusedIndex,
      onPointTap: _handleFocusPoint,
      onMapCreated: _handleMapCreated,
      onSaved: widget.onSaved,
      itemBuilder: widget.itemBuilder,
    );

    if (widget.scaffoldBuilder != null) {
      return widget.scaffoldBuilder!(
          context, appBar, const SizedBox.shrink(), body);
    }
    return Scaffold(appBar: appBar, body: body);
  }
}
