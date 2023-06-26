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
  final forge.World world = forge.World(vector.Vector2(0, 0)); // no gravity
  final List<forge.Body> strings = [];
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();

    const double stringWidth = 10.0;
    const double stringHeight = 50.0;

    ticker = createTicker((delta) {
      world.stepDt(delta.inSeconds.toDouble());
      setState(() {});
    });

    ticker.start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size!;
      final int rowCount = size.height ~/ stringHeight;
      final int columnCount = size.width ~/ stringWidth;

      for (int i = 0; i < rowCount; i++) {
        for (int j = 0; j < columnCount; j++) {
          final x = j * stringWidth * 2;
          final y = i * stringHeight * 2;

          final shape = forge.PolygonShape();
          shape.setAsBoxXY(stringWidth / 2, stringHeight / 2);

          final bodyDef = forge.BodyDef()
            ..type = forge.BodyType.dynamic
            ..position = vector.Vector2(x, y);

          final body = world.createBody(bodyDef);
          body.createFixtureFromShape(shape);

          strings.add(body);
        }
      }
    });
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
        final force = vector.Vector2(details.delta.dx, details.delta.dy);
        for (final string in strings) {
          string.applyForce(force);
        }
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
