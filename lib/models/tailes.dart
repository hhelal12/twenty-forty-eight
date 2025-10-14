import 'package:flutter/material.dart';

Color getTileColor(int value) {
  switch (value) {
    case 2:
      return Colors.orange[100]!;
    case 4:
      return Colors.orange[200]!;
    case 8:
      return Colors.orange[300]!;
    case 16:
      return Colors.deepOrange[300]!;
    case 32:
      return Colors.deepOrange[400]!;
    case 64:
      return Colors.deepOrange[500]!;
    case 128:
      return Colors.amber[400]!;
    case 256:
      return Colors.amber[600]!;
    case 512:
      return Colors.amber[700]!;
    case 1024:
      return Colors.yellow[700]!;
    case 2048:
      return Colors.yellow[800]!;
    default:
      return Colors.grey[400]!; // For empty or unknown tiles
  }
}


Color getTextColor(int value) {
  if (value <= 4) {
    return const Color(0xFF776E65); 
  } else {
    return const Color(0xFFF9F6F2);
  }
}