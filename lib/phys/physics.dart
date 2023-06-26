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
  final double radius = 20.0;
  final List<List<forge.Body>> strings = [];
  late final Ticker ticker;

  late final AnimationController colorController;
  late final Animation<Color?> colorStartSources;
  late final Animation<Color?> colorEndSources;

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

      for (int j = 0; j < columnCount; j++) {
        final stringBodies =
            <forge.Body>[]; // Create a new list for each string

        for (int i = 0; i < rowCount; i++) {
          final x = j * stringWidth * 2;
          final y = i * stringHeight * 2;

          final shape = forge.PolygonShape();
          shape.setAsBoxXY(stringWidth / 2, stringHeight / 2);

          final bodyDef = forge.BodyDef()
            ..type = forge.BodyType.dynamic
            ..position = vector.Vector2(x, y);

          final body = world.createBody(bodyDef);
          body.createFixtureFromShape(shape);

          // If this is not the first segment in the string, connect it to the previous segment with a DistanceJoint
          if (i > 0) {
            final prevBody = stringBodies.last;

            final jointDef = forge.DistanceJointDef()
              ..initialize(prevBody, body, prevBody.position, body.position);

            final joint = forge.DistanceJoint(
                jointDef); // Create a DistanceJoint from the DistanceJointDef

            world.createJoint(joint);
          }

          stringBodies.add(body);
        }

        strings.addAll([stringBodies]);
      }
    });

    colorController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    colorStartSources = ColorTween(
      begin: Colors.red,
      end: Colors.blue,
    ).animate(colorController);
    colorEndSources = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(colorController);
  }

  @override
  void dispose() {
    ticker.stop();
    colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final force = vector.Vector2(details.delta.dx, details.delta.dy);
        final inputPoint =
            vector.Vector2(details.localPosition.dx, details.localPosition.dy);

        for (final stringGroup in strings) {
          for (final string in stringGroup) {
            final stringPosition = string.position;
            final distance = (stringPosition - inputPoint).length;

            if (distance < radius) {
              string.applyForce(force);
            }
          }
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: StringPainter(
              world,
              strings,
              colorsStart: colorStartSources,
              colorsEnd: colorEndSources,
            ),
          );
        },
      ),
    );
  }
}
