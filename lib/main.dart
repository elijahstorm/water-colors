import 'package:flutter/material.dart';
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
        backgroundColor: Colors.black87,
        body: InteractiveViewer(
          child: const StringPhysics(),
        ),
      ),
    );
  }
}
