import 'package:flutter/services.dart';

/// Validation and formatting helpers for height/weight entry fields.
class MeasurementService {
  const MeasurementService();

  static final RegExp _completeMeasurementPattern = RegExp(
    r'^\d{1,3}(\.\d{1,2})?$',
  );
  static final RegExp _partialMeasurementPattern = RegExp(
    r'^\d{0,3}(\.\d{0,2})?$',
  );

  static final TextInputFormatter inputFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        return _partialMeasurementPattern.hasMatch(newValue.text)
            ? newValue
            : oldValue;
      });

  bool hasValidMeasurementInput(String value) {
    return _completeMeasurementPattern.hasMatch(value.trim());
  }

  double? parsePositiveMeasurement(String value) {
    if (!hasValidMeasurementInput(value)) return null;

    final measurement = double.tryParse(value.trim());
    if (measurement == null || measurement <= 0) return null;

    return measurement;
  }

  String trimTrailingZeros(double value) {
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
