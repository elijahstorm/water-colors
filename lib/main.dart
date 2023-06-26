import 'package:flutter/material.dart';
import 'package:water_colors/anim/strings.dart';
import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:water_colors/phys/physics.dart';

void main() {
  runApp(const WaterColors());
}

class WaterColors extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: InteractiveViewer(
          child: GestureDetector(
            onPanUpdate: (details) {
              // update the wind force based on the swipe direction and velocity
            },
            child: const StringPhysics(),
          ),
        ),
      ),
    );
  }
}
