import '../models/exercise.dart';
import '../models/user_profile.dart';
import '../data/exercises.dart';

class RecommendationService {
  /// Returns all exercises suitable for the given user profile, sorted by relevance.
  List<Exercise> getRecommendations(UserProfile user) {
    // First, filter exercises based on safety and suitability
    List<Exercise> suitable = sampleExercises.where((exercise) {
      return exercise.isSuitableFor(
        // Basic info
        age: user.age,
        location: user.preferredLocation,
        equipment: user.availableEquipment,
        availableTime: user.dailyTimeAvailable,
        healthConditions: [...user.healthConditions, ...user.chronicConditions],

        // Enhanced parameters from user profile
        fitnessLevel: user.fitnessLevel,
        currentInjuries: user.currentInjuries,
        isPregnant: user.pregnancyStatus == 'pregnant',
        intensityPreference: user.intensityPreference,
        hasOutdoorSpace: user.hasOutdoorSpace,
        workoutSocial: user.workoutSocial,
        likedSports: user.likedSports,
        dislikedSports: user.dislikedSports,
        stressLevel: user.stressLevel,
        hasAnxiety: user.hasAnxiety,
        hasDepression: user.hasDepression,
        contraindications: [
          ...user.healthConditions,
          ...user.chronicConditions
        ],
      );
    }).toList();

    // Then, sort by match score (best matches first)
    suitable.sort((a, b) {
      int scoreA = a.calculateMatchScore(
        likedSports: user.likedSports,
        primaryGoal: user.primaryGoal,
        stressLevel: user.stressLevel,
        hasAnxiety: user.hasAnxiety,
        hasDepression: user.hasDepression,
      );
      int scoreB = b.calculateMatchScore(
        likedSports: user.likedSports,
        primaryGoal: user.primaryGoal,
        stressLevel: user.stressLevel,
        hasAnxiety: user.hasAnxiety,
        hasDepression: user.hasDepression,
      );
      return scoreB.compareTo(scoreA); // Higher score first
    });

    return suitable;
  }

  /// Returns a quick workout (exercises that fit within daily time, prioritizing best matches).
  List<Exercise> getQuickWorkout(UserProfile user) {
    final suitable = getRecommendations(user);
    final List<Exercise> workout = [];
    int remainingTime = user.dailyTimeAvailable;

    // Take best matching exercises that fit the time
    for (var ex in suitable) {
      if (ex.duration <= remainingTime) {
        workout.add(ex);
        remainingTime -= ex.duration;
      }
      if (remainingTime <= 0) break;
    }

    return workout;
  }

  /// Get exercises filtered by category
  List<Exercise> getExercisesByCategory(UserProfile user, String category) {
    return getRecommendations(user)
        .where((ex) => ex.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get exercises that target specific muscle groups
  List<Exercise> getExercisesByTargetMuscle(UserProfile user, String muscle) {
    return getRecommendations(user)
        .where((ex) => ex.targetMuscles
            .any((m) => m.toLowerCase().contains(muscle.toLowerCase())))
        .toList();
  }

  /// Get exercises suitable for stress relief
  List<Exercise> getStressReliefExercises(UserProfile user) {
    return getRecommendations(user)
        .where((ex) =>
            ex.mentalHealthBenefit == 'stress relief' ||
            ex.category == 'relaxation' ||
            ex.category == 'yoga' ||
            ex.mentalHealthBenefit == 'relaxation' ||
            ex.mentalHealthBenefit == 'calming')
        .toList();
  }

  /// Get exercises by intensity level
  List<Exercise> getExercisesByIntensity(UserProfile user, String intensity) {
    return getRecommendations(user)
        .where((ex) => ex.intensity?.toLowerCase() == intensity.toLowerCase())
        .toList();
  }

  /// Get exercises safe for specific injuries
  List<Exercise> getExercisesSafeForInjury(UserProfile user, String injury) {
    return getRecommendations(user)
        .where((ex) =>
            ex.suitableForInjuries.contains(injury) ||
            (!ex.avoidForInjuries.contains(injury) &&
                ex.suitableForInjuries.isEmpty))
        .toList();
  }

  /// Get exercises by fitness level
  List<Exercise> getExercisesByFitnessLevel(UserProfile user, String level) {
    return getRecommendations(user)
        .where((ex) => ex.fitnessLevel == level || ex.difficulty == level)
        .toList();
  }

  /// Get exercises that can be done at specific location
  List<Exercise> getExercisesByLocation(UserProfile user, String location) {
    return getRecommendations(user)
        .where((ex) =>
            ex.places.contains(location) || ex.places.contains('anywhere'))
        .toList();
  }

  /// Get exercises that match user's preferred sports
  List<Exercise> getExercisesBySportTypes(UserProfile user) {
    if (user.likedSports.isEmpty) return getRecommendations(user);

    return getRecommendations(user)
        .where((ex) =>
            ex.sportTypes.any((sport) => user.likedSports.contains(sport)))
        .toList();
  }

  /// Get beginner-friendly exercises
  List<Exercise> getBeginnerExercises(UserProfile user) {
    return getRecommendations(user)
        .where((ex) =>
            ex.fitnessLevel == 'beginner' || ex.difficulty == 'beginner')
        .toList();
  }

  /// Get equipment-free exercises (no equipment needed)
  List<Exercise> getNoEquipmentExercises(UserProfile user) {
    return getRecommendations(user)
        .where((ex) =>
            ex.equipmentNeeded.isEmpty ||
            (ex.equipmentNeeded.length == 1 &&
                ex.equipmentNeeded.first == 'none'))
        .toList();
  }

  /// Get exercises suitable for seniors
  List<Exercise> getSeniorFriendlyExercises(UserProfile user) {
    return getRecommendations(user)
        .where((ex) =>
            ex.suitableForSeniors == true ||
            ex.suitableFor.contains('senior') ||
            ex.intensity == 'low')
        .toList();
  }

  /// Get pregnancy-safe exercises
  List<Exercise> getPregnancySafeExercises(UserProfile user) {
    if (user.pregnancyStatus != 'pregnant') return [];

    return getRecommendations(user)
        .where((ex) => ex.suitableForPregnancy == true)
        .toList();
  }

  /// Get exercises by duration range
  List<Exercise> getExercisesByDuration(
      UserProfile user, int minMinutes, int maxMinutes) {
    return getRecommendations(user)
        .where((ex) => ex.duration >= minMinutes && ex.duration <= maxMinutes)
        .toList();
  }

  /// Get exercises that burn the most calories
  List<Exercise> getHighCalorieBurningExercises(UserProfile user,
      {int limit = 10}) {
    final sorted = List<Exercise>.from(getRecommendations(user))
      ..sort((a, b) =>
          (b.caloriesBurnRate ?? 0).compareTo(a.caloriesBurnRate ?? 0));

    return sorted.take(limit).toList();
  }

  /// Get a balanced weekly workout plan
  Map<String, List<Exercise>> getWeeklyPlan(UserProfile user) {
    final allExercises = getRecommendations(user);
    final Map<String, List<Exercise>> plan = {};

    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final targetDays =
        user.preferredDays.isEmpty ? days.take(3).toList() : user.preferredDays;

    for (var day in targetDays) {
      // Get different types of exercises for each day
      final dayExercises = <Exercise>[];

      // Add one cardio if available
      final cardio =
          allExercises.where((ex) => ex.category == 'cardio').toList();
      if (cardio.isNotEmpty) dayExercises.add(cardio[0]);

      // Add one strength if available
      final strength =
          allExercises.where((ex) => ex.category == 'strength').toList();
      if (strength.isNotEmpty) dayExercises.add(strength[0]);

      // Add one flexibility if available
      final flex = allExercises
          .where((ex) => ex.category == 'flexibility' || ex.category == 'yoga')
          .toList();
      if (flex.isNotEmpty) dayExercises.add(flex[0]);

      // Ensure total time doesn't exceed user's daily limit
      int totalTime = 0;
      final validExercises = <Exercise>[];
      for (var ex in dayExercises) {
        if (totalTime + ex.duration <= user.dailyTimeAvailable) {
          validExercises.add(ex);
          totalTime += ex.duration;
        }
      }

      plan[day] = validExercises;
    }

    return plan;
  }

  /// Get exercise statistics
  Map<String, dynamic> getExerciseStatistics(UserProfile user) {
    final allExercises = getRecommendations(user);

    return {
      'totalAvailable': allExercises.length,
      'byCategory': {
        'cardio': allExercises.where((ex) => ex.category == 'cardio').length,
        'strength':
            allExercises.where((ex) => ex.category == 'strength').length,
        'flexibility':
            allExercises.where((ex) => ex.category == 'flexibility').length,
        'balance': allExercises.where((ex) => ex.category == 'balance').length,
        'relaxation':
            allExercises.where((ex) => ex.category == 'relaxation').length,
        'yoga': allExercises.where((ex) => ex.category == 'yoga').length,
      },
      'byIntensity': {
        'low': allExercises.where((ex) => ex.intensity == 'low').length,
        'moderate':
            allExercises.where((ex) => ex.intensity == 'moderate').length,
        'high': allExercises.where((ex) => ex.intensity == 'high').length,
        'very high':
            allExercises.where((ex) => ex.intensity == 'very high').length,
      },
      'byEquipment': {
        'no equipment': allExercises
            .where((ex) =>
                ex.equipmentNeeded.isEmpty ||
                (ex.equipmentNeeded.length == 1 &&
                    ex.equipmentNeeded.first == 'none'))
            .length,
        'needs equipment': allExercises
            .where((ex) =>
                ex.equipmentNeeded.isNotEmpty &&
                !(ex.equipmentNeeded.length == 1 &&
                    ex.equipmentNeeded.first == 'none'))
            .length,
      },
      'averageDuration': allExercises.isEmpty
          ? 0
          : allExercises.map((ex) => ex.duration).reduce((a, b) => a + b) ~/
              allExercises.length,
    };
  }
}
