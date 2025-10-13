import 'package:flutter/material.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int score = 0;
  List<int> grid = List.filled(16, 0);
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _spawnRandomTile();
    _spawnRandomTile();
  }

  // Spawn a new tile with 2 in an empty cell
  void _spawnRandomTile() {
    List<int> emptyIndices = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == 0) emptyIndices.add(i);
    }
    if (emptyIndices.isNotEmpty) {
      int randomIndex = emptyIndices[random.nextInt(emptyIndices.length)];
      grid[randomIndex] = 2;
    }
  }

  // Reset the game
  void _resetGame() {
    setState(() {
      score = 0;
      grid = List.filled(16, 0);
      _spawnRandomTile();
      _spawnRandomTile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('2048 Flutter'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🧮 Score + Restart
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

            // 🟩 4x4 Grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              padding: const EdgeInsets.all(32),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(16, (index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      grid[index] == 0 ? '' : '${grid[index]}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // 🎮 Movement Buttons (dummy for now)
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      score++;
                      _spawnRandomTile(); // temporary: add a new tile
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
                          score++;
                          _spawnRandomTile();
                        });
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          score++;
                          _spawnRandomTile();
                        });
                      },
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      score++;
                      _spawnRandomTile();
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

