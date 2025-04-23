import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityBlock extends StatelessWidget {
  final String activity;
  final int value;
  final Color color;
  final double width;
  final double height;
  final double rotation;
  
  const ActivityBlock({
    Key? key,
    required this.activity,
    required this.value,
    required this.color,
    required this.width,
    required this.height,
    this.rotation = 0.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: width * 0.4,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
