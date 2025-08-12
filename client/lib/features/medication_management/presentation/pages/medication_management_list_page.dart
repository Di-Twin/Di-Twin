import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:client/features/medication_management/presentation/pages/medication_management_day.dart';
import 'package:client/features/medication_management/presentation/pages/medication_management_edit.dart';
import 'package:client/features/medication_management/presentation/providers/medication_api_provider.dart';
import 'package:client/features/medication_management/data/models/api_medication_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicationManagementListPage extends ConsumerStatefulWidget {
  const MedicationManagementListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicationManagementListPage> createState() => _MedicationManagementListPageState();
}

class _MedicationManagementListPageState extends ConsumerState<MedicationManagementListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchFocused = false;

  // Color palette for medications
  final List<Color> _medicationColors = [
    const Color(0xFF4285F4),
    const Color(0xFF34A853),
    const Color(0xFFEA4335),
    const Color(0xFFFBBC04),
    const Color(0xFF9C27B0),
    const Color(0xFF00BCD4),
    const Color(0xFF795548),
    const Color(0xFF607D8B),
    const Color(0xFFFF5722),
    const Color(0xFF3F51B5),
  ];

  List<ApiMedicationModel> _getFilteredMedications(List<ApiMedicationModel> medications) {
    if (_searchQuery.isEmpty) {
      return medications;
    }
    return medications.where((medication) =>
    medication.medicationName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (medication.afterFood ? 'After Food' : 'Before Food').toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onAddMedicationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicationsManagementDay(),
      ),
    );
  }

  Color _getMedicationColor(int index) {
    return _medicationColors[index % _medicationColors.length];
  }

  String _getTimingText(bool afterFood) {
    return afterFood ? 'After Food' : 'Before Food';
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 400.0;
    final medicationsAsync = ref.watch(userMedicationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Main content with proper padding to avoid header overlap
          Column(
            children: [
              // Space for header
              SizedBox(height: headerHeight.h),

              // Content Section
              Expanded(
                child: medicationsAsync.when(
                  data: (medications) => _isSearchFocused
                      ? _buildSearchView(medications)
                      : _buildNormalView(medications),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error.toString()),
                ),
              ),
            ],
          ),

          // Fixed Header positioned at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: headerHeight.h,
              child: medicationsAsync.when(
                data: (medications) => CustomActivityHeader(
                  title: 'Medications',
                  score: medications.length.toString(),
                  subtitle: 'Medications',
                  badgeText: 'Active',
                  buttonImage: 'images/SignInAddIcon.png',
                  onButtonTap: _onAddMedicationTap,
                  backgroundColor: const Color(0xFF4285F4),
                  backgroundImagePath: 'images/activity_header_background.png',
                  titleTextColor: Colors.white,
                  scoreTextColor: Colors.white,
                  subtitleTextColor: Colors.white,
                  backButtonBorderColor: Colors.white,
                  badgeBackgroundColor: Colors.white,
                  badgeTextColor: const Color(0xFF4285F4),
                  buttonColor: const Color(0xFF1E293B),
                  buttonShadowColor: const Color(0xFF1E293B),
                  backButtonBorderWidth: 1.0,
                  bottomLeftRadius: 30,
                  bottomRightRadius: 30,
                  buttonShadowSpread: 0,
                  headerHeight: headerHeight,
                  showBadge: true,
                  showMenu: false,
                ),
                loading: () => CustomActivityHeader(
                  title: 'Medications',
                  score: '0',
                  subtitle: 'Medications',
                  badgeText: 'Active',
                  buttonImage: 'images/SignInAddIcon.png',
                  onButtonTap: _onAddMedicationTap,
                  backgroundColor: const Color(0xFF4285F4),
                  backgroundImagePath: 'images/activity_header_background.png',
                  titleTextColor: Colors.white,
                  scoreTextColor: Colors.white,
                  subtitleTextColor: Colors.white,
                  backButtonBorderColor: Colors.white,
                  badgeBackgroundColor: Colors.white,
                  badgeTextColor: const Color(0xFF4285F4),
                  buttonColor: const Color(0xFF1E293B),
                  buttonShadowColor: const Color(0xFF1E293B),
                  backButtonBorderWidth: 1.0,
                  bottomLeftRadius: 30,
                  bottomRightRadius: 30,
                  buttonShadowSpread: 0,
                  headerHeight: headerHeight,
                  showBadge: true,
                  showMenu: false,
                ),
                error: (error, stack) => CustomActivityHeader(
                  title: 'Medications',
                  score: '0',
                  subtitle: 'Medications',
                  badgeText: 'Error',
                  buttonImage: 'images/SignInAddIcon.png',
                  onButtonTap: _onAddMedicationTap,
                  backgroundColor: const Color(0xFF4285F4),
                  backgroundImagePath: 'images/activity_header_background.png',
                  titleTextColor: Colors.white,
                  scoreTextColor: Colors.white,
                  subtitleTextColor: Colors.white,
                  backButtonBorderColor: Colors.white,
                  badgeBackgroundColor: Colors.white,
                  badgeTextColor: const Color(0xFF4285F4),
                  buttonColor: const Color(0xFF1E293B),
                  buttonShadowColor: const Color(0xFF1E293B),
                  backButtonBorderWidth: 1.0,
                  bottomLeftRadius: 30,
                  bottomRightRadius: 30,
                  buttonShadowSpread: 0,
                  headerHeight: headerHeight,
                  showBadge: true,
                  showMenu: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalView(List<ApiMedicationModel> medications) {
    return Column(
      children: [
        // Fixed Section Title and Search Bar
        Container(
          color: const Color(0xFFF8F9FA),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Medications',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit mode')),
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 18.sp,
                      color: const Color(0xFF4285F4),
                    ),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4285F4),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Medications',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 24.sp,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[400],
                        size: 20.sp,
                      ),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),

        // Scrollable Medications List Only
        Expanded(
          child: _buildMedicationsList(medications),
        ),
      ],
    );
  }

  Widget _buildSearchView(List<ApiMedicationModel> medications) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit mode')),
                    );
                  },
                  icon: Icon(
                    Icons.edit,
                    size: 18.sp,
                    color: const Color(0xFF4285F4),
                  ),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search Medications',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 24.sp,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                      size: 20.sp,
                    ),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Search Results Count
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(
                  '${_getFilteredMedications(medications).length} result${_getFilteredMedications(medications).length != 1 ? 's' : ''} found',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            // Search Results
            _buildMedicationsList(medications),

            SizedBox(height: 100.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsList(List<ApiMedicationModel> medications) {
    final filteredMedications = _getFilteredMedications(medications);

    if (filteredMedications.isEmpty) {
      return _buildEmptyState();
    }

    return _isSearchFocused
        ? ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredMedications.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _MedicationCard(
          medication: filteredMedications[index],
          color: _getMedicationColor(index),
          onTap: () => _showMedicationDetails(filteredMedications[index], index),
        );
      },
    )
        : ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: filteredMedications.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _MedicationCard(
          medication: filteredMedications[index],
          color: _getMedicationColor(index),
          onTap: () => _showMedicationDetails(filteredMedications[index], index),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFF4285F4),
              strokeWidth: 3.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading medications...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load medications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              errorMessage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(userMedicationsProvider);
              },
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text(
                'Retry',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.medication : Icons.search_off,
            size: 64.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isEmpty ? 'No medications found' : 'No results for "$_searchQuery"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isEmpty
                ? 'Add your first medication to get started'
                : 'Try searching with different keywords',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: ElevatedButton.icon(
                onPressed: _onAddMedicationTap,
                icon: Icon(Icons.add, size: 20.sp),
                label: Text(
                  'Add Medication',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMedicationDetails(ApiMedicationModel medication, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CompactMedicationDetailSheet(
        medication: medication,
        color: _getMedicationColor(index),
        onDelete: () => _deleteMedication(medication),
        onEdit: () => _editMedication(medication),
      ),
    );
  }

  Future<void> _deleteMedication(ApiMedicationModel medication) async {
    final medicationActions = ref.read(medicationActionsProvider);

    // Show enhanced confirmation dialog
    final confirmed = await _showEnhancedDeleteDialog(medication);

    if (confirmed == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4285F4),
          ),
        ),
      );

      final success = await medicationActions.deleteMedication(medication.id);

      // Hide loading indicator
      Navigator.pop(context);

      if (success) {
        // Add haptic feedback
        HapticFeedback.lightImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '${medication.medicationName} deleted successfully',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      } else {
        // Add haptic feedback for error
        HapticFeedback.heavyImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Failed to delete ${medication.medicationName}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }

  Future<bool?> _showEnhancedDeleteDialog(ApiMedicationModel medication) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Warning Icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6B6B).withOpacity(0.1),
                        const Color(0xFFEE5A52).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: const Color(0xFFEE5A52),
                    size: 28.sp,
                  ),
                ),
                SizedBox(height: 16.h),

                // Title
                Text(
                  'Delete Medication?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 12.h),

                // Medication Name Highlight
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    medication.medicationName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Warning Message
                Text(
                  'This action cannot be undone. All medication data, schedules, and history will be permanently removed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop(false);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Delete Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop(true);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF6B6B),
                                Color(0xFFEE5A52),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEE5A52).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Delete',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editMedication(ApiMedicationModel medication) async {
    // Navigate to edit medication page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationManagementEdit(medication: medication),
      ),
    );

    // If medication was updated successfully, refresh the list
    if (result == true) {
      ref.invalidate(userMedicationsProvider);
    }
  }
}

class _MedicationCard extends StatelessWidget {
  final ApiMedicationModel medication;
  final Color color;
  final VoidCallback onTap;

  const _MedicationCard({
    required this.medication,
    required this.color,
    required this.onTap,
  });

  String _getTimingText(bool afterFood) {
    return afterFood ? 'After Food' : 'Before Food';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            // Medication Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.7),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.medication,
                color: Colors.white,
                size: 24.sp,
              ),
            ),

            SizedBox(width: 12.w),

            // Medication Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          medication.medicationName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (medication.reminder)
                        Icon(
                          Icons.notifications_active,
                          size: 16.sp,
                          color: Colors.green,
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${medication.timings.join(', ')} • ${_getTimingText(medication.afterFood)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          medication.dose,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          medication.frequency,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactMedicationDetailSheet extends StatelessWidget {
  final ApiMedicationModel medication;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _CompactMedicationDetailSheet({
    required this.medication,
    required this.color,
    required this.onDelete,
    required this.onEdit,
  });

  String _getTimingText(bool afterFood) {
    return afterFood ? 'After Food' : 'Before Food';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Compact Header
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.7),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.medicationName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              medication.dose,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            medication.reminder ? Icons.notifications_active : Icons.notifications_off,
                            size: 16.sp,
                            color: medication.reminder ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Compact Info Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  // Schedule Row
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: color, size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Schedule',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${medication.timings.join(', ')} • ${_getTimingText(medication.afterFood)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactInfoCard(
                          'Frequency',
                          medication.frequency,
                          Icons.repeat,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildCompactInfoCard(
                          'Duration',
                          '${medication.startDate.split('-')[0]} - ${medication.endDate.split('-')[0]}',
                          Icons.calendar_today,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: medication.reminder ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          medication.reminder ? Icons.notifications_active : Icons.notifications_off,
                          color: medication.reminder ? Colors.green : Colors.red,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          medication.reminder ? 'Reminders On' : 'Reminders Off',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: medication.reminder ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          // Compact Action Buttons
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                    icon: Icon(Icons.edit, size: 18.sp),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: color, width: 1.5),
                      foregroundColor: color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    icon: Icon(Icons.delete, size: 18.sp),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
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

  Widget _buildCompactInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
