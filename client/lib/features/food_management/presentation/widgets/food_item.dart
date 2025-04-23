import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/food_management/presentation/widgets/nutrient_badge.dart';

class FoodItem extends StatelessWidget {
  final Map<String, dynamic> food;
  final int index;
  final bool isSmallScreen;
  final bool isExpanded;
  final Function(int) onToggleExpand;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const FoodItem({
    Key? key,
    required this.food,
    required this.index,
    required this.isSmallScreen,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Map food names to appropriate icons
    IconData getFoodIcon(String foodName) {
      switch (foodName.toLowerCase()) {
        case 'dosa':
          return Icons.breakfast_dining;
        case 'salad bowl':
          return Icons.eco;
        case 'grilled chicken':
          return Icons.set_meal;
        case 'smoothie bowl':
          return Icons.blender;
        case 'pasta':
          return Icons.dinner_dining;
        default:
          return Icons.restaurant;
      }
    }

    return GestureDetector(
      onTap: () => onToggleExpand(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
          child: Column(
            children: [
              // Main food item row
              Row(
                children: [
                  // Food icon instead of image
                  Container(
                    width: isSmallScreen ? 50 : 60,
                    height: isSmallScreen ? 50 : 60,
                    decoration: BoxDecoration(
                      color: food['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getFoodIcon(food['name']),
                      color: food['color'],
                      size: isSmallScreen ? 24 : 30,
                    ),
                  ),

                  SizedBox(width: 12),

                  // Food details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food['name'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        SizedBox(height: 4),

                        // Weight and time
                        Row(
                          children: [
                            Icon(
                              Icons.scale,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              food['weight'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            SizedBox(width: 12),

                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              food['time'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        // Calories
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${food['calories']} kcal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse indicator
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ],
              ),

              // Expanded section with macros and action buttons
              if (isExpanded) ...[
                Divider(height: 24, color: Colors.grey.shade200),

                // Macros
                if (food.containsKey('protein') &&
                    food.containsKey('carbs') &&
                    food.containsKey('fat'))
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NutrientBadge(
                          label: 'Protein',
                          value: food['protein'],
                          color: Color(0xFF4CAF50),
                          unit: 'g',
                        ),
                        NutrientBadge(
                          label: 'Carbs',
                          value: food['carbs'],
                          color: Color(0xFF2196F3),
                          unit: 'g',
                        ),
                        NutrientBadge(
                          label: 'Fat',
                          value: food['fat'],
                          color: Color(0xFFFF9800),
                          unit: 'g',
                        ),
                      ],
                    ),
                  ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit button
                    TextButton.icon(
                      onPressed: () => onEdit(food),
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: Color(0xFF0F67FE),
                      ),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F67FE),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    // Delete button
                    TextButton.icon(
                      onPressed: () => onDelete(food),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFF44336),
                      ),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF44336),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
