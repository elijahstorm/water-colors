import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart' as forge;

class StringPainter extends CustomPainter {
  final forge.World world;
  final List<forge.Body> strings;

  StringPainter(this.world, this.strings);
  final double stringWidth = 10;
  final double stringHeight = 50;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final string in strings) {
      final position = string.position;
      final rect = Rect.fromLTWH(
        position.x - stringWidth / 2,
        position.y - stringHeight / 2,
        stringWidth,
        stringHeight,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
