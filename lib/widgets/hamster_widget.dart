import 'package:flutter/material.dart';
import '../models/fortune.dart';

class HamsterWidget extends StatelessWidget {
  final HamsterExpression expression;
  final double size;

  const HamsterWidget({super.key, required this.expression, this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual hamster images
    // For now, use colored circles as placeholders
    Color color;
    IconData icon;
    switch (expression) {
      case HamsterExpression.normal:
        color = Colors.grey;
        icon = Icons.pets;
        break;
      case HamsterExpression.smile:
        color = Colors.yellow;
        icon = Icons.sentiment_satisfied;
        break;
      case HamsterExpression.sparkle:
        color = Colors.pink;
        icon = Icons.star;
        break;
      case HamsterExpression.cheer:
        color = Colors.orange;
        icon = Icons.celebration;
        break;
      case HamsterExpression.worry:
        color = Colors.blue;
        icon = Icons.sentiment_dissatisfied;
        break;
      case HamsterExpression.proud:
        color = Colors.green;
        icon = Icons.emoji_events;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: size * 0.6),
    );
  }
}
