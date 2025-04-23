import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/food_management/presentation/widgets/food_grid_item.dart';
import 'package:client/features/food_management/presentation/widgets/sugar_spike_widget.dart';
import 'package:client/features/food_management/presentation/widgets/food_impact_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/food_management_provider.dart';

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
      foodData['date'] = DateTime.now();
      foodData['mealType'] = widget.mealType;
      foodData['time'] = TimeOfDay.now().format(context);

      // Add food item
      final result = await foodProvider.addFoodItem(foodData);

      if (result['success'] == true) {
        // Close the sheet and return success
        Navigator.pop(context, true);
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add food: ${result['message']}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isAddingFood = false;
      });
    }
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
                child: _isAddingFood
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add to ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF0F67FE).withOpacity(0.5),
                  disabledForegroundColor: Colors.white.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
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
          // Food grid header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Text(
              _isSearching ? 'Search Results' : 'Popular Foods',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
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
