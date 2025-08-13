import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WatchConnectionAlert extends StatefulWidget {
  final String backgroundImagePath;
  final Function(String) onWatchSelected;

  const WatchConnectionAlert({
    super.key,
    this.backgroundImagePath = './images/watch_connection_background.png',
    required this.onWatchSelected,
  });

  @override
  State<WatchConnectionAlert> createState() => _WatchConnectionAlertState();
}

class _WatchConnectionAlertState extends State<WatchConnectionAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final double _dragExtent = 0.0;

  // Selected watch type
  String? _selectedWatchType;

  // Watch options
  final List<Map<String, dynamic>> _watchOptions = [
    {'name': 'Fitbit', 'icon': Icons.watch, 'color': Color(0xFF00B0B9)},
    {
      'name': 'Garmin',
      'icon': Icons.watch_outlined,
      'color': Color(0xFF006CFF),
    },
    {
      'name': 'Google Health',
      'icon': Icons.health_and_safety,
      'color': Color(0xFF34A853),
    },
    {
      'name': 'Apple Health',
      'icon': Icons.favorite,
      'color': Color(0xFFFF2D55),
    },
    {
      'name': 'Samsung Health',
      'icon': Icons.monitor_heart,
      'color': Color(0xFF1428A0),
    },
    {
      'name': 'Mi Fit',
      'icon': Icons.fitness_center,
      'color': Color(0xFFFF6700),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color blueColor = Color(0xFF0F67FE);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        Image.asset(
                          widget.backgroundImagePath,
                          fit: BoxFit.cover,
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                        // Watch icon with pulsing animation
                        Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.9, end: 1.1),
                            duration: Duration(seconds: 2),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.watch,
                                    color: Colors.white,
                                    size: 40.sp,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content section
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        'Connect Your Watch',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3142),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 16.h),

                      // Description
                      Text(
                        'Track your health metrics automatically by connecting your fitness watch or health app',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 32.h),

                      // Watch options grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                        ),
                        itemCount: _watchOptions.length,
                        itemBuilder: (context, index) {
                          final option = _watchOptions[index];
                          final bool isSelected =
                              _selectedWatchType == option['name'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedWatchType = option['name'];
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? option['color']
                                            : option['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: option['color']
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ]
                                            : null,
                                    border:
                                        isSelected
                                            ? null
                                            : Border.all(
                                              color: option['color']
                                                  .withOpacity(0.3),
                                            ),
                                  ),
                                  child: Icon(
                                    option['icon'],
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : option['color'],
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  option['name'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                    color:
                                        isSelected
                                            ? option['color']
                                            : const Color(0xFF2D3142),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 32.h),

                      // Connect button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed:
                              _selectedWatchType != null
                                  ? () {
                                    widget.onWatchSelected(_selectedWatchType!);
                                    Navigator.of(context).pop();
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Connect',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Skip button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Skip for now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
}

// Queue for managing watch connection alerts
class WatchConnectionAlertQueue {
  static final WatchConnectionAlertQueue _instance =
      WatchConnectionAlertQueue._internal();
  factory WatchConnectionAlertQueue() => _instance;
  WatchConnectionAlertQueue._internal();

  bool _isShowingAlert = false;

  // Show watch connection alert
  void showAlert(BuildContext context, Function(String) onWatchSelected) {
    if (_isShowingAlert) return;

    _isShowingAlert = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return WatchConnectionAlert(onWatchSelected: onWatchSelected);
      },
    ).then((_) {
      _isShowingAlert = false;
    });
  }
}
