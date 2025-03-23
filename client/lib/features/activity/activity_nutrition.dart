import 'package:client/widgets/ActivityHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Data model for nutrition information
class NutritionData {
  final double totalAmount;
  final String unit;
  final int proteins;
  final int macro;
  final int fiber;
  final DateTime date;

  NutritionData({
    required this.totalAmount,
    required this.unit,
    required this.proteins,
    required this.macro,
    required this.fiber,
    required this.date,
  });
}

// Provider setup for dynamic data
final nutritionProvider = StateProvider<NutritionData>((ref) {
  return NutritionData(
    totalAmount: 501.81,
    unit: 'mg',
    proteins: 510,
    macro: 16,
    fiber: 70,
    date: DateTime.now(),
  );
});

class ActivityNutrition extends ConsumerWidget {
  const ActivityNutrition({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionData = ref.watch(nutritionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              ActivityHeader(
                name: 'Nutrition',
                onTrack: 'Needs More',
                backgroundColor: const Color(0xFFFA4D5E),
                padding: EdgeInsets.all(6.w),
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 24.h),
              NutritionValueDisplay(
                totalAmount: nutritionData.totalAmount,
                unit: nutritionData.unit,
              ),
              SizedBox(height: 24.h),
              const NutritionBarChart(),
              SizedBox(height: 16.h),
              const NutritionLegend(),
              SizedBox(height: 40.h),
              NutritionMetricsRow(
                proteins: nutritionData.proteins,
                macro: nutritionData.macro,
                fiber: nutritionData.fiber,
              ),
              SizedBox(height: 24.h),
              const DateNavigator(),
              const Spacer(),
              const AddFoodButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class NutritionValueDisplay extends StatelessWidget {
  final double totalAmount;
  final String unit;

  const NutritionValueDisplay({
    Key? key,
    required this.totalAmount,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Nutrition',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1D2939),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              totalAmount.toString().replaceAll('.', ','),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 48.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D2939),
              ),
            ),
          SizedBox(width: 4.w),
            Text(
              unit,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NutritionBarChart extends StatelessWidget {
  const NutritionBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row of bars
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6FEE),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E4FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // Second row of bars
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5B6A),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 2,
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6DC),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // Third row of bars
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2939),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NutritionLegend extends StatelessWidget {
  const NutritionLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Target legend
        Row(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD6E4FF),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD6DC),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
        SizedBox(width: 8.w),
        Text(
          'Target',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1D2939),
          ),
        ),
        SizedBox(width: 32.w),
        // Taken legend
        Row(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1A6FEE),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5B6A),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1D2939),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
        SizedBox(width: 8.w),
        Text(
          'Taken',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1D2939),
          ),
        ),
      ],
    );
  }
}

class NutritionMetricsRow extends StatelessWidget {
  final int proteins;
  final int macro;
  final int fiber;

  const NutritionMetricsRow({
    Key? key,
    required this.proteins,
    required this.macro,
    required this.fiber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNutritionItem(
            context,
            color: const Color(0xFF1A6FEE),
            title: 'Proteins',
            value: '${proteins}g',
          ),
        ),
        Container(width: 1, height: 64.h, color: Colors.grey.shade300),
        Expanded(
          child: _buildNutritionItem(
            context,
            color: const Color(0xFFFF5B6A),
            title: 'Macro',
            value: '${macro}g',
          ),
        ),
        Container(width: 1, height: 64.h, color: Colors.grey.shade300),
        Expanded(
          child: _buildNutritionItem(
            context,
            color: const Color(0xFF1D2939),
            title: 'Fiber',
            value: '${fiber}g',
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionItem(
    BuildContext context, {
    required Color color,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D2939),
          ),
        ),
      ],
    );
  }
}

class DateNavigator extends StatelessWidget {
  const DateNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        SizedBox(width: 8.w),
        Text(
          'Today',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1D2939),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}

class AddFoodButton extends StatelessWidget {
  const AddFoodButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A6FEE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Add Food',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            const Icon(Icons.add, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
