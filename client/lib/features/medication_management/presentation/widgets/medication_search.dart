import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationSearch extends StatefulWidget {
  final String selectedMedication;
  final Function(String) onMedicationSelected;

  const MedicationSearch({
    super.key,
    required this.selectedMedication,
    required this.onMedicationSelected,
  });

  @override
  State<MedicationSearch> createState() => _MedicationSearchState();
}

class _MedicationSearchState extends State<MedicationSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  
  final Color _primaryColor = Color(0xFF0F67FE);
  final Color _textPrimaryColor = Color(0xFF1E293B);
  final Color _textSecondaryColor = Color(0xFF64748B);
  final Color _borderColor = Color(0xFFE2E8F0);
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.selectedMedication;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchMedications(String query) {
    setState(() {
      _isSearching = true;
    });

    // Simulate API delay
    Future.delayed(Duration(milliseconds: 800), () {
      // Mock data - in a real app, this would be an API call
      final mockResults = [
        {'name': 'Amoxicillin', 'description': 'Antibiotic - 500mg'},
        {'name': 'Lisinopril', 'description': 'Blood pressure medication'},
        {'name': 'Metformin', 'description': 'Diabetes medication'},
        {'name': 'Atorvastatin', 'description': 'Cholesterol medication'},
        {'name': 'Albuterol', 'description': 'Asthma inhaler'},
      ];

      // Filter results based on query
      final filteredResults = mockResults
          .where((med) => med['name']?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();

      setState(() {
        _searchResults = filteredResults;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Medication',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: _textPrimaryColor,
          ),
        ),

        SizedBox(height: 16.h),

        // Medication search bar
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              color: _textPrimaryColor,
            ),
            decoration: InputDecoration(
              hintText: 'Search medication name',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: Colors.grey.shade400,
                fontSize: 16.sp,
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12.w),
                child: Icon(Icons.search, color: _primaryColor, size: 24.r),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: _textSecondaryColor,
                        size: 20.r,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchResults = [];
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            onChanged: (value) {
              if (value.length > 2) {
                _searchMedications(value);
              } else {
                setState(() {
                  _searchResults = [];
                  _isSearching = false;
                });
              }
            },
          ),
        ),

        // Search results
        if (_isSearching)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                ),
              ),
            ),
          )
        else if (_searchResults.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            constraints: BoxConstraints(maxHeight: 250.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              shrinkWrap: true,
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => Divider(
                color: _borderColor,
                height: 1,
                indent: 16.w,
                endIndent: 16.w,
              ),
              itemBuilder: (context, index) {
                final medication = _searchResults[index];
                final bool isSelected = widget.selectedMedication == medication['name'];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      widget.onMedicationSelected(medication['name']);
                      setState(() {
                        _searchController.text = medication['name'];
                        _searchResults = [];
                      });
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.medication_outlined,
                                color: isSelected ? _primaryColor : Colors.grey.shade400,
                                size: 20.r,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medication['name'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimaryColor,
                                  ),
                                ),
                                if (medication['description'] != null)
                                  Text(
                                    medication['description'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      color: _textSecondaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: _primaryColor,
                              size: 20.r,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Selected medication
        if (widget.selectedMedication.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 24.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.medication,
                      color: _primaryColor,
                      size: 24.r,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Medication',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: _textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.selectedMedication,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: _textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: _primaryColor, size: 20.r),
                  onPressed: () {
                    setState(() {
                      _searchController.text = widget.selectedMedication;
                      _searchMedications(widget.selectedMedication);
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
