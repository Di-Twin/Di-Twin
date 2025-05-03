import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/activity_management/domain/entities/activity_type.dart';

class ActivitySelection extends StatefulWidget {
  final Function(String) onActivitySelected;

  const ActivitySelection({
    Key? key,
    required this.onActivitySelected,
  }) : super(key: key);

  @override
  _ActivitySelectionState createState() => _ActivitySelectionState();
}

class _ActivitySelectionState extends State<ActivitySelection> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityTypes = ActivityType.getActivityTypes();
    final filteredActivities = activityTypes
        .where((activity) => 
            activity.label.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search activities',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Section title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'Popular Activities',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        
        SizedBox(height: 8.h),
        
        // Activity grid
        Expanded(
          child: filteredActivities.isEmpty
              ? Center(
                  child: Text(
                    'No activities found',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: filteredActivities.length,
                  itemBuilder: (context, index) {
                    final activity = filteredActivities[index];
                    return GestureDetector(
                      onTap: () {
                        widget.onActivitySelected(activity.label);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 80.r,
                            height: 80.r,
                            decoration: BoxDecoration(
                              color: activity.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Center(
                              child: Icon(
                                activity.icon,
                                size: 36.sp,
                                color: activity.color,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            activity.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}