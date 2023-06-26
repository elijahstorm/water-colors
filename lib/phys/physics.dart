import 'package:flutter/material.dart';
import 'package:water_colors/anim/strings.dart';
import 'package:flutter/scheduler.dart';
import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math_64.dart' as vector;

class StringPhysics extends StatefulWidget {
  const StringPhysics({Key? key}) : super(key: key);

  @override
  StringPhysicsState createState() => StringPhysicsState();
}

class StringPhysicsState extends State<StringPhysics>
    with TickerProviderStateMixin {
  final forge.World world = forge.World(vector.Vector2(0, -10));
  final List<forge.Body> strings = [];
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker((delta) {
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
    return GestureDetector(
      onPanUpdate: (details) {
        // update the wind force based on the swipe direction and velocity
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: StringPainter(world, strings),
          );
        },
      ),
    );
  }
}
