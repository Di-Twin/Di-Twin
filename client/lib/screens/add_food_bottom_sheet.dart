import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/food_grid_item.dart';
import 'package:client/screens/food_detail_sheet.dart';

class AddFoodBottomSheet extends StatefulWidget {
  final String mealType;
  final List<Map<String, dynamic>> popularFoods;

  const AddFoodBottomSheet({
    Key? key,
    required this.mealType,
    required this.popularFoods,
  }) : super(key: key);

  @override
  State<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends State<AddFoodBottomSheet> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Track if search is active
  bool _isSearching = false;

  // Search results
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchResults = List.from(widget.popularFoods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Search for foods
  void _searchFoods(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = List.from(widget.popularFoods);
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults =
          widget.popularFoods
              .where(
                (food) => food['name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  // Show food detail sheet
  void _showFoodDetailSheet(Map<String, dynamic> food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FoodDetailSheet(
          food: food,
          mealType: widget.mealType,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to ${widget.mealType.substring(0, 1).toUpperCase() + widget.mealType.substring(1)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchFoods,
                decoration: InputDecoration(
                  hintText: 'Search for food...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF64748B),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Search results or popular foods
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Text(
              _isSearching ? 'Search Results' : 'Popular Foods',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Food grid
          Expanded(
            child:
                _searchResults.isEmpty
                    ? Center(
                      child: Text(
                        'No results found',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    )
                    : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.r),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                          ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final food = _searchResults[index];
                        return FoodGridItem(
                          food: food,
                          onTap: () {
                            // Add food to meal
                            Navigator.pop(context);
                            _showFoodDetailSheet(food);
                          },
                        );
                      },
                    ),
          ),

          // Alternative options
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                // Divider with text
                Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: Text(
                        'OR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),

                SizedBox(height: 16.h),

                // Scan barcode button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Implement barcode scanning
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Barcode scanning coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text(
                      'Scan Food',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0F67FE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Create custom food button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Implement custom food creation
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Custom food creation coming soon',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(Icons.add_circle_outline),
                    label: Text(
                      'Create Custom Food',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF0F67FE),
                      side: BorderSide(color: Color(0xFF0F67FE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
