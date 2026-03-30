import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../enums/marker_style.dart';

class NumberedMarkerPainter {
  NumberedMarkerPainter._();

  static const _firstMarkerColor = Color(0xFF1D9E75);
  static const _lastMarkerColor = Color(0xFFE24B4A);
  static const _focusedMarkerColor = Color(0xFFEF9F27);

  static Future<BitmapDescriptor> create({
    required int number,
    required Color color,
    required MarkerStyle style,
  }) async {
    final double size = switch (style) {
      MarkerStyle.first || MarkerStyle.focused || MarkerStyle.lastFocused => 96,
      MarkerStyle.last => 88,
      MarkerStyle.normal => 80,
    };

    final double radius = switch (style) {
      MarkerStyle.first || MarkerStyle.focused || MarkerStyle.lastFocused => 32,
      MarkerStyle.last => 28,
      MarkerStyle.normal => 26,
    };

    final Color markerColor = switch (style) {
      MarkerStyle.first => _firstMarkerColor,
      MarkerStyle.last => _lastMarkerColor,
      MarkerStyle.focused || MarkerStyle.lastFocused => _focusedMarkerColor,
      MarkerStyle.normal => color,
    };

    final double cx = size / 2;
    final double cy = size / 2 - 8;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

    // Focus effect
    if (style == MarkerStyle.focused) {
      canvas.drawCircle(
        Offset(cx, cy),
        radius + 8,
        Paint()..color = markerColor.withValues(alpha: .2),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        radius + 4,
        Paint()..color = markerColor.withValues(alpha: .35),
      );
    }

    // Main Circle
    canvas.drawCircle(Offset(cx, cy), radius, Paint()..color = markerColor);

    // Last Marker — flag
    if (style == MarkerStyle.last || style == MarkerStyle.lastFocused) {
      final flagPaint = Paint()..color = Colors.redAccent;
      canvas.drawRect(
        Rect.fromLTWH(cx + radius - 10, cy - radius, 3, 14),
        flagPaint,
      );
      final flagPath = Path()
        ..moveTo(cx + radius - 7, cy - radius)
        ..lineTo(cx + radius + 6, cy - radius + 5)
        ..lineTo(cx + radius - 7, cy - radius + 10)
        ..close();
      canvas.drawPath(flagPath, flagPaint);
    }

    // Bottom triangle
    final triangle = Path()
      ..moveTo(cx - 8, cy + radius - 4)
      ..lineTo(cx + 8, cy + radius - 4)
      ..lineTo(cx, size - 4)
      ..close();
    canvas.drawPath(triangle, Paint()..color = markerColor);

    // Inner circle
    canvas.drawCircle(
        Offset(cx, cy), radius - 6, Paint()..color = Colors.white);

    // Number
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: markerColor,
          fontSize: number > 9 ? 16 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
}
