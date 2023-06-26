import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:water_colors/deps/utils.dart' as utils;
import 'package:water_colors/phys/physics.dart';

class WindPhysicsState extends State<StringPhysics>
    with TickerProviderStateMixin {
  late final Ticker ticker;
  final forge.World world = forge.World(vector.Vector2(0, 0)); // no gravity
  final List<List<forge.Body>> strings = [];
  late Size size = const Size(0, 0);

  final int gridWidth = 10;
  final int gridHeight = 10;
  late final windGrid = List.generate(
    gridWidth,
    (_) => List.generate(
      gridHeight,
      (_) => vector.Vector2.zero(),
    ),
  );

  vector.Vector2 wind = vector.Vector2.zero();

  List<vector.Vector2> getNeighbors(int i, int j) {
    final neighbors = <vector.Vector2>[];

    // Iterate over the cells in the neighborhood of the cell at (i, j)
    for (int di = -1; di <= 1; di++) {
      for (int dj = -1; dj <= 1; dj++) {
        // Skip the cell itself
        if (di == 0 && dj == 0) continue;

        final ni = i + di;
        final nj = j + dj;

        // Check if the neighbor is inside the grid
        if (ni >= 0 &&
            ni < windGrid.length &&
            nj >= 0 &&
            nj < windGrid[i].length) {
          neighbors.add(windGrid[ni][nj]);
        }
      }
    }

    return neighbors;
  }

  vector.Vector2 getAverageWind(List<vector.Vector2> neighbors) {
    if (neighbors.isEmpty) {
      return vector.Vector2.zero();
    }

    vector.Vector2 sum = vector.Vector2.zero();
    for (var neighbor in neighbors) {
      sum.add(neighbor);
    }

    return sum.scaled(1.0 / neighbors.length);
  }

  @override
  void initState() {
    super.initState();

    ticker = createTicker((delta) {
      // Update the wind vectors
      for (int i = 0; i < windGrid.length; i++) {
        for (int j = 0; j < windGrid[i].length; j++) {
          final neighbors = getNeighbors(i, j);
          final averageWind = getAverageWind(neighbors);

          // Adjust the wind cell's vector towards the average of its neighbors
          windGrid[i][j] = utils.vectorLerp(windGrid[i][j], averageWind, 0.05);

          // Add some randomness to simulate turbulence
          windGrid[i][j].add(vector.Vector2(math.Random().nextDouble() - 0.5,
              math.Random().nextDouble() - 0.5));
        }
      }

      // Apply the wind force to each string
      for (final stringGroup in strings) {
        for (final string in stringGroup) {
          // Find the closest grid cell to the string
          final int gridX =
              (string.position.x / size.width * gridWidth).toInt();
          final int gridY =
              (string.position.y / size.height * gridHeight).toInt();

          // Apply the wind force from that cell
          string.applyForce(windGrid[gridX % gridWidth][gridY % gridHeight]);
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
