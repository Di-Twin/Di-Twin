import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class MedicationManagementAlert extends StatefulWidget {
  final String medicationName;
  final String dosage;
  final String instructions;
  final String backgroundImagePath;

  const MedicationManagementAlert({
    super.key,
    required this.medicationName,
    this.dosage = "Default dosage",
    required this.instructions,
    this.backgroundImagePath = './images/medication_management_alert.png',
  });

  @override
  State<MedicationManagementAlert> createState() =>
      _MedicationManagementAlertState();
}

class _MedicationManagementAlertState extends State<MedicationManagementAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeHintController;
  double _dragExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _swipeHintController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swipeHintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color blueColor = Color(0xFF0F67FE);
    const Color redColor = Color(0xFFFA4D5E);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      // Use a semi-transparent barrier color
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Swipeable medication card
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragExtent += details.primaryDelta!;
                // Limit the drag extent for visual feedback
                _dragExtent = _dragExtent.clamp(-100.0, 100.0);
              });
            },
            onHorizontalDragEnd: (details) {
              if (_dragExtent > 80) {
                // Swiped right - Take medication
                Navigator.of(context).pop('take');
              } else if (_dragExtent < -80) {
                // Swiped left - Skip medication
                Navigator.of(context).pop('skip');
              }

              // Reset drag extent if not enough to trigger action
              setState(() {
                _dragExtent = 0;
              });
            },
            child: Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: Stack(
                children: [
                  // Main card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image container with proper aspect ratio
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(20.r),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              widget.backgroundImagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Medication information section
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            children: [
                              // Medication name
                              Text(
                                widget.medicationName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D3142),
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 16.h),

                              // Medication details
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Dosage info
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.medication,
                                          color: blueColor,
                                          size: 16.sp,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          widget.dosage,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 12.w),

                                  // Instructions info
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.restaurant,
                                          color: blueColor,
                                          size: 16.sp,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          widget.instructions,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Added more gap between medication details and swipe instructions
                              SizedBox(height: 40.h),

                              // Swipe instruction text - now static
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swipe,
                                      color: Colors.grey.shade600,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 12.w), // Increased gap
                                    Text(
                                      "Swipe to take or skip",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Added increased gap between swipe instructions and buttons
                              SizedBox(height: 40.h),

                              // Action buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.close,
                                    label: "Skip",
                                    color: redColor,
                                    onTap: () {
                                      Navigator.of(context).pop('skip');
                                    },
                                  ),

                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.calendar_today,
                                    label: "Reschedule",
                                    color: const Color(0xFFAEC5EB),
                                    onTap: () {
                                      Navigator.of(context).pop('reschedule');
                                    },
                                  ),

                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.add,
                                    label: "Take",
                                    color: blueColor,
                                    onTap: () {
                                      Navigator.of(context).pop('take');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Swipe indicators
                  if (_dragExtent != 0)
                    Positioned(
                      left: _dragExtent > 0 ? 16.w : null,
                      right: _dragExtent < 0 ? 16.w : null,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color:
                                _dragExtent > 0
                                    ? blueColor.withOpacity(0.9)
                                    : redColor.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _dragExtent > 0 ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Close button
          Padding(
            padding: EdgeInsets.only(top: 24.h),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.grey.shade700,
                  size: 28.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28.sp),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }
}

// Queue for managing medication alerts
class MedicationAlertQueue {
  static final MedicationAlertQueue _instance =
      MedicationAlertQueue._internal();
  factory MedicationAlertQueue() => _instance;
  MedicationAlertQueue._internal();

  final List<Map<String, dynamic>> _queue = [];
  bool _isShowingAlert = false;

  // Add a medication to the queue
  void addToQueue(
    BuildContext context,
    String medicationName,
    String dosage,
    String instructions,
  ) {
    _queue.add({
      'context': context,
      'medicationName': medicationName,
      'dosage': dosage,
      'instructions': instructions,
    });

    // Start showing alerts if not already showing
    if (!_isShowingAlert) {
      _showNextAlert();
    }
  }

  // Show the next alert in the queue
  void _showNextAlert() {
    if (_queue.isEmpty) {
      _isShowingAlert = false;
      return;
    }

    _isShowingAlert = true;
    final medication = _queue.removeAt(0);

    showDialog(
      context: medication['context'],
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return MedicationManagementAlert(
          medicationName: medication['medicationName'],
          dosage: medication['dosage'],
          instructions: medication['instructions'],
        );
      },
    ).then((value) {
      // Show the next alert after this one is closed
      _showNextAlert();
    });
  }
}

// Updated function to show medication alerts one by one
// void showMedicationAlert(
//   BuildContext context,
//   String medicationName,
//   String dosage,
//   String instructions,
// ) {
//   // Add to queue instead of showing directly
//   MedicationAlertQueue().addToQueue(
//     context,
//     medicationName,
//     dosage,
//     instructions,
//   );
// }
