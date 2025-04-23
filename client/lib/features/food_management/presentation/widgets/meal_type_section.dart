import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/food_management/presentation/widgets/food_item.dart';

class MealTypeSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> foods;
  final Color color;
  final IconData icon;
  final bool isSmallScreen;
  final int? expandedFoodIndex;
  final Function(int) onToggleExpand;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const MealTypeSection({
    super.key,
    required this.title,
    required this.foods,
    required this.color,
    required this.icon,
    required this.isSmallScreen,
    required this.expandedFoodIndex,
    required this.onToggleExpand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 16 : 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),

        // Food items
        ...foods.asMap().entries.map((entry) {
          final index = entry.key;
          final food = entry.value;
          final globalIndex = foods.indexOf(food);
          return FoodItem(
            food: food,
            index: globalIndex,
            isSmallScreen: isSmallScreen,
            isExpanded: expandedFoodIndex == globalIndex,
            onToggleExpand: onToggleExpand,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        }),
      ],
    );
  }
}
