import 'package:flutter/material.dart';
import 'package:water_colors/anim/strings.dart';
import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:water_colors/phys/wind.dart';

class StringPhysics extends StatefulWidget {
  const StringPhysics({Key? key}) : super(key: key);

  @override
  StringPhysicsState createState() => StringPhysicsState();
}

class StringPhysicsState extends WindPhysicsState {
  final double radius = 20.0;
  final double stringWidth = 8.0;
  final double stringHeight = 100.0;
  final double borderBounds = 10.0;
  final int stringJoints = 10;

  late final AnimationController colorController;
  late final Animation<Color?> colorStartSources;
  late final Animation<Color?> colorEndSources;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size!;
      final int columnCount = size.width ~/ (stringWidth * 5);
      final int rowCount = size.height ~/ (stringHeight);

      for (int j = 0; j < columnCount; j++) {
        for (int i = 0; i < rowCount; i++) {
          final stringBodies = <forge.Body>[];

          for (int k = 0; k < stringJoints; k++) {
            final x = (j + 1) * (stringWidth * 5) + (i * stringWidth * 2);
            final y = (i + 1) * (stringHeight * 0.8) +
                (k * (stringHeight / stringJoints));

            final shape = forge.PolygonShape();
            shape.setAsBoxXY(stringWidth, stringHeight / stringJoints);

            final bodyDef = forge.BodyDef()
              ..type = k == 0 ? forge.BodyType.static : forge.BodyType.dynamic
              ..position = vector.Vector2(x, y);

            final body = world.createBody(bodyDef);
            final fixtureDef = forge.FixtureDef(shape)..isSensor = true;
            body.createFixture(fixtureDef);

            // If this is not the first segment in the string, connect it to the previous segment with a DistanceJoint
            if (k > 0) {
              final prevBody = stringBodies[k - 1];

              final jointDef = forge.DistanceJointDef()
                ..initialize(prevBody, body, prevBody.position, body.position)
                ..dampingRatio = 0.9
                ..frequencyHz = 15.0;

              final joint = forge.DistanceJoint(jointDef);

              world.createJoint(joint);
            }

            stringBodies.add(body);
          }

          strings.addAll([stringBodies]);
        }
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
