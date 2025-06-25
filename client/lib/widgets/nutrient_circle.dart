import 'package:flutter/material.dart';
import 'package:client/features/food_management/presentation/providers/food_management_provider.dart';

class NutrientCircle extends StatelessWidget {
  final Map<String, dynamic> nutrient;
  final double size;

  const NutrientCircle({
    super.key,
    required this.nutrient,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    // Get the icon and color using the helper methods
    final IconData icon = nutrient['iconName'] != null 
        ? FoodManagementProvider().getIconFromName(nutrient['iconName'])
        : Icons.help_outline;
        
    final Color color = nutrient['colorValue'] != null 
        ? FoodManagementProvider().getColorFromValue(nutrient['colorValue'])
        : Colors.grey;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: size * 0.3,
          ),
          SizedBox(height: size * 0.05),
          Text(
            '${nutrient['value']} ${nutrient['unit']}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.18,
            ),
          ),
          Text(
            nutrient['name'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: size * 0.14,
            ),
          ),
        ],
      ),
    );
  }
}
