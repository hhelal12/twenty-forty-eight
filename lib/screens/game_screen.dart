import 'package:flutter/material.dart';
import 'dart:math';
import 'package:twenty_forty_eight/logic/logic.dart';
import 'package:twenty_forty_eight/models/tailes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int score = 0;
  int bestScore = 0; 
  List<Tile> tiles = [];
  final Random _random = Random();
  bool gameOver = false; 
  double _panDx = 0.0;
  double _panDy = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBestScore(); 
    _spawnRandomTile();
    _spawnRandomTile();
    _spawnRandomTile();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore', bestScore);
  }

  // Spawn a random tile 
  void _spawnRandomTile() {
    List<int> emptyIndices = [];
    for (int i = 0; i < 16; i++) {
      final r = i ~/ 4;
      final c = i % 4;
      if (tiles.every((t) => t.row != r || t.col != c)) {
        emptyIndices.add(i);
      }
    }
    if (emptyIndices.isNotEmpty) {
      int i = emptyIndices[_random.nextInt(emptyIndices.length)];
      final r = i ~/ 4;
      final c = i % 4;
      tiles.add(Tile(
        id: DateTime.now().microsecondsSinceEpoch + i,
        value: _random.nextInt(10) == 0 ? 4 : 2,
        row: r,
        col: c,
      ));
    }
  }

  void _resetGame() {
    setState(() {
      score = 0;
      gameOver = false; 
      tiles.clear();
      _spawnRandomTile();
      _spawnRandomTile();
      _spawnRandomTile();
    });
  }

  void _handleSwipeDirection(DragDirection dir) {
    if (gameOver) return; // ignore input if game over
    setState(() {
      List<int> grid = List.filled(16, 0);
      for (var tile in tiles) {
        grid[tile.row * 4 + tile.col] = tile.value;
      }

      //  applayinglogic from logic.dart
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

      // --- NEW: try to update existing tiles positions instead of recreating them
      // Greedy nearest-match: for each occupied target cell, try to find the closest old tile with the same value.
      List<Tile> oldTiles = List.from(tiles); // copy of previous tiles
      List<bool> usedOld = List<bool>.filled(oldTiles.length, false);
      List<Tile> updatedTiles = [];

      for (int i = 0; i < 16; i++) {
        if (grid[i] != 0) {
          final r = i ~/ 4;
          final c = i % 4;
          int targetValue = grid[i];

          // find closest unused old tile with same value
          int bestIndex = -1;
          int bestDist = 1 << 30;
          for (int j = 0; j < oldTiles.length; j++) {
            if (usedOld[j]) continue;
            final ot = oldTiles[j];
            if (ot.value != targetValue) continue;
            final dist = (ot.row - r).abs() + (ot.col - c).abs();
            if (dist < bestDist) {
              bestDist = dist;
              bestIndex = j;
            }
          }

          if (bestIndex != -1) {
            // reuse existing tile: update its coords and mark used
            Tile reused = oldTiles[bestIndex];
            reused.row = r;
            reused.col = c;
            usedOld[bestIndex] = true;
            updatedTiles.add(reused);
          } else {
            // no matching previous tile — probably result of merge or brand-new value
            // create a new tile (it will appear at target position)
            updatedTiles.add(Tile(
              id: DateTime.now().microsecondsSinceEpoch + i,
              value: targetValue,
              row: r,
              col: c,
            ));
          }
        }
      }

      // tiles that were not reused likely merged into others — they can be dropped
      tiles = updatedTiles;

      _spawnRandomTile();

      // update best score
      if (score > bestScore) {
        bestScore = score;
        _saveBestScore(); 
      }

      // Check Game Over 
      if (isGameOver(grid)) {
        gameOver = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('2048 Flutter'), centerTitle: true),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score + Restart 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Display both score and best score
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Score: $score',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('Best: $bestScore',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)),
                        ],
                      ),
                      ElevatedButton(onPressed: _resetGame, child: const Text('Restart')),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- Board & swipe area ---
                GestureDetector(
                  onPanUpdate: (details) {
                    _panDx += details.delta.dx;
                    _panDy += details.delta.dy;
                  },
                  onPanEnd: (details) {
                    if (_panDx.abs() > _panDy.abs()) {
                      if (_panDx > 0) {
                        _handleSwipeDirection(DragDirection.right);
                      } else {
                        _handleSwipeDirection(DragDirection.left);
                      }
                    } else {
                      if (_panDy > 0) {
                        _handleSwipeDirection(DragDirection.down);
                      } else {
                        _handleSwipeDirection(DragDirection.up);
                      }
                    }
                    _panDx = 0.0;
                    _panDy = 0.0;
                  },

                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      children: [
                        // --- Background Grid ---
                        ...List.generate(16, (i) {
                          final r = i ~/ 4;
                          final c = i % 4;
                          return Positioned(
                            left: c * 78,
                            top: r * 78,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[400]!, width: 1),
                              ),
                            ),
                          );
                        }),

                        // Actual Tiles 
                        ...tiles.map((tile) {
                          return AnimatedPositioned(
                            key: ValueKey(tile.id),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            left: tile.col * 78,
                            top: tile.row * 78,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: getTileColor(tile.value),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${tile.value}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: getTextColor(tile.value),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Manual movement buttons
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _handleSwipeDirection(DragDirection.up),
                      child: const Icon(Icons.arrow_upward),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _handleSwipeDirection(DragDirection.left),
                          child: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _handleSwipeDirection(DragDirection.right),
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _handleSwipeDirection(DragDirection.down),
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
              ],
            ),

            // Game Over
            if (gameOver)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: const Text(
                          'Restart',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// small enum to improve readability 
enum DragDirection { left, right, up, down }
