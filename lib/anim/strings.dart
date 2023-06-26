import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:water_colors/deps/utils.dart';
import 'package:forge2d/forge2d.dart' as forge;

class StringPainter extends CustomPainter {
  final forge.World world;
  final List<List<forge.Body>> strings;
  final Animation<Color?> colorsStart;
  final Animation<Color?> colorsEnd;
  final double stringWidth;
  final double stringHeight;

  StringPainter(
    this.world,
    this.strings, {
    required this.colorsStart,
    required this.colorsEnd,
    required this.stringWidth,
    required this.stringHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final string in strings) {
      for (int i = 0; i < string.length; i++) {
        final body = string[i];
        final position = body.position;

        double angle = 0;
        if (i < string.length - 1) {
          final nextBody = string[i + 1];
          final dx = nextBody.position.x - position.x;
          final dy = nextBody.position.y - position.y;
          angle = math.atan2(dy, dx) - math.pi / 2;
        }

        canvas.save();

        canvas.translate(position.x, position.y);
        canvas.rotate(angle);

        // Calculate the blend factor based on the vertical position of the string
        final t = position.y / size.height;

        // Interpolate between two colors based on the blend factor
        final color = lerp(colorsStart.value!, colorsEnd.value!, t);

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        // Create a path for a rectangle with rounded ends
        final curve = Radius.circular(stringWidth / 2);
        final path = Path()
          ..addRRect(RRect.fromRectAndCorners(
            Rect.fromLTWH(
                -stringWidth / 2, -stringHeight / 2, stringWidth, stringHeight),
            topRight: i == 0 ? curve : Radius.zero,
            topLeft: i == 0 ? curve : Radius.zero,
            bottomLeft: i == string.length - 1 ? curve : Radius.zero,
            bottomRight: i == string.length - 1 ? curve : Radius.zero,
          ));

        canvas.drawPath(path, paint);

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
