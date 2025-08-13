import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/food_management/domain/entities/food_item.dart';

class MealTypeSection extends StatelessWidget {
  final String title;
  final List<dynamic> foods;
  final Color? color;
  final IconData? icon;
  final bool isSmallScreen;
  final int? expandedFoodIndex;
  final Function(int)? onToggleExpand;
  final Function(dynamic)? onEdit;
  final Function(dynamic)? onDelete;
  final Function(dynamic)? onFoodTap;

  const MealTypeSection({
    super.key,
    required this.title,
    required this.foods,
    this.color,
    this.icon,
    this.isSmallScreen = false,
    this.expandedFoodIndex,
    this.onToggleExpand,
    this.onEdit,
    this.onDelete,
    this.onFoodTap,
  });

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return SizedBox.shrink();
    }

    final sectionColor = color ?? _getMealColor(title);
    final mealIcon = icon ?? _getMealIcon(title);

    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: sectionColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    mealIcon,
                    color: sectionColor,
                    size: 20.0,
                  ),
                ),
                SizedBox(width: 12.0),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 16.0 : 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${_calculateTotalCalories(foods)} cal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmallScreen ? 12.0 : 14.0,
                      fontWeight: FontWeight.w600,
                      color: sectionColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Food items
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: foods.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16.0,
              endIndent: 16.0,
            ),
            itemBuilder: (context, index) {
              final food = foods[index];
              final isExpanded = expandedFoodIndex == index;
              
              return _buildFoodItem(
                context, 
                food, 
                index, 
                isExpanded, 
                sectionColor
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(
    BuildContext context, 
    dynamic food, 
    int index, 
    bool isExpanded,
    Color sectionColor
  ) {
    // Extract food properties based on type
    String name = '';
    int calories = 0;
    String time = '';
    
    if (food is FoodItem) {
      name = food.name;
      calories = food.calories;
      time = food.time;
    } else if (food is Map<String, dynamic>) {
      name = food['name'] ?? 'Unknown';
      calories = (food['calories'] as num?)?.toInt() ?? 0;
      time = food['time'] ?? '';
    }

    return InkWell(
      onTap: () {
        if (onFoodTap != null) {
          onFoodTap!(food);
        } else if (onToggleExpand != null) {
          onToggleExpand!(index);
        }
      },
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmallScreen ? 12.0 : 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '$calories cal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmallScreen ? 12.0 : 14.0,
                      fontWeight: FontWeight.w600,
                      color: sectionColor,
                    ),
                  ),
                ),
                if (onToggleExpand != null)
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20.0,
                    ),
                    onPressed: () => onToggleExpand!(index),
                  ),
              ],
            ),
            
            // Expanded details
            if (isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.0),
                  Divider(),
                  SizedBox(height: 12.0),
                  _buildNutritionInfo(food),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: () => onEdit!(food),
                          icon: Icon(Icons.edit, size: 16.0),
                          label: Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                      SizedBox(width: 8.0),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: () => onDelete!(food),
                          icon: Icon(Icons.delete, size: 16.0),
                          label: Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(dynamic food) {
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    
    if (food is FoodItem) {
      protein = food.protein;
      carbs = food.carbs;
      fat = food.fat;
    } else if (food is Map<String, dynamic>) {
      protein = (food['protein'] as num?)?.toDouble() ?? 0;
      carbs = (food['carbs'] as num?)?.toDouble() ?? 0;
      fat = (food['fat'] as num?)?.toDouble() ?? 0;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNutrientBadge('Protein', '$protein g', Colors.blue),
        _buildNutrientBadge('Carbs', '$carbs g', Colors.orange),
        _buildNutrientBadge('Fat', '$fat g', Colors.green),
      ],
    );
  }

  Widget _buildNutrientBadge(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalCalories(List<dynamic> foods) {
    int total = 0;
    for (var food in foods) {
      if (food is FoodItem) {
        total += food.calories;
      } else if (food is Map<String, dynamic>) {
        total += (food['calories'] as num?)?.toInt() ?? 0;
      }
    }
    return total;
  }

  Color _getMealColor(String mealType) {
    final lowerMealType = mealType.toLowerCase();
    if (lowerMealType.contains('breakfast')) {
      return Color(0xFF4CAF50);
    } else if (lowerMealType.contains('lunch')) {
      return Color(0xFFFFA726);
    } else if (lowerMealType.contains('dinner')) {
      return Color(0xFFEC407A);
    } else if (lowerMealType.contains('snack')) {
      return Color(0xFF7E57C2);
    }
    return Color(0xFF2196F3);
  }

  IconData _getMealIcon(String mealType) {
    final lowerMealType = mealType.toLowerCase();
    if (lowerMealType.contains('breakfast')) {
      return Icons.breakfast_dining;
    } else if (lowerMealType.contains('lunch')) {
      return Icons.lunch_dining;
    } else if (lowerMealType.contains('dinner')) {
      return Icons.dinner_dining;
    } else if (lowerMealType.contains('snack')) {
      return Icons.cookie;
    }
    return Icons.restaurant;
  }
}
