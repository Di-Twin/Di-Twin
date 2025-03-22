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

                final maxPossibleValue = 100.0;

                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(
                            'Awake',
                            const Color(0xFFC1D8FA),
                            'images/sun.png',
                          ),
                          _buildLegendItem(
                            'REM',
                            const Color(0xFF9A6EFA),
                            'images/bed.png',
                          ),
                          _buildLegendItem(
                            'Light',
                            const Color(0xFFFA5C5C),
                            'images/warning.png',
                          ),
                          _buildLegendItem(
                            'Deep',
                            const Color(0xFF5B6B7F),
                            'images/sleep.png',
                          ),
                        ],
                      ),
                    ),

                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: DottedLinePainter(),
                    ),

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

    return Positioned(
      left: x.w,
      bottom: 0,
      child: Container(
        width: barWidth.w,
        height: barHeight.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              value.toInt().toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String iconPath) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: 16.w,
          height: 16.h,
          // colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
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

    for (
      double y = size.height * 0.125;
      y < size.height;
      y += size.height * 0.125
    ) {
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
