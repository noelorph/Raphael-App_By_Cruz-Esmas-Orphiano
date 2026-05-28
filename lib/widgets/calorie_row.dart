import 'package:flutter/material.dart';

class CalorieRow extends StatelessWidget {
  final String weightRange;
  final String calories;

  const CalorieRow({
    super.key,
    required this.weightRange,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(weightRange, style: const TextStyle(fontSize: 14)),
          Text(
            calories,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF35E8AE),
            ),
          ),
        ],
      ),
    );
  }
}
