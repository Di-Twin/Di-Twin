import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/medication_management/presentation/pages/medication_management_add_step2.dart';

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
      body: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E2639),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Add Medication',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'You can either manually add medications or let our AI decide based on your data.',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // AI Setup Option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = 0;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: selectedOption == 0
                            ? const Color(0xFF0F67FE)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: selectedOption == 0
                            ? null
                            : Border.all(color: const Color(0xFFE1E2E6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: selectedOption == 0
                                  ? Colors.white.withOpacity(0.2)
                                  : const Color(0xFFF0F1F5),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.auto_awesome,
                                size: 28.sp,
                                color: selectedOption == 0
                                    ? Colors.white
                                    : const Color(0xFF0F67FE),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Auto AI Setup',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: selectedOption == 0
                                  ? Colors.white
                                  : const Color(0xFF1A202C),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Setup medication/supplements based on our AI recommendations.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: selectedOption == 0
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Manual Setup Option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = 1;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: selectedOption == 1
                            ? const Color(0xFF0F67FE)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: selectedOption == 1
                            ? null
                            : Border.all(color: const Color(0xFFE1E2E6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: selectedOption == 1
                                  ? Colors.white.withOpacity(0.2)
                                  : const Color(0xFFF0F1F5),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.edit_outlined,
                                size: 28.sp,
                                color: selectedOption == 1
                                    ? Colors.white
                                    : const Color(0xFF0F67FE),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Manual Setup',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: selectedOption == 1
                                  ? Colors.white
                                  : const Color(0xFF1A202C),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Manually add new medication by yourself with full control.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: selectedOption == 1
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Continue",
                      iconPath: 'images/SignInAddIcon.png',
                      onPressed: () {
                        if (selectedOption == 1) {
                          // Navigate to manual setup page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddMedicationPage(),
                            ),
                          );
                        } else {
                          // Handle AI setup - you can implement this later
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AI Setup coming soon!'),
                            ),
                          );
                        }
                      },
                      height: 50.h,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
