import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart' as forge;
import 'package:water_colors/deps/utils.dart';

class StringPainter extends CustomPainter {
  final forge.World world;
  final List<forge.Body> strings;
  final Animation<Color?> colorsStart;
  final Animation<Color?> colorsEnd;

  StringPainter(
    this.world,
    this.strings, {
    required this.colorsStart,
    required this.colorsEnd,
  });

  final double stringWidth = 8.0;
  final double stringHeight = 80.0;

  @override
  void paint(Canvas canvas, Size size) {
    for (final string in strings) {
      final position = string.position;
      final rect = Rect.fromLTWH(
        position.x - stringWidth / 2,
        position.y - stringHeight / 2,
        stringWidth,
        stringHeight,
      );

      // Calculate the blend factor based on the vertical position of the string
      final t = position.y / size.height;

      // Interpolate between two colors based on the blend factor
      final color = lerp(colorsStart.value!, colorsEnd.value!, t);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Create a path for a rectangle with rounded ends
      final path = Path()
        ..addRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(stringWidth / 2)));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
