import 'package:flutter/material.dart';

import '../models/calorie_entry_model.dart';
import '../models/recommendation_model.dart';
import '../models/user_model.dart';
import '../services/app_settings_service.dart';
import '../services/auth_service.dart';
import '../services/calorie_tracker_service.dart';
import '../widgets/recommendation_widgets.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final AuthService _authService = AuthService();
  final CalorieTrackerService _calorieTrackerService = CalorieTrackerService();
  final TextEditingController _manualCaloriesController =
      TextEditingController();
  final Set<String> _completedWorkoutKeys = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;
    final foods = _dailyFoods;
    final workouts = _dailyWorkouts;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6FAF8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
          children: [
            const RecommendationScreenHeader(),
            const SizedBox(height: 26),
            const RecommendationSectionHeader(
              title: 'Healthy Food Picks',
              icon: Icons.restaurant_rounded,
            ),
            const SizedBox(height: 10),
            for (final food in foods)
              FoodRecommendationCard(
                food: food,
                onTap: () => _showFoodDetails(food),
              ),
            const SizedBox(height: 24),
            const RecommendationSectionHeader(
              title: "Today's Calorie Intake",
              icon: Icons.calculate_rounded,
            ),
            const SizedBox(height: 10),
            StreamBuilder<UserModel?>(
              stream: _authService.currentUserProfileStream(),
              builder: (context, snapshot) {
                return StreamBuilder<List<CalorieEntryModel>>(
                  stream: _calorieTrackerService.todayEntriesStream(),
                  builder: (context, entriesSnapshot) {
                    return CalorieTrackerCard(
                      entries: entriesSnapshot.data ?? const [],
                      currentWeightKg: snapshot.data?.weightKilograms,
                      manualCaloriesController: _manualCaloriesController,
                      onAddManualCalories: _addManualCalories,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const RecommendationSectionHeader(
              title: 'Workout Routines',
              icon: Icons.fitness_center_rounded,
            ),
            const SizedBox(height: 10),
            for (final workout in workouts)
              WorkoutRoutineCard(
                workout: workout,
                isComplete: _completedWorkoutKeys.contains(
                  _workoutKey(workout),
                ),
                onOpenRoutine: () => _openWorkoutRoutine(workout),
              ),
            Text(
              'Recommendations are general wellness guidance.',
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FoodRecommendation> get _dailyFoods {
    return _dailyRotation(recommendedFoods, 3);
  }

  List<WorkoutRoutine> get _dailyWorkouts {
    return _dailyRotation(recommendedWorkouts, 3);
  }

  List<T> _dailyRotation<T>(List<T> items, int count) {
    if (items.isEmpty) return const [];
    final visibleCount = count > items.length ? items.length : count;
    final startIndex = _dailyRotationIndex(items.length);
    return List.generate(
      visibleCount,
      (index) => items[(startIndex + index) % items.length],
    );
  }

  int _dailyRotationIndex(int itemCount) {
    final now = DateTime.now();
    final dayNumber = now.difference(DateTime(now.year, 1, 1)).inDays;
    return dayNumber % itemCount;
  }

  String _workoutKey(WorkoutRoutine workout) {
    return '${workout.focus}:${workout.title}';
  }

  Future<void> _addManualCalories() async {
    final calories = int.tryParse(_manualCaloriesController.text.trim());
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid calorie amount.')),
      );
      return;
    }

    await _addCalories('Manual food entry', calories);
    _manualCaloriesController.clear();
  }

  Future<void> _addCalories(String label, int calories) async {
    await _calorieTrackerService.addEntry(label: label, calories: calories);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$calories kcal added to today.')));
  }

  void _showFoodDetails(FoodRecommendation food) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final mutedColor = isDark ? Colors.white60 : Colors.black54;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${food.cookTimeMinutes} minutes total',
                  style: TextStyle(
                    color: mutedColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                NutritionGrid(food: food),
                const SizedBox(height: 18),
                const Text(
                  'Health Benefits',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                for (final benefit in food.healthBenefits)
                  IconTextRow(icon: Icons.favorite_rounded, label: benefit),
                const SizedBox(height: 18),
                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                for (final ingredient in food.ingredients)
                  IconTextRow(icon: Icons.check_rounded, label: ingredient),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: recommendationPrimaryButtonStyle(),
                    onPressed: () {
                      Navigator.pop(context);
                      _openFoodTimer(food);
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Cooking'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openFoodTimer(FoodRecommendation food) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TimerSessionScreen(
          title: food.title,
          subtitle: 'Cooking timer',
          tasks: food.cookingTasks,
          completionTitle: 'Food finished',
          completionMessage: 'Add ${food.calories} kcal to today?',
          completionActionLabel: 'Add calories',
          checkpointTitle: 'Cooking step finished',
          checkpointMessage:
              'Check your food, then start the next cooking step when ready.',
          checkpointActionLabel: 'Start next step',
        ),
      ),
    );

    if (completed == true && mounted) {
      await _addCalories(food.title, food.calories);
    }
  }

  Future<void> _openWorkoutRoutine(WorkoutRoutine workout) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => WorkoutRoutineScreen(
          workout: workout,
          onStartExercise: (exercise) => _openWorkoutTimer(workout, exercise),
          onFinishRoutine: () =>
              _authService.addReward('${workout.focus} Finisher'),
        ),
      ),
    );

    if (!mounted || completed != true) return;
    setState(() => _completedWorkoutKeys.add(_workoutKey(workout)));
  }

  Future<bool> _openWorkoutTimer(
    WorkoutRoutine workout,
    WorkoutExercise exercise,
  ) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TimerSessionScreen(
          title: exercise.name,
          subtitle: '${workout.focus} - ${exercise.sets} sets',
          tasks: exercise.timerTasks,
          completionTitle: 'Exercise complete',
          completionMessage: 'Nice work. Choose another exercise when ready.',
          completionActionLabel: 'Done',
          checkpointTitle: 'Set finished',
          checkpointMessage:
              'Rest is complete. Start the next set when you are ready.',
          checkpointActionLabel: 'Start next set',
          restDurationSeconds: AppSettingsService.workoutRestSeconds.value,
        ),
      ),
    );
    return completed == true;
  }

  @override
  void dispose() {
    _manualCaloriesController.dispose();
    super.dispose();
  }
}
