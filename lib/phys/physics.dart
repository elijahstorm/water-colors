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
  late final Ticker ticker;
  final forge.World world = forge.World(vector.Vector2(0, 0)); // no gravity
  final List<List<forge.Body>> strings = [];
  final double radius = 20.0;
  final double stringWidth = 8.0;
  final double stringHeight = 30.0;
  final double borderBounds = 10.0;

  late final AnimationController colorController;
  late final Animation<Color?> colorStartSources;
  late final Animation<Color?> colorEndSources;

  @override
  void initState() {
    super.initState();

    ticker = createTicker((delta) {
      world.stepDt(delta.inSeconds.toDouble());
      setState(() {});
    });

    ticker.start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size!;
      final int columnCount = size.width ~/ stringWidth;
      const int rowCount = 10;

      for (int j = 0; j < columnCount; j++) {
        final stringBodies = <forge.Body>[];

        for (int i = 0; i < rowCount; i++) {
          final x = j * stringWidth;
          final y = i * stringHeight + 100;

          final shape = forge.PolygonShape();
          shape.setAsBoxXY(stringWidth / 2, stringHeight);

          final bodyDef = forge.BodyDef()
            ..type = forge.BodyType.dynamic
            ..position = vector.Vector2(x, y);

          final body = world.createBody(bodyDef);
          final fixtureDef = forge.FixtureDef(shape)..isSensor = true;
          body.createFixture(fixtureDef);

          // If this is not the first segment in the string, connect it to the previous segment with a DistanceJoint
          if (i > 0) {
            final prevBody = stringBodies.last;

            final jointDef = forge.DistanceJointDef()
              ..initialize(prevBody, body, prevBody.position, body.position);

            final joint = forge.DistanceJoint(jointDef);

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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = vector.Vector2(size.width / 2, size.height / 2);

        for (final string in strings) {
          for (final body in string) {
            final position = body.position;

            if (position.x < borderBounds ||
                position.y < borderBounds ||
                position.x > size.width - borderBounds ||
                position.y > size.height - borderBounds) {
              final force = (center - position).normalized() * 0.003;
              body.applyForce(force);
            }
          }
        }

        return GestureDetector(
          onPanUpdate: (details) {
            final force = vector.Vector2(details.delta.dx, details.delta.dy);
            final inputPoint = vector.Vector2(
                details.localPosition.dx, details.localPosition.dy);

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
                  stringHeight: stringHeight,
                  stringWidth: stringWidth,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
