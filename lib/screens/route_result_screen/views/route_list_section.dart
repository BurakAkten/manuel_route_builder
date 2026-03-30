import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/route_point.dart';
import '../widgets/route_count_bar.dart';
import '../widgets/route_list_item.dart';

class RouteListSection extends StatelessWidget {
  final List<RoutePoint> route;
  final bool showStartPoint;
  final Color primaryColor;
  final int? focusedIndex;
  final void Function(LatLng, int) onPointTap;
  final Widget Function(BuildContext, RoutePoint, int)? itemBuilder;

  const RouteListSection({
    required this.route,
    required this.showStartPoint,
    required this.primaryColor,
    required this.focusedIndex,
    required this.onPointTap,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RouteCountBar(
          count: route.length,
          showStartPointWarning: !showStartPoint,
          color: primaryColor,
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: route.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final point = route[i];
              if (itemBuilder != null) return itemBuilder!(ctx, point, i);
              return RouteListItem(
                index: i,
                point: point,
                color: primaryColor,
                isFocused: focusedIndex == i,
                onTap: () => onPointTap(point.location, i),
              );
            },
          ),
        ),
      ],
    );
  }
}
