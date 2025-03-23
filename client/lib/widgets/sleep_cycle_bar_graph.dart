import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SleepCycleBarGraph extends StatelessWidget {
  final double awakeValue;
  final double remValue;
  final double lightValue;
  final double deepValue;

  const SleepCycleBarGraph({
    Key? key,
    this.awakeValue = 5,
    this.remValue = 31,
    this.lightValue = 24,
    this.deepValue = 43,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Move legend to the top, outside the graph area
        Padding(
          padding: EdgeInsets.only(bottom: 16.0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                'Awake',
                'images/sleep_management_sun.png',
              ),
              _buildLegendItem(
                'REM',
                'images/sleep_management_bed.png',
              ),
              _buildLegendItem(
                'Light',
                'images/sleep_management_warning.png',
              ),
              _buildLegendItem(
                'Deep',
                'images/sleep_management_sleep.png',
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16.0.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = constraints.maxHeight;
                final barWidth = constraints.maxWidth / 8;
                final spacing = constraints.maxWidth / 16;

                final startX = spacing;
                final bar1X = startX;
                final bar2X = startX + barWidth + spacing;
                final bar3X = bar2X + barWidth + spacing;
                final bar4X = bar3X + barWidth + spacing;

                // Set the max value to exactly 100
                final maxPossibleValue = 100.h;

                return Stack(
                  children: [
                    // Dotted lines
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: DottedLinePainter(),
                    ),

                    // Bars
                    _buildBar(
                      x: bar1X,
                      value: awakeValue,
                      maxValue: maxPossibleValue,
                      maxHeight: maxHeight,
                      barWidth: barWidth,
                      color: const Color(0xFFC1D8FA),
                    ),
                    _buildBar(
                      x: bar2X,
                      value: remValue,
                      maxValue: maxPossibleValue,
                      maxHeight: maxHeight,
                      barWidth: barWidth,
                      color: const Color(0xFF9A6EFA),
                    ),
                    _buildBar(
                      x: bar3X,
                      value: lightValue,
                      maxValue: maxPossibleValue,
                      maxHeight: maxHeight,
                      barWidth: barWidth,
                      color: const Color(0xFFFA5C5C),
                    ),
                    _buildBar(
                      x: bar4X,
                      value: deepValue,
                      maxValue: maxPossibleValue,
                      maxHeight: maxHeight,
                      barWidth: barWidth,
                      color: const Color(0xFF5B6B7F),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBar({
    required double x,
    required double value,
    required double maxValue,
    required double maxHeight,
    required double barWidth,
    required Color color,
  }) {
    final clampedValue = value > maxValue ? maxValue : value;
    final barHeight = (clampedValue / maxValue) * maxHeight;
    
    // Ensure we have enough space for the text at the top
    final textPadding = 4.h;
    final textHeight = 20.h; // Estimate text height
    
    return Positioned(
      left: x.w,
      bottom: 0,
      child: Stack(
        clipBehavior: Clip.none, // Allow the text to overflow the container if needed
        children: [
          Container(
            width: barWidth.w,
            height: barHeight.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          // Position the text at the top of the bar, but slightly outside if needed
          Positioned(
            top: value == maxValue ? -textHeight / 2 : textPadding,
            width: barWidth.w,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: value == maxValue ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String iconPath) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: 16.w,
          height: 16.h,
        ),
        SizedBox(width: 8.w),
        Text(label, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    const double dashWidth = 4;
    const double dashSpace = 4;
    final double startX = 0;
    final double endX = size.width;

    // Draw exactly 7 horizontal lines
    // This divides the height into 6 equal parts to create 7 lines
    for (int i = 0; i <= 6; i++) {
      double y = size.height - (size.height * i / 6);
      
      double currentX = startX;
      while (currentX < endX) {
        canvas.drawLine(
          Offset(currentX, y),
          Offset(currentX + dashWidth, y),
          paint,
        );
        currentX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}