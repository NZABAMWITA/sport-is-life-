import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserProfile? initialProfile;
  const ProfileSetupScreen({super.key, this.initialProfile});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Basic Info
  int _age = 30;
  String _fitnessGoal = 'general_fitness';
  String _preferredLocation = 'home';
  List<String> _healthConditions = [];
  int _dailyTimeAvailable = 15;
  List<String> _availableEquipment = ['none'];

  // Physical Attributes
  double? _height;
  double? _weight;
  String? _gender;
  String? _bloodType;
  String? _bodyType;
  int? _restingHeartRate;

  // Health & Medical
  List<String> _chronicConditions = [];
  List<String> _pastInjuries = [];
  List<String> _currentInjuries = [];
  List<String> _surgeries = [];
  List<String> _medications = [];
  List<String> _allergies = [];
  String? _pregnancyStatus;
  String? _disability;

  // Fitness Experience
  String? _fitnessLevel;
  int? _yearsActive;
  List<String> _sportsPlayed = [];
  List<String> _workoutTypes = [];
  double? _maxBenchPress;
  double? _maxSquat;
  double? _runDistance;

  // Schedule & Time
  int? _workoutFrequency;
  int? _workoutDuration;
  String? _preferredTime;
  List<String> _preferredDays = [];
  bool _weekendAvailability = true;

  // Goals & Motivation
  String? _primaryGoal;
  String? _secondaryGoal;
  double? _targetWeight;
  DateTime? _targetDate;
  String? _motivationLevel;
  String? _challengePreference;

  // Environment & Resources
  String? _workoutLocation;
  bool? _hasGymAccess;
  bool? _hasOutdoorSpace;
  List<String> _homeEquipment = [];
  String? _climate;

  // Social Preferences
  String? _workoutSocial;
  String? _competitiveness;
  bool _shareProgress = false;
  bool _joinChallenges = false;

  // Diet & Nutrition
  String? _dietType;
  int? _dailyCalories;
  int? _waterIntake;
  List<String> _foodAllergies = [];

  // Sleep & Recovery
  double? _sleepHours;
  String? _sleepQuality;
  String? _wakeTime;
  int? _recoveryTime;

  // Lifestyle
  String? _occupation;
  int? _workHours;
  int? _sittingHours;
  int? _standingHours;
  bool _hasKids = false;

  // Preferences
  bool _musicDuringWorkout = false;
  String? _musicGenre;
  String? _intensityPreference;
  String? _durationPreference;

  // Interests
  List<String> _likedSports = [];
  List<String> _dislikedSports = [];
  List<String> _wantToTry = [];
  String? _favoriteAthlete;

  // Mental Health
  String? _stressLevel;
  bool _hasAnxiety = false;
  bool _hasDepression = false;

  // Accessibility
  String? _mobilityAids;
  bool _visualImpairment = false;
  bool _hearingImpairment = false;

  // Options Lists
  final List<String> _fitnessGoals = [
    'weight_loss',
    'strength',
    'flexibility',
    'balance',
    'cardio',
    'general_fitness',
  ];

  final List<String> _locations = ['home', 'office', 'park', 'gym', 'anywhere'];

  final List<String> _healthOptions = [
    'knee pain',
    'back pain',
    'high blood pressure',
    'diabetes',
    'asthma',
    'arthritis',
    'heart condition',
  ];

  final List<String> _equipmentOptions = [
    'none',
    'chair',
    'mat',
    'light weights',
    'resistance bands',
    'dumbbells',
    'treadmill',
    'exercise bike',
  ];

  final List<String> _genders = [
    'male',
    'female',
    'other',
    'prefer_not_to_say'
  ];
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
    'unknown'
  ];
  final List<String> _bodyTypes = [
    'ectomorph',
    'mesomorph',
    'endomorph',
    'unknown'
  ];

  final List<String> _fitnessLevels = [
    'beginner',
    'intermediate',
    'advanced',
    'athlete'
  ];
  final List<String> _sportsOptions = [
    'Running',
    'Swimming',
    'Cycling',
    'Yoga',
    'Weightlifting',
    'Dancing',
    'Martial Arts',
    'Pilates',
    'Boxing'
  ];
  final List<String> _workoutTypeOptions = [
    'Cardio',
    'Strength',
    'Flexibility',
    'Balance',
    'HIIT',
    'Pilates'
  ];

  final List<String> _preferredTimes = [
    'morning',
    'afternoon',
    'evening',
    'night',
    'flexible'
  ];
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> _primaryGoals = [
    'weight loss',
    'muscle gain',
    'stress relief',
    'rehabilitation',
    'general fitness'
  ];
  final List<String> _motivationLevels = ['low', 'medium', 'high', 'very high'];

  final List<String> _workoutLocations = [
    'home',
    'gym',
    'park',
    'office',
    'mixed'
  ];
  final List<String> _climates = ['tropical', 'temperate', 'cold', 'arid'];

  final List<String> _workoutSocials = [
    'alone',
    'partner',
    'group',
    'trainer',
    'mixed'
  ];
  final List<String> _competitivenessLevels = [
    'not competitive',
    'somewhat',
    'very'
  ];

  final List<String> _dietTypes = [
    'vegetarian',
    'vegan',
    'keto',
    'paleo',
    'mediterranean',
    'none'
  ];
  final List<String> _sleepQualities = ['poor', 'fair', 'good', 'excellent'];
  final List<String> _wakeTimes = ['early bird', 'night owl', 'flexible'];

  final List<String> _intensityPreferences = ['low', 'moderate', 'high'];
  final List<String> _durationPreferences = [
    'short (<15min)',
    'medium (15-30min)',
    'long (>30min)'
  ];
  final List<String> _musicGenres = [
    'upbeat',
    'rock',
    'pop',
    'electronic',
    'calm',
    'none'
  ];

  final List<String> _stressLevels = ['low', 'moderate', 'high', 'severe'];
  final List<String> _mobilityAidsList = [
    'none',
    'cane',
    'walker',
    'wheelchair'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialProfile();
  }

  void _loadInitialProfile() {
    final profile = widget.initialProfile;
    if (profile != null) {
      // Basic Info
      _age = profile.age;
      _fitnessGoal = profile.fitnessGoal;
      _preferredLocation = profile.preferredLocation;
      _healthConditions = List.from(profile.healthConditions);
      _dailyTimeAvailable = profile.dailyTimeAvailable;
      _availableEquipment = List.from(profile.availableEquipment);

      // Physical
      _height = profile.height;
      _weight = profile.weight;
      _gender = profile.gender;
      _bloodType = profile.bloodType;
      _bodyType = profile.bodyType;
      _restingHeartRate = profile.restingHeartRate;

      // Health
      _chronicConditions = List.from(profile.chronicConditions ?? const []);
      _pastInjuries = List.from(profile.pastInjuries ?? const []);
      _currentInjuries = List.from(profile.currentInjuries ?? const []);
      _surgeries = List.from(profile.surgeries ?? const []);
      _medications = List.from(profile.medications);
      _allergies = List.from(profile.allergies);
      _pregnancyStatus = profile.pregnancyStatus;
      _disability = profile.disability;

      // Fitness
      _fitnessLevel = profile.fitnessLevel;
      _yearsActive = profile.yearsActive;
      _sportsPlayed = List.from(profile.sportsPlayed ?? const []);
      _workoutTypes = List.from(profile.workoutTypes ?? const []);
      _maxBenchPress = profile.maxBenchPress;
      _maxSquat = profile.maxSquat;
      _runDistance = profile.runDistance;

      // Schedule
      _workoutFrequency = profile.workoutFrequency;
      _workoutDuration = profile.workoutDuration;
      _preferredTime = profile.preferredTime;
      _preferredDays = List.from(profile.preferredDays);
      _weekendAvailability = profile.weekendAvailability ?? true;

      // Goals
      _primaryGoal = profile.primaryGoal;
      _secondaryGoal = profile.secondaryGoal;
      _targetWeight = profile.targetWeight;
      _targetDate = profile.targetDate;
      _motivationLevel = profile.motivationLevel;
      _challengePreference = profile.challengePreference;

      // Environment
      _workoutLocation = profile.workoutLocation;
      _hasGymAccess = profile.hasGymAccess;
      _hasOutdoorSpace = profile.hasOutdoorSpace;
      _homeEquipment = List.from(profile.homeEquipment ?? const []);
      _climate = profile.climate;

      // Social
      _workoutSocial = profile.workoutSocial;
      _competitiveness = profile.competitiveness;
      _shareProgress = profile.shareProgress ?? false;
      _joinChallenges = profile.joinChallenges ?? false;

      // Diet
      _dietType = profile.dietType;
      _dailyCalories = profile.dailyCalories;
      _waterIntake = profile.waterIntake;
      _foodAllergies = List.from(profile.foodAllergies ?? const []);

      // Sleep
      _sleepHours = profile.sleepHours;
      _sleepQuality = profile.sleepQuality;
      _wakeTime = profile.wakeTime;
      _recoveryTime = profile.recoveryTime;

      // Lifestyle
      _occupation = profile.occupation;
      _workHours = profile.workHours;
      _sittingHours = profile.sittingHours;
      _standingHours = profile.standingHours;
      _hasKids = profile.hasKids ?? false;

      // Preferences
      _musicDuringWorkout = profile.musicDuringWorkout ?? false;
      _musicGenre = profile.musicGenre;
      _intensityPreference = profile.intensityPreference;
      _durationPreference = profile.durationPreference;

      // Interests
      _likedSports = List.from(profile.likedSports ?? const []);
      _dislikedSports = List.from(profile.dislikedSports ?? const []);
      _wantToTry = List.from(profile.wantToTry ?? const []);
      _favoriteAthlete = profile.favoriteAthlete;

      // Mental
      _stressLevel = profile.stressLevel;
      _hasAnxiety = profile.hasAnxiety ?? false;
      _hasDepression = profile.hasDepression ?? false;

      // Accessibility
      _mobilityAids = profile.mobilityAids;
      _visualImpairment = profile.visualImpairment ?? false;
      _hearingImpairment = profile.hearingImpairment ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔥 ProfileSetupScreen build() called');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialProfile == null
            ? 'Setup Your Profile'
            : 'Edit Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 15,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildBasicStep(),
                _buildPhysicalStep(),
                _buildHealthStep(),
                _buildMedicalStep(),
                _buildFitnessStep(),
                _buildScheduleStep(),
                _buildGoalsStep(),
                _buildEnvironmentStep(),
                _buildSocialStep(),
                _buildDietStep(),
                _buildSleepStep(),
                _buildLifestyleStep(),
                _buildPreferencesStep(),
                _buildInterestsStep(),
                _buildMentalStep(),
                _buildSummaryStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentPage < 15
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            )
                        : _saveProfile,
                    child: Text(_currentPage < 15 ? 'Next' : 'Complete'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Basic Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSliderField(
                'Age', _age.toDouble(), 10, 90, (val) => _age = val.toInt()),
            const SizedBox(height: 20),
            const Text('Fitness Goal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ..._fitnessGoals.map((goal) => RadioListTile<String>(
                  title: Text(goal.replaceAll('_', ' ').toUpperCase()),
                  value: goal,
                  groupValue: _fitnessGoal,
                  onChanged: (value) => setState(() => _fitnessGoal = value!),
                )),
            const SizedBox(height: 20),
            const Text('Preferred Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ..._locations.map((loc) => RadioListTile<String>(
                  title: Text(loc[0].toUpperCase() + loc.substring(1)),
                  value: loc,
                  groupValue: _preferredLocation,
                  onChanged: (value) =>
                      setState(() => _preferredLocation = value!),
                )),
            const SizedBox(height: 20),
            _buildSliderField(
                'Daily Time Available (minutes)',
                _dailyTimeAvailable.toDouble(),
                5,
                60,
                (val) => _dailyTimeAvailable = val.toInt()),
            const SizedBox(height: 20),
            const Text('Equipment You Have',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ..._equipmentOptions.map((eq) => CheckboxListTile(
                  title: Text(eq),
                  value: _availableEquipment.contains(eq),
                  onChanged: (checked) {
                    setState(() {
                      if (checked!) {
                        _availableEquipment.add(eq);
                      } else {
                        _availableEquipment.remove(eq);
                      }
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Physical Attributes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(
                'Height (cm)', _height, (val) => _height = double.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(
                'Weight (kg)', _weight, (val) => _weight = double.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildDropdownField(
                'Gender', _gender, _genders, (val) => _gender = val),
            const SizedBox(height: 12),
            _buildDropdownField('Blood Type', _bloodType, _bloodTypes,
                (val) => _bloodType = val),
            const SizedBox(height: 12),
            _buildDropdownField(
                'Body Type', _bodyType, _bodyTypes, (val) => _bodyType = val),
            const SizedBox(height: 12),
            _buildTextField('Resting Heart Rate (bpm)', _restingHeartRate,
                (val) => _restingHeartRate = int.tryParse(val),
                keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Health Conditions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('General Health Conditions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ..._healthOptions.map((condition) => CheckboxListTile(
                  title: Text(condition),
                  value: _healthConditions.contains(condition),
                  onChanged: (checked) {
                    setState(() {
                      if (checked!) {
                        _healthConditions.add(condition);
                      } else {
                        _healthConditions.remove(condition);
                      }
                    });
                  },
                )),
            const SizedBox(height: 20),
            const Text('Chronic Conditions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: [
                'Diabetes',
                'Hypertension',
                'Asthma',
                'Arthritis',
                'Thyroid'
              ],
              selectedList: _chronicConditions,
              onChanged: (list) => _chronicConditions = list,
            ),
            const SizedBox(height: 20),
            const Text('Current Injuries',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: [
                'Back pain',
                'Knee pain',
                'Shoulder pain',
                'Neck pain',
                'Ankle sprain'
              ],
              selectedList: _currentInjuries,
              onChanged: (list) => _currentInjuries = list,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medical History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Past Injuries',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: [
                'ACL tear',
                'Ankle sprain',
                'Shoulder dislocation',
                'Fracture',
                'Concussion'
              ],
              selectedList: _pastInjuries,
              onChanged: (list) => _pastInjuries = list,
            ),
            const SizedBox(height: 20),
            const Text('Surgeries',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: [
                'Appendectomy',
                'Knee surgery',
                'Shoulder surgery',
                'C-section'
              ],
              selectedList: _surgeries,
              onChanged: (list) => _surgeries = list,
            ),
            const SizedBox(height: 20),
            _buildTextField(
                'Medications (comma separated)',
                _medications.join(', '),
                (val) => _medications =
                    val.split(',').map((e) => e.trim()).toList()),
            const SizedBox(height: 12),
            _buildTextField(
                'Allergies (comma separated)',
                _allergies.join(', '),
                (val) =>
                    _allergies = val.split(',').map((e) => e.trim()).toList()),
            const SizedBox(height: 12),
            _buildDropdownField(
                'Pregnancy Status',
                _pregnancyStatus,
                [
                  'not_pregnant',
                  'pregnant',
                  'postpartum',
                  'trying',
                  'not_applicable'
                ],
                (val) => _pregnancyStatus = val),
            const SizedBox(height: 12),
            _buildDropdownField(
                'Disability',
                _disability,
                ['none', 'mobility', 'visual', 'hearing', 'cognitive', 'other'],
                (val) => _disability = val),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fitness Experience',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDropdownField('Fitness Level', _fitnessLevel, _fitnessLevels,
                (val) => _fitnessLevel = val),
            const SizedBox(height: 12),
            _buildTextField('Years Active', _yearsActive,
                (val) => _yearsActive = int.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            const Text('Sports Played',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: _sportsOptions,
              selectedList: _sportsPlayed,
              onChanged: (list) => _sportsPlayed = list,
            ),
            const SizedBox(height: 20),
            const Text('Workout Types',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: _workoutTypeOptions,
              selectedList: _workoutTypes,
              onChanged: (list) => _workoutTypes = list,
            ),
            const SizedBox(height: 20),
            _buildTextField('Max Bench Press (kg)', _maxBenchPress,
                (val) => _maxBenchPress = double.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Max Squat (kg)', _maxSquat,
                (val) => _maxSquat = double.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Max Run Distance (km)', _runDistance,
                (val) => _runDistance = double.tryParse(val),
                keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Schedule & Time',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDropdownField('Workouts per Week', _workoutFrequency,
                [1, 2, 3, 4, 5, 6, 7], (val) => _workoutFrequency = val),
            const SizedBox(height: 12),
            _buildDropdownField('Workout Duration (min)', _workoutDuration,
                [15, 20, 25, 30, 45, 60, 90], (val) => _workoutDuration = val),
            const SizedBox(height: 12),
            _buildDropdownField('Preferred Time', _preferredTime,
                _preferredTimes, (val) => _preferredTime = val),
            const SizedBox(height: 12),
            const Text('Preferred Days',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: _daysOfWeek,
              selectedList: _preferredDays,
              onChanged: (list) => _preferredDays = list,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Weekend Availability'),
              value: _weekendAvailability,
              onChanged: (value) =>
                  setState(() => _weekendAvailability = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goals & Motivation',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDropdownField('Primary Goal', _primaryGoal, _primaryGoals,
                (val) => _primaryGoal = val),
            const SizedBox(height: 12),
            _buildDropdownField('Secondary Goal', _secondaryGoal, _primaryGoals,
                (val) => _secondaryGoal = val),
            const SizedBox(height: 12),
            _buildTextField('Target Weight (kg)', _targetWeight,
                (val) => _targetWeight = double.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildDatePicker(
                'Target Date', _targetDate, (date) => _targetDate = date),
            const SizedBox(height: 12),
            _buildDropdownField('Motivation Level', _motivationLevel,
                _motivationLevels, (val) => _motivationLevel = val),
            const SizedBox(height: 12),
            _buildDropdownField(
                'Challenge Preference',
                _challengePreference,
                ['yes', 'no', 'sometimes'],
                (val) => _challengePreference = val),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Environment & Resources',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDropdownField('Workout Location', _workoutLocation,
                _workoutLocations, (val) => _workoutLocation = val),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Gym Access'),
              value: _hasGymAccess ?? false,
              onChanged: (value) => setState(() => _hasGymAccess = value),
            ),
            SwitchListTile(
              title: const Text('Outdoor Space'),
              value: _hasOutdoorSpace ?? false,
              onChanged: (value) => setState(() => _hasOutdoorSpace = value),
            ),
            const SizedBox(height: 12),
            const Text('Home Equipment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: _equipmentOptions,
              selectedList: _homeEquipment,
              onChanged: (list) => _homeEquipment = list,
            ),
            const SizedBox(height: 12),
            _buildDropdownField(
                'Climate', _climate, _climates, (val) => _climate = val),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Social Preferences',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDropdownField('Workout Style', _workoutSocial,
                _workoutSocials, (val) => _workoutSocial = val),
            const SizedBox(height: 12),
            _buildDropdownField('Competitiveness', _competitiveness,
                _competitivenessLevels, (val) => _competitiveness = val),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Share Progress on Social Media'),
              value: _shareProgress,
              onChanged: (value) => setState(() => _shareProgress = value),
            ),
            SwitchListTile(
              title: const Text('Join Challenges'),
              value: _joinChallenges,
              onChanged: (value) => setState(() => _joinChallenges = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Diet & Nutrition',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDropdownField(
                'Diet Type', _dietType, _dietTypes, (val) => _dietType = val),
            const SizedBox(height: 12),
            _buildTextField('Daily Calories', _dailyCalories,
                (val) => _dailyCalories = int.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Water Intake (glasses)', _waterIntake,
                (val) => _waterIntake = int.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            const Text('Food Allergies',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: ['Nuts', 'Dairy', 'Gluten', 'Shellfish', 'Eggs', 'Soy'],
              selectedList: _foodAllergies,
              onChanged: (list) => _foodAllergies = list,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sleep & Recovery',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField('Sleep Hours', _sleepHours,
                (val) => _sleepHours = double.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildDropdownField('Sleep Quality', _sleepQuality, _sleepQualities,
                (val) => _sleepQuality = val),
            const SizedBox(height: 12),
            _buildDropdownField(
                'Wake Time', _wakeTime, _wakeTimes, (val) => _wakeTime = val),
            const SizedBox(height: 12),
            _buildTextField('Recovery Time (hours)', _recoveryTime,
                (val) => _recoveryTime = int.tryParse(val),
                keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lifestyle',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDropdownField(
                'Occupation',
                _occupation,
                [
                  'sedentary',
                  'active',
                  'manual labor',
                  'remote',
                  'student',
                  'retired'
                ],
                (val) => _occupation = val),
            const SizedBox(height: 12),
            _buildTextField('Work Hours per Day', _workHours,
                (val) => _workHours = int.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Sitting Hours per Day', _sittingHours,
                (val) => _sittingHours = int.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField('Standing Hours per Day', _standingHours,
                (val) => _standingHours = int.tryParse(val),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Have Children'),
              value: _hasKids,
              onChanged: (value) => setState(() => _hasKids = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Workout Preferences',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Music During Workout'),
              value: _musicDuringWorkout,
              onChanged: (value) => setState(() => _musicDuringWorkout = value),
            ),
            if (_musicDuringWorkout)
              _buildDropdownField('Music Genre', _musicGenre, _musicGenres,
                  (val) => _musicGenre = val),
            const SizedBox(height: 12),
            _buildDropdownField('Intensity Preference', _intensityPreference,
                _intensityPreferences, (val) => _intensityPreference = val),
            const SizedBox(height: 12),
            _buildDropdownField('Duration Preference', _durationPreference,
                _durationPreferences, (val) => _durationPreference = val),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sports Interests',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Liked Sports',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: _sportsOptions,
              selectedList: _likedSports,
              onChanged: (list) => _likedSports = list,
            ),
            const SizedBox(height: 20),
            const Text('Disliked Sports',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: _sportsOptions,
              selectedList: _dislikedSports,
              onChanged: (list) => _dislikedSports = list,
            ),
            const SizedBox(height: 20),
            const Text('Want to Try',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildMultiSelectChip(
              items: _sportsOptions,
              selectedList: _wantToTry,
              onChanged: (list) => _wantToTry = list,
            ),
            const SizedBox(height: 12),
            _buildTextField('Favorite Athlete', _favoriteAthlete,
                (val) => _favoriteAthlete = val),
          ],
        ),
      ),
    );
  }

  Widget _buildMentalStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mental Health',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDropdownField('Stress Level', _stressLevel, _stressLevels,
                (val) => _stressLevel = val),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Anxiety'),
              value: _hasAnxiety,
              onChanged: (value) => setState(() => _hasAnxiety = value),
            ),
            SwitchListTile(
              title: const Text('Depression'),
              value: _hasDepression,
              onChanged: (value) => setState(() => _hasDepression = value),
            ),
            const SizedBox(height: 12),
            _buildDropdownField('Mobility Aids', _mobilityAids,
                _mobilityAidsList, (val) => _mobilityAids = val),
            SwitchListTile(
              title: const Text('Visual Impairment'),
              value: _visualImpairment,
              onChanged: (value) => setState(() => _visualImpairment = value),
            ),
            SwitchListTile(
              title: const Text('Hearing Impairment'),
              value: _hearingImpairment,
              onChanged: (value) => setState(() => _hearingImpairment = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Your Info',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryItem('Age', '$_age years'),
                    _buildSummaryItem(
                        'Goal', _fitnessGoal.replaceAll('_', ' ')),
                    _buildSummaryItem('Location', _preferredLocation),
                    _buildSummaryItem(
                        'Health',
                        _healthConditions.isEmpty
                            ? 'None'
                            : _healthConditions.join(', ')),
                    _buildSummaryItem('Time', '$_dailyTimeAvailable min/day'),
                    _buildSummaryItem(
                        'Equipment', _availableEquipment.join(', ')),
                    if (_height != null)
                      _buildSummaryItem('Height', '$_height cm'),
                    if (_weight != null)
                      _buildSummaryItem('Weight', '$_weight kg'),
                    if (_gender != null) _buildSummaryItem('Gender', _gender!),
                    if (_fitnessLevel != null)
                      _buildSummaryItem('Fitness Level', _fitnessLevel!),
                    if (_primaryGoal != null)
                      _buildSummaryItem('Primary Goal', _primaryGoal!),
                    if (_likedSports.isNotEmpty)
                      _buildSummaryItem(
                          'Liked Sports', _likedSports.join(', ')),
                    if (_workoutSocial != null)
                      _buildSummaryItem('Workout Style', _workoutSocial!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSliderField(String label, double value, double min, double max,
      Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
        Center(
            child: Text(
                '${value.toInt()} ${label.contains('Age') ? 'years' : 'min'}',
                style: const TextStyle(fontSize: 18))),
      ],
    );
  }

  Widget _buildTextField(
      String label, dynamic value, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField<T>(
      String label, T? value, List<T> items, Function(T?) onChanged) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item.toString().replaceAll('_', ' ')),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMultiSelectChip({
    required List<String> items,
    required List<String> selectedList,
    required Function(List<String>) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      children: items.map((item) {
        final isSelected = selectedList.contains(item);
        return FilterChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              selectedList.add(item);
            } else {
              selectedList.remove(item);
            }
            onChanged(List.from(selectedList));
          },
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? value, Function(DateTime?) onChanged) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value != null
          ? '${value.day}/${value.month}/${value.year}'
          : 'Not set'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _saveProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final profile = UserProfile(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
      age: _age,
      fitnessGoal: _fitnessGoal,
      preferredLocation: _preferredLocation,
      healthConditions: _healthConditions,
      dailyTimeAvailable: _dailyTimeAvailable,
      availableEquipment: _availableEquipment,

      // Physical
      height: _height,
      weight: _weight,
      gender: _gender,
      bloodType: _bloodType,
      bodyType: _bodyType,
      restingHeartRate: _restingHeartRate,

      // Health
      chronicConditions: _chronicConditions,
      pastInjuries: _pastInjuries,
      currentInjuries: _currentInjuries,
      surgeries: _surgeries,
      medications: _medications,
      allergies: _allergies,
      pregnancyStatus: _pregnancyStatus,
      disability: _disability,

      // Fitness
      fitnessLevel: _fitnessLevel,
      yearsActive: _yearsActive,
      sportsPlayed: _sportsPlayed,
      workoutTypes: _workoutTypes,
      maxBenchPress: _maxBenchPress,
      maxSquat: _maxSquat,
      runDistance: _runDistance,

      // Schedule
      workoutFrequency: _workoutFrequency,
      workoutDuration: _workoutDuration,
      preferredTime: _preferredTime,
      preferredDays: _preferredDays,
      weekendAvailability: _weekendAvailability,

      // Goals
      primaryGoal: _primaryGoal,
      secondaryGoal: _secondaryGoal,
      targetWeight: _targetWeight,
      targetDate: _targetDate,
      motivationLevel: _motivationLevel,
      challengePreference: _challengePreference,

      // Environment
      workoutLocation: _workoutLocation,
      hasGymAccess: _hasGymAccess,
      hasOutdoorSpace: _hasOutdoorSpace,
      homeEquipment: _homeEquipment,
      climate: _climate,

      // Social
      workoutSocial: _workoutSocial,
      competitiveness: _competitiveness,
      shareProgress: _shareProgress,
      joinChallenges: _joinChallenges,

      // Diet
      dietType: _dietType,
      dailyCalories: _dailyCalories,
      waterIntake: _waterIntake,
      foodAllergies: _foodAllergies,

      // Sleep
      sleepHours: _sleepHours,
      sleepQuality: _sleepQuality,
      wakeTime: _wakeTime,
      recoveryTime: _recoveryTime,

      // Lifestyle
      occupation: _occupation,
      workHours: _workHours,
      sittingHours: _sittingHours,
      standingHours: _standingHours,
      hasKids: _hasKids,

      // Preferences
      musicDuringWorkout: _musicDuringWorkout,
      musicGenre: _musicGenre,
      intensityPreference: _intensityPreference,
      durationPreference: _durationPreference,

      // Interests
      likedSports: _likedSports,
      dislikedSports: _dislikedSports,
      wantToTry: _wantToTry,
      favoriteAthlete: _favoriteAthlete,

      // Mental
      stressLevel: _stressLevel,
      hasAnxiety: _hasAnxiety,
      hasDepression: _hasDepression,

      // Accessibility
      mobilityAids: _mobilityAids,
      visualImpairment: _visualImpairment,
      hearingImpairment: _hearingImpairment,

      // Gamification fields
      totalWorkouts: widget.initialProfile?.totalWorkouts ?? 0,
      streakDays: widget.initialProfile?.streakDays ?? 0,
      lastWorkoutDate: widget.initialProfile?.lastWorkoutDate,
      activityLog: widget.initialProfile?.activityLog ?? {},
      experiencePoints: widget.initialProfile?.experiencePoints ?? 0,
      level: widget.initialProfile?.level ?? 1,
      completedChallenges: widget.initialProfile?.completedChallenges ?? {},
      challengeProgress: widget.initialProfile?.challengeProgress ?? {},
      unlockedAchievements: widget.initialProfile?.unlockedAchievements ?? [],
    );

    // ✅ Save to UserProvider (which now saves to Firestore AND SharedPreferences)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUserProfile(profile);

    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_${firebaseUser.uid}', true);

    if (mounted) {
      Navigator.pop(context); // Return to previous screen (profile screen)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
