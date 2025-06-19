// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:client/features/food_management/presentation/providers/food_management_provider.dart';
// import 'package:intl/intl.dart';

// class FoodDetailSheet extends StatefulWidget {
//   final Map<String, dynamic> food;
//   final String mealType;

//   const FoodDetailSheet({
//     super.key,
//     required this.food,
//     required this.mealType,
//   });

//   @override
//   State<FoodDetailSheet> createState() => _FoodDetailSheetState();
// }

// class _FoodDetailSheetState extends State<FoodDetailSheet> {
  // final FoodManagementProvider _foodProvider = FoodManagementProvider();
  // bool _isAdding = false;
  // double _servingAmount = 1.0; // Default serving amount

  // Future<void> _addFoodToMeal() async {
  //   setState(() => _isAdding = true);

  //   try {
  //     final foodSession = {
  //       "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
  //       "foodItems": [
  //         {
  //           "foodName": widget.food['name'] ?? 'Unknown Food',
  //           "macronutrients": {
  //             "energy_kcal": (widget.food['calories'] as num).toDouble(),
  //             "protein_g": (widget.food['protein'] as num).toDouble(),
  //             "fat_g": (widget.food['fat'] as num).toDouble(),
  //             "carbohydrates_g": (widget.food['carbs'] as num).toDouble(),
              
  //           },
  //           "serving_size": widget.food['weight'] ?? '100g',
  //           "serving_amount": _servingAmount,
  //           "mealType": widget.mealType,
  //         }
  //       ]
  //     };

  //     final response = await _foodProvider.createFoodSession(foodSession);

  //     if (response['success'] == true) {
  //       Navigator.pop(context, true);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(response['message'] ?? 'Failed to add food'),
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: ${e.toString()}'),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   } finally {
  //     setState(() => _isAdding = false);
  //   }
  // }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24.r),
//           topRight: Radius.circular(24.r),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Handle bar
//           Center(
//             child: Container(
//               margin: EdgeInsets.only(top: 12.h),
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//           ),

//           // Header
//           Padding(
//             padding: EdgeInsets.all(20.r),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Food Details',
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 20.sp,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF1E293B),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(Icons.close, color: Color(0xFF64748B)),
//                 ),
//               ],
//             ),
//           ),

//           // Serving amount selector
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.r),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Serving Amount',
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xFF1E293B),
//                   ),
//                 ),
//                 Slider(
//                   value: _servingAmount,
//                   min: 0.5,
//                   max: 3.0,
//                   divisions: 5,
//                   label: _servingAmount.toStringAsFixed(1),
//                   onChanged: (value) {
//                     setState(() => _servingAmount = value);
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Food image
//           Center(
//             child: Container(
//               width: 120.w,
//               height: 120.h,
//               decoration: BoxDecoration(
//                 color: widget.food['color'] ?? Colors.blue,
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//               child: Icon(
//                 Icons.restaurant,
//                 size: 60.sp,
//                 color: Colors.white,
//               ),
//             ),
//           ),

//           SizedBox(height: 20.h),

//           // Food name
//           Center(
//             child: Text(
//               widget.food['name'],
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 24.sp,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF1E293B),
//               ),
//             ),
//           ),

//           SizedBox(height: 8.h),

//           // Calories
//           Center(
//             child: Text(
//               '${(widget.food['calories'] * _servingAmount).toStringAsFixed(0)} calories (${_servingAmount.toStringAsFixed(1)} serving${_servingAmount != 1.0 ? 's' : ''})',
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF64748B),
//               ),
//             ),
//           ),

//           SizedBox(height: 24.h),

//           // Nutrition info
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.r),
//             child: Text(
//               'Nutrition Information (per serving)',
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF1E293B),
//               ),
//             ),
//           ),

//           SizedBox(height: 16.h),

//           // Nutrition cards
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.r),
//             child: Row(
//               children: [
//                 _buildNutrientCard(
//                   'Protein',
//                   '${widget.food['protein']}g',
//                   Color(0xFFEDF2FF),
//                   Color(0xFF0F67FE),
//                 ),
//                 SizedBox(width: 12.w),
//                 _buildNutrientCard(
//                   'Carbs',
//                   '${widget.food['carbs']}g',
//                   Color(0xFFFFF4DE),
//                   Color(0xFFFF9500),
//                 ),
//                 SizedBox(width: 12.w),
//                 _buildNutrientCard(
//                   'Fat',
//                   '${widget.food['fat']}g',
//                   Color(0xFFFFEEF6),
//                   Color(0xFFFF2D55),
//                 ),
//               ],
//             ),
//           ),

//           Spacer(),

//           // Add button
//           Padding(
//             padding: EdgeInsets.all(20.r),
//             child: SizedBox(
//               width: double.infinity,
//               height: 56.h,
//               child: ElevatedButton(
//                 onPressed: _isAdding ? null : _addFoodToMeal,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF0F67FE),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.r),
//                   ),
//                 ),
//                 child: _isAdding
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text(
//                         'Add to ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
//                         style: GoogleFonts.plusJakartaSans(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNutrientCard(String title, String value, Color bgColor, Color textColor) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(12.r),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w500,
//                 color: textColor,
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               value,
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }