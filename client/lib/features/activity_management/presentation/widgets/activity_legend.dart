import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../activity_management/data/models/activity_stat_model.dart';

class ActivityLegend extends StatelessWidget {
  final List<ActivityStatModel> activities;
  
  const ActivityLegend({
    super.key,
    required this.activities,
  });
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: activities.map((activity) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: activity.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              activity.name,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
