import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

Color lerp(Color a, Color b, double t) {
  return Color.lerp(a, b, t)!;
}

vector.Vector2 vectorLerp(vector.Vector2 a, vector.Vector2 b, double t) {
  return a * (1.0 - t) + b * t;
}
