import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/activity_management/domain/entities/activity_type.dart';

class ActivityTypeSelection extends StatelessWidget {
  final String? selectedActivityType;
  final Function(String) onActivitySelected;

  const ActivityTypeSelection({
    Key? key,
    required this.selectedActivityType,
    required this.onActivitySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activityTypes = ActivityType.getActivityTypes();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: activityTypes.length,
                itemBuilder: (context, index) {
                  final activity = activityTypes[index];
                  final bool isSelected = selectedActivityType == activity.label;

                  return GestureDetector(
                    onTap: () => onActivitySelected(activity.label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? activity.color.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? activity.color
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activity.color
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity.icon,
                              color: isSelected
                                  ? Colors.white
                                  : activity.color,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              activity.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? activity.color
                                    : const Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
