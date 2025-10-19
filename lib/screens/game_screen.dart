import 'package:flutter/material.dart';
import 'package:twenty_forty_eight/logic/logic.dart';
import 'package:twenty_forty_eight/models/tailes.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int score = 0;
  List<int> grid = List.filled(16, 0);

  // accumulate pan delta
  double _panDx = 0.0;
  double _panDy = 0.0;

  @override
  void initState() {
    super.initState();
    spawnRandomTile(grid);
    spawnRandomTile(grid);
    spawnRandomTile(grid);
  }

  // Reset the game
  void _resetGame() {
    setState(() {
      score = 0;
      grid = List.filled(16, 0);
      spawnRandomTile(grid);
      spawnRandomTile(grid);
      spawnRandomTile(grid);
    });
  }

  // handle decided swipe direction
  void _handleSwipeDirection(DragDirection dir) {
    setState(() {
      switch (dir) {
        case DragDirection.left:
          score = moveLeft(grid, score);
          break;
        case DragDirection.right:
          score = moveRight(grid, score);
          break;
        case DragDirection.up:
          score = moveUp(grid, score);
          break;
        case DragDirection.down:
          score = moveDown(grid, score);
          break;
      }
      spawnRandomTile(grid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('2048 Flutter'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score + Restart Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4x4 Grid with improved swipe detection
            GestureDetector(
              // accumulate deltas while dragging
              onPanUpdate: (details) {
                _panDx += details.delta.dx;
                _panDy += details.delta.dy;
              },
              onPanEnd: (details) {
                // decide direction by comparing absolute deltas
                if (_panDx.abs() > _panDy.abs()) {
                  // horizontal swipe
                  if (_panDx > 0) {
                    _handleSwipeDirection(DragDirection.right);
                  } else {
                    _handleSwipeDirection(DragDirection.left);
                  }
                } else {
                  // vertical swipe
                  if (_panDy > 0) {
                    _handleSwipeDirection(DragDirection.down);
                  } else {
                    _handleSwipeDirection(DragDirection.up);
                  }
                }
                // reset
                _panDx = 0.0;
                _panDy = 0.0;
              },
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                padding: const EdgeInsets.all(32),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                // IMPORTANT: prevent GridView from intercepting vertical drags
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(16, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: getTileColor(grid[index]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        grid[index] == 0 ? '' : '${grid[index]}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(grid[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 30),

            // Movement Buttons (still available)
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      score = moveUp(grid, score);
                      spawnRandomTile(grid);
                    });
                  },
                  child: const Icon(Icons.arrow_upward),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          score = moveLeft(grid, score);
                          spawnRandomTile(grid);
                        });
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          score = moveRight(grid, score);
                          spawnRandomTile(grid);
                        });
                      },
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      score = moveDown(grid, score);
                      spawnRandomTile(grid);
                    });
                  },
                  child: const Icon(Icons.arrow_downward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// small enum to improve readability
enum DragDirection { left, right, up, down }
