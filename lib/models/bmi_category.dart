import 'package:flutter/material.dart';

/// The standard BMI ranges used throughout the app.
///
/// Keeping the display label, colors, and suggestions together prevents the
/// screens and services from drifting into slightly different interpretations.
enum BmiCategory {
  unknown('--'),
  underweight('Underweight'),
  normal('Normal'),
  overweight('Overweight'),
  obese('Obese');

  const BmiCategory(this.label);

  final String label;

  static BmiCategory fromBmi(double? bmi) {
    if (bmi == null || bmi <= 0) return BmiCategory.unknown;
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25) return BmiCategory.normal;
    if (bmi < 30) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  String get insightLabel {
    return this == BmiCategory.unknown ? 'Unknown' : label;
  }

  String get progressSuggestion {
    switch (this) {
      case BmiCategory.underweight:
        return 'Try adding one protein-rich meal or snack today and keep strength training light but consistent.';
      case BmiCategory.normal:
        return 'Keep the balance going with steady meals, hydration, and a short movement goal today.';
      case BmiCategory.overweight:
      case BmiCategory.obese:
        return 'Aim for one gentle walk, mindful portions, and another check-in this week without rushing the process.';
      case BmiCategory.unknown:
        return 'Log your weight and height when you can so I can personalize your next step better.';
    }
  }

  Color backgroundColor({required bool isDark}) {
    switch (this) {
      case BmiCategory.underweight:
        return isDark ? const Color(0xFF3B3212) : const Color(0xFFFFF1BF);
      case BmiCategory.normal:
        return isDark ? const Color(0xFF1E3A34) : const Color(0xFFDDF8EA);
      case BmiCategory.overweight:
        return isDark ? const Color(0xFF3B2615) : const Color(0xFFFFE0C2);
      case BmiCategory.obese:
        return isDark ? const Color(0xFF3A171B) : const Color(0xFFFFD4DB);
      case BmiCategory.unknown:
        return isDark ? const Color(0xFF252626) : const Color(0xFFEDEDED);
    }
  }

  Color foregroundColor({required bool isDark}) {
    switch (this) {
      case BmiCategory.underweight:
        return isDark ? const Color(0xFFFFD76A) : const Color(0xFF6B4E00);
      case BmiCategory.normal:
        return isDark ? const Color(0xFF7CFFD0) : Colors.black87;
      case BmiCategory.overweight:
        return isDark ? const Color(0xFFFFB56F) : const Color(0xFF7A3D00);
      case BmiCategory.obese:
        return isDark ? const Color(0xFFFF8B9A) : const Color(0xFF8B1E2D);
      case BmiCategory.unknown:
        return isDark ? Colors.white70 : Colors.black54;
    }
  }
}
