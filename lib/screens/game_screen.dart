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

  // accumulate pan delta
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

  // --- Reset the game ---
  void _resetGame() {
    setState(() {
      score = 0;
      tiles.clear();
      _spawnRandomTile();
      _spawnRandomTile();
      _spawnRandomTile();
    });
  }

  void _handleSwipeDirection(DragDirection dir) {
    setState(() {
      List<int> grid = List.filled(16, 0);
      for (var tile in tiles) {
        grid[tile.row * 4 + tile.col] = tile.value;
      }

      //  Apply logic from logic.dart
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

      //  update existing tiles positions and merge 
      List<Tile> newTiles = [];
      for (var value in grid) {
        if (value == 0) continue;
        Tile? existing = tiles.firstWhere(
            (t) => t.value == value && !newTiles.contains(t),
            orElse: () => Tile(
                id: DateTime.now().microsecondsSinceEpoch + newTiles.length,
                value: value,
                row: 0,
                col: 0));
        // new position
        int index = grid.indexOf(value);
        final r = index ~/ 4;
        final c = index % 4;
        existing.row = r;
        existing.col = c;
        newTiles.add(existing);
        grid[index] = 0;
      }
      tiles = newTiles;

      _spawnRandomTile();

      if (score > bestScore) {
        bestScore = score;
        _saveBestScore(); 
      }
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
            // --- Score + Restart ---
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

                    // --- Actual Tiles (Animated) ---
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

            // --- Manual movement buttons ---
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
      ),
    );
  }
}

// small enum to improve readability
enum DragDirection { left, right, up, down }
