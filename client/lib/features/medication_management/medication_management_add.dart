import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationManagementAddPage extends StatefulWidget {
  const MedicationManagementAddPage({Key? key}) : super(key: key);

  @override
  State<MedicationManagementAddPage> createState() =>
      _MedicationManagementAddPageState();
}

class _MedicationManagementAddPageState
    extends State<MedicationManagementAddPage> {
  int selectedOption = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFE1E2E6)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18.sp,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              Text(
                'Add Medication',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A202C),
                ),
              ),

              SizedBox(height: 12.h),

              Text(
                'You can either manually add medications or let our AI decide based on your data.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  color: const Color(0xFF64748B),
                ),
              ),

              SizedBox(height: 32.h),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = 0;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color:
                        selectedOption == 0
                            ? const Color(0xFF0F67FE)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        selectedOption == 0
                            ? null
                            : Border.all(color: const Color(0xFFE1E2E6)),
                    boxShadow:
                        selectedOption == 0
                            ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.25),
                                blurRadius: 0,
                                spreadRadius: 4,
                              ),
                            ]
                            : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color:
                              selectedOption == 0
                                  ? Colors.white.withOpacity(0.2)
                                  : const Color(0xFFF0F1F5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.settings,
                            size: 28.sp,
                            color:
                                selectedOption == 0
                                    ? Colors.white
                                    : const Color(0xFF000000),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Auto AI Setup',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              selectedOption == 0
                                  ? Colors.white
                                  : const Color(0xFF1A202C),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Setup medication/supplements based on our AI.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color:
                              selectedOption == 0
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = 1;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color:
                        selectedOption == 1
                            ? const Color(0xFF0F67FE)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        selectedOption == 1
                            ? null
                            : Border.all(color: const Color(0xFFE1E2E6)),
                    boxShadow:
                        selectedOption == 1
                            ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.25),
                                blurRadius: 0,
                                spreadRadius: 4,
                              ),
                            ]
                            : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color:
                              selectedOption == 1
                                  ? Colors.white.withOpacity(0.2)
                                  : const Color(0xFFF0F1F5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.tune,
                            size: 28.sp,
                            color:
                                selectedOption == 1
                                    ? Colors.white
                                    : const Color(0xFF000000),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Manual Setup',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              selectedOption == 1
                                  ? Colors.white
                                  : const Color(0xFF1A202C),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Manually add new medication by yourself.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color:
                              selectedOption == 1
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Continue",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {},
                  height: 45.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
