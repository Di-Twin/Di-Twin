import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodGridItem extends StatelessWidget {
  final Map<String, dynamic> food;
  final VoidCallback onTap;

  const FoodGridItem({
    super.key,
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract food properties with fallbacks
    final String name = food['name'] ?? 'Unknown Food';
    final int calories = food['calories'] ?? 0;
    final Color color = food['color'] ?? Colors.blue;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getFoodIcon(name),
                color: color,
                size: 24.sp,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Food name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 4.h),
            
            // Calories
            Text(
              '$calories cal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
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
