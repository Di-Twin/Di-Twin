import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// State provider to track which option is selected
final selectedOptionProvider = StateProvider<String>((ref) => 'manual');

class AddMedication extends ConsumerWidget {
  const AddMedication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOption = ref.watch(selectedOptionProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              // Back button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_left,
                      size: 24.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Title
              Text(
                'Add Medication',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 8.h),
              // Subtitle
              Text(
                'You can either manually add medications or let our AI decide based on your data.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32.h),
              // AI Setup Option
              GestureDetector(
                onTap: () => ref.read(selectedOptionProvider.notifier).state = 'ai',
                child: Container(
                  width: double.infinity,
                  height: 180.h, // Increased height
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: selectedOption == 'ai' 
                        ? const Color(0xFF2563EB) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: selectedOption == 'ai' 
                              ? Colors.white.withOpacity(0.2) 
                              : const Color(0xFFF2F3F7),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.settings,
                            color: selectedOption == 'ai' 
                                ? Colors.white 
                                : Colors.grey.shade700,
                            size: 24.sp,
                          ),
                        ),
                      ),
                      const Spacer(), // Pushes the text to the bottom
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto AI Setup',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: selectedOption == 'ai' 
                                  ? Colors.white 
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Setup medication/supplements based \n on our AI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: selectedOption == 'ai' 
                                  ? Colors.white.withOpacity(0.8) 
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Manual Setup Option
              GestureDetector(
                onTap: () => ref.read(selectedOptionProvider.notifier).state = 'manual',
                child: Container(
                  width: double.infinity,
                  height: 180.h, // Increased height
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: selectedOption == 'manual' 
                        ? const Color(0xFF0F67FE) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: selectedOption == 'manual' 
                              ? Colors.white.withOpacity(0.2) 
                              : const Color(0xFFF2F3F7),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(
                            FontAwesomeIcons.layerGroup,
                            color: selectedOption == 'manual' 
                                ? Colors.white 
                                : Colors.grey.shade700,
                            size: 20.sp,
                          ),
                        ),
                      ),
                      const Spacer(), // Pushes the text to the bottom
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manual Setup',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: selectedOption == 'manual' 
                                  ? Colors.white 
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Manually add new medication by \n yourself.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: selectedOption == 'manual' 
                                  ? Colors.white.withOpacity(0.8) 
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
                            const Spacer(),
                            const Spacer(),

              // Continue Button
              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: CustomButton(
                  text: 'Continue',
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {
                    // Navigate to next screen based on selection
                    if (selectedOption == 'ai') {
                      // Navigate to AI setup
                    } else {
                      // Navigate to manual setup
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
