import 'package:flutter/foundation.dart';

class AppSettingsService {
  AppSettingsService._();

  static const int minWorkoutRestSeconds = 15;
  static const int maxWorkoutRestSeconds = 120;
  static const int defaultWorkoutRestSeconds = 45;

  static final ValueNotifier<int> workoutRestSeconds = ValueNotifier<int>(
    defaultWorkoutRestSeconds,
  );

  static void setWorkoutRestSeconds(int seconds) {
    workoutRestSeconds.value = seconds.clamp(
      minWorkoutRestSeconds,
      maxWorkoutRestSeconds,
    );
  }
}
