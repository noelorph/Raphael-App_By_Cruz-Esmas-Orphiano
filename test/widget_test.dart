import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raphael/widgets/calorie_row.dart';

void main() {
  testWidgets('CalorieRow displays range and calories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CalorieRow(
            weightRange: '50 - 60 kg',
            calories: '1,600 - 1,900 kcal',
          ),
        ),
      ),
    );

    expect(find.text('50 - 60 kg'), findsOneWidget);
    expect(find.text('1,600 - 1,900 kcal'), findsOneWidget);
  });
}
