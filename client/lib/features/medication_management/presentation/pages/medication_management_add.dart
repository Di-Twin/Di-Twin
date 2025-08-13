import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    extends State<MedicationManagementAddPage> with TickerProviderStateMixin {
  int selectedOption = 1;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectOption(int option) {
    if (selectedOption != option) {
      HapticFeedback.mediumImpact();
      setState(() {
        selectedOption = option;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildScrollableContent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
              Row(
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
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Step 1 of 2',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                'Choose how you\'d like to set up your medication schedule',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildOptionCard(
              index: 0,
              title: 'AI-Powered Setup',
              subtitle: 'Smart recommendations based on your health data',
              description: 'Let our AI analyze your profile and suggest the optimal medication schedule',
              icon: Icons.psychology_outlined,
              comingSoon: true,
            ),
            SizedBox(height: 16.h),
            _buildOptionCard(
              index: 1,
              title: 'Manual Setup',
              subtitle: 'Full control over your medication details',
              description: 'Customize every aspect of your medication schedule yourself',
              icon: Icons.tune_outlined,
            ),
            SizedBox(height: 32.h),
            _buildContinueButton(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    bool comingSoon = false,
  }) {
    final isSelected = selectedOption == index;

    return GestureDetector(
      onTap: comingSoon ? null : () => _selectOption(index),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F67FE) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected ? null : Border.all(color: const Color(0xFFE1E2E6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : (comingSoon ? const Color(0xFFF0F1F5) : const Color(0xFFF0F1F5)),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 28.sp,
                      color: isSelected
                          ? Colors.white
                          : (comingSoon ? Colors.grey : const Color(0xFF0F67FE)),
                    ),
                  ),
                ),
                const Spacer(),
                if (comingSoon)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : (comingSoon ? Colors.grey.shade600 : const Color(0xFF1A202C)),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white70
                    : (comingSoon ? Colors.grey.shade500 : const Color(0xFF64748B)),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: isSelected
                    ? Colors.white70
                    : (comingSoon ? Colors.grey.shade400 : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: "Continue",
        iconPath: 'images/SignInAddIcon.png',
        onPressed: () {
          HapticFeedback.mediumImpact();
          if (selectedOption == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMedicationPage(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20.r,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'AI Setup coming soon!',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.all(16.w),
              ),
            );
          }
        },
        height: 50.h,
      ),
    );
  }
}
