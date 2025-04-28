import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodGridItem extends StatelessWidget {
  final Map<String, dynamic> food;
  final VoidCallback onTap;

  const FoodGridItem({
    Key? key,
    required this.food,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Food icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: food['color'] != null 
                    ? (food['color'] as Color).withOpacity(0.2) 
                    : Color(0xFFEDF2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getFoodIcon(food['name']),
                color: food['color'] ?? Color(0xFF0F67FE),
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            
            // Food name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                food['name'],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4.h),
            
            // Calories
            Text(
              '${food['calories']} cal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get icon based on food name
  IconData _getFoodIcon(String foodName) {
    final lowerCaseName = foodName.toLowerCase();
    
    if (lowerCaseName.contains('broccoli') || 
        lowerCaseName.contains('vegetable') || 
        lowerCaseName.contains('salad')) {
      return Icons.eco;
    } else if (lowerCaseName.contains('chicken') || 
               lowerCaseName.contains('meat') || 
               lowerCaseName.contains('beef') ||
               lowerCaseName.contains('fish')) {
      return Icons.set_meal;
    } else if (lowerCaseName.contains('apple') || 
               lowerCaseName.contains('fruit') || 
               lowerCaseName.contains('banana') ||
               lowerCaseName.contains('orange')) {
      return Icons.apple;
    } else if (lowerCaseName.contains('bread') || 
               lowerCaseName.contains('toast') || 
               lowerCaseName.contains('sandwich')) {
      return Icons.breakfast_dining;
    } else if (lowerCaseName.contains('coffee') || 
               lowerCaseName.contains('tea') || 
               lowerCaseName.contains('water') ||
               lowerCaseName.contains('juice') ||
               lowerCaseName.contains('drink')) {
      return Icons.local_cafe;
    } else if (lowerCaseName.contains('soup') || 
               lowerCaseName.contains('broth')) {
      return Icons.soup_kitchen;
    } else if (lowerCaseName.contains('cake') || 
               lowerCaseName.contains('dessert') || 
               lowerCaseName.contains('cookie') ||
               lowerCaseName.contains('sweet')) {
      return Icons.cake;
    } else if (lowerCaseName.contains('egg')) {
      return Icons.egg;
    } else if (lowerCaseName.contains('pizza')) {
      return Icons.local_pizza;
    } else if (lowerCaseName.contains('rice') || 
               lowerCaseName.contains('grain')) {
      return Icons.rice_bowl;
    }
    
    // Default icon
    return Icons.restaurant;
  }
}
