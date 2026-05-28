import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/bmi_category.dart';
import '../models/weight_entry_model.dart';
import '../services/date_format_service.dart';
import '../services/measurement_service.dart';
import '../services/weight_tracker_service.dart';

class WeightTrackerController extends ChangeNotifier {
  WeightTrackerController({
    WeightTrackerService? weightTrackerService,
    DateFormatService? dateFormatService,
    MeasurementService? measurementService,
  }) : _weightTrackerService = weightTrackerService ?? WeightTrackerService(),
       _dateFormatService = dateFormatService ?? const DateFormatService(),
       _measurementService = measurementService ?? const MeasurementService();

  final WeightTrackerService _weightTrackerService;
  final DateFormatService _dateFormatService;
  final MeasurementService _measurementService;

  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  List<WeightEntryModel> entries = [];

  WeightEntryModel? get latestEntry {
    if (entries.isEmpty) return null;
    return entries.last;
  }

  BmiCategory get bmiCategory => BmiCategory.fromBmi(latestEntry?.bmi);

  String get bmiStatus => bmiCategory.label;

  Future<void> saveEntry() async {
    final weightText = weightController.text.trim();
    final heightText = heightController.text.trim();

    final weight = _measurementService.parsePositiveMeasurement(weightText);
    final height = _measurementService.parsePositiveMeasurement(heightText);
    if (weight == null || height == null) return;

    await _weightTrackerService.saveEntry(
      weight: weight,
      heightCentimeters: height,
    );
    await loadEntries();

    weightController.clear();
    notifyListeners();
  }

  Future<bool> updateLatestEntry({
    required String entryId,
    required String weightText,
    required String heightText,
  }) async {
    final trimmedWeight = weightText.trim();
    final trimmedHeight = heightText.trim();

    final weight = _measurementService.parsePositiveMeasurement(trimmedWeight);
    final height = _measurementService.parsePositiveMeasurement(trimmedHeight);
    if (weight == null || height == null) return false;

    final wasUpdated = await _weightTrackerService.updateLatestEntry(
      entryId: entryId,
      weight: weight,
      heightCentimeters: height,
    );

    if (!wasUpdated) return false;

    await loadEntries();
    heightController.text = height.toStringAsFixed(0);
    notifyListeners();
    return true;
  }

  Future<void> loadEntries() async {
    entries = await _weightTrackerService.loadEntries();
    notifyListeners();
  }

  Future<void> loadProfileHeight() async {
    if (heightController.text.trim().isNotEmpty) return;

    final height = await _weightTrackerService.loadProfileHeight();
    if (height == null || height <= 0) return;

    heightController.text = height.toStringAsFixed(0);
    notifyListeners();
  }

  List<WeightEntryModel> get chartEntries {
    if (entries.length <= 7) return entries;
    return entries.sublist(entries.length - 7);
  }

  List<FlSpot> get chartSpots {
    final visibleEntries = chartEntries;

    if (visibleEntries.length == 1) {
      return [
        FlSpot(0, visibleEntries.first.weight),
        FlSpot(1, visibleEntries.first.weight),
      ];
    }

    return [
      for (var i = 0; i < visibleEntries.length; i++)
        FlSpot(i.toDouble(), visibleEntries[i].weight),
    ];
  }

  List<String> get chartDates {
    return chartEntries
        .map((entry) => '${entry.date.month}/${entry.date.day}')
        .toList();
  }

  String get latestDate {
    final date = latestEntry?.date;
    if (date == null) return '--';

    return _dateFormatService.shortMonthDate(date);
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }
}
