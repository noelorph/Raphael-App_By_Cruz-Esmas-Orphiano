import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _formatRestTime(int seconds) {
    if (seconds < 60) return '$seconds seconds';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return minutes == 1 ? '1 minute' : '$minutes minutes';
    }
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF050606) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF222323)
                      : const Color(0xFFE1E7E5),
                ),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: AppSettingsService.workoutRestSeconds,
                builder: (context, restSeconds, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Color(0xFF35E8AE),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Workout rest timer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            _formatRestTime(restSeconds),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Runs after each completed set before the ready check.',
                        style: TextStyle(
                          color: mutedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        min: AppSettingsService.minWorkoutRestSeconds
                            .toDouble(),
                        max: AppSettingsService.maxWorkoutRestSeconds
                            .toDouble(),
                        divisions: 7,
                        label: _formatRestTime(restSeconds),
                        value: restSeconds.toDouble(),
                        onChanged: (value) {
                          final snappedSeconds = (value / 15).round() * 15;
                          AppSettingsService.setWorkoutRestSeconds(
                            snappedSeconds,
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '15 sec',
                            style: TextStyle(
                              color: mutedColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '2 min',
                            style: TextStyle(
                              color: mutedColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
