import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/calorie_entry_model.dart';
import '../models/recommendation_model.dart';
import '../services/app_settings_service.dart';

const recommendationAccentColor = Color(0xFF35E8AE);

ButtonStyle recommendationPrimaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: recommendationAccentColor,
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

class RecommendationScreenHeader extends StatelessWidget {
  const RecommendationScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: isDark
                ? const Color(0xFF111212)
                : const Color(0xFFEAF4F0),
            foregroundColor: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommendations',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 4),
              Text(
                'Updated daily',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RecommendationSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const RecommendationSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: recommendationAccentColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class RecommendationSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RecommendationSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF050606) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF222323) : const Color(0xFFE1E7E5),
        ),
      ),
      child: child,
    );
  }
}

class FoodRecommendationCard extends StatelessWidget {
  final FoodRecommendation food;
  final VoidCallback onTap;

  const FoodRecommendationCard({
    super.key,
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return RecommendationSurfaceCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.eco_rounded,
          color: recommendationAccentColor,
        ),
        title: Text(
          food.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${food.description}\n${food.calories} kcal - ${food.proteinGrams}g protein',
          style: TextStyle(color: mutedColor),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class WorkoutRoutineCard extends StatelessWidget {
  final WorkoutRoutine workout;
  final bool isComplete;
  final VoidCallback onOpenRoutine;

  const WorkoutRoutineCard({
    super.key,
    required this.workout,
    this.isComplete = false,
    required this.onOpenRoutine,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return RecommendationSurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onOpenRoutine,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isComplete
                        ? recommendationAccentColor.withValues(alpha: 0.16)
                        : workout.color.withValues(alpha: 0.16),
                    child: Icon(
                      isComplete
                          ? Icons.check_circle_rounded
                          : Icons.play_arrow_rounded,
                      color: isComplete
                          ? recommendationAccentColor
                          : workout.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.focus,
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          workout.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isComplete)
                    const _RoutineMetaChip(
                      icon: Icons.check_rounded,
                      label: 'Done',
                    )
                  else
                    const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 14),
              Text(workout.description, style: TextStyle(color: mutedColor)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RoutineMetaChip(
                    icon: Icons.timer_outlined,
                    label: '${workout.totalMinutes} min',
                  ),
                  _RoutineMetaChip(
                    icon: Icons.fitness_center_rounded,
                    label: '${workout.exercises.length} exercises',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final exercise in workout.exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: workout.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${exercise.name}: ${exercise.sets} sets x ${exercise.secondsPerSet}s',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalorieTrackerCard extends StatelessWidget {
  final List<CalorieEntryModel> entries;
  final double? currentWeightKg;
  final TextEditingController manualCaloriesController;
  final Future<void> Function() onAddManualCalories;

  const CalorieTrackerCard({
    super.key,
    required this.entries,
    required this.currentWeightKg,
    required this.manualCaloriesController,
    required this.onAddManualCalories,
  });

  int get _takenCalories {
    return entries.fold(0, (total, entry) => total + entry.calories);
  }

  int get _goalCalories {
    final weight = currentWeightKg;
    if (weight == null || weight <= 0) return 2000;
    return (weight * 30).round().clamp(1200, 3600);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;
    final progress = (_takenCalories / _goalCalories).clamp(0.0, 1.0);
    final percent = (progress * 100).round().clamp(0, 100);

    return RecommendationSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentWeightKg == null
                          ? 'Goal uses a 2,000 kcal default until weight is set'
                          : 'Goal based on ${currentWeightKg!.toStringAsFixed(1)} kg',
                      style: TextStyle(color: mutedColor),
                    ),
                  ],
                ),
              ),
              Text(
                '$_takenCalories / $_goalCalories kcal',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              minHeight: 14,
              value: progress,
              backgroundColor: isDark
                  ? const Color(0xFF222323)
                  : const Color(0xFFE1E7E5),
              color: recommendationAccentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percent% of calorie goal',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: manualCaloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Add untracked calories',
                    suffixText: 'kcal',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: () => onAddManualCalories(),
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add calories',
              ),
            ],
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final entry in entries.reversed.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.label)),
                    Text(
                      '${entry.calories} kcal',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class NutritionGrid extends StatelessWidget {
  final FoodRecommendation food;

  const NutritionGrid({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NutritionTile(label: 'Calories', value: '${food.calories}'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: NutritionTile(
            label: 'Protein',
            value: '${food.proteinGrams}g',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: NutritionTile(label: 'Fiber', value: '${food.fiberGrams}g'),
        ),
      ],
    );
  }
}

class NutritionTile extends StatelessWidget {
  final String label;
  final String value;

  const NutritionTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111212) : const Color(0xFFEAF4F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class IconTextRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const IconTextRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class TimerSessionScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<TimerTask> tasks;
  final String completionTitle;
  final String completionMessage;
  final String completionActionLabel;
  final String checkpointTitle;
  final String checkpointMessage;
  final String checkpointActionLabel;
  final int restDurationSeconds;
  final Future<void> Function()? onCompleted;

  const TimerSessionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.completionTitle,
    required this.completionMessage,
    required this.completionActionLabel,
    this.checkpointTitle = 'Step complete',
    this.checkpointMessage = 'Start the next step when you are ready.',
    this.checkpointActionLabel = 'Start next',
    this.restDurationSeconds = 0,
    this.onCompleted,
  });

  @override
  State<TimerSessionScreen> createState() => _TimerSessionScreenState();
}

class _TimerSessionScreenState extends State<TimerSessionScreen> {
  Timer? _timer;
  int _taskIndex = 0;
  late int _remainingSeconds;
  bool _isRunning = false;
  bool _isComplete = false;
  bool _completionHandled = false;
  bool _isWaitingForNextTask = false;
  bool _isResting = false;
  int _restRemainingSeconds = 0;

  TimerTask get _currentTask => widget.tasks[_taskIndex];

  TimerTask? get _nextTask {
    final nextIndex = _taskIndex + 1;
    if (nextIndex >= widget.tasks.length) return null;
    return widget.tasks[nextIndex];
  }

  int get _totalSeconds {
    return widget.tasks.fold(0, (total, task) => total + task.seconds);
  }

  int get _completedSeconds {
    final completedTasks = widget.tasks
        .take(_taskIndex)
        .fold(0, (total, task) => total + task.seconds);
    final currentElapsed = _currentTask.seconds - _remainingSeconds;
    return completedTasks + currentElapsed;
  }

  double get _progress {
    if (_totalSeconds <= 0) return 1;
    return (_completedSeconds / _totalSeconds).clamp(0, 1);
  }

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.tasks.isEmpty ? 0 : widget.tasks.first.seconds;
    if (widget.tasks.isEmpty) {
      _isComplete = true;
    }
  }

  void _start() {
    if (_isComplete || _isRunning || widget.tasks.isEmpty) return;
    if (_isWaitingForNextTask) {
      _startNextTask();
      return;
    }
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _taskIndex = 0;
      _remainingSeconds = widget.tasks.isEmpty ? 0 : widget.tasks.first.seconds;
      _isRunning = false;
      _isComplete = false;
      _completionHandled = false;
      _isWaitingForNextTask = false;
      _isResting = false;
      _restRemainingSeconds = 0;
    });
  }

  void _tick() {
    if (_isResting) {
      _tickRest();
      return;
    }

    if (_remainingSeconds > 1) {
      setState(() => _remainingSeconds--);
      return;
    }

    if (_taskIndex < widget.tasks.length - 1) {
      _timer?.cancel();
      if (widget.restDurationSeconds > 0) {
        setState(() {
          _remainingSeconds = 0;
          _restRemainingSeconds = widget.restDurationSeconds;
          _isRunning = true;
          _isResting = true;
          _isWaitingForNextTask = false;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
        return;
      }

      setState(() {
        _remainingSeconds = 0;
        _isRunning = false;
        _isWaitingForNextTask = true;
      });
      _ring();
      return;
    }

    _finish();
  }

  void _tickRest() {
    if (_restRemainingSeconds > 1) {
      setState(() => _restRemainingSeconds--);
      return;
    }

    _timer?.cancel();
    setState(() {
      _restRemainingSeconds = 0;
      _isRunning = false;
      _isResting = false;
      _isWaitingForNextTask = true;
    });
    _ring();
  }

  void _startNextTask() {
    final nextTask = _nextTask;
    if (nextTask == null) return;
    _timer?.cancel();
    setState(() {
      _taskIndex++;
      _remainingSeconds = nextTask.seconds;
      _isWaitingForNextTask = false;
      _isResting = false;
      _restRemainingSeconds = 0;
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _finish() async {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
      _isComplete = true;
      _isWaitingForNextTask = false;
      _isResting = false;
      _restRemainingSeconds = 0;
    });
    await _ring();
    if (widget.onCompleted != null && !_completionHandled) {
      _completionHandled = true;
      await widget.onCompleted!();
    }
  }

  Future<void> _ring() async {
    await SystemSound.play(SystemSoundType.alert);
    await HapticFeedback.vibrate();
  }

  String _formatSeconds(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;
    const restColor = Color(0xFFE53E3E);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF111212)
                          : const Color(0xFFEAF4F0),
                      foregroundColor: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  Text(
                    '${((_progress * 100).round()).clamp(0, 100)}%',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: SizedBox.square(
                  dimension: 236,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 16,
                        backgroundColor: isDark
                            ? const Color(0xFF222323)
                            : const Color(0xFFE1E7E5),
                        color: _isResting
                            ? restColor
                            : recommendationAccentColor,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _isComplete
                                      ? 'Done'
                                      : _isResting
                                      ? _formatSeconds(_restRemainingSeconds)
                                      : _isWaitingForNextTask
                                      ? 'Are you ready?'
                                      : _formatSeconds(_remainingSeconds),
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isComplete
                                  ? widget.completionTitle
                                  : _isResting
                                  ? 'Rest before next set'
                                  : _isWaitingForNextTask
                                  ? widget.checkpointTitle
                                  : _currentTask.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: mutedColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = widget.tasks[index];
                    final isCurrent =
                        index == _taskIndex &&
                        !_isComplete &&
                        !_isWaitingForNextTask &&
                        !_isResting;
                    final isDone =
                        index < _taskIndex ||
                        _isComplete ||
                        ((_isWaitingForNextTask || _isResting) &&
                            index == _taskIndex);
                    return TimerTaskTile(
                      task: task,
                      isCurrent: isCurrent,
                      isDone: isDone,
                    );
                  },
                ),
              ),
              if (_isWaitingForNextTask && _nextTask != null) ...[
                TimerCheckpointPanel(
                  title: widget.checkpointTitle,
                  message: widget.checkpointMessage,
                  nextTask: _nextTask!,
                  actionLabel: widget.checkpointActionLabel,
                  onAction: _startNextTask,
                ),
                const SizedBox(height: 12),
              ],
              if (_isComplete) ...[
                CompletionPanel(
                  title: widget.completionTitle,
                  message: widget.completionMessage,
                  actionLabel: widget.completionActionLabel,
                  onAction: () => Navigator.pop(context, true),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _stop,
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Stop'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: recommendationPrimaryButtonStyle(),
                      onPressed: _isComplete
                          ? null
                          : (_isRunning ? _pause : _start),
                      icon: Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        _isRunning
                            ? 'Pause'
                            : _isWaitingForNextTask
                            ? widget.checkpointActionLabel
                            : _isResting
                            ? 'Resume rest'
                            : 'Start',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class WorkoutRoutineScreen extends StatefulWidget {
  final WorkoutRoutine workout;
  final Future<bool> Function(WorkoutExercise exercise) onStartExercise;
  final Future<void> Function()? onFinishRoutine;

  const WorkoutRoutineScreen({
    super.key,
    required this.workout,
    required this.onStartExercise,
    this.onFinishRoutine,
  });

  @override
  State<WorkoutRoutineScreen> createState() => _WorkoutRoutineScreenState();
}

class _WorkoutRoutineScreenState extends State<WorkoutRoutineScreen> {
  final Set<int> _completedExerciseIndexes = {};
  bool _isFinishingRoutine = false;

  int get _completedExerciseCount => _completedExerciseIndexes.length;

  bool get _isRoutineComplete {
    return widget.workout.exercises.isNotEmpty &&
        _completedExerciseCount >= widget.workout.exercises.length;
  }

  String get _exercisePickerTitle {
    if (_completedExerciseCount >= widget.workout.exercises.length) {
      return 'All Exercises Complete';
    }
    if (_completedExerciseCount == 0) return 'Choose First Exercise';
    return 'Choose ${_ordinal(_completedExerciseCount + 1)} Exercise';
  }

  String _ordinal(int value) {
    if (value % 100 >= 11 && value % 100 <= 13) return '${value}th';
    return switch (value % 10) {
      1 => '${value}st',
      2 => '${value}nd',
      3 => '${value}rd',
      _ => '${value}th',
    };
  }

  Future<void> _startExercise(int index, WorkoutExercise exercise) async {
    if (_completedExerciseIndexes.contains(index)) return;
    final completed = await widget.onStartExercise(exercise);
    if (!mounted || !completed) return;
    setState(() => _completedExerciseIndexes.add(index));
  }

  Future<void> _finishRoutine() async {
    if (!_isRoutineComplete || _isFinishingRoutine) return;
    setState(() => _isFinishingRoutine = true);
    await widget.onFinishRoutine?.call();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;
    final workout = widget.workout;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            Row(
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF111212)
                        : const Color(0xFFEAF4F0),
                    foregroundColor: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    workout.focus,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            RecommendationSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: workout.color.withValues(alpha: 0.16),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: workout.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${workout.totalMinutes} min total',
                              style: TextStyle(
                                color: mutedColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    workout.description,
                    style: TextStyle(color: mutedColor),
                  ),
                  if (_isRoutineComplete) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: recommendationPrimaryButtonStyle(),
                        onPressed: _isFinishingRoutine ? null : _finishRoutine,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          _isFinishingRoutine
                              ? 'Finishing...'
                              : 'Finish Routine',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const WorkoutRestTimerSettingsCard(),
            const SizedBox(height: 14),
            RecommendationSectionHeader(
              title: _exercisePickerTitle,
              icon: Icons.playlist_add_check_rounded,
            ),
            const SizedBox(height: 10),
            for (final entry in workout.exercises.asMap().entries)
              ExercisePickerTile(
                exercise: entry.value,
                isComplete: _completedExerciseIndexes.contains(entry.key),
                onStart: () => _startExercise(entry.key, entry.value),
              ),
          ],
        ),
      ),
    );
  }
}

class WorkoutRestTimerSettingsCard extends StatelessWidget {
  const WorkoutRestTimerSettingsCard({super.key});

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

    return RecommendationSurfaceCard(
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
                    color: recommendationAccentColor,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Rest Between Sets',
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
                'Set your rest before choosing the first exercise.',
                style: TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                min: AppSettingsService.minWorkoutRestSeconds.toDouble(),
                max: AppSettingsService.maxWorkoutRestSeconds.toDouble(),
                divisions: 7,
                label: _formatRestTime(restSeconds),
                value: restSeconds.toDouble(),
                onChanged: (value) {
                  final snappedSeconds = (value / 15).round() * 15;
                  AppSettingsService.setWorkoutRestSeconds(snappedSeconds);
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
    );
  }
}

class TimerCheckpointPanel extends StatelessWidget {
  final String title;
  final String message;
  final TimerTask nextTask;
  final String actionLabel;
  final VoidCallback onAction;

  const TimerCheckpointPanel({
    super.key,
    required this.title,
    required this.message,
    required this.nextTask,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return RecommendationSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.next_plan_rounded, color: mutedColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Next: ${nextTask.label}',
                  style: TextStyle(
                    color: mutedColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: recommendationPrimaryButtonStyle(),
              onPressed: onAction,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletionPanel extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const CompletionPanel({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return RecommendationSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: recommendationPrimaryButtonStyle(),
              onPressed: onAction,
              icon: const Icon(Icons.check_rounded),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerTaskTile extends StatelessWidget {
  final TimerTask task;
  final bool isCurrent;
  final bool isDone;

  const TimerTaskTile({
    super.key,
    required this.task,
    required this.isCurrent,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? recommendationAccentColor.withValues(alpha: 0.16)
            : isDark
            ? const Color(0xFF050606)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent
              ? recommendationAccentColor
              : isDark
              ? const Color(0xFF222323)
              : const Color(0xFFE1E7E5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.timer_outlined,
            color: isDone ? recommendationAccentColor : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            _formatSeconds(task.seconds),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (minutes == 0) return '${remaining}s';
    if (remaining == 0) return '${minutes}m';
    return '${minutes}m ${remaining}s';
  }
}

class ExercisePickerTile extends StatelessWidget {
  final WorkoutExercise exercise;
  final bool isComplete;
  final VoidCallback onStart;

  const ExercisePickerTile({
    super.key,
    required this.exercise,
    this.isComplete = false,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completeColor = isDark ? Colors.white54 : Colors.black45;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle_rounded : Icons.timer_outlined,
            size: 18,
            color: isComplete ? recommendationAccentColor : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${exercise.name}: ${exercise.sets} sets x ${exercise.secondsPerSet}s',
              style: TextStyle(
                color: isComplete ? completeColor : null,
                decoration: isComplete ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton.filledTonal(
            onPressed: isComplete ? null : onStart,
            icon: Icon(
              isComplete ? Icons.check_rounded : Icons.play_arrow_rounded,
            ),
            tooltip: isComplete ? 'Exercise complete' : 'Start exercise',
          ),
        ],
      ),
    );
  }
}

class _RoutineMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RoutineMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111212) : const Color(0xFFEAF4F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
