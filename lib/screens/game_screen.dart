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
        // child: Text('Let’s build 2048!'),
        child: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          
        
        ),
      ),
    );
  }
}
