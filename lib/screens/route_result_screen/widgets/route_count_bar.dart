import 'package:flutter/material.dart';

import '../../../configs/manuel_route_builder_config.dart';

class RouteCountBar extends StatelessWidget {
  final int count;
  final bool showStartPointWarning;
  final Color color;

  const RouteCountBar({
    required this.count,
    required this.showStartPointWarning,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color.withOpacity(0.08),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${ManuelRouteBuilderConfig.l10n.pointsCount(count)}'
            '${showStartPointWarning ? ' · ${ManuelRouteBuilderConfig.l10n.startPointWarning}' : ''}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
