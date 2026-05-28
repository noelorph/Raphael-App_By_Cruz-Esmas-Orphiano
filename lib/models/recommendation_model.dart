import 'package:flutter/material.dart';

class TimerTask {
  final String label;
  final int seconds;

  const TimerTask({required this.label, required this.seconds});
}

class FoodRecommendation {
  final String title;
  final String description;
  final int cookTimeMinutes;
  final int calories;
  final int proteinGrams;
  final int fiberGrams;
  final List<String> ingredients;
  final List<String> healthBenefits;
  final List<TimerTask> cookingTasks;

  const FoodRecommendation({
    required this.title,
    required this.description,
    required this.cookTimeMinutes,
    required this.calories,
    required this.proteinGrams,
    required this.fiberGrams,
    required this.ingredients,
    required this.healthBenefits,
    required this.cookingTasks,
  });
}

class WorkoutRoutine {
  final String focus;
  final String title;
  final String description;
  final Color color;
  final List<WorkoutExercise> exercises;

  const WorkoutRoutine({
    required this.focus,
    required this.title,
    required this.description,
    required this.color,
    required this.exercises,
  });

  int get totalSeconds {
    return exercises.fold(
      0,
      (total, exercise) => total + exercise.sets * exercise.secondsPerSet,
    );
  }

  int get totalMinutes => (totalSeconds / 60).ceil();
}

class WorkoutExercise {
  final String name;
  final int sets;
  final int secondsPerSet;

  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.secondsPerSet,
  });

  List<TimerTask> get timerTasks {
    return List.generate(
      sets,
      (index) =>
          TimerTask(label: '$name - Set ${index + 1}', seconds: secondsPerSet),
    );
  }
}

const List<FoodRecommendation> recommendedFoods = [
  FoodRecommendation(
    title: 'Avocado Egg Toast',
    description: 'Fiber, healthy fats, and protein for steady energy.',
    cookTimeMinutes: 12,
    calories: 420,
    proteinGrams: 20,
    fiberGrams: 11,
    ingredients: [
      '2 slices whole-grain bread',
      '1 ripe avocado',
      '2 eggs',
      'Cherry tomatoes',
      'Lemon juice, salt, and pepper',
    ],
    healthBenefits: [
      'Healthy fats support fullness and heart health.',
      'Eggs add complete protein for muscle repair.',
      'Whole grains and avocado provide steady fiber.',
    ],
    cookingTasks: [
      TimerTask(label: 'Toast whole-grain bread', seconds: 180),
      TimerTask(label: 'Cook eggs', seconds: 300),
      TimerTask(label: 'Assemble and season', seconds: 120),
    ],
  ),
  FoodRecommendation(
    title: 'Salmon Quinoa Bowl',
    description: 'Lean protein with omega-3 fats and complex carbs.',
    cookTimeMinutes: 28,
    calories: 610,
    proteinGrams: 39,
    fiberGrams: 8,
    ingredients: [
      '120 g salmon fillet',
      '1 cup cooked quinoa',
      'Cucumber and spinach',
      'Greek yogurt sauce',
      'Olive oil and lemon',
    ],
    healthBenefits: [
      'Omega-3 fats support brain and heart health.',
      'Quinoa adds slow-digesting carbs and minerals.',
      'Greens contribute potassium, folate, and hydration.',
    ],
    cookingTasks: [
      TimerTask(label: 'Cook quinoa', seconds: 900),
      TimerTask(label: 'Sear salmon', seconds: 480),
      TimerTask(label: 'Rest salmon and assemble bowl', seconds: 300),
    ],
  ),
  FoodRecommendation(
    title: 'Chicken Veggie Stir Fry',
    description: 'Quick high-protein meal with colorful vegetables.',
    cookTimeMinutes: 22,
    calories: 540,
    proteinGrams: 43,
    fiberGrams: 9,
    ingredients: [
      '150 g chicken breast',
      'Broccoli and bell pepper',
      'Carrots',
      'Garlic and low-sodium soy sauce',
      'Brown rice',
    ],
    healthBenefits: [
      'Lean protein helps recovery and satiety.',
      'Colorful vegetables add antioxidants and fiber.',
      'Brown rice provides longer-lasting workout fuel.',
    ],
    cookingTasks: [
      TimerTask(label: 'Cook brown rice', seconds: 1080),
      TimerTask(label: 'Cook chicken pieces', seconds: 420),
      TimerTask(label: 'Stir fry vegetables', seconds: 300),
    ],
  ),
  FoodRecommendation(
    title: 'Tuna Sweet Potato Plate',
    description: 'Simple lean protein with potassium-rich carbs.',
    cookTimeMinutes: 24,
    calories: 500,
    proteinGrams: 36,
    fiberGrams: 10,
    ingredients: [
      '1 medium sweet potato',
      '1 can tuna in water',
      'Steamed green beans',
      'Greek yogurt or light mayo',
      'Paprika and lemon',
    ],
    healthBenefits: [
      'Tuna adds lean protein for muscle maintenance.',
      'Sweet potato supports training energy and potassium intake.',
      'Green beans add fiber without feeling heavy.',
    ],
    cookingTasks: [
      TimerTask(label: 'Bake or microwave sweet potato', seconds: 900),
      TimerTask(label: 'Steam green beans', seconds: 360),
      TimerTask(label: 'Mix tuna and plate meal', seconds: 180),
    ],
  ),
  FoodRecommendation(
    title: 'Turkey Lettuce Wraps',
    description: 'Light, crunchy, and high-protein for busy days.',
    cookTimeMinutes: 18,
    calories: 390,
    proteinGrams: 34,
    fiberGrams: 6,
    ingredients: [
      '150 g lean ground turkey',
      'Large lettuce leaves',
      'Shredded carrots',
      'Cucumber strips',
      'Garlic, ginger, and low-sodium soy sauce',
    ],
    healthBenefits: [
      'Lean turkey helps keep protein high with moderate calories.',
      'Crisp vegetables add hydration and volume.',
      'A lighter meal can fit well before evening workouts.',
    ],
    cookingTasks: [
      TimerTask(label: 'Cook turkey with garlic and ginger', seconds: 540),
      TimerTask(label: 'Prep lettuce and vegetables', seconds: 300),
      TimerTask(label: 'Fill wraps and serve', seconds: 180),
    ],
  ),
  FoodRecommendation(
    title: 'Lentil Spinach Soup',
    description: 'Plant-forward comfort food with iron and fiber.',
    cookTimeMinutes: 30,
    calories: 450,
    proteinGrams: 25,
    fiberGrams: 15,
    ingredients: [
      '1 cup cooked lentils',
      'Spinach',
      'Diced tomatoes',
      'Carrots and onion',
      'Vegetable broth',
    ],
    healthBenefits: [
      'Lentils provide fiber and plant protein for fullness.',
      'Spinach contributes iron, folate, and magnesium.',
      'Soup supports hydration while staying nutrient dense.',
    ],
    cookingTasks: [
      TimerTask(label: 'Simmer vegetables and broth', seconds: 600),
      TimerTask(label: 'Add lentils and tomatoes', seconds: 720),
      TimerTask(label: 'Wilt spinach and season', seconds: 240),
    ],
  ),
  FoodRecommendation(
    title: 'Berry Yogurt Parfait',
    description: 'A lighter pick with probiotics and antioxidants.',
    cookTimeMinutes: 8,
    calories: 330,
    proteinGrams: 24,
    fiberGrams: 7,
    ingredients: [
      '1 cup Greek yogurt',
      'Mixed berries',
      'Rolled oats or granola',
      'Chia seeds',
      'Honey',
    ],
    healthBenefits: [
      'Greek yogurt supports protein intake and gut health.',
      'Berries provide antioxidants with natural sweetness.',
      'Chia and oats add fiber for steadier energy.',
    ],
    cookingTasks: [
      TimerTask(label: 'Toast oats or granola', seconds: 180),
      TimerTask(label: 'Layer yogurt, berries, and seeds', seconds: 180),
    ],
  ),
];

const List<WorkoutRoutine> recommendedWorkouts = [
  WorkoutRoutine(
    focus: 'Back Routine',
    title: 'Pull Strength Builder',
    description: 'Controlled pulls and rows to train your back and posture.',
    color: Color(0xFF7BA7FF),
    exercises: [
      WorkoutExercise(name: 'Bodyweight rows', sets: 3, secondsPerSet: 45),
      WorkoutExercise(name: 'Dumbbell rows', sets: 3, secondsPerSet: 50),
      WorkoutExercise(name: 'Superman hold', sets: 3, secondsPerSet: 35),
    ],
  ),
  WorkoutRoutine(
    focus: 'Leg Routine',
    title: 'Lower Body Drive',
    description: 'Squats, lunges, and calf work for a strong base.',
    color: Color(0xFFFFB86B),
    exercises: [
      WorkoutExercise(name: 'Squats', sets: 4, secondsPerSet: 45),
      WorkoutExercise(name: 'Reverse lunges', sets: 3, secondsPerSet: 50),
      WorkoutExercise(name: 'Calf raises', sets: 3, secondsPerSet: 35),
    ],
  ),
  WorkoutRoutine(
    focus: 'Chest Routine',
    title: 'Push Power Session',
    description: 'Push-up variations and presses for chest and triceps.',
    color: Color(0xFF35E8AE),
    exercises: [
      WorkoutExercise(name: 'Push-ups', sets: 4, secondsPerSet: 40),
      WorkoutExercise(name: 'Floor press', sets: 3, secondsPerSet: 50),
      WorkoutExercise(name: 'Plank shoulder taps', sets: 3, secondsPerSet: 35),
    ],
  ),
  WorkoutRoutine(
    focus: 'Core Routine',
    title: 'Midline Stability',
    description: 'Timed core sets for balance, control, and endurance.',
    color: Color(0xFFB38CFF),
    exercises: [
      WorkoutExercise(name: 'Plank', sets: 3, secondsPerSet: 45),
      WorkoutExercise(name: 'Dead bugs', sets: 3, secondsPerSet: 40),
      WorkoutExercise(name: 'Mountain climbers', sets: 3, secondsPerSet: 35),
    ],
  ),
  WorkoutRoutine(
    focus: 'Full Body Routine',
    title: 'Total Body Circuit',
    description: 'Balanced strength moves to train upper, lower, and core.',
    color: Color(0xFFFF7BA7),
    exercises: [
      WorkoutExercise(name: 'Bodyweight squats', sets: 3, secondsPerSet: 45),
      WorkoutExercise(name: 'Incline push-ups', sets: 3, secondsPerSet: 40),
      WorkoutExercise(name: 'Alternating lunges', sets: 3, secondsPerSet: 45),
      WorkoutExercise(name: 'Plank hold', sets: 3, secondsPerSet: 35),
    ],
  ),
  WorkoutRoutine(
    focus: 'Cardio Routine',
    title: 'Low-Impact Sweat',
    description: 'Joint-friendly intervals for heart health and stamina.',
    color: Color(0xFF5ED6D1),
    exercises: [
      WorkoutExercise(name: 'Marching high knees', sets: 4, secondsPerSet: 35),
      WorkoutExercise(name: 'Step jacks', sets: 4, secondsPerSet: 35),
      WorkoutExercise(name: 'Fast feet taps', sets: 3, secondsPerSet: 30),
      WorkoutExercise(name: 'Standing punches', sets: 3, secondsPerSet: 35),
    ],
  ),
  WorkoutRoutine(
    focus: 'Mobility Routine',
    title: 'Recovery Flow',
    description: 'Gentle mobility work for hips, shoulders, and spine.',
    color: Color(0xFF9EE493),
    exercises: [
      WorkoutExercise(name: 'Cat cow flow', sets: 3, secondsPerSet: 40),
      WorkoutExercise(name: 'Hip flexor stretch', sets: 3, secondsPerSet: 45),
      WorkoutExercise(name: 'Shoulder circles', sets: 3, secondsPerSet: 35),
      WorkoutExercise(name: 'Hamstring reach', sets: 3, secondsPerSet: 40),
    ],
  ),
];
