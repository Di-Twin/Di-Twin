import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/food_management_provider.dart';
import 'package:client/features/food_management/presentation/widgets/food_item.dart';
import 'package:client/features/food_management/presentation/widgets/empty_time_period_state.dart';

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
    // Filter foods that belong to this time period
    List<Map<String, dynamic>> periodFoods =
        foodProvider.getFoodsForTimePeriod(mealData, timePeriod);

    // Calculate total calories for this period
    int totalCalories = 0;
    for (var food in periodFoods) {
      totalCalories += food['calories'] as int;
    }

    // Check if this is the current time period
    bool isCurrentTimePeriod = timePeriod['name'] == currentTimePeriod;

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
            EmptyTimePeriodState(timePeriod: timePeriod)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: periodFoods.length,
              separatorBuilder: (context, index) => Divider(
                color: Color(0xFFE2E8F0),
                height: 1,
                indent: 20.r,
                endIndent: 20.r,
              ),
              itemBuilder: (context, index) {
                final food = periodFoods[index];
                return StatefulBuilder(
                  builder: (context, setState) {
                    // Local state for expanded status
                    bool isExpanded = false;
                    
                    return FoodItem(
                      food: food,
                      index: index,
                      isSmallScreen: MediaQuery.of(context).size.width < 360,
                      isExpanded: isExpanded,
                      onToggleExpand: (idx) {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      onEdit: (food) {
                        // Call the provider's edit method
                        // foodProvider.editFood(food);
                      },
                      onDelete: (food) {
                        // Call the provider's delete method
                        // foodProvider.deleteFood(food);
                      },
                    );
                  }
                );
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
                    () => showAddFoodBottomSheet(
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
}
