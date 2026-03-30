import 'package:flutter/material.dart';

import '../../../models/route_point.dart';

class RouteListItem extends StatelessWidget {
  final int index;
  final RoutePoint point;
  final Color color;
  final bool isFocused;
  final VoidCallback onTap;

  const RouteListItem({
    required this.index,
    required this.point,
    required this.color,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isFocused ? color.withOpacity(0.08) : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isFocused ? const Color(0xFFEF9F27) : color,
          radius: isFocused ? 18 : 16,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          point.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isFocused ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
