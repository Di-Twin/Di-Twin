import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/providers/water_intake_provider.dart';

class QuickAddButtons extends StatelessWidget {
  const QuickAddButtons({super.key});

  final List<Map<String, dynamic>> _quickAmounts = const [
    {'amount': 250, 'label': 'Glass', 'icon': '🥛'},
    {'amount': 500, 'label': 'Bottle', 'icon': '🍼'},
    {'amount': 750, 'label': 'Large', 'icon': '🧴'},
    {'amount': 1000, 'label': 'Jumbo', 'icon': '🪣'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterIntakeProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Add',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: _quickAmounts.length,
                itemBuilder: (context, index) {
                  final item = _quickAmounts[index];
                  return _buildQuickAddButton(
                    context,
                    provider,
                    item['amount'],
                    item['label'],
                    item['icon'],
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildCustomAmountButton(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAddButton(
      BuildContext context,
      WaterIntakeProvider provider,
      int amount,
      String label,
      String icon,
      ) {
    return GestureDetector(
      onTap: () => _addWaterIntake(context, provider, amount.toDouble()),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              '${amount}ml',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAmountButton(BuildContext context, WaterIntakeProvider provider) {
    return GestureDetector(
      onTap: () => _showCustomAmountDialog(context, provider),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
            SizedBox(width: 8.w),
            Text(
              'Custom Amount',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomAmountDialog(BuildContext context, WaterIntakeProvider provider) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Custom Amount',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount (ml)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.of(context).pop();
                _addWaterIntake(context, provider, amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addWaterIntake(
      BuildContext context,
      WaterIntakeProvider provider,
      double amount,
      ) async {
    try {
      await provider.addWaterIntake(amount);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8.w),
                Text('Added ${amount.toInt()}ml! 💧'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
