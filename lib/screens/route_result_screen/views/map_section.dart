import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manuel_route_builder/configs/manuel_route_builder_config.dart';
import '../../../models/route_point.dart';

class MapSection extends StatelessWidget {
  final double? heightFactor;
  final List<RoutePoint> route;
  final LatLng startPoint;
  final bool showStartPoint;
  final Color primaryColor;
  final Map<int, BitmapDescriptor> numberedMarkers;
  final Map<int, BitmapDescriptor> focusedMarkers;
  final int? focusedIndex;
  final void Function(LatLng, int) onPointTap;
  final void Function(GoogleMapController) onMapCreated;

  const MapSection({
    this.heightFactor,
    required this.route,
    required this.startPoint,
    required this.showStartPoint,
    required this.primaryColor,
    required this.numberedMarkers,
    required this.focusedMarkers,
    required this.focusedIndex,
    required this.onPointTap,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    final content = GoogleMap(
      initialCameraPosition: CameraPosition(
        target: route.isNotEmpty ? route.first.location : startPoint,
        zoom: 13,
      ),
      onMapCreated: onMapCreated,
      markers: _markers,
      polylines: _polylines,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
    );

    if (heightFactor != null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * heightFactor!,
        child: content,
      );
    }
    return content;
  }

  Set<Marker> get _markers => {
        if (showStartPoint)
          Marker(
            markerId: const MarkerId('start'),
            position: startPoint,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: ManuelRouteBuilderConfig.l10n.starting),
          ),
        for (int i = 0; i < route.length; i++)
          Marker(
            markerId: MarkerId('route_$i'),
            position: route[i].location,
            icon: focusedIndex == i
                ? (focusedMarkers[i] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange))
                : (numberedMarkers[i] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)),
            infoWindow: InfoWindow(title: '${i + 1}. ${route[i].title}'),
            zIndexInt: focusedIndex == i ? 1 : 0,
            onTap: () => onPointTap(route[i].location, i),
          ),
      };

  Set<Polyline> get _polylines => {
        Polyline(
          polylineId: const PolylineId('route_line'),
          points: [
            if (showStartPoint) startPoint,
            ...route.map((p) => p.location),
          ],
          color: primaryColor,
          width: 3,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
}
