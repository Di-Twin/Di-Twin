import 'package:client/data/providers/food_management_provider.dart';
import 'package:client/features/food_management/food_management_my_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;

// Sugar data point class for Syncfusion charts - moved to top level
class SugarDataPoint {
  final double time;
  final double value;

  SugarDataPoint(this.time, this.value);
}

// Custom painter for ideal response curve
class IdealResponsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.5,
      size.width,
      size.height * 0.6,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for actual response curve
class ActualResponsePainter extends CustomPainter {
  final String curveType;
  final Color color;

  ActualResponsePainter(this.curveType, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, size.height * 0.6);

    switch (curveType) {
      case 'Low':
        // Gentle curve
        path.quadraticBezierTo(
          size.width * 0.3,
          size.height * 0.45,
          size.width * 0.5,
          size.height * 0.5,
        );
        path.quadraticBezierTo(
          size.width * 0.7,
          size.height * 0.55,
          size.width,
          size.height * 0.6,
        );
        break;
      case 'Moderate':
        // Medium curve
        path.quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.3,
          size.width * 0.4,
          size.height * 0.3,
        );
        path.quadraticBezierTo(
          size.width * 0.6,
          size.height * 0.3,
          size.width * 0.7,
          size.height * 0.5,
        );
        path.quadraticBezierTo(
          size.width * 0.8,
          size.height * 0.6,
          size.width,
          size.height * 0.6,
        );
        break;
      case 'High':
        // Sharp spike
        path.quadraticBezierTo(
          size.width * 0.2,
          size.height * 0.1,
          size.width * 0.3,
          size.height * 0.1,
        );
        path.quadraticBezierTo(
          size.width * 0.4,
          size.height * 0.1,
          size.width * 0.5,
          size.height * 0.3,
        );
        path.quadraticBezierTo(
          size.width * 0.7,
          size.height * 0.5,
          size.width,
          size.height * 0.6,
        );
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FoodIntelligenceScreen extends StatefulWidget {
  const FoodIntelligenceScreen({super.key});

  @override
  State<FoodIntelligenceScreen> createState() => _FoodIntelligenceScreenState();
}

class _FoodIntelligenceScreenState extends State<FoodIntelligenceScreen> {
  // ScrollController for auto-scrolling
  final ScrollController _scrollController = ScrollController();
  final FoodManagementProvider _foodProvider = FoodManagementProvider();

  // Current time period
  String _currentTimePeriod = 'Morning';

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Track if search is active
  bool _isSearching = false;

  // Sample meal data
  final Map<String, List<Map<String, dynamic>>> _mealData = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snacks': [],
    'custom': [],
  };
  

  // Popular food suggestions
  final List<Map<String, dynamic>> _popularFoods = [
    {
      'name': 'Biriyani',
      'weight': '450g',
      'calories': 650,
      'icon': Icons.rice_bowl,
      'image': 'images/biriyani.png',
    },
    {
      'name': 'Banana',
      'weight': '120g',
      'calories': 105,
      'icon': Icons.breakfast_dining,
      'image': 'images/banana.png',
    },
    {
      'name': 'Chicken Curry',
      'weight': '250g',
      'calories': 350,
      'icon': Icons.dinner_dining,
      'image': 'images/chicken_curry.png',
    },
    {
      'name': 'Salad Bowl',
      'weight': '300g',
      'calories': 180,
      'icon': Icons.eco,
      'image': 'images/salad_bowl.png',
    },
    {
      'name': 'Protein Bar',
      'weight': '60g',
      'calories': 220,
      'icon': Icons.food_bank,
      'image': 'images/protein_bar.png',
    },
    {
      'name': 'Smoothie',
      'weight': '350ml',
      'calories': 210,
      'icon': Icons.local_drink,
      'image': 'images/smoothie.png',
    },
  ];

  // Search results
  List<Map<String, dynamic>> _searchResults = [];

  // Custom meal times
  final Map<String, String> _mealTimes = {
    'breakfast': '06:00 - 10:00',
    'lunch': '12:00 - 14:00',
    'dinner': '18:00 - 21:00',
    'snacks': 'Any time',
    'custom': 'Custom meal',
  };

  // Meal illustrations
  final Map<String, String> _mealIllustrations = {
    'breakfast': 'images/breakfast_illustration.png',
    'lunch': 'images/lunch_illustration.png',
    'dinner': 'images/dinner_illustration.png',
    'snacks': 'images/snacks_illustration.png',
    'custom': 'images/custom_illustration.png',
  };

  // Time periods for the timeline
  final List<Map<String, dynamic>> _timePeriods = [
    {
      'name': 'Morning',
      'icon': Icons.wb_sunny,
      'color': Color(0xFFFFA726),
      'startTime': 6,
      'endTime': 12,
    },
    {
      'name': 'Afternoon',
      'icon': Icons.wb_cloudy,
      'color': Color(0xFF42A5F5),
      'startTime': 12,
      'endTime': 18,
    },
    {
      'name': 'Evening',
      'icon': Icons.nights_stay,
      'color': Color(0xFF7E57C2),
      'startTime': 18,
      'endTime': 24,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchResults = List.from(_popularFoods);

    // Determine current time period based on current hour
    final currentHour = DateTime.now().hour;
    if (currentHour >= 6 && currentHour < 12) {
      _currentTimePeriod = 'Morning';
    } else if (currentHour >= 12 && currentHour < 18) {
      _currentTimePeriod = 'Afternoon';
    } else {
      _currentTimePeriod = 'Evening';
    }

    // Schedule auto-scroll after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTimePeriod();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Scroll to current time period
  void _scrollToCurrentTimePeriod() {
    // Find the index of the current time period
    int index = _timePeriods.indexWhere(
      (period) => period['name'] == _currentTimePeriod,
    );
    if (index != -1) {
      // Calculate approximate scroll position (each section is about 300 height units)
      double scrollPosition = index * 300.0;

      // Animate to the position
      _scrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Calculate total calories for the day
  int _calculateTotalCalories() {
    int total = 0;
    _mealData.forEach((mealType, foods) {
      for (var food in foods) {
        total += food['calories'] as int;
      }
    });
    return total;
  }

  // Calculate total nutrients for the day
  Map<String, int> _calculateTotalNutrients() {
    int protein = 0;
    int carbs = 0;
    int fat = 0;

    _mealData.forEach((mealType, foods) {
      for (var food in foods) {
        protein += food['protein'] as int;
        carbs += food['carbs'] as int;
        fat += food['fat'] as int;
      }
    });

    return {'protein': protein, 'carbs': carbs, 'fat': fat};
  }

  // Get all foods sorted by time
  List<Map<String, dynamic>> _getAllFoodsSortedByTime() {
    List<Map<String, dynamic>> allFoods = [];

    _mealData.forEach((mealType, foods) {
      for (var food in foods) {
        // Add meal type to the food data
        Map<String, dynamic> foodWithType = Map.from(food);
        foodWithType['mealType'] = mealType;
        allFoods.add(foodWithType);
      }
    });

    // Sort by time value
    allFoods.sort(
      (a, b) => (a['timeValue'] as double).compareTo(b['timeValue'] as double),
    );

    return allFoods;
  }

  // Search for foods
  void _searchFoods(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = List.from(_popularFoods);
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults =
          _popularFoods
              .where(
                (food) => food['name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  // Show add food bottom sheet
  void _showAddFoodBottomSheet(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                          'Add to ${mealType.substring(0, 1).toUpperCase() + mealType.substring(1)}',
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

                  SizedBox(height: 20.h),

                  // Search results or popular foods
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
                    child:
                        _searchResults.isEmpty
                            ? Center(
                              child: Text(
                                'No results found',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            )
                            : GridView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 20.r),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                  ),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final food = _searchResults[index];
                                return _buildFoodGridItem(food, () {
                                  // Add food to meal
                                  Navigator.pop(context);
                                  _showFoodDetailSheet(food, mealType);
                                });
                              },
                            ),
                  ),

                  // Alternative options
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      children: [
                        // Divider with text
                        Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.r),
                              child: Text(
                                'OR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Scan barcode button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Implement barcode scanning
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Barcode scanning coming soon'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: Icon(Icons.qr_code_scanner),
                            label: Text(
                              'Scan Food',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0F67FE),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Create custom food button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Implement custom food creation
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Custom food creation coming soon',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: Icon(Icons.add_circle_outline),
                            label: Text(
                              'Create Custom Food',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF0F67FE),
                              side: BorderSide(color: Color(0xFF0F67FE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Show food detail sheet with improved UI and Syncfusion charts
  void _showFoodDetailSheet(Map<String, dynamic> food, String mealType) {
    TimeOfDay selectedTime = TimeOfDay.now();
    double servingSize = 1.0;
    String servingUnit = 'g'; // Default unit

    // Generate data for charts
    final int metabolicImpact = _calculateMetabolicImpact(food);
    final String impactLevel = _getImpactLevel(metabolicImpact);
    final Color impactColor = _getImpactColor(metabolicImpact);

    // Calculate nutrition values based on serving size
    int calories = food['calories'] as int;
    int protein = food.containsKey('protein') ? food['protein'] as int : 0;
    int carbs = food.containsKey('carbs') ? food['carbs'] as int : 0;
    int fat = food.containsKey('fat') ? food['fat'] as int : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Calculate adjusted nutrition values based on serving size
            int adjustedCalories = (calories * servingSize).round();
            int adjustedProtein = (protein * servingSize).round();
            int adjustedCarbs = (carbs * servingSize).round();
            int adjustedFat = (fat * servingSize).round();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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

                  // Header with food info
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0F67FE).withOpacity(0.05),
                          Color(0xFF4D8EFF).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add to ${mealType.substring(0, 1).toUpperCase() + mealType.substring(1)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: Color(0xFF64748B)),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Food info card with compact layout
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Food icon
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  food['icon'] ?? Icons.restaurant,
                                  size: 28.sp,
                                  color: Color(0xFF0F67FE),
                                ),
                              ),

                              SizedBox(width: 12.w),

                              // Food details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food['name'],
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_fire_department,
                                          size: 14.sp,
                                          color: Color(0xFFFF9800),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '$adjustedCalories cal',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Container(
                                          width: 4.w,
                                          height: 4.h,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF64748B),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          food['weight'],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // Time selection - MOVED TO TOP
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    InkWell(
                                      onTap: () async {
                                        final TimeOfDay? time =
                                            await showTimePicker(
                                              context: context,
                                              initialTime: selectedTime,
                                            );

                                        if (time != null) {
                                          setState(() {
                                            selectedTime = time;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.r,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: Color(0xFF0F67FE),
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              selectedTime.format(context),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                      0xFF1E293B,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Serving size - COMPACT VERSION
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Serving Size',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.r,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              // Extract base weight from food weight string
                                              final baseWeight = double.parse(
                                                food['weight']
                                                    .toString()
                                                    .replaceAll(
                                                      RegExp(r'[^0-9.]'),
                                                      '',
                                                    ),
                                              );
                                              if (servingSize > 0.5) {
                                                setState(() {
                                                  // Decrease by 50g
                                                  servingSize =
                                                      ((baseWeight *
                                                              servingSize) -
                                                          50) /
                                                      baseWeight;
                                                  servingSize = servingSize
                                                      .clamp(0.5, 5.0);
                                                });
                                              }
                                            },
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            color: Color(0xFF0F67FE),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                            iconSize: 20.sp,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '${(double.parse(food['weight'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) * servingSize).toStringAsFixed(0)}$servingUnit',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                        0xFF1E293B,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              // Extract base weight from food weight string
                                              final baseWeight = double.parse(
                                                food['weight']
                                                    .toString()
                                                    .replaceAll(
                                                      RegExp(r'[^0-9.]'),
                                                      '',
                                                    ),
                                              );
                                              if (servingSize < 5.0) {
                                                setState(() {
                                                  // Increase by 50g
                                                  servingSize =
                                                      ((baseWeight *
                                                              servingSize) +
                                                          50) /
                                                      baseWeight;
                                                  servingSize = servingSize
                                                      .clamp(0.5, 5.0);
                                                });
                                              }
                                            },
                                            icon: Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            color: Color(0xFF0F67FE),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                            iconSize: 20.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Nutrition info - COMPACT CARD
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nutrition Facts',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildNutrientCircle(
                                      'Protein',
                                      adjustedProtein,
                                      Color(0xFF4CAF50),
                                      'g',
                                    ),
                                    _buildNutrientCircle(
                                      'Carbs',
                                      adjustedCarbs,
                                      Color(0xFF2196F3),
                                      'g',
                                    ),
                                    _buildNutrientCircle(
                                      'Fat',
                                      adjustedFat,
                                      Color(0xFFFF9800),
                                      'g',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Metabolic impact - SIMPLIFIED
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  impactColor.withOpacity(0.8),
                                  impactColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: impactColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getImpactIcon(metabolicImpact),
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$impactLevel Impact',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'This food will ${metabolicImpact > 0 ? 'increase' : 'decrease'} your metabolic score by ${metabolicImpact.abs()}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.sp,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Blood Sugar Response - SIMPLIFIED
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Blood Sugar Response',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // Simplified blood sugar response visualization
                                _buildSimplifiedBloodSugarResponse(
                                  food,
                                  impactLevel,
                                  impactColor,
                                ),

                                SizedBox(height: 8.h),

                                // Simple explanation
                                Text(
                                  _getSimplifiedSugarExplanation(
                                    food['name'],
                                    impactLevel,
                                  ),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Add button
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24.r),
                        bottomRight: Radius.circular(24.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add food to meal
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${food['name']} added to $mealType',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0F67FE),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Color(0xFF0F67FE).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Add to $mealType',
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
          },
        );
      },
    );
  }

  // Build nutrient circle
  Widget _buildNutrientCircle(
    String label,
    int value,
    Color color,
    String unit,
  ) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // Build simplified blood sugar response
  Widget _buildSimplifiedBloodSugarResponse(
    Map<String, dynamic> food,
    String impactLevel,
    Color impactColor,
  ) {
    // Determine the curve type based on impact level
    String curveType = 'Moderate';
    if (impactLevel == 'Excellent' || impactLevel == 'Good') {
      curveType = 'Low';
    } else if (impactLevel == 'High') {
      curveType = 'High';
    }

    return SizedBox(
      height: 120.h,
      child: Row(
        children: [
          // Y-axis label
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'High',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                'Blood\nSugar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Low',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          // Graph area
          Expanded(
            child: Stack(
              children: [
                // Background grid
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 1, color: Color(0xFFE2E8F0)),
                      Container(height: 1, color: Color(0xFFE2E8F0)),
                      Container(height: 1, color: Color(0xFFE2E8F0)),
                    ],
                  ),
                ),

                // Ideal response curve
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: CustomPaint(painter: IdealResponsePainter()),
                ),

                // Actual response curve based on impact
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: CustomPaint(
                    painter: ActualResponsePainter(curveType, impactColor),
                  ),
                ),

                // Time labels
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '1h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '2h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '3h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get simplified sugar explanation
  String _getSimplifiedSugarExplanation(String foodName, String impactLevel) {
    switch (impactLevel) {
      case 'Excellent':
      case 'Good':
        return '$foodName has a minimal effect on blood sugar levels, making it a good choice for metabolic health.';
      case 'Neutral':
        return '$foodName causes a moderate rise in blood sugar that returns to normal within 2-3 hours.';
      case 'Moderate':
        return '$foodName may cause a moderate blood sugar spike. Consider pairing with protein or fiber.';
      case 'High':
        return '$foodName may cause a significant blood sugar spike. Consider smaller portions or alternatives.';
      default:
        return 'This shows how $foodName affects your blood sugar over time after eating.';
    }
  }

  // Generate sugar spike data based on food type
  List<SugarDataPoint> _generateSugarSpikeData(Map<String, dynamic> food) {
    final List<SugarDataPoint> data = [];
    final String foodName = food['name'].toString().toLowerCase();

    // Different curve patterns based on food type
    double peakValue = 0;
    double peakTime = 0;
    double endValue = 0;

    // Determine curve characteristics based on food
    if (foodName.contains('sugar') ||
        foodName.contains('cake') ||
        foodName.contains('sweet') ||
        foodName.contains('candy')) {
      // High glycemic foods - sharp spike
      peakValue = 9.0 + (math.Random().nextDouble() * 2.0);
      peakTime = 0.5 + (math.Random().nextDouble() * 0.5);
      endValue = 4.0 + (math.Random().nextDouble() * 1.0);
    } else if (foodName.contains('fruit') ||
        foodName.contains('banana') ||
        foodName.contains('apple') ||
        foodName.contains('smoothie')) {
      // Medium glycemic foods - moderate spike
      peakValue = 7.0 + (math.Random().nextDouble() * 1.5);
      peakTime = 1.0 + (math.Random().nextDouble() * 0.5);
      endValue = 4.5 + (math.Random().nextDouble() * 0.5);
    } else if (foodName.contains('protein') ||
        foodName.contains('meat') ||
        foodName.contains('chicken') ||
        foodName.contains('fish') ||
        foodName.contains('egg')) {
      // Low glycemic foods - gentle curve
      peakValue = 5.5 + (math.Random().nextDouble() * 1.0);
      peakTime = 1.5 + (math.Random().nextDouble() * 0.5);
      endValue = 4.8 + (math.Random().nextDouble() * 0.3);
    } else {
      // Default curve for other foods
      peakValue = 6.5 + (math.Random().nextDouble() * 2.0);
      peakTime = 1.0 + (math.Random().nextDouble() * 1.0);
      endValue = 4.5 + (math.Random().nextDouble() * 0.5);
    }

    // Generate the curve points
    for (double i = 0; i <= 4; i += 0.2) {
      double value;
      if (i == 0) {
        value = 5.0; // Starting blood sugar level
      } else if (i < peakTime) {
        // Rising phase - accelerating
        value = 5.0 + (peakValue - 5.0) * math.pow(i / peakTime, 1.5);
      } else {
        // Falling phase - decelerating
        value =
            peakValue -
            (peakValue - endValue) *
                math.pow((i - peakTime) / (4 - peakTime), 0.8);
      }

      // Add some natural variation
      value += (math.Random().nextDouble() * 0.3) - 0.15;

      data.add(SugarDataPoint(i, value));
    }

    return data;
  }

  // Generate ideal response data
  List<SugarDataPoint> _generateIdealResponseData() {
    return [
      SugarDataPoint(0, 5.0),
      SugarDataPoint(0.5, 5.5),
      SugarDataPoint(1.0, 6.0),
      SugarDataPoint(1.5, 5.8),
      SugarDataPoint(2.0, 5.5),
      SugarDataPoint(2.5, 5.2),
      SugarDataPoint(3.0, 5.0),
      SugarDataPoint(3.5, 4.9),
      SugarDataPoint(4.0, 4.8),
    ];
  }

  // Calculate metabolic impact score
  int _calculateMetabolicImpact(Map<String, dynamic> food) {
    final String foodName = food['name'].toString().toLowerCase();
    final int calories = food['calories'] as int;

    // Base impact on calories
    int impact = 0;

    // Adjust based on food type
    if (foodName.contains('sugar') ||
        foodName.contains('cake') ||
        foodName.contains('sweet') ||
        foodName.contains('candy')) {
      // High glycemic foods - negative impact
      impact = -3 - (calories ~/ 100);
    } else if (foodName.contains('fruit') ||
        foodName.contains('banana') ||
        foodName.contains('apple') ||
        foodName.contains('smoothie')) {
      // Medium glycemic foods - slight positive impact
      impact = 1 + (calories ~/ 200);
    } else if (foodName.contains('protein') ||
        foodName.contains('meat') ||
        foodName.contains('chicken') ||
        foodName.contains('fish') ||
        foodName.contains('egg')) {
      // Protein foods - positive impact
      impact = 2 + (calories ~/ 150);
    } else if (foodName.contains('vegetable') ||
        foodName.contains('salad') ||
        foodName.contains('greens')) {
      // Vegetables - very positive impact
      impact = 3 + (calories ~/ 100);
    } else {
      // Default impact for other foods
      impact = (calories > 300) ? -1 : 1;
    }

    // Ensure impact is within reasonable range
    return impact.clamp(-5, 5);
  }

  // Get impact level description
  String _getImpactLevel(int impact) {
    if (impact >= 3) return 'Excellent';
    if (impact >= 1) return 'Good';
    if (impact >= -1) return 'Neutral';
    if (impact >= -3) return 'Moderate';
    return 'High';
  }

  // Get impact color
  Color _getImpactColor(int impact) {
    if (impact >= 3) return Color(0xFF4CAF50); // Green
    if (impact >= 1) return Color(0xFF8BC34A); // Light Green
    if (impact >= -1) return Color(0xFFFFC107); // Amber
    if (impact >= -3) return Color(0xFFFF9800); // Orange
    return Color(0xFFF44336); // Red
  }

  // Get impact icon
  IconData _getImpactIcon(int impact) {
    if (impact >= 3) return Icons.emoji_events; // Trophy
    if (impact >= 1) return Icons.thumb_up; // Thumbs up
    if (impact >= -1) return Icons.thumbs_up_down; // Neutral
    if (impact >= -3) return Icons.warning; // Warning
    return Icons.priority_high; // Alert
  }

  // Get impact description based on food and impact level
  String _getImpactDescription(String foodName, String impactLevel) {
    switch (impactLevel) {
      case 'Excellent':
        return '$foodName is an excellent choice for your metabolic health. It contains nutrients that support your metabolism and help maintain stable blood sugar levels.';
      case 'Good':
        return '$foodName has a positive effect on your metabolic health. It provides good nutritional value without causing significant blood sugar spikes.';
      case 'Neutral':
        return '$foodName has a neutral effect on your metabolic health. It\'s neither particularly beneficial nor harmful when consumed in moderation.';
      case 'Moderate':
        return '$foodName may cause moderate blood sugar spikes. Consider pairing it with protein or fiber to reduce its glycemic impact.';
      case 'High':
        return '$foodName may cause significant blood sugar spikes. Consider reducing portion size or choosing alternatives with lower glycemic impact.';
      default:
        return 'Consider how $foodName affects your blood sugar levels and overall metabolic health.';
    }
  }

  // Get sugar spike explanation based on food
  String _getSugarSpikeExplanation(String foodName) {
    return 'This graph shows how your blood sugar levels may change after consuming $foodName. The blue line represents your expected response, while the gray line shows an ideal response.';
  }

  // Build sugar spike chart with Syncfusion
  Widget _buildSugarSpikeChart(
    List<SugarDataPoint> sugarSpikeData,
    List<SugarDataPoint> idealResponseData,
  ) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.all(0),
      primaryXAxis: NumericAxis(
        minimum: 0,
        maximum: 4,
        interval: 1,
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 1, color: Color(0xFFE2E8F0)),
        title: AxisTitle(
          text: 'Hours after consumption',
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: Color(0xFF64748B),
        ),
      ),
      primaryYAxis: NumericAxis(
        minimum: 3,
        maximum: 11,
        interval: 2,
        majorGridLines: MajorGridLines(width: 1, color: Color(0xFFE2E8F0)),
        axisLine: AxisLine(width: 1, color: Color(0xFFE2E8F0)),
        title: AxisTitle(
          text: 'Blood Sugar (mmol/L)',
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: Color(0xFF64748B),
        ),
      ),
      series: <CartesianSeries>[
        // Ideal response area
        AreaSeries<SugarDataPoint, double>(
          dataSource: idealResponseData,
          xValueMapper: (SugarDataPoint data, _) => data.time,
          yValueMapper: (SugarDataPoint data, _) => data.value,
          color: Colors.grey.shade200,
          borderColor: Colors.grey.shade400,
          borderWidth: 2,
          name: 'Ideal Response',
        ),
        // Actual response area
        AreaSeries<SugarDataPoint, double>(
          dataSource: sugarSpikeData,
          xValueMapper: (SugarDataPoint data, _) => data.time,
          yValueMapper: (SugarDataPoint data, _) => data.value,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F67FE).withOpacity(0.3),
              Color(0xFF4D8EFF).withOpacity(0.1),
            ],
          ),
          borderColor: Color(0xFF0F67FE),
          borderWidth: 3,
          name: 'Your Response',
          markerSettings: MarkerSettings(
            isVisible: true,
            height: 8,
            width: 8,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Color(0xFF0F67FE),
            color: Colors.white,
          ),
          enableTooltip: true,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: Color(0xFF1E293B),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: Colors.white,
        ),
        format: 'Blood Sugar: point.y mmol/L\nTime: point.x h',
        duration: 3000,
      ),
      crosshairBehavior: CrosshairBehavior(
        enable: true,
        lineType: CrosshairLineType.both,
        lineColor: Color(0xFF64748B),
        lineDashArray: <double>[5, 5],
        lineWidth: 1,
      ),
    );
  }

  // Build legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // Build nutrient badge
  Widget _buildNutrientBadge(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4.w),
          Text(
            '$label: ${value}g',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Show edit meal time sheet
  void _showEditMealTimeSheet(String mealType) {
    TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0); // Default
    TimeOfDay endTime = TimeOfDay(hour: 10, minute: 0); // Default

    // Parse current time range
    if (mealType != 'snacks' && mealType != 'custom') {
      final timeRange = _mealTimes[mealType]!.split(' - ');
      final startTimeStr = timeRange[0];
      final endTimeStr = timeRange[1];

      // Parse start time
      final startHour = int.parse(startTimeStr.split(':')[0]);
      final startMinute = int.parse(startTimeStr.split(':')[1]);
      startTime = TimeOfDay(hour: startHour, minute: startMinute);

      // Parse end time
      final endHour = int.parse(endTimeStr.split(':')[0]);
      final endMinute = int.parse(endTimeStr.split(':')[1]);
      endTime = TimeOfDay(hour: endHour, minute: endMinute);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
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
                          'Edit ${mealType.substring(0, 1).toUpperCase() + mealType.substring(1)} Time',
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

                  // Time selection
                  if (mealType != 'snacks' && mealType != 'custom')
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Range',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Start time
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start Time',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.sp,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),

                                    SizedBox(height: 8.h),

                                    InkWell(
                                      onTap: () async {
                                        final TimeOfDay? time =
                                            await showTimePicker(
                                              context: context,
                                              initialTime: startTime,
                                            );

                                        if (time != null) {
                                          setState(() {
                                            startTime = time;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.r,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              startTime.format(context),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16.sp,
                                                    color: const Color(
                                                      0xFF1E293B,
                                                    ),
                                                  ),
                                            ),
                                            Icon(
                                              Icons.access_time,
                                              color: Color(0xFF64748B),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 16.w),

                              // End time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Time',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.sp,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),

                                    SizedBox(height: 8.h),

                                    InkWell(
                                      onTap: () async {
                                        final TimeOfDay? time =
                                            await showTimePicker(
                                              context: context,
                                              initialTime: endTime,
                                            );

                                        if (time != null) {
                                          setState(() {
                                            endTime = time;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.r,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              endTime.format(context),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16.sp,
                                                    color: const Color(
                                                      0xFF1E293B,
                                                    ),
                                                  ),
                                            ),
                                            Icon(
                                              Icons.access_time,
                                              color: Color(0xFF64748B),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Custom meal name (for custom meal type)
                  if (mealType == 'custom')
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Meal Name',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter meal name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.r,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Spacer(),

                  // Save button
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // Save meal time
                          if (mealType != 'snacks' && mealType != 'custom') {
                            final startTimeStr =
                                '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                            final endTimeStr =
                                '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

                            setState(() {
                              _mealTimes[mealType] =
                                  '$startTimeStr - $endTimeStr';
                            });
                          }

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$mealType time updated'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0F67FE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
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
          },
        );
      },
    );
  }

  // Navigate to stats screen
  void onButtonTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                FoodManagementStatsScreen(userJoinDate: DateTime(2025, 4, 1)),
      ),
    );
  }

  // Build food grid item
  Widget _buildFoodGridItem(Map<String, dynamic> food, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  food['icon'] ?? Icons.restaurant,
                  color: Color(0xFF0F67FE),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    food['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              '${food['calories']} cal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            Text(
              food['weight'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build food item with enhanced UI - simplified version without nutrient indicators
  Widget _buildFoodItem(Map<String, dynamic> food) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.h),
      child: Row(
        children: [
          // Food icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: (food['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              food['icon'] as IconData,
              color: food['color'] as Color,
              size: 24.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // Food info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),

                SizedBox(height: 4.h),

                // Simplified row with just calories and time
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14.sp,
                      color: Color(0xFFFF9800),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${food['calories']} cal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 4.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF64748B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      food['time'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build time period section
  Widget _buildTimePeriodSection(Map<String, dynamic> timePeriod) {
    // Filter foods that belong to this time period
    List<Map<String, dynamic>> periodFoods =
        _foodProvider.getFoodsForTimePeriod(_mealData, timePeriod);

    // Calculate total calories for this period
    int totalCalories = 0;
    for (var food in periodFoods) {
      totalCalories += food['calories'] as int;
    }

    // Check if this is the current time period
    bool isCurrentTimePeriod = timePeriod['name'] == _currentTimePeriod;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCurrentTimePeriod ? timePeriod['color'] : Color(0xFFE2E8F0),
          width: isCurrentTimePeriod ? 2.0 : 1.0,
        ),
        boxShadow:
            isCurrentTimePeriod
                ? [
                  BoxShadow(
                    color: (timePeriod['color'] as Color).withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Column(
        children: [
          // Time period header
          Container(
            decoration: BoxDecoration(
              color: timePeriod['color'].withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  // Time period icon
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: timePeriod['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      timePeriod['icon'] as IconData,
                      color: timePeriod['color'] as Color,
                      size: 24.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Time period info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timePeriod['name'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Row(
                          children: [
                            Text(
                              '$totalCalories calories',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 4.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: Color(0xFF64748B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${periodFoods.length} items',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Current time indicator
                  if (isCurrentTimePeriod)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: timePeriod['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: timePeriod['color'] as Color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Food items or empty state
          if (periodFoods.isEmpty)
            _buildEmptyTimePeriodState(timePeriod)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: periodFoods.length,
              separatorBuilder:
                  (context, index) => Divider(
                    color: Color(0xFFE2E8F0),
                    height: 1,
                    indent: 20.r,
                    endIndent: 20.r,
                  ),
              itemBuilder: (context, index) {
                final food = periodFoods[index];
                return _buildFoodItem(food);
              },
            ),

          // Single full-width add button
          Padding(
            padding: EdgeInsets.all(16.r),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed:
                    () => _showAddFoodBottomSheet(
                      timePeriod['name'].toString().toLowerCase(),
                    ),
                icon: Icon(Icons.add, size: 18.sp),
                label: Text(
                  'Add ${timePeriod['name']} Food',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: timePeriod['color'] as Color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build empty time period state
  Widget _buildEmptyTimePeriodState(Map<String, dynamic> timePeriod) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.r),
      child: Column(
        children: [
          // Illustration
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: (timePeriod['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              timePeriod['icon'] as IconData,
              size: 50.sp,
              color: (timePeriod['color'] as Color).withOpacity(0.7),
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            'No foods added yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          Text(
            'Track your ${timePeriod['name'].toLowerCase()} meals to maintain a healthy diet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fixed header height
    final double headerHeight = 370.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Custom header with reduced height
          SizedBox(
            height: headerHeight.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FutureBuilder<String>(
                  future: _foodProvider.getTodayFoodScore(),
                  builder: (context, snapshot) {
                    // Default score if data is not loaded yet or there's an error
                    String score = snapshot.hasData ? snapshot.data! : '0';
                    return CustomActivityHeader(
                      title: 'Food Intelligence',
                      badgeText: 'Healthy',
                      score: score,
                      subtitle: 'Your Metabolic Score',
                      buttonImage: 'images/SignInAddIcon.png',
                      onButtonTap: () => onButtonTap(context),
                      backgroundColor: Color(0xFFD9EAFF),
                      backgroundImagePath:
                          'images/activity_header_background.png',
                      buttonColor: Color(0xFF1E293B),
                      buttonShadowColor: Color(0xFF1E293B),
                      titleTextColor: Color(0xFF1E293B),
                      scoreTextColor: Color(0xFF1E293B),
                      subtitleTextColor: Color(0xFF1E293B),
                      backButtonBorderColor: Color(0xFF1E293B),
                      badgeBackgroundColor: Colors.blue.withOpacity(0.2),
                      badgeTextColor: Colors.blue,
                      backButtonBorderWidth: 1.0,
                      bottomLeftRadius: 30,
                      bottomRightRadius: 30,
                      buttonShadowSpread: 0,
                      headerHeight: headerHeight,
                      showBadge: true,
                      showMenu: false,
                    );
                  },
                ),
              ],
            ),
          ),

          // Food Intake Title with day summary
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Food Timeline',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFEDF2FF),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16.sp,
                        color: Color(0xFF0F67FE),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${_calculateTotalCalories()} cal today',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F67FE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Timeline content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Column(
                children:
                    _timePeriods
                        .map(
                          (timePeriod) => _buildTimePeriodSection(timePeriod),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
