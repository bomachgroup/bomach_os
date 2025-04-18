import 'dart:math';

import 'package:flutter/material.dart';

int stringToSeed(String text) {
  // Simple approach: sum the character codes
  int seed = 0;
  for (int i = 0; i < text.length; i++) {
    seed += text.codeUnitAt(i);
  }
  return seed;
}

Color getRandomColorFromList(String? text) {
  final availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,

    // Adding 30 more distinct colors
    Colors.amber,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.yellow,
    Colors.blueGrey,
  ];

  Random? random;

  if (text != null) {
    final seed = stringToSeed(text);

    random = Random(seed);
  }

  final randomIndex = (random ?? Random()).nextInt(availableColors.length);

  return availableColors[randomIndex];
}
