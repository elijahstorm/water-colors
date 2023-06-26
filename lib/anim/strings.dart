import 'package:flutter/material.dart';
import 'package:water_colors/deps/utils.dart' as utils;
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
      for (int i = 0; i < string.length - 1; i++) {
        final body = string[i];
        final position = body.position;
        final nextBody = string[i + 1];
        final nextPosition = nextBody.position;

        // Calculate the mid-point between the current position and the next position
        final midPoint = utils.vectorLerp(position, nextPosition, 0.5);

        // Calculate the blend factor based on the vertical position of the string
        final t = position.y / size.height;

        // Interpolate between two colors based on the blend factor
        final color = utils.lerp(colorsStart.value!, colorsEnd.value!, t);

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stringWidth
          ..strokeCap = StrokeCap.round;

        final path = Path()
          ..moveTo(position.x, position.y)
          ..quadraticBezierTo(
            midPoint.x,
            midPoint.y,
            nextPosition.x,
            nextPosition.y,
          );

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
