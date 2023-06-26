import 'package:flutter/material.dart';
import 'package:water_colors/anim/strings.dart';
import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:water_colors/phys/physics.dart';

void main() {
  runApp(const WaterColors());
}

class WaterColors extends StatelessWidget {
  const WaterColors({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: InteractiveViewer(
          child: const StringPhysics(),
        ),
      ),
    );
  }
}
