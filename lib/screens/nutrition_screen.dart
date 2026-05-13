import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import '../services/nutrition_recommendation_engine.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  int _waterIntake = 0;
  final int _dailyWaterGoal = 8; // 8 glasses per day

  // Color scheme
  final Color _primaryColor = const Color(0xFF4CAF50); // Green
  final Color _secondaryColor = const Color(0xFFFF9800); // Orange
  final Color _accentColor = const Color(0xFF2196F3); // Blue
  final Color _backgroundColor = const Color(0xFFF5F5F5); // Light gray

  // Nutrition categories
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.fastfood, 'color': Colors.grey},
    {'name': 'Breakfast', 'icon': Icons.free_breakfast, 'color': Colors.orange},
    {'name': 'Lunch', 'icon': Icons.lunch_dining, 'color': Colors.green},
    {'name': 'Dinner', 'icon': Icons.dinner_dining, 'color': Colors.purple},
    {'name': 'Snacks', 'icon': Icons.cookie, 'color': Colors.brown},
    {'name': 'Drinks', 'icon': Icons.local_drink, 'color': Colors.blue},
    {'name': 'Weight Loss', 'icon': Icons.fitness_center, 'color': Colors.red},
    {'name': 'Muscle Gain', 'icon': Icons.fitness_center, 'color': Colors.teal},
  ];

  // Nutrition tips organized by category
  final List<Map<String, dynamic>> _nutritionTips = [
    // Breakfast tips
    {
      'id': '1',
      'title': 'Power Protein Breakfast',
      'description':
          'Start your day with protein-rich foods to stay full longer and maintain energy.',
      'content':
          'Eggs, Greek yogurt, cottage cheese, or protein smoothie with fruits and spinach.',
      'category': 'Breakfast',
      'icon': Icons.egg,
      'color': Colors.orange,
      'calories': 350,
      'protein': '20g',
      'carbs': '30g',
      'fats': '15g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '2',
      'title': 'Overnight Oats',
      'description':
          'Prepare a healthy breakfast the night before for busy mornings.',
      'content':
          'Mix oats with milk or yogurt, add chia seeds, fruits, and nuts. Refrigerate overnight.',
      'category': 'Breakfast',
      'icon': Icons.free_breakfast,
      'color': Colors.orange,
      'calories': 300,
      'protein': '12g',
      'carbs': '45g',
      'fats': '8g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '3',
      'title': 'Healthy Smoothie Bowl',
      'description':
          'Thick smoothie topped with nutritious ingredients for a satisfying breakfast.',
      'content':
          'Blend frozen bananas, berries, spinach, and protein powder. Top with granola, coconut, and fresh fruits.',
      'category': 'Breakfast',
      'icon': Icons.breakfast_dining,
      'color': Colors.orange,
      'calories': 320,
      'protein': '15g',
      'carbs': '50g',
      'fats': '7g',
      'imageUrl': '',
      'isFavorite': false,
    },

    // Lunch tips
    {
      'id': '4',
      'title': 'Lean Protein Salad',
      'description':
          'A balanced lunch with lean protein and plenty of vegetables.',
      'content':
          'Grilled chicken or tofu over mixed greens with cherry tomatoes, cucumber, and light vinaigrette.',
      'category': 'Lunch',
      'icon': Icons.lunch_dining,
      'color': Colors.green,
      'calories': 400,
      'protein': '35g',
      'carbs': '20g',
      'fats': '15g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '5',
      'title': 'Quinoa Buddha Bowl',
      'description':
          'Nutrient-dense bowl with whole grains and colorful vegetables.',
      'content':
          'Quinoa base with roasted sweet potatoes, chickpeas, avocado, and tahini dressing.',
      'category': 'Lunch',
      'icon': Icons.rice_bowl,
      'color': Colors.green,
      'calories': 450,
      'protein': '15g',
      'carbs': '60g',
      'fats': '18g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '6',
      'title': 'Whole Grain Wrap',
      'description': 'Portable and healthy lunch option with balanced macros.',
      'content':
          'Whole wheat tortilla with hummus, turkey or tempeh, lettuce, tomato, and avocado.',
      'category': 'Lunch',
      'icon': Icons.lunch_dining,
      'color': Colors.green,
      'calories': 380,
      'protein': '25g',
      'carbs': '40g',
      'fats': '12g',
      'imageUrl': '',
      'isFavorite': false,
    },

    // Dinner tips
    {
      'id': '7',
      'title': 'Salmon with Roasted Vegetables',
      'description':
          'Omega-3 rich dinner perfect for recovery and heart health.',
      'content':
          'Baked salmon fillet with asparagus, broccoli, and sweet potatoes. Drizzle with lemon and herbs.',
      'category': 'Dinner',
      'icon': Icons.dinner_dining,
      'color': Colors.purple,
      'calories': 500,
      'protein': '40g',
      'carbs': '35g',
      'fats': '22g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '8',
      'title': 'Lean Turkey Chili',
      'description': 'High-protein, warming dinner that\'s easy to meal prep.',
      'content':
          'Ground turkey, beans, tomatoes, and spices. Top with Greek yogurt and avocado.',
      'category': 'Dinner',
      'icon': Icons.dinner_dining,
      'color': Colors.purple,
      'calories': 420,
      'protein': '38g',
      'carbs': '40g',
      'fats': '12g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '9',
      'title': 'Stir-Fry with Brown Rice',
      'description':
          'Quick and healthy dinner with endless vegetable combinations.',
      'content':
          'Stir-fry your choice of protein with colorful vegetables in low-sodium soy sauce. Serve with brown rice.',
      'category': 'Dinner',
      'icon': Icons.rice_bowl,
      'color': Colors.purple,
      'calories': 450,
      'protein': '30g',
      'carbs': '55g',
      'fats': '10g',
      'imageUrl': '',
      'isFavorite': false,
    },

    // Snacks
    {
      'id': '10',
      'title': 'Greek Yogurt with Berries',
      'description': 'Protein-rich snack that satisfies sweet cravings.',
      'content':
          'Plain Greek yogurt topped with fresh berries and a drizzle of honey.',
      'category': 'Snacks',
      'icon': Icons.cookie,
      'color': Colors.brown,
      'calories': 150,
      'protein': '15g',
      'carbs': '12g',
      'fats': '4g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '11',
      'title': 'Apple with Almond Butter',
      'description': 'Perfect combination of fiber and healthy fats.',
      'content': 'Sliced apple with 1-2 tablespoons of natural almond butter.',
      'category': 'Snacks',
      'icon': Icons.cookie,
      'color': Colors.brown,
      'calories': 200,
      'protein': '5g',
      'carbs': '25g',
      'fats': '10g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '12',
      'title': 'Hummus with Veggies',
      'description': 'Savory snack packed with fiber and plant-based protein.',
      'content':
          'Carrot sticks, cucumber, and bell peppers with 1/4 cup hummus.',
      'category': 'Snacks',
      'icon': Icons.cookie,
      'color': Colors.brown,
      'calories': 150,
      'protein': '5g',
      'carbs': '15g',
      'fats': '8g',
      'imageUrl': '',
      'isFavorite': false,
    },

    // Weight loss specific
    {
      'id': '13',
      'title': 'Volume Eating Strategy',
      'description':
          'Eat more food for fewer calories by choosing low-calorie dense foods.',
      'content':
          'Fill half your plate with vegetables, choose soups and salads, and prioritize whole foods over processed.',
      'category': 'Weight Loss',
      'icon': Icons.fitness_center,
      'color': Colors.red,
      'calories': 0,
      'protein': 'N/A',
      'carbs': 'N/A',
      'fats': 'N/A',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '14',
      'title': 'Meal Prep for Success',
      'description':
          'Prepare meals in advance to avoid unhealthy choices when busy.',
      'content':
          'Spend 2 hours on Sunday prepping ingredients or full meals for the week.',
      'category': 'Weight Loss',
      'icon': Icons.fitness_center,
      'color': Colors.red,
      'calories': 0,
      'protein': 'N/A',
      'carbs': 'N/A',
      'fats': 'N/A',
      'imageUrl': '',
      'isFavorite': false,
    },

    // Muscle gain
    {
      'id': '15',
      'title': 'Post-Workout Nutrition',
      'description':
          'Refuel with protein and carbs within 30 minutes after exercise.',
      'content':
          'Protein shake with banana or chocolate milk for optimal recovery.',
      'category': 'Muscle Gain',
      'icon': Icons.fitness_center,
      'color': Colors.teal,
      'calories': 250,
      'protein': '25g',
      'carbs': '30g',
      'fats': '3g',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '16',
      'title': 'Protein Distribution',
      'description':
          'Spread protein intake throughout the day for better muscle synthesis.',
      'content': 'Aim for 20-40g protein per meal, 3-4 times daily.',
      'category': 'Muscle Gain',
      'icon': Icons.fitness_center,
      'color': Colors.teal,
      'calories': 0,
      'protein': 'N/A',
      'carbs': 'N/A',
      'fats': 'N/A',
      'imageUrl': '',
      'isFavorite': false,
    },

    // Hydration
    {
      'id': '17',
      'title': 'Hydration Calculator',
      'description':
          'Calculate your daily water needs based on activity level.',
      'content':
          'Body weight (lbs) / 2 = ounces of water per day. Add 12 oz for every 30 min of exercise.',
      'category': 'Drinks',
      'icon': Icons.local_drink,
      'color': Colors.blue,
      'calories': 0,
      'protein': 'N/A',
      'carbs': 'N/A',
      'fats': 'N/A',
      'imageUrl': '',
      'isFavorite': false,
    },
    {
      'id': '18',
      'title': 'Infused Water Ideas',
      'description': 'Make water more exciting with natural flavors.',
      'content':
          'Try combinations: strawberry-basil, cucumber-mint, lemon-ginger, or orange-blueberry.',
      'category': 'Drinks',
      'icon': Icons.local_drink,
      'color': Colors.blue,
      'calories': 0,
      'protein': 'N/A',
      'carbs': 'N/A',
      'fats': 'N/A',
      'imageUrl': '',
      'isFavorite': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWaterIntake();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadWaterIntake() {
    setState(() {
      _waterIntake = Random().nextInt(5) + 3; // Random between 3-7
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Nutrition Tips',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Tips', icon: Icon(Icons.lightbulb)),
            Tab(text: 'Meal Plan', icon: Icon(Icons.restaurant_menu)),
            Tab(text: 'Hydration', icon: Icon(Icons.water_drop)),
          ],
        ),
      ),
      body: profile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Complete your profile for personalized nutrition',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTipsTab(profile),
                _buildMealPlannerTab(profile),
                _buildHydrationTab(profile),
              ],
            ),
    );
  }

  // ==================== TIPS TAB ====================
  Widget _buildTipsTab(UserProfile profile) {
    // Filter tips based on selected category
    final filteredTips = _selectedCategory == 'All'
        ? _nutritionTips
        : _nutritionTips
            .where((tip) => tip['category'] == _selectedCategory)
            .toList();

    return Column(
      children: [
        // Category filter chips
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category['name']),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  avatar: Icon(
                    category['icon'],
                    color: isSelected ? Colors.white : category['color'],
                    size: 16,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category['name'] : 'All';
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: category['color'],
                  checkmarkColor: Colors.white,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              );
            },
          ),
        ),

        // Tips grid
        Expanded(
          child: filteredTips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tips in this category yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredTips.length,
                  itemBuilder: (context, index) {
                    final tip = filteredTips[index];
                    return _buildTipCard(tip);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return GestureDetector(
      onTap: () => _showTipDetails(tip),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top colored section
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tip['color'],
                    tip['color'].withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: Icon(
                        tip['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          tip['isFavorite'] = !tip['isFavorite'];
                        });
                      },
                    ),
                  ),
                  Center(
                    child: Icon(
                      tip['icon'],
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['description'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tip['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tip['category'],
                            style: TextStyle(
                              fontSize: 9,
                              color: tip['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (tip['calories'] > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 12,
                                color: Colors.red[300],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${tip['calories']} cal',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTipDetails(Map<String, dynamic> tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tip['color'], tip['color'].withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      tip['icon'],
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tip['category'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tip['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 16),

              // Content/Recipe
              const Text(
                'How to prepare',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tip['content'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),

              if (tip['calories'] > 0) ...[
                const SizedBox(height: 16),

                // Nutrition info
                const Text(
                  'Nutrition (approx)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientChip('${tip['calories']} cal',
                        Icons.local_fire_department, Colors.red),
                    _buildNutrientChip(
                        tip['protein'], Icons.fitness_center, Colors.green),
                    _buildNutrientChip(tip['carbs'], Icons.bolt, Colors.orange),
                    _buildNutrientChip(
                        tip['fats'], Icons.oil_barrel, Colors.brown),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          tip['isFavorite'] = !tip['isFavorite'];
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tip['isFavorite']
                                  ? 'Added to favorites!'
                                  : 'Removed from favorites',
                            ),
                            backgroundColor:
                                tip['isFavorite'] ? Colors.green : Colors.grey,
                          ),
                        );
                      },
                      icon: Icon(tip['isFavorite']
                          ? Icons.favorite
                          : Icons.favorite_border),
                      label: Text(tip['isFavorite'] ? 'Saved' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tip['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildNutrientChip(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MEAL PLANNER TAB ====================
  Widget _buildMealPlannerTab(UserProfile profile) {
    // Get personalized nutrition data from the engine
    final nutritionData =
        NutritionRecommendationEngine.getPersonalizedNutrition(profile);
    final mealPlan = nutritionData['mealPlan'] as List<Map<String, dynamic>>;
    final dailyCalories = nutritionData['dailyCalories'] as int;
    final macros = nutritionData['macros'] as Map<String, int>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with goal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_secondaryColor, _secondaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Personalized Meal Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your goal: ${profile.primaryGoal?.toUpperCase() ?? 'GENERAL FITNESS'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily target: ~$dailyCalories calories',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Daily summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutritionSummary(
                    'Protein', '${macros['protein']}g', _primaryColor),
                _buildNutritionSummary(
                    'Carbs', '${macros['carbs']}g', _accentColor),
                _buildNutritionSummary(
                    'Fats', '${macros['fats']}g', _secondaryColor),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Meal plan by day
          const Text(
            'Weekly Meal Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mealPlan.length,
            itemBuilder: (context, index) {
              final day = mealPlan[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          day['day'][0],
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      day['day'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${day['calories']} calories • ${day['meals'].length} meals + ${day['snacks'].length} snacks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    children: [
                      ...day['meals'].map<Widget>((meal) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:
                                  _getMealColor(meal['type']).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getMealIcon(meal['type']),
                              color: _getMealColor(meal['type']),
                              size: 16,
                            ),
                          ),
                          title: Text(meal['name']),
                          subtitle: Text(
                              '${meal['calories']} cal • P:${meal['protein']}g C:${meal['carbs']}g F:${meal['fats']}g'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              meal['time'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      ...day['snacks'].map<Widget>((snack) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cookie,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                          title: Text(snack['name']),
                          subtitle: Text('${snack['calories']} cal • Snack'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              snack['time'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== HYDRATION TAB (COMPLETELY FIXED) ====================
  Widget _buildHydrationTab(UserProfile profile) {
    // Get personalized hydration goal from engine
    final nutritionData =
        NutritionRecommendationEngine.getPersonalizedNutrition(profile);
    final recommendedWater = nutritionData['hydrationGoal'] as int;
    final waterProgress = _waterIntake / recommendedWater;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water tracking card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Water Intake',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_waterIntake of $recommendedWater glasses',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: waterProgress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildWaterButton('-', () {
                      if (_waterIntake > 0) {
                        setState(() => _waterIntake--);
                      }
                    }),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_waterIntake / $recommendedWater',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildWaterButton('+', () {
                      if (_waterIntake < recommendedWater) {
                        setState(() => _waterIntake++);
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Hydration tips
          const Text(
            'Hydration Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildHydrationTip(
            'Start Your Day Right',
            'Drink a glass of water as soon as you wake up to rehydrate after sleep.',
            Icons.wb_sunny,
            Colors.orange,
          ),
          _buildHydrationTip(
            'Track Your Intake',
            'Use marked water bottles or apps to track your daily water consumption.',
            Icons.track_changes,
            Colors.blue,
          ),
          _buildHydrationTip(
            'Hydrate Before Meals',
            'Drinking water 30 minutes before meals can aid digestion and portion control.',
            Icons.restaurant,
            Colors.green,
          ),
          _buildHydrationTip(
            'Electrolyte Balance',
            'For intense workouts, consider adding electrolytes to your water.',
            Icons.bolt,
            Colors.purple,
          ),
          _buildHydrationTip(
            'Infused Water Ideas',
            'Add fruits, herbs, or cucumber to make water more enjoyable.',
            Icons.emoji_food_beverage,
            Colors.teal,
          ),

          const SizedBox(height: 20),

          // Hydration facts
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why Hydration Matters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // FIXED: Replaced Icons.energy with Icons.flash_on
                _buildHydrationFact(
                    Icons.flash_on, 'Boosts energy and brain function'),
                _buildHydrationFact(
                    Icons.fitness_center, 'Improves workout performance'),
                // FIXED: Replaced Icons.skin with Icons.face
                _buildHydrationFact(Icons.face, 'Promotes healthy skin'),
                _buildHydrationFact(Icons.kitchen, 'Aids digestion'),
                _buildHydrationFact(
                    Icons.thermostat, 'Regulates body temperature'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterButton(String label, VoidCallback onPressed) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHydrationTip(
      String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationFact(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Colors.orange;
      case 'Lunch':
        return Colors.green;
      case 'Dinner':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}
