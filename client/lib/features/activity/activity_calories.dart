import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCalories extends StatelessWidget {
  // Dummy data - would be replaced with actual data later
  final int caloriesBurned = 1000;
  final int heartRate = 87;
  final int cardioLoadMinutes = 47;
  final int activityScore = 4;
  final String cardioWorkoutCalories = "154";

  const ActivityCalories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildCaloriesSection(),
                  _buildHeartRateSection(),
                  _buildCardioAndActivitySection(),
                  _buildBenefitsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 30.h, left: 16.w, right: 16.w, bottom: 60.h),
      decoration: BoxDecoration(
        color: Color(0xFF0F67FE),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.r),
          bottomRight: Radius.circular(15.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18.sp),
                  onPressed: () {},
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.white, size: 24.sp),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Center(
            child: Text(
              "Jogging Stats",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                icon: Icon(Icons.local_fire_department, color: Colors.white),
                value: "$caloriesBurned",
                unit: "kcal",
              ),
              SizedBox(width: 30.w),
              _buildStatItem(
                icon: Icon(Icons.favorite, color: Colors.white),
                value: "$heartRate",
                unit: "BPM",
              ),
              SizedBox(width: 30.w),
              _buildStatItem(
                icon: Icon(Icons.trending_up, color: Colors.white),
                value: "+2",
                unit: "Score",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required Icon icon,
    required String value,
    required String unit,
  }) {
    return Row(
      children: [
        icon,
        SizedBox(width: 8.w),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          unit,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Calories Burned",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "You just burned",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "$caloriesBurned",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                "kcal",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              height: 30.h,
              child: Row(
                children: [
                  Expanded(
                    flex: 40,
                    child: Container(
                      color: Color(0xFF0F67FE),
                    ),
                  ),
                  Expanded(
                    flex: 60,
                    child: Container(
                      color: Colors.grey[200],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              SizedBox(width: 8.w),
              Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                "Target",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Color(0xFF0F67FE),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                "Burned",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Heart Rate",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.favorite,
                color: Colors.red,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "$heartRate",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "BPM",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Average Heart Rate",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardioAndActivitySection() {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cardio Load",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.monitor_heart_outlined,
                      color: Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.monitor_heart_outlined,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "$cardioLoadMinutes",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "mins",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Cardio Load",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
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
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Activity Score",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "+$activityScore",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "score",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Your Activity score",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
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
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Benefits",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.add_box,
                color: Colors.teal,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.directions_run,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cardio Workout",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "$cardioWorkoutCalories Calories Burned",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
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
}