import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../features/sleep_management/presentation/providers/sleep_provider.dart';
import '../../features/sleep_management/domain/entities/sleep_entry.dart';

class SleepHomeWidget extends StatefulWidget {
  const SleepHomeWidget({super.key});

  @override
  State<SleepHomeWidget> createState() => _SleepHomeWidgetState();
}

class _SleepHomeWidgetState extends State<SleepHomeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, child) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: double.infinity,
                height: 180.h,
                margin: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1B3A),
                      Color(0xFF2D1B69),
                      Color(0xFF4C1D95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1A1B3A).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background stars pattern
                    Positioned(
                      top: 20.h,
                      right: 30.w,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Icon(
                          Icons.star,
                          color: Colors.white.withOpacity(0.3),
                          size: 12.sp,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40.h,
                      right: 60.w,
                      child: Icon(
                        Icons.star,
                        color: Colors.white.withOpacity(0.2),
                        size: 8.sp,
                      ),
                    ),
                    Positioned(
                      bottom: 30.h,
                      left: 40.w,
                      child: Icon(
                        Icons.star,
                        color: Colors.white.withOpacity(0.25),
                        size: 10.sp,
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            children: [
                              Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Icon(
                                    Icons.nightlight_round,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sleep Tracker',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _getStatusText(sleepProvider),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Sleep content
                          Expanded(
                            child: _buildSleepContent(sleepProvider),
                          ),
                        ],
                      ),
                    ),

                    // Floating action button
                    Positioned(
                      bottom: 16.h,
                      right: 16.w,
                      child: GestureDetector(
                        onTap: () => _handleSleepAction(sleepProvider),
                        child: Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            sleepProvider.hasActiveSleep
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                            color: Color(0xFF4C1D95),
                            size: 28.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getStatusText(SleepProvider sleepProvider) {
    if (sleepProvider.isLoading) {
      return 'Loading...';
    }

    if (sleepProvider.hasActiveSleep) {
      final duration = DateTime.now().difference(sleepProvider.currentSleep!.startTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return 'Sleeping for ${hours}h ${minutes}m';
    }

    if (sleepProvider.lastNightSleep != null) {
      return 'Last night: ${sleepProvider.lastNightSleep!.formattedDuration}';
    }

    return 'Ready to track your sleep';
  }

  Widget _buildSleepContent(SleepProvider sleepProvider) {
    if (sleepProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      );
    }

    if (sleepProvider.hasActiveSleep) {
      return _buildActiveSleepContent(sleepProvider.currentSleep!);
    }

    if (sleepProvider.lastNightSleep != null) {
      return _buildLastNightContent(sleepProvider.lastNightSleep!);
    }

    return _buildNoDataContent();
  }

  Widget _buildActiveSleepContent(SleepEntry sleepEntry) {
    final now = DateTime.now();
    final duration = now.difference(sleepEntry.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sleep in Progress',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${hours}h ${minutes}m',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                'Started at ${sleepEntry.formattedStartTime}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLastNightContent(SleepEntry sleepEntry) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Night\'s Sleep',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                sleepEntry.formattedDuration,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                '${sleepEntry.formattedStartTime} - ${sleepEntry.formattedEndTime}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataContent() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to Sleep?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Track Tonight',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                'Tap to start sleep tracking',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSleepAction(SleepProvider sleepProvider) async {
    if (sleepProvider.hasActiveSleep) {
      // End sleep
      final success = await sleepProvider.endSleep();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  '🌅 Sleep ended! Good morning!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Start sleep
      final success = await sleepProvider.startSleep();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.nightlight_round, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  '🌙 Sleep tracking started! Sweet dreams!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4C1D95),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    if (sleepProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sleepProvider.errorMessage!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }
}
