import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:client/features/food_management/data/providers/food_management_provider.dart';
import '../providers/daily_food_provider.dart';
import '../../domain/entities/meal_item.dart';
import 'empty_time_period_state.dart';
import 'meal_type_section.dart';

class TimePeriodSection extends StatelessWidget {
  final Map<String, dynamic> timePeriod;
  final Map<String, List<Map<String, dynamic>>> mealData;
  final String currentTimePeriod;
  final Function(String) showAddFoodBottomSheet;
  final FoodManagementProvider foodProvider;

  const TimePeriodSection({
    super.key,
    required this.timePeriod,
    required this.mealData,
    required this.currentTimePeriod,
    required this.showAddFoodBottomSheet,
    required this.foodProvider,
  });

  @override
  Widget build(BuildContext context) {
    final dailyFoodProvider = Provider.of<DailyFoodProvider>(context);
    final isCurrentTimePeriod = timePeriod['name'] == currentTimePeriod;

    // Get meals for this time period
    final mealsByTimePeriod =
        dailyFoodProvider.dailyFood != null
            ? dailyFoodProvider.getMealsByTimePeriod(timePeriod['name'])
            : <String, List<MealItem>>{};

    final totalCalories =
        dailyFoodProvider.dailyFood != null
            ? dailyFoodProvider
                .getTotalCaloriesForTimePeriod(timePeriod['name'])
                .toInt()
            : 0;

    final bool hasMeals = mealsByTimePeriod.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: timePeriod['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  timePeriod['icon'],
                  color: timePeriod['color'],
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                timePeriod['name'],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              if (totalCalories > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2FF),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    '$totalCalories cal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F67FE),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Time period content
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0A000000),
                  blurRadius: 8.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                hasMeals
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          mealsByTimePeriod.entries.map((entry) {
                            final mealType = entry.key;
                            final mealItems = entry.value;

                            // Convert MealItems to a format MealTypeSection can use
                            final foods =
                                mealItems.map((item) {
                                  // Create a map with default values in case properties don't exist
                                  return {
                                    'name':
                                        item.toString(), // Use toString as fallback
                                    'calories': 0,
                                    'protein': 0,
                                    'carbs': 0,
                                    'fat': 0,
                                    'time': '12:00',
                                    'weight': 0,
                                    'color': Colors.blue.shade200,
                                  };
                                }).toList();

                            return MealTypeSection(
                              title: mealType,
                              foods: foods,
                              color: Colors.blue,
                              icon: Icons.restaurant,
                              isSmallScreen:
                                  MediaQuery.of(context).size.width < 380,
                              expandedFoodIndex: null,
                              onToggleExpand: (_) {},
                              onEdit: (_) {},
                              onDelete: (_) {},
                            );
                          }).toList(),
                    )
                    : EmptyTimePeriodState(
                      timePeriod: timePeriod['name'],
                      onAddFood: () => showAddFoodBottomSheet('custom'),
                    ),
          ),
        ],
      ),
    );
  }
}
