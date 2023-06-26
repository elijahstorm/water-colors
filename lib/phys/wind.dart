import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:water_colors/phys/physics.dart';

class WindPhysicsState extends State<StringPhysics>
    with TickerProviderStateMixin {
  late final Ticker ticker;
  final forge.World world = forge.World(vector.Vector2(0, 0)); // no gravity
  final List<List<forge.Body>> strings = [];

  vector.Vector2 wind = vector.Vector2.zero();

  @override
  void initState() {
    super.initState();

    ticker = createTicker((delta) {
      // Update the wind vector
      wind.x += (Random().nextDouble() - 0.5) *
          0.2; // Change 0.2 to adjust the strength of the wind
      wind.y += (Random().nextDouble() - 0.5) * 0.2;

      // Apply the wind force to each string
      for (final stringGroup in strings) {
        for (final string in stringGroup) {
          string.applyForce(wind);
        }
      }

      world.stepDt(delta.inSeconds.toDouble());
      setState(() {});
    });

    ticker.start();
  }

  @override
  void dispose() {
    ticker.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
