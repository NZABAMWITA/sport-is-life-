class UserProfile {
  final String uid; // Firebase user ID
  String? displayName;
  String? email;
  int age;
  String fitnessGoal; // e.g., 'weight_loss', 'strength', 'mobility'
  String preferredLocation; // 'home', 'office', 'park', 'gym', 'anywhere'
  List<String> healthConditions;
  int dailyTimeAvailable; // minutes
  List<String> availableEquipment; // e.g., ['none', 'chair', 'mat']
  int totalWorkouts;
  int streakDays;
  String? lastWorkoutDate; // ISO 8601 date string
  Map<String, int> activityLog; // key: date YYYY-MM-DD, value: minutes

  // Gamification fields
  int experiencePoints;
  int level;
  Map<String, bool> completedChallenges;
  Map<String, int> challengeProgress;
  List<String> unlockedAchievements;

  // PHYSICAL ATTRIBUTES (8)
  double? height; // Height in cm
  double? weight; // Weight in kg
  double? bmi; // Body Mass Index (calculated)
  double? bodyFatPercentage; // Estimated body fat %
  String? gender; // 'male', 'female', 'other'
  String? bloodType; // 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  String? bodyType; // 'ectomorph', 'mesomorph', 'endomorph'
  int? restingHeartRate; // Resting heart rate in bpm

  // HEALTH & MEDICAL (8)
  List<String> chronicConditions; // ['diabetes', 'hypertension', 'asthma']
  List<String> pastInjuries; // ['ACL tear', 'shoulder dislocation']
  List<String> currentInjuries; // ['lower back pain', 'knee pain']
  List<String> surgeries; // ['appendectomy', 'knee surgery']
  List<String> medications; // ['blood pressure meds', 'insulin']
  List<String> allergies; // ['pollen', 'dust', 'medications']
  String? pregnancyStatus; // 'not pregnant', 'pregnant', 'postpartum', 'trying'
  String? disability; // 'none', 'mobility', 'visual', 'hearing', 'cognitive'

  // FITNESS EXPERIENCE (7)
  String? fitnessLevel; // 'beginner', 'intermediate', 'advanced', 'athlete'
  int? yearsActive; // Years of regular exercise
  List<String> sportsPlayed; // ['running', 'yoga', 'swimming', 'cycling']
  List<String> workoutTypes; // ['cardio', 'strength', 'flexibility', 'balance']
  double? maxBenchPress; // Max weight lifted in kg
  double? maxSquat; // Max squat weight in kg
  double? runDistance; // Max run distance in km

  // SCHEDULE & TIME (5)
  int? workoutFrequency; // Times per week (1-7)
  int? workoutDuration; // Minutes per session
  String? preferredTime; // 'morning', 'afternoon', 'evening', 'night'
  List<String> preferredDays; // ['Monday', 'Wednesday', 'Friday']
  bool? weekendAvailability; // Can workout on weekends

  // GOALS & MOTIVATION (6)
  String?
      primaryGoal; // 'weight loss', 'muscle gain', 'stress relief', 'rehabilitation', 'general fitness'
  String? secondaryGoal; // 'flexibility', 'endurance', 'strength', 'balance'
  double? targetWeight; // Desired weight in kg
  DateTime? targetDate; // Goal achievement date
  String? motivationLevel; // 'low', 'medium', 'high', 'very high'
  String? challengePreference; // 'yes', 'no', 'sometimes'

  // ENVIRONMENT & RESOURCES (5)
  String? workoutLocation; // 'home', 'gym', 'park', 'office', 'mixed'
  bool? hasGymAccess; // Gym membership
  bool? hasOutdoorSpace; // Access to outdoors
  List<String>
      homeEquipment; // ['dumbbells', 'yoga mat', 'resistance bands', 'treadmill']
  String? climate; // 'tropical', 'temperate', 'cold', 'arid'

  // SOCIAL PREFERENCES (4)
  String? workoutSocial; // 'alone', 'partner', 'group', 'trainer', 'mixed'
  String? competitiveness; // 'not competitive', 'somewhat', 'very'
  bool? shareProgress; // Share achievements on social media
  bool? joinChallenges; // Join group challenges

  // DIET & NUTRITION (4)
  String?
      dietType; // 'vegetarian', 'vegan', 'keto', 'paleo', 'mediterranean', 'none'
  int? dailyCalories; // Average daily calorie intake
  int? waterIntake; // Glasses of water per day
  List<String> foodAllergies; // ['nuts', 'dairy', 'gluten', 'shellfish']

  // SLEEP & RECOVERY (4)
  double? sleepHours; // Average hours of sleep per night
  String? sleepQuality; // 'poor', 'fair', 'good', 'excellent'
  String? wakeTime; // 'early bird', 'night owl', 'flexible'
  int? recoveryTime; // Hours needed between workouts

  // LIFESTYLE (5)
  String?
      occupation; // 'sedentary', 'active', 'manual labor', 'remote', 'student'
  int? workHours; // Hours worked per day
  int? sittingHours; // Hours sitting per day
  int? standingHours; // Hours standing per day
  bool? hasKids; // Have children

  // PREFERENCES (4)
  bool? musicDuringWorkout; // Listen to music while exercising
  String? musicGenre; // 'upbeat', 'rock', 'pop', 'electronic', 'calm'
  String? intensityPreference; // 'low', 'moderate', 'high'
  String?
      durationPreference; // 'short (<15min)', 'medium (15-30min)', 'long (>30min)'

  // INTERESTS (4)
  List<String> likedSports; // ['yoga', 'running', 'swimming', 'cycling']
  List<String> dislikedSports; // ['weightlifting', 'boxing', 'crossfit']
  List<String> wantToTry; // ['pilates', 'martial arts', 'dancing']
  String? favoriteAthlete; // Sports inspiration

  // MENTAL HEALTH (3)
  String? stressLevel; // 'low', 'moderate', 'high', 'severe'
  bool? hasAnxiety; // Anxiety disorder
  bool? hasDepression; // Depression

  // ACCESSIBILITY (3)
  String? mobilityAids; // 'none', 'cane', 'walker', 'wheelchair'
  bool? visualImpairment; // Vision problems
  bool? hearingImpairment; // Hearing problems

  UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    required this.age,
    required this.fitnessGoal,
    required this.preferredLocation,
    required this.healthConditions,
    required this.dailyTimeAvailable,
    required this.availableEquipment,
    this.totalWorkouts = 0,
    this.streakDays = 0,
    this.lastWorkoutDate,
    Map<String, int>? activityLog,
    this.experiencePoints = 0,
    this.level = 1,
    Map<String, bool>? completedChallenges,
    Map<String, int>? challengeProgress,
    List<String>? unlockedAchievements,

    // New with defaults
    this.height,
    this.weight,
    this.bmi,
    this.bodyFatPercentage,
    this.gender,
    this.bloodType,
    this.bodyType,
    this.restingHeartRate,
    this.chronicConditions = const [],
    this.pastInjuries = const [],
    this.currentInjuries = const [],
    this.surgeries = const [],
    this.medications = const [],
    this.allergies = const [],
    this.pregnancyStatus,
    this.disability,
    this.fitnessLevel,
    this.yearsActive,
    this.sportsPlayed = const [],
    this.workoutTypes = const [],
    this.maxBenchPress,
    this.maxSquat,
    this.runDistance,
    this.workoutFrequency,
    this.workoutDuration,
    this.preferredTime,
    this.preferredDays = const [],
    this.weekendAvailability,
    this.primaryGoal,
    this.secondaryGoal,
    this.targetWeight,
    this.targetDate,
    this.motivationLevel,
    this.challengePreference,
    this.workoutLocation,
    this.hasGymAccess,
    this.hasOutdoorSpace,
    this.homeEquipment = const [],
    this.climate,
    this.workoutSocial,
    this.competitiveness,
    this.shareProgress,
    this.joinChallenges,
    this.dietType,
    this.dailyCalories,
    this.waterIntake,
    this.foodAllergies = const [],
    this.sleepHours,
    this.sleepQuality,
    this.wakeTime,
    this.recoveryTime,
    this.occupation,
    this.workHours,
    this.sittingHours,
    this.standingHours,
    this.hasKids,
    this.musicDuringWorkout,
    this.musicGenre,
    this.intensityPreference,
    this.durationPreference,
    this.likedSports = const [],
    this.dislikedSports = const [],
    this.wantToTry = const [],
    this.favoriteAthlete,
    this.stressLevel,
    this.hasAnxiety,
    this.hasDepression,
    this.mobilityAids,
    this.visualImpairment,
    this.hearingImpairment,
  })  : activityLog = activityLog ?? {},
        completedChallenges = completedChallenges ?? {},
        challengeProgress = challengeProgress ?? {},
        unlockedAchievements = unlockedAchievements ?? [];

  // Getters for level system
  int get expForNextLevel => level * 100;
  double get levelProgress => experiencePoints / expForNextLevel;

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'age': age,
        'fitnessGoal': fitnessGoal,
        'preferredLocation': preferredLocation,
        'healthConditions': healthConditions,
        'dailyTimeAvailable': dailyTimeAvailable,
        'availableEquipment': availableEquipment,
        'totalWorkouts': totalWorkouts,
        'streakDays': streakDays,
        'lastWorkoutDate': lastWorkoutDate,
        'activityLog': activityLog,
        'experiencePoints': experiencePoints,
        'level': level,
        'completedChallenges': completedChallenges,
        'challengeProgress': challengeProgress,
        'unlockedAchievements': unlockedAchievements,

        // New fields
        'height': height,
        'weight': weight,
        'bmi': bmi,
        'bodyFatPercentage': bodyFatPercentage,
        'gender': gender,
        'bloodType': bloodType,
        'bodyType': bodyType,
        'restingHeartRate': restingHeartRate,
        'chronicConditions': chronicConditions,
        'pastInjuries': pastInjuries,
        'currentInjuries': currentInjuries,
        'surgeries': surgeries,
        'medications': medications,
        'allergies': allergies,
        'pregnancyStatus': pregnancyStatus,
        'disability': disability,
        'fitnessLevel': fitnessLevel,
        'yearsActive': yearsActive,
        'sportsPlayed': sportsPlayed,
        'workoutTypes': workoutTypes,
        'maxBenchPress': maxBenchPress,
        'maxSquat': maxSquat,
        'runDistance': runDistance,
        'workoutFrequency': workoutFrequency,
        'workoutDuration': workoutDuration,
        'preferredTime': preferredTime,
        'preferredDays': preferredDays,
        'weekendAvailability': weekendAvailability,
        'primaryGoal': primaryGoal,
        'secondaryGoal': secondaryGoal,
        'targetWeight': targetWeight,
        'targetDate': targetDate?.toIso8601String(),
        'motivationLevel': motivationLevel,
        'challengePreference': challengePreference,
        'workoutLocation': workoutLocation,
        'hasGymAccess': hasGymAccess,
        'hasOutdoorSpace': hasOutdoorSpace,
        'homeEquipment': homeEquipment,
        'climate': climate,
        'workoutSocial': workoutSocial,
        'competitiveness': competitiveness,
        'shareProgress': shareProgress,
        'joinChallenges': joinChallenges,
        'dietType': dietType,
        'dailyCalories': dailyCalories,
        'waterIntake': waterIntake,
        'foodAllergies': foodAllergies,
        'sleepHours': sleepHours,
        'sleepQuality': sleepQuality,
        'wakeTime': wakeTime,
        'recoveryTime': recoveryTime,
        'occupation': occupation,
        'workHours': workHours,
        'sittingHours': sittingHours,
        'standingHours': standingHours,
        'hasKids': hasKids,
        'musicDuringWorkout': musicDuringWorkout,
        'musicGenre': musicGenre,
        'intensityPreference': intensityPreference,
        'durationPreference': durationPreference,
        'likedSports': likedSports,
        'dislikedSports': dislikedSports,
        'wantToTry': wantToTry,
        'favoriteAthlete': favoriteAthlete,
        'stressLevel': stressLevel,
        'hasAnxiety': hasAnxiety,
        'hasDepression': hasDepression,
        'mobilityAids': mobilityAids,
        'visualImpairment': visualImpairment,
        'hearingImpairment': hearingImpairment,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'],
        displayName: json['displayName'],
        email: json['email'],
        age: json['age'] ?? 30,
        fitnessGoal: json['fitnessGoal'] ?? 'general_fitness',
        preferredLocation: json['preferredLocation'] ?? 'home',
        healthConditions: List<String>.from(json['healthConditions'] ?? []),
        dailyTimeAvailable: json['dailyTimeAvailable'] ?? 15,
        availableEquipment:
            List<String>.from(json['availableEquipment'] ?? ['none']),
        totalWorkouts: json['totalWorkouts'] ?? 0,
        streakDays: json['streakDays'] ?? 0,
        lastWorkoutDate: json['lastWorkoutDate'],
        activityLog: json['activityLog'] != null
            ? Map<String, int>.from(json['activityLog'])
            : {},
        experiencePoints: json['experiencePoints'] ?? 0,
        level: json['level'] ?? 1,
        completedChallenges: json['completedChallenges'] != null
            ? Map<String, bool>.from(json['completedChallenges'])
            : {},
        challengeProgress: json['challengeProgress'] != null
            ? Map<String, int>.from(json['challengeProgress'])
            : {},
        unlockedAchievements: json['unlockedAchievements'] != null
            ? List<String>.from(json['unlockedAchievements'])
            : [],

        // New fields
        height: json['height']?.toDouble(),
        weight: json['weight']?.toDouble(),
        bmi: json['bmi']?.toDouble(),
        bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
        gender: json['gender'],
        bloodType: json['bloodType'],
        bodyType: json['bodyType'],
        restingHeartRate: json['restingHeartRate'],
        chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
        pastInjuries: List<String>.from(json['pastInjuries'] ?? []),
        currentInjuries: List<String>.from(json['currentInjuries'] ?? []),
        surgeries: List<String>.from(json['surgeries'] ?? []),
        medications: List<String>.from(json['medications'] ?? []),
        allergies: List<String>.from(json['allergies'] ?? []),
        pregnancyStatus: json['pregnancyStatus'],
        disability: json['disability'],
        fitnessLevel: json['fitnessLevel'],
        yearsActive: json['yearsActive'],
        sportsPlayed: List<String>.from(json['sportsPlayed'] ?? []),
        workoutTypes: List<String>.from(json['workoutTypes'] ?? []),
        maxBenchPress: json['maxBenchPress']?.toDouble(),
        maxSquat: json['maxSquat']?.toDouble(),
        runDistance: json['runDistance']?.toDouble(),
        workoutFrequency: json['workoutFrequency'],
        workoutDuration: json['workoutDuration'],
        preferredTime: json['preferredTime'],
        preferredDays: List<String>.from(json['preferredDays'] ?? []),
        weekendAvailability: json['weekendAvailability'],
        primaryGoal: json['primaryGoal'],
        secondaryGoal: json['secondaryGoal'],
        targetWeight: json['targetWeight']?.toDouble(),
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'])
            : null,
        motivationLevel: json['motivationLevel'],
        challengePreference: json['challengePreference'],
        workoutLocation: json['workoutLocation'],
        hasGymAccess: json['hasGymAccess'],
        hasOutdoorSpace: json['hasOutdoorSpace'],
        homeEquipment: List<String>.from(json['homeEquipment'] ?? []),
        climate: json['climate'],
        workoutSocial: json['workoutSocial'],
        competitiveness: json['competitiveness'],
        shareProgress: json['shareProgress'],
        joinChallenges: json['joinChallenges'],
        dietType: json['dietType'],
        dailyCalories: json['dailyCalories'],
        waterIntake: json['waterIntake'],
        foodAllergies: List<String>.from(json['foodAllergies'] ?? []),
        sleepHours: json['sleepHours']?.toDouble(),
        sleepQuality: json['sleepQuality'],
        wakeTime: json['wakeTime'],
        recoveryTime: json['recoveryTime'],
        occupation: json['occupation'],
        workHours: json['workHours'],
        sittingHours: json['sittingHours'],
        standingHours: json['standingHours'],
        hasKids: json['hasKids'],
        musicDuringWorkout: json['musicDuringWorkout'],
        musicGenre: json['musicGenre'],
        intensityPreference: json['intensityPreference'],
        durationPreference: json['durationPreference'],
        likedSports: List<String>.from(json['likedSports'] ?? []),
        dislikedSports: List<String>.from(json['dislikedSports'] ?? []),
        wantToTry: List<String>.from(json['wantToTry'] ?? []),
        favoriteAthlete: json['favoriteAthlete'],
        stressLevel: json['stressLevel'],
        hasAnxiety: json['hasAnxiety'],
        hasDepression: json['hasDepression'],
        mobilityAids: json['mobilityAids'],
        visualImpairment: json['visualImpairment'],
        hearingImpairment: json['hearingImpairment'],
      );

  bool get hasCompletedOnboarding =>
      age != 0 && fitnessGoal.isNotEmpty && preferredLocation.isNotEmpty;

  bool get isComplete => hasCompletedOnboarding;

  void addExperience(int minutes) {
    experiencePoints += minutes;
    while (experiencePoints >= expForNextLevel) {
      level++;
      // Level up celebration will be triggered in UI
    }
  }

  void updateChallengeProgress(String challengeId, int increment) {
    challengeProgress[challengeId] =
        (challengeProgress[challengeId] ?? 0) + increment;

    // Check if challenge completed (define thresholds)
    int target = _getChallengeTarget(challengeId);
    if (!(completedChallenges[challengeId] ?? false) &&
        challengeProgress[challengeId]! >= target) {
      completedChallenges[challengeId] = true;
      unlockedAchievements.add(challengeId);
      addExperience(50); // Bonus XP for completing challenge
    }
  }

  int _getChallengeTarget(String challengeId) {
    switch (challengeId) {
      case 'daily_30min':
        return 30;
      case 'daily_strength':
        return 2;
      case 'daily_balance':
        return 1;
      default:
        return 1;
    }
  }

  void logWorkout(int minutes) {
    totalWorkouts++;
    final now = DateTime.now();
    lastWorkoutDate = now.toIso8601String();

    final today = now.toIso8601String().split('T')[0];
    activityLog[today] = (activityLog[today] ?? 0) + minutes;

    // Add experience points
    addExperience(minutes);

    // Update challenge progress
    updateChallengeProgress('daily_30min', minutes);
    updateChallengeProgress('daily_strength', 1);
    updateChallengeProgress('daily_balance', 1);

    // Simple streak calculation
    streakDays = activityLog.length;
  }
}
