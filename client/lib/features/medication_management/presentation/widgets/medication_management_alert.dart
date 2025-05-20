import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A dialog that shows when it's time to take medication
/// Features a swipeable card and buttons for taking, skipping, or rescheduling
class MedicationManagementAlert extends StatefulWidget {
  /// The name of the medication
  final String medicationName;
  
  /// The dosage information (e.g., "1 pill")
  final String dosage;
  
  /// Instructions for taking the medication (e.g., "Take with food")
  final String instructions;
  
  /// Path to the background image
  final String backgroundImagePath;
  
  /// Callback when the medication is taken
  final VoidCallback? onTake;
  
  /// Callback when the medication is skipped
  final VoidCallback? onSkip;
  
  /// Callback when the medication is rescheduled
  final VoidCallback? onReschedule;

  const MedicationManagementAlert({
    super.key,
    required this.medicationName,
    this.dosage = "Default dosage",
    required this.instructions,
    this.backgroundImagePath = 'assets/images/medication_management_alert.png',
    this.onTake,
    this.onSkip,
    this.onReschedule,
  });
  
  /// Create an alert from a Medication entity
  factory MedicationManagementAlert.fromMedication({
    required Medication medication,
    required VoidCallback onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
  }) {
    return MedicationManagementAlert(
      medicationName: medication.name,
      dosage: medication.dosage ?? "Default dosage",
      instructions: medication.instruction ?? "",
      backgroundImagePath: backgroundImagePath,
      onTake: onTake,
      onSkip: onSkip,
      onReschedule: onReschedule,
    );
  }

  @override
  State<MedicationManagementAlert> createState() =>
      _MedicationManagementAlertState();
}

class _MedicationManagementAlertState extends State<MedicationManagementAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeHintController;
  double _dragExtent = 0.0;
  bool _imageLoadError = false;

  @override
  void initState() {
    super.initState();
    _swipeHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
                if (widget.onTake != null) widget.onTake!();
                Navigator.of(context).pop('take');
              } else if (_dragExtent < -80) {
                // Swiped left - Skip medication
                if (widget.onSkip != null) widget.onSkip!();
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
                          offset: const Offset(0, 10),
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
                            child: _imageLoadError
                                ? Container(
                                    color: blueColor.withOpacity(0.1),
                                    child: Center(
                                      child: Icon(
                                        Icons.medication_rounded,
                                        color: blueColor,
                                        size: 48.sp,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    widget.backgroundImagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // If image fails to load, show a fallback
                                      setState(() {
                                        _imageLoadError = true;
                                      });
                                      return Container(
                                        color: blueColor.withOpacity(0.1),
                                        child: Center(
                                          child: Icon(
                                            Icons.medication_rounded,
                                            color: blueColor,
                                            size: 48.sp,
                                          ),
                                        ),
                                      );
                                    },
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
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12.w,
                                runSpacing: 8.h,
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
                                      mainAxisSize: MainAxisSize.min,
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

                                  // Instructions info (only if not empty)
                                  if (widget.instructions.isNotEmpty)
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
                                        mainAxisSize: MainAxisSize.min,
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
                                      if (widget.onSkip != null) widget.onSkip!();
                                      Navigator.of(context).pop('skip');
                                    },
                                  ),

                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.calendar_today,
                                    label: "Reschedule",
                                    color: const Color(0xFFAEC5EB),
                                    onTap: () {
                                      if (widget.onReschedule != null) widget.onReschedule!();
                                      Navigator.of(context).pop('reschedule');
                                    },
                                  ),

                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.add,
                                    label: "Take",
                                    color: blueColor,
                                    onTap: () {
                                      if (widget.onTake != null) widget.onTake!();
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
                      offset: const Offset(0, 2),
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
                  offset: const Offset(0, 4),
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

/// Service for managing medication alerts
class MedicationAlertService {
  static final MedicationAlertService _instance = MedicationAlertService._internal();
  
  /// Get the singleton instance
  factory MedicationAlertService() => _instance;
  MedicationAlertService._internal();

  final List<Map<String, dynamic>> _queue = [];
  bool _isShowingAlert = false;

  /// Add a medication to the queue
  void addToQueue({
    required BuildContext context,
    required String medicationName,
    required String dosage,
    required String instructions,
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
    VoidCallback? onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
  }) {
    _queue.add({
      'context': context,
      'medicationName': medicationName,
      'dosage': dosage,
      'instructions': instructions,
      'backgroundImagePath': backgroundImagePath,
      'onTake': onTake,
      'onSkip': onSkip,
      'onReschedule': onReschedule,
    });

    // Start showing alerts if not already showing
    if (!_isShowingAlert) {
      _showNextAlert();
    }
  }

  /// Add a medication entity to the queue
  void addMedicationToQueue({
    required BuildContext context,
    required Medication medication,
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
    VoidCallback? onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
  }) {
    addToQueue(
      context: context,
      medicationName: medication.name,
      dosage: medication.dosage ?? "Default dosage",
      instructions: medication.instruction ?? "",
      backgroundImagePath: backgroundImagePath,
      onTake: onTake,
      onSkip: onSkip,
      onReschedule: onReschedule,
    );
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
          backgroundImagePath: medication['backgroundImagePath'],
          onTake: medication['onTake'],
          onSkip: medication['onSkip'],
          onReschedule: medication['onReschedule'],
        );
      },
    ).then((value) {
      // Show the next alert after this one is closed
      _showNextAlert();
    });
  }
}

/// Extension methods for Medication entity
extension MedicationAlertExtension on Medication {
  /// Show an alert for this medication
  Future<String?> showAlert(
    BuildContext context, {
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
    VoidCallback? onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return MedicationManagementAlert.fromMedication(
          medication: this,
          backgroundImagePath: backgroundImagePath,
          onTake: onTake ?? () {},
          onSkip: onSkip,
          onReschedule: onReschedule,
        );
      },
    );
  }
  
  /// Add this medication to the alert queue
  void addToAlertQueue(
    BuildContext context, {
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
    VoidCallback? onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
  }) {
    MedicationAlertService().addMedicationToQueue(
      context: context,
      medication: this,
      backgroundImagePath: backgroundImagePath,
      onTake: onTake,
      onSkip: onSkip,
      onReschedule: onReschedule,
    );
  }
}
