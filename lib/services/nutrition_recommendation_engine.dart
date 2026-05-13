import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class NutritionRecommendationEngine {
  // ==================== MAIN RECOMMENDATION METHOD ====================
  static Map<String, dynamic> getPersonalizedNutrition(UserProfile profile) {
    // Step 1: Calculate calorie needs
    final calories = _calculateCalorieNeeds(profile);

    // Step 2: Calculate macros
    final macros = _calculateMacros(profile, calories);

    // Step 3: Get food restrictions
    final restrictions = _getFoodRestrictions(profile);

    // Step 4: Get recent workout data
    final workoutData = _analyzeWorkoutHistory(profile);

    // Step 5: Generate meal plan
    final mealPlan =
        _generateMealPlan(profile, calories, macros, restrictions, workoutData);

    // Step 6: Generate shopping list
    final shoppingList = _generateShoppingList(mealPlan);

    // Step 7: Generate nutrition tips
    final tips = _generateTips(profile, workoutData);

    return {
      'dailyCalories': calories,
      'macros': macros,
      'mealPlan': mealPlan,
      'shoppingList': shoppingList,
      'tips': tips,
      'restrictions': restrictions,
      'hydrationGoal': _calculateHydrationNeeds(profile, workoutData),
    };
  }

  // ==================== CALORIE CALCULATION ====================
  static int _calculateCalorieNeeds(UserProfile profile) {
    // Mifflin-St Jeor Equation
    double bmr;

    if (profile.gender == 'male') {
      bmr = (10 * (profile.weight ?? 70)) +
          (6.25 * (profile.height ?? 170)) -
          (5 * profile.age) +
          5;
    } else {
      bmr = (10 * (profile.weight ?? 60)) +
          (6.25 * (profile.height ?? 160)) -
          (5 * profile.age) -
          161;
    }

    // Activity factor based on profile
    double activityFactor;
    switch (profile.fitnessLevel ?? 'moderate') {
      case 'sedentary':
        activityFactor = 1.2;
        break;
      case 'light':
        activityFactor = 1.375;
        break;
      case 'moderate':
        activityFactor = 1.55;
        break;
      case 'active':
        activityFactor = 1.725;
        break;
      case 'very active':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.55;
    }

    // Adjust for workout frequency
    double workoutBonus = (profile.workoutFrequency ?? 3) * 100;

    // Goal adjustment
    double goalMultiplier;
    switch (profile.primaryGoal) {
      case 'weight loss':
        goalMultiplier = 0.85;
        break;
      case 'muscle gain':
        goalMultiplier = 1.1;
        break;
      case 'maintain':
        goalMultiplier = 1.0;
        break;
      default:
        goalMultiplier = 1.0;
    }

    return ((bmr * activityFactor * goalMultiplier) + workoutBonus).round();
  }

  // ==================== MACRONUTRIENT CALCULATION ====================
  static Map<String, int> _calculateMacros(UserProfile profile, int calories) {
    int protein, carbs, fats;
    double weight = profile.weight ?? 70;

    switch (profile.primaryGoal) {
      case 'muscle gain':
        protein = (weight * 2.2).round(); // 2.2g per kg
        fats = (calories * 0.25 ~/ 9); // 25% fat
        carbs = (calories - (protein * 4) - (fats * 9)) ~/ 4;
        break;

      case 'weight loss':
        protein = (weight * 2.0).round(); // 2.0g per kg
        fats = (calories * 0.3 ~/ 9); // 30% fat
        carbs = (calories - (protein * 4) - (fats * 9)) ~/ 4;
        break;

      case 'endurance':
        protein = (weight * 1.6).round();
        fats = (calories * 0.2 ~/ 9);
        carbs = (calories - (protein * 4) - (fats * 9)) ~/ 4;
        break;

      default: // balanced
        protein = (weight * 1.6).round();
        fats = (calories * 0.25 ~/ 9);
        carbs = (calories - (protein * 4) - (fats * 9)) ~/ 4;
    }

    return {'protein': protein, 'carbs': carbs, 'fats': fats};
  }

  // ==================== FOOD RESTRICTIONS ====================
  static List<String> _getFoodRestrictions(UserProfile profile) {
    List<String> restrictions = [];

    // Diet type restrictions
    switch (profile.dietType) {
      case 'vegetarian':
        restrictions.addAll(['No meat', 'No poultry', 'No fish']);
        break;
      case 'vegan':
        restrictions.addAll(['No animal products', 'No dairy', 'No eggs']);
        break;
      case 'keto':
        restrictions.addAll(['Low carb (<50g)', 'High fat', 'No sugar']);
        break;
      case 'paleo':
        restrictions.addAll(['No grains', 'No dairy', 'No processed foods']);
        break;
    }

    // Allergies
    if (profile.foodAllergies.isNotEmpty) {
      restrictions.addAll(profile.foodAllergies.map((a) => 'No $a'));
    }

    // Health conditions
    if (profile.healthConditions.contains('diabetes')) {
      restrictions
          .addAll(['Low sugar', 'Low glycemic index', 'Complex carbs only']);
    }

    if (profile.healthConditions.contains('high blood pressure')) {
      restrictions.addAll(['Low sodium (<1500mg)', 'No processed foods']);
    }

    if (profile.chronicConditions.contains('celiac') ||
        profile.allergies.contains('gluten')) {
      restrictions.add('Gluten-free only');
    }

    if (profile.pregnancyStatus == 'pregnant') {
      restrictions.addAll(['No alcohol', 'Limited caffeine', 'No raw fish']);
    }

    return restrictions;
  }

  // ==================== WORKOUT HISTORY ANALYSIS ====================
  static Map<String, dynamic> _analyzeWorkoutHistory(UserProfile profile) {
    final now = DateTime.now();
    int totalWeekMinutes = 0;
    int workoutDays = 0;
    Map<String, int> workoutTypes = {};

    // Analyze last 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final minutes = profile.activityLog[dateStr] ?? 0;

      if (minutes > 0) {
        workoutDays++;
        totalWeekMinutes += minutes;
        // This would need actual workout type data
        workoutTypes['cardio'] = (workoutTypes['cardio'] ?? 0) + 1;
      }
    }

    // Determine if today is a workout day
    final today = DateFormat('yyyy-MM-dd').format(now);
    final todayMinutes = profile.activityLog[today] ?? 0;
    final hasWorkoutToday = todayMinutes > 0;

    return {
      'totalWeekMinutes': totalWeekMinutes,
      'workoutDays': workoutDays,
      'averageDaily': workoutDays > 0 ? totalWeekMinutes ~/ workoutDays : 0,
      'hasWorkoutToday': hasWorkoutToday,
      'workoutTypes': workoutTypes,
      'isRestDay': !hasWorkoutToday && todayMinutes == 0,
    };
  }

  // ==================== PERSONALIZED MEAL PLAN ====================
  static List<Map<String, dynamic>> _generateMealPlan(
      UserProfile profile,
      int calories,
      Map<String, int> macros,
      List<String> restrictions,
      Map<String, dynamic> workoutData) {
    final List<Map<String, dynamic>> weeklyPlan = [];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // Calculate per-meal calories
    final mealCalories = (calories * 0.25).round(); // 4 meals per day
    final snackCalories = (calories * 0.15).round(); // 2 snacks

    for (var day in days) {
      final isWorkoutDay =
          workoutData['hasWorkoutToday'] && day == _getTodayName();

      List<Map<String, dynamic>> meals = [];
      List<Map<String, dynamic>> snacks = [];

      // Breakfast
      meals.add({
        'type': 'Breakfast',
        'time': '7:00 AM',
        'name': _getBreakfastSuggestion(profile, restrictions),
        'calories': mealCalories,
        'protein': (macros['protein']! * 0.25).round(),
        'carbs': (macros['carbs']! * 0.25).round(),
        'fats': (macros['fats']! * 0.25).round(),
      });

      // Lunch
      meals.add({
        'type': 'Lunch',
        'time': '12:30 PM',
        'name': _getLunchSuggestion(profile, restrictions),
        'calories': mealCalories,
        'protein': (macros['protein']! * 0.3).round(),
        'carbs': (macros['carbs']! * 0.3).round(),
        'fats': (macros['fats']! * 0.3).round(),
      });

      // Pre-workout snack (if workout day)
      if (isWorkoutDay) {
        snacks.add({
          'type': 'Pre-Workout',
          'time': _calculatePreWorkoutTime(profile.preferredTime ?? 'evening'),
          'name': _getPreWorkoutSnack(profile),
          'calories': snackCalories ~/ 2,
          'protein': 10,
          'carbs': 25,
          'fats': 3,
        });
      }

      // Dinner
      meals.add({
        'type': 'Dinner',
        'time': '7:00 PM',
        'name': _getDinnerSuggestion(profile, restrictions),
        'calories': mealCalories,
        'protein': (macros['protein']! * 0.3).round(),
        'carbs': (macros['carbs']! * 0.25).round(),
        'fats': (macros['fats']! * 0.3).round(),
      });

      // Post-workout snack (if workout day)
      if (isWorkoutDay) {
        snacks.add({
          'type': 'Post-Workout',
          'time': _calculatePostWorkoutTime(profile.preferredTime ?? 'evening'),
          'name': _getPostWorkoutSnack(profile),
          'calories': snackCalories ~/ 2,
          'protein': 20,
          'carbs': 30,
          'fats': 5,
        });
      } else {
        // Regular evening snack
        snacks.add({
          'type': 'Evening Snack',
          'time': '9:00 PM',
          'name': _getEveningSnack(profile, restrictions),
          'calories': snackCalories,
          'protein': (macros['protein']! * 0.15).round(),
          'carbs': (macros['carbs']! * 0.2).round(),
          'fats': (macros['fats']! * 0.15).round(),
        });
      }

      weeklyPlan.add({
        'day': day,
        'isWorkoutDay': isWorkoutDay,
        'calories': calories,
        'meals': meals,
        'snacks': snacks,
      });
    }

    return weeklyPlan;
  }

  // ==================== SHOPPING LIST GENERATOR ====================
  static List<Map<String, dynamic>> _generateShoppingList(
      List<Map<String, dynamic>> mealPlan) {
    Map<String, Map<String, dynamic>> groceryMap = {};

    for (var day in mealPlan) {
      for (var meal in day['meals']) {
        // Parse meal name and extract ingredients
        // This would need a proper recipe database
        _addToGroceryList(groceryMap, meal['name'], meal['type']);
      }
      for (var snack in day['snacks']) {
        _addToGroceryList(groceryMap, snack['name'], 'snack');
      }
    }

    return groceryMap.values.toList();
  }

  static void _addToGroceryList(
      Map<String, Map<String, dynamic>> map, String meal, String type) {
    // Simplified - would need real ingredient parsing
    if (!map.containsKey('chicken')) {
      map['chicken'] = {
        'item': 'Chicken Breast',
        'category': 'Protein',
        'quantity': '500g',
        'checked': false,
      };
    }
    if (!map.containsKey('broccoli')) {
      map['broccoli'] = {
        'item': 'Broccoli',
        'category': 'Vegetables',
        'quantity': '2 heads',
        'checked': false,
      };
    }
    if (!map.containsKey('rice')) {
      map['rice'] = {
        'item': 'Brown Rice',
        'category': 'Grains',
        'quantity': '1kg',
        'checked': false,
      };
    }
  }

  // ==================== NUTRITION TIPS GENERATOR ====================
  static List<Map<String, dynamic>> _generateTips(
      UserProfile profile, Map<String, dynamic> workoutData) {
    List<Map<String, dynamic>> tips = [];

    // Tip based on goal
    switch (profile.primaryGoal) {
      case 'weight loss':
        tips.add({
          'title': '🌱 Calorie Deficit',
          'tip':
              'Focus on volume eating - fill half your plate with vegetables for fewer calories.',
          'icon': Icons.emoji_flags,
          'color': Colors.green,
        });
        break;
      case 'muscle gain':
        tips.add({
          'title': '💪 Protein Timing',
          'tip':
              'Spread protein intake across all meals (20-40g each) for optimal muscle synthesis.',
          'icon': Icons.fitness_center,
          'color': Colors.blue,
        });
        break;
    }

    // Tip based on workout
    if (workoutData['hasWorkoutToday']) {
      tips.add({
        'title': '⚡ Pre-Workout Fuel',
        'tip':
            'Have a banana or light carbs 30-60 minutes before your workout for energy.',
        'icon': Icons.bolt,
        'color': Colors.orange,
      });

      tips.add({
        'title': '🔄 Post-Workout Recovery',
        'tip':
            'Consume protein within 30 minutes after workout for best recovery.',
        'icon': Icons.restore,
        'color': Colors.purple,
      });
    }

    // Tip based on health
    if (profile.healthConditions.contains('diabetes')) {
      tips.add({
        'title': '🩸 Blood Sugar Management',
        'tip': 'Pair carbs with protein or fat to slow glucose absorption.',
        'icon': Icons.health_and_safety,
        'color': Colors.red,
      });
    }

    // General tips
    tips.add({
      'title': '💧 Hydration',
      'tip':
          'Drink water consistently throughout the day, not just when thirsty.',
      'icon': Icons.water_drop,
      'color': Colors.blue,
    });

    return tips;
  }

  // ==================== HYDRATION CALCULATION ====================
  static int _calculateHydrationNeeds(
      UserProfile profile, Map<String, dynamic> workoutData) {
    // Base: weight in kg * 30-35ml
    double baseWater = (profile.weight ?? 70) * 33; // ml

    // Add for exercise
    if (workoutData['hasWorkoutToday']) {
      baseWater += 500; // Extra 500ml for workout
    }

    // Adjust for climate
    if (profile.climate == 'hot' || profile.climate == 'tropical') {
      baseWater *= 1.2;
    }

    // Convert to glasses (250ml per glass)
    return (baseWater / 250).round();
  }

  // ==================== HELPER METHODS ====================

  static String _getTodayName() {
    return DateFormat('EEEE').format(DateTime.now());
  }

  static String _calculatePreWorkoutTime(String preferredTime) {
    if (preferredTime == 'morning') return '6:30 AM';
    if (preferredTime == 'evening') return '5:30 PM';
    return '3:00 PM';
  }

  static String _calculatePostWorkoutTime(String preferredTime) {
    if (preferredTime == 'morning') return '8:00 AM';
    if (preferredTime == 'evening') return '7:00 PM';
    return '4:30 PM';
  }

  static String _getBreakfastSuggestion(
      UserProfile profile, List<String> restrictions) {
    if (restrictions.contains('No dairy')) {
      return 'Oatmeal with berries and almond milk';
    }
    if (profile.primaryGoal == 'muscle gain') {
      return 'Protein pancakes with Greek yogurt';
    }
    return 'Scrambled eggs with avocado toast';
  }

  static String _getLunchSuggestion(
      UserProfile profile, List<String> restrictions) {
    if (restrictions.contains('No meat')) {
      return 'Quinoa Buddha bowl with chickpeas';
    }
    return 'Grilled chicken salad with quinoa';
  }

  static String _getDinnerSuggestion(
      UserProfile profile, List<String> restrictions) {
    if (profile.primaryGoal == 'weight loss') {
      return 'Baked salmon with roasted vegetables';
    }
    return 'Lean steak with sweet potato and broccoli';
  }

  static String _getPreWorkoutSnack(UserProfile profile) {
    return 'Banana with almond butter';
  }

  static String _getPostWorkoutSnack(UserProfile profile) {
    return 'Protein shake with milk';
  }

  static String _getEveningSnack(
      UserProfile profile, List<String> restrictions) {
    if (profile.primaryGoal == 'weight loss') {
      return 'Greek yogurt with berries';
    }
    return 'Cottage cheese with nuts';
  }
}
