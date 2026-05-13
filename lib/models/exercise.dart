class Exercise {
  final String id;
  final String title;
  final String description;
  final int duration; // minutes
  final List<String>
      suitableFor; // age groups: 'young', 'adult', 'senior', 'all'
  final List<String> places; // 'home', 'office', 'park', 'gym', 'anywhere'
  final List<String>
      equipmentNeeded; // 'none', 'chair', 'mat', 'light weights', 'resistance bands'
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String
      category; // 'cardio', 'strength', 'flexibility', 'balance', 'sports', 'relaxation'
  final String imageUrl;
  final String videoUrl;
  final List<String> instructions;
  final List<String> benefits;
  final List<String>
      healthConsiderations; // conditions that make this exercise risky

  // NEW FIELDS for enhanced personalization
  final String? fitnessLevel; // 'beginner', 'intermediate', 'advanced'
  final List<String>
      suitableForInjuries; // injuries this exercise is SAFE for (empty if safe for all)
  final List<String> avoidForInjuries; // injuries that make this exercise risky
  final String? intensity; // 'low', 'moderate', 'high', 'very high'
  final List<String>
      targetMuscles; // ['legs', 'core', 'arms', 'back', 'chest', 'shoulders', 'full body']
  final List<String>
      sportTypes; // ['running', 'swimming', 'yoga', 'weightlifting', 'dancing', 'boxing', etc.]
  final bool? suitableForPregnancy; // true/false
  final bool? suitableForSeniors; // true/false
  final bool? requiresOutdoorSpace; // true/false
  final bool? canBeDoneAlone; // true/false
  final bool? canBeDoneInGroup; // true/false
  final int? caloriesBurnRate; // calories burned per minute (approx)
  final String?
      mentalHealthBenefit; // 'stress relief', 'anxiety relief', 'mood boost', 'focus', 'relaxation', 'energy'
  final List<String>
      contraindications; // absolute no-nos (e.g., 'heart conditions', 'severe asthma')

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.suitableFor,
    required this.places,
    required this.equipmentNeeded,
    required this.difficulty,
    required this.category,
    required this.imageUrl,
    required this.videoUrl,
    required this.instructions,
    required this.benefits,
    required this.healthConsiderations,

    // New fields with defaults
    this.fitnessLevel,
    this.suitableForInjuries = const [],
    this.avoidForInjuries = const [],
    this.intensity,
    this.targetMuscles = const [],
    this.sportTypes = const [],
    this.suitableForPregnancy,
    this.suitableForSeniors,
    this.requiresOutdoorSpace,
    this.canBeDoneAlone,
    this.canBeDoneInGroup,
    this.caloriesBurnRate,
    this.mentalHealthBenefit,
    this.contraindications = const [],
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'duration': duration,
        'suitableFor': suitableFor,
        'places': places,
        'equipmentNeeded': equipmentNeeded,
        'difficulty': difficulty,
        'category': category,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'instructions': instructions,
        'benefits': benefits,
        'healthConsiderations': healthConsiderations,

        // New fields
        'fitnessLevel': fitnessLevel,
        'suitableForInjuries': suitableForInjuries,
        'avoidForInjuries': avoidForInjuries,
        'intensity': intensity,
        'targetMuscles': targetMuscles,
        'sportTypes': sportTypes,
        'suitableForPregnancy': suitableForPregnancy,
        'suitableForSeniors': suitableForSeniors,
        'requiresOutdoorSpace': requiresOutdoorSpace,
        'canBeDoneAlone': canBeDoneAlone,
        'canBeDoneInGroup': canBeDoneInGroup,
        'caloriesBurnRate': caloriesBurnRate,
        'mentalHealthBenefit': mentalHealthBenefit,
        'contraindications': contraindications,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        duration: json['duration'],
        suitableFor: List<String>.from(json['suitableFor']),
        places: List<String>.from(json['places']),
        equipmentNeeded: List<String>.from(json['equipmentNeeded']),
        difficulty: json['difficulty'],
        category: json['category'],
        imageUrl: json['imageUrl'],
        videoUrl: json['videoUrl'],
        instructions: List<String>.from(json['instructions']),
        benefits: List<String>.from(json['benefits']),
        healthConsiderations: List<String>.from(json['healthConsiderations']),

        // New fields
        fitnessLevel: json['fitnessLevel'],
        suitableForInjuries:
            List<String>.from(json['suitableForInjuries'] ?? []),
        avoidForInjuries: List<String>.from(json['avoidForInjuries'] ?? []),
        intensity: json['intensity'],
        targetMuscles: List<String>.from(json['targetMuscles'] ?? []),
        sportTypes: List<String>.from(json['sportTypes'] ?? []),
        suitableForPregnancy: json['suitableForPregnancy'],
        suitableForSeniors: json['suitableForSeniors'],
        requiresOutdoorSpace: json['requiresOutdoorSpace'],
        canBeDoneAlone: json['canBeDoneAlone'],
        canBeDoneInGroup: json['canBeDoneInGroup'],
        caloriesBurnRate: json['caloriesBurnRate'],
        mentalHealthBenefit: json['mentalHealthBenefit'],
        contraindications: List<String>.from(json['contraindications'] ?? []),
      );

  /// Helper to check if exercise is suitable for a given user profile
  bool isSuitableFor({
    required int age,
    required String location,
    required List<String> equipment,
    required int availableTime,
    required List<String> healthConditions,

    // New parameters from enhanced user profile
    String? fitnessLevel,
    List<String>? currentInjuries,
    bool? isPregnant,
    String? intensityPreference,
    bool? hasOutdoorSpace,
    String? workoutSocial,
    List<String>? likedSports,
    List<String>? dislikedSports,
    String? stressLevel,
    bool? hasAnxiety,
    bool? hasDepression,
    List<String>? contraindications,
  }) {
    // Determine age group from age
    final ageGroup = age >= 60 ? 'senior' : (age >= 18 ? 'adult' : 'young');

    // ===== SAFETY CHECKS (These are mandatory - if any fail, exercise is NOT suitable) =====

    // Age suitability
    if (!suitableFor.contains('all') && !suitableFor.contains(ageGroup)) {
      return false;
    }

    // Location suitability
    if (!places.contains('anywhere') && !places.contains(location)) {
      return false;
    }

    // Equipment availability – all required equipment must be present
    for (var eq in equipmentNeeded) {
      if (eq != 'none' && !equipment.contains(eq)) {
        return false;
      }
    }

    // Time available
    if (duration > availableTime) {
      return false;
    }

    // Health considerations – if user has a condition listed, exercise is not suitable
    for (var condition in healthConditions) {
      if (healthConsiderations.contains(condition)) {
        return false;
      }
    }

    // Contraindications check (absolute no-nos)
    if (contraindications != null) {
      for (var contra in contraindications) {
        if (this.contraindications.contains(contra)) {
          return false;
        }
      }
    }

    // Injury checks – avoid exercises that could worsen injuries
    if (currentInjuries != null) {
      for (var injury in currentInjuries) {
        if (avoidForInjuries.contains(injury)) {
          return false; // Exercise is risky for this injury
        }
      }
    }

    // Pregnancy check
    if (isPregnant == true && suitableForPregnancy == false) {
      return false; // Not safe during pregnancy
    }

    // Outdoor space requirement
    if (requiresOutdoorSpace == true && hasOutdoorSpace == false) {
      return false; // Requires outdoor space but user doesn't have it
    }

    // ===== PREFERENCE CHECKS (These influence suitability but aren't absolute) =====
    // Note: These return false only for strong dislikes/contradictions

    // Fitness level check – advanced users can do beginner exercises, but beginners shouldn't do advanced
    if (fitnessLevel != null && this.fitnessLevel != null) {
      if (fitnessLevel == 'beginner' && this.fitnessLevel == 'advanced') {
        return false; // Beginner can't do advanced exercises
      }
    }

    // Intensity preference – if user wants low intensity and exercise is high, skip
    if (intensityPreference != null && intensity != null) {
      if (intensityPreference == 'low' &&
          (intensity == 'high' || intensity == 'very high')) {
        return false;
      }
      if (intensityPreference == 'moderate' && intensity == 'very high') {
        return false;
      }
    }

    // Social preference
    if (workoutSocial != null) {
      if (workoutSocial == 'alone' && canBeDoneAlone == false) {
        return false; // User wants to exercise alone but this is a group exercise
      }
      if (workoutSocial == 'group' && canBeDoneInGroup == false) {
        return false; // User wants group exercise but this is solo
      }
    }

    // Disliked sports
    if (dislikedSports != null && dislikedSports.isNotEmpty) {
      for (var sport in dislikedSports) {
        if (sportTypes.contains(sport)) {
          return false; // User dislikes this type of sport
        }
      }
    }

    // ===== RECOMMENDATION SCORING (These don't exclude, just help with ranking) =====
    // We'll handle these in the recommendation service for scoring/ranking

    return true;
  }

  /// Calculate a match score for ranking exercises (higher is better)
  int calculateMatchScore({
    List<String>? likedSports,
    String? primaryGoal,
    String? stressLevel,
    bool? hasAnxiety,
    bool? hasDepression,
  }) {
    int score = 50; // Base score

    // Boost for liked sports
    if (likedSports != null) {
      for (var sport in likedSports) {
        if (sportTypes.contains(sport)) {
          score += 20;
          break;
        }
      }
    }

    // Boost for mental health benefits
    if (stressLevel == 'high' && mentalHealthBenefit == 'stress relief') {
      score += 15;
    }
    if (hasAnxiety == true && mentalHealthBenefit == 'anxiety relief') {
      score += 15;
    }
    if (hasDepression == true && mentalHealthBenefit == 'mood boost') {
      score += 15;
    }

    // Boost for goal alignment
    if (primaryGoal != null) {
      if (primaryGoal == 'weight loss' && category == 'cardio') {
        score += 10;
      }
      if (primaryGoal == 'muscle gain' && category == 'strength') {
        score += 10;
      }
      if (primaryGoal == 'stress relief' &&
          mentalHealthBenefit == 'stress relief') {
        score += 10;
      }
    }

    return score;
  }
}
