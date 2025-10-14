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

  @override
  void initState() {
    super.initState();
    spawnRandomTile(grid);
    spawnRandomTile(grid);
    spawnRandomTile(grid);
  }

  // restating the game
  void _resetGame() {
    setState(() {
      score = 0;
      grid = List.filled(16, 0);
      spawnRandomTile(grid);
      spawnRandomTile(grid);
      spawnRandomTile(grid);
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
            //  Score + Restart
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

            const SizedBox(height: 30),

            // 🎮 Movement Buttons
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      moveUp(grid, score);
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
                          moveRight(grid, score);
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
                      moveDown(grid, score);
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

