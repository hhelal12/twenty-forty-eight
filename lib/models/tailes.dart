import 'package:flutter/material.dart';

class Tile {
  final int id; // unique tile identity
  int value;
  int row;
  int col;

  Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
  });
}

// optional helper for colors
Color getTileColor(int value) {
  switch (value) {
    case 2:
      return Colors.orange[100]!;
    case 4:
      return Colors.orange[200]!;
    case 8:
      return Colors.orange[300]!;
    case 16:
      return Colors.orange[400]!;
    case 32:
      return Colors.orange[500]!;
    case 64:
      return Colors.orange[600]!;
    case 128:
      return Colors.orange[700]!;
    case 256:
      return Colors.orange[800]!;
    case 512:
    case 1024:
    case 2048:
      return Colors.deepOrange;
    default:
      return Colors.grey[400]!;
  }
}

Color getTextColor(int value) {
  return value <= 4 ? Colors.black : Colors.white;
}
