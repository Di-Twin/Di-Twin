import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/food_management/domain/entities/food_item.dart';
import 'package:client/features/food_management/presentation/widgets/food_grid_item.dart';
import 'package:client/features/food_management/presentation/widgets/sugar_spike_widget.dart';
import 'package:client/features/food_management/presentation/widgets/food_impact_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/food_management_provider.dart';
import 'package:intl/intl.dart';

class AddFoodBottomSheet extends ConsumerStatefulWidget {
  final String mealType;
  final List<Map<String, dynamic>> popularFoods;

  const AddFoodBottomSheet({
    super.key,
    required this.mealType,
    required this.popularFoods,
  });

  @override
  ConsumerState<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends ConsumerState<AddFoodBottomSheet> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Track if search is active
  bool _isSearching = false;

  // Search results
  List<Map<String, dynamic>> _searchResults = [];

  // Selected food
  Map<String, dynamic>? _selectedFood;

  // Food impact data
  Map<String, dynamic>? _impactData;

  // Loading states
  bool _isLoadingImpact = false;
  bool _isAddingFood = false;

  @override
  void initState() {
    super.initState();
    _searchResults = List.from(widget.popularFoods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Search for foods
  void _searchFoods(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = List.from(widget.popularFoods);
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults =
          widget.popularFoods
              .where(
                (food) => food['name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  // Select food and calculate impact
  Future<void> _selectFood(Map<String, dynamic> food) async {
    setState(() {
      _selectedFood = food;
      _isLoadingImpact = true;
    });

    // Add mealType to the food data
    _selectedFood!['mealType'] = widget.mealType;

    // Calculate food impact
    final impactData = await FoodImpactCalculator.calculateImpact(food, ref);

    setState(() {
      _impactData = impactData;
      _isLoadingImpact = false;
    });
  }

  // Add food to meal
  Future<void> _addFoodToMeal() async {
    if (_selectedFood == null) return;

    setState(() {
      _isAddingFood = true;
    });

    try {
      final foodProvider = FoodManagementProvider();
      
      // Create food data with current date and meal type
      final foodData = Map<String, dynamic>.from(_selectedFood!);
      foodData['date'] = DateTime.now().toIso8601String();
      foodData['mealType'] = widget.mealType;
      foodData['time'] = DateFormat('HH:mm').format(DateTime.now());
      foodData['foodName'] = foodData['name']; // Ensure name is mapped correctly

      // Convert to FoodItem object
      final FoodItem foodItem = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: foodData['name'],
        calories: foodData['calories'] ?? 0,
        weight: foodData['weight'] ?? '0g',  // Add the missing weight parameter
        protein: foodData['protein'] ?? 0,
        carbs: foodData['carbs'] ?? 0,
        fat: foodData['fat'] ?? 0,
        mealType: widget.mealType,
        time: foodData['time'] ?? '',
        date: DateTime.now(),
        color: foodData['color'] ?? Colors.blue,
      );

      // Add food item to the API
      await foodProvider.addFoodItem(widget.mealType, foodData);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${foodData['name']} added to ${widget.mealType}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Close the bottom sheet
      Navigator.pop(context, true);
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add food: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isAddingFood = false;
      });
    }
  }

  // Add custom food
  void _showAddCustomFoodDialog() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    // Create a map to store the custom food data
    final customFood = <String, dynamic>{};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Food Name*'),
              ),
              TextField(
                controller: caloriesController,
                decoration: InputDecoration(labelText: 'Calories*'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: TextEditingController(),
                decoration: InputDecoration(labelText: 'Weight (g)*'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Store the weight in the form
                  if (value.isNotEmpty) {
                    // Add 'g' suffix if the user doesn't include it
                    final weightText = value.toLowerCase().endsWith('g') ? value : '${value}g';
                    customFood['weight'] = weightText;
                  }
                },
              ),
              TextField(
                controller: proteinController,
                decoration: InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carbsController,
                decoration: InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fatController,
                decoration: InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              if (nameController.text.isEmpty || caloriesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Name and calories are required')),
                );
                return;
              }

              // Create custom food
              final customFood = {
                'name': nameController.text,
                'calories': int.tryParse(caloriesController.text) ?? 0,
                'weight': '0g', // Default weight
                'protein': double.tryParse(proteinController.text) ?? 0,
                'carbs': double.tryParse(carbsController.text) ?? 0,
                'fat': double.tryParse(fatController.text) ?? 0,
                'color': Colors.blue,
              };

              // Close dialog and select the custom food
              Navigator.pop(context);
              _selectFood(customFood);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _selectedFood != null ? MediaQuery.of(context).size.height * 0.85 : MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchFoods,
                decoration: InputDecoration(
                  hintText: 'Search for food...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF64748B),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Food grid or selected food details
          if (_selectedFood == null) 
            _buildFoodGrid()
          else
            _buildSelectedFoodDetails(),

          // Add button
          Padding(
            padding: EdgeInsets.all(20.r),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: (_selectedFood != null && !_isAddingFood && !_isLoadingImpact) 
                    ? _addFoodToMeal 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF0F67FE).withOpacity(0.5),
                  disabledForegroundColor: Colors.white.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: _isAddingFood
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add to ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food grid header with custom food button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isSearching ? 'Search Results' : 'Popular Foods',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddCustomFoodDialog,
                  icon: Icon(Icons.add, size: 18.sp),
                  label: Text('Custom Food'),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF0F67FE),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Food grid
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48.sp,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No foods found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.r),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final food = _searchResults[index];
                      return FoodGridItem(
                        food: food,
                        onTap: () => _selectFood(food),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFoodDetails() {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFood = null;
                  _impactData = null;
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    size: 16.sp,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Back to foods',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Food image and name
            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: _selectedFood!['color'] ?? Colors.blue,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: 40.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFood!['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${_selectedFood!['calories']} calories',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Nutrition info
            Text(
              'Nutrition Information',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),

            SizedBox(height: 12.h),

            // Nutrition cards
            Row(
              children: [
                _buildNutrientCard(
                  'Protein',
                  '${_selectedFood!['protein']}g',
                  Color(0xFFEDF2FF),
                  Color(0xFF0F67FE),
                ),
                SizedBox(width: 12.w),
                _buildNutrientCard(
                  'Carbs',
                  '${_selectedFood!['carbs']}g',
                  Color(0xFFFFF4DE),
                  Color(0xFFFF9500),
                ),
                SizedBox(width: 12.w),
                _buildNutrientCard(
                  'Fat',
                  '${_selectedFood!['fat']}g',
                  Color(0xFFFFEEF6),
                  Color(0xFFFF2D55),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Sugar spike information
            if (_isLoadingImpact)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF0F67FE),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Calculating blood sugar impact...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            else if (_impactData != null)
              SugarSpikeWidget(
                food: _selectedFood!,
                sugarSpike: _impactData!['sugarSpike'],
                impactLevel: _impactData!['impactLevel'],
                impactColor: _impactData!['impactColor'],
              ),
          ],
        ),
      ),
    );
  }

  // Build nutrient card
  Widget _buildNutrientCard(String title, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
