import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

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
            // 🧮 SCORE + RESTART BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Score: 0', // later we’ll make this dynamic
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Reset the game logic
                      print("retsart press");
                    },
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🟩 4x4 GRID
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true, // allows GridView inside Column
              padding: const EdgeInsets.all(32),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(16, (index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '', // later show tile value
                      style: TextStyle(
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

            // 🎮 MOVEMENT BUTTONS
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // move up
                  },
                  child: const Icon(Icons.arrow_upward),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // move left
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        // move right
                      },
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // move down
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
