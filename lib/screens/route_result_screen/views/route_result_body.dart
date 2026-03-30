import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manuel_route_builder/screens/route_result_screen/views/route_list_section.dart';
import '../../../models/route_point.dart';
import '../widgets/save_button.dart';
import 'map_section.dart';

class RouteResultBody extends StatelessWidget {
  final List<RoutePoint> route;
  final LatLng startPoint;
  final bool showStartPoint;
  final Color primaryColor;
  final Color successColor;
  final Map<int, BitmapDescriptor> numberedMarkers;
  final Map<int, BitmapDescriptor> focusedMarkers;
  final int? focusedIndex;
  final void Function(LatLng, int) onPointTap;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(List<RoutePoint>, LatLng)? onSaved;
  final Widget Function(BuildContext, RoutePoint, int)? itemBuilder;

  const RouteResultBody({
    required this.route,
    required this.startPoint,
    required this.showStartPoint,
    required this.primaryColor,
    required this.successColor,
    required this.numberedMarkers,
    required this.focusedMarkers,
    required this.focusedIndex,
    required this.onPointTap,
    required this.onMapCreated,
    this.onSaved,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Container(
          color: Colors.grey[50],
          child: Column(
            children: [
              Expanded(
                child: !isLandscape ? _buildVertical() : _buildHorizontal(),
              ),
              SaveButton(
                color: successColor,
                onPressed: () => onSaved?.call(route, startPoint),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVertical() {
    return Column(
      children: [
        MapSection(
          heightFactor: 0.45,
          route: route,
          startPoint: startPoint,
          showStartPoint: showStartPoint,
          primaryColor: primaryColor,
          numberedMarkers: numberedMarkers,
          focusedMarkers: focusedMarkers,
          focusedIndex: focusedIndex,
          onPointTap: onPointTap,
          onMapCreated: onMapCreated,
        ),
        Expanded(
          child: RouteListSection(
            route: route,
            showStartPoint: showStartPoint,
            primaryColor: primaryColor,
            focusedIndex: focusedIndex,
            onPointTap: onPointTap,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontal() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RouteListSection(
            route: route,
            showStartPoint: showStartPoint,
            primaryColor: primaryColor,
            focusedIndex: focusedIndex,
            onPointTap: onPointTap,
            itemBuilder: itemBuilder,
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MapSection(
                route: route,
                startPoint: startPoint,
                showStartPoint: showStartPoint,
                primaryColor: primaryColor,
                numberedMarkers: numberedMarkers,
                focusedMarkers: focusedMarkers,
                focusedIndex: focusedIndex,
                onPointTap: onPointTap,
                onMapCreated: onMapCreated,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
