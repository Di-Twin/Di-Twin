import 'package:client/features/medication_management/medication_management_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:client/features/medication_management/medication_management_list.dart';
import 'package:client/features/medication_management/medication_management_edit.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Medication> _filteredMedications = [];
  final List<Medication> _allMedications = [
    // Uncomment this to test with medications
    Medication(name: 'Amoxicilline', timing: 'Before Eating'),
    Medication(name: 'Metformin', timing: 'With meals'),
    Medication(name: 'Atorvastatin', timing: 'Evening or bedtime'),
  ];
  bool _isEditMode = false;
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _medicationsTitleKey = GlobalKey();
  bool _isKeyboardVisible = false;

  // Medication statistics
  int _takenToday = 2; // Example value - replace with actual data
  int _missedToday = 1; // Example value - replace with actual data

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Colors for medication types
  final List<Color> _medicationColors = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF0EA5E9), // Sky blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
  ];

  @override
  void initState() {
    super.initState();
    _filteredMedications = _allMedications;

    // Add listener to focus node to detect keyboard visibility
    _searchFocusNode.addListener(_onFocusChange);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _searchFocusNode.hasFocus;
    });

    // If keyboard becomes visible, scroll to the medications title
    if (_searchFocusNode.hasFocus) {
      // Add a small delay to ensure the keyboard is fully visible
      Future.delayed(Duration(milliseconds: 300), () {
        if (_medicationsTitleKey.currentContext != null) {
          Scrollable.ensureVisible(
            _medicationsTitleKey.currentContext!,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _filterMedications(String query) {
    setState(() {
      _filteredMedications =
          _allMedications
              .where(
                (medication) =>
                    medication.name.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    medication.timing.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _editMedication(Medication medication) {
    // Navigate to edit page instead of showing dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicationManagementEdit()),
    );
  }

  void _deleteMedication(Medication medication) {
    // Show an impressive delete confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 300.w,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                    size: 36.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                // Title
                Text(
                  'Delete Medication',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),

                SizedBox(height: 8.h),

                // Message
                Text(
                  'Are you sure you want to delete ${medication.name}? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: Color(0xFF64748B),
                  ),
                ),

                SizedBox(height: 24.h),

                // Buttons
                Row(
                  children: [
                    // Cancel button - Using GestureDetector to remove ripple effect
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Color(0xFFE2E8F0)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Delete button - Using GestureDetector to remove ripple effect
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _allMedications.removeWhere(
                              (item) => item.name == medication.name,
                            );
                            _filteredMedications.removeWhere(
                              (item) => item.name == medication.name,
                            );
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Delete',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
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

  void _navigateToAddMedication() {
    // Dismiss keyboard if it's showing
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicationsManagementDay()),
    );
  }

  // Get a color for a medication based on its name
  Color _getMedicationColor(String name) {
    // Use a hash of the name to get a consistent color
    final int hash = name.hashCode;
    return _medicationColors[hash % _medicationColors.length];
  }

  @override
  Widget build(BuildContext context) {
    // Check if there are any medications
    final bool hasMedications = _allMedications.isNotEmpty;

    // Fixed header height regardless of keyboard visibility
    final double headerHeight = 320.0;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Lighter background for better contrast
      // Prevent automatic resizing when keyboard appears
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Static header section with fixed height
          SizedBox(
            height: headerHeight.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomActivityHeader(
                  title: 'Medications',
                  backgroundColor: Color(0xFF0F67FE),
                  buttonColor: Color(0xFF242E49),
                  buttonShadowColor: Color(0xFF242E49),
                  badgeText: 'Insomniac',
                  backgroundImagePath: './images/header_background.png',
                  score: '12',
                  subtitle: 'Medications',
                  showBadge: false,
                  buttonImage: 'images/SignInAddIcon.png',
                  onButtonTap: _navigateToAddMedication,
                  bottomLeftRadius: 20.0,
                  bottomRightRadius: 20.0,
                  backButtonBorderColor: Colors.white.withOpacity(0.3),
                  titleTextColor: Colors.white,
                  headerHeight: headerHeight, // Fixed header height
                ),
              ],
            ),
          ),

          // Add padding to prevent overlap with header
          SizedBox(height: 30.h), // Increased spacing to prevent overlap
          // Content area - either empty state or scrollable medications list
          Expanded(
            child:
                hasMedications
                    ? _buildMedicationsList()
                    : SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: _buildEmptyState(),
                    ),
          ),
        ],
      ),
    );
  }

  // New method to build the medications list
  Widget _buildMedicationsList() {
    return Column(
      children: [
        // Search and edit controls
        Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Your Medications heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Medications',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  // Edit/Cancel button
                  GestureDetector(
                    onTap: _toggleEditMode,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _isEditMode
                                ? Color(0xFFEF4444).withOpacity(0.1)
                                : Color(0xFF0066FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isEditMode ? Icons.close : Icons.edit_outlined,
                            size: 16.sp,
                            color:
                                _isEditMode
                                    ? Color(0xFFEF4444)
                                    : Color(0xFF0066FF),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _isEditMode ? 'Cancel' : 'Edit',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  _isEditMode
                                      ? Color(0xFFEF4444)
                                      : Color(0xFF0066FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Search bar
              Container(
                height: 40.h, // Reduced height
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _filterMedications,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp, // Smaller font size
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Medications',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp, // Smaller font size
                    ),
                    prefixIcon: Container(
                      padding: EdgeInsets.all(8.r),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF0F67FE),
                        size: 16.sp, // Smaller icon
                      ),
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade400,
                                size: 16.sp, // Smaller icon
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _filteredMedications = _allMedications;
                                });
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 8.w,
                    ), // Reduced padding
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Medication statistics badges
              Row(
                children: [
                  // Total medications badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF0F67FE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 12.sp,
                          color: Color(0xFF0F67FE),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${_filteredMedications.length} Medications',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F67FE),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Taken today badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12.sp,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$_takenToday Taken',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Missed today badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.highlight_off,
                          size: 12.sp,
                          color: Color(0xFFEF4444),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$_missedToday Missed',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable list of medications
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: _filteredMedications.length,
            itemBuilder: (context, index) {
              final medication = _filteredMedications[index];
              final medicationColor = _getMedicationColor(medication.name);

              return GestureDetector(
                onTap: () => _editMedication(medication),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h), // Reduced margin
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ), // Increased vertical padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align to top
                    children: [
                      // Pill icon container with color
                      Container(
                        width: 40.w, // Smaller size
                        height: 40.h, // Smaller size
                        decoration: BoxDecoration(
                          color: medicationColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.medication_outlined,
                          color: Colors.white,
                          size: 20.sp, // Smaller icon
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Medication details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize:
                              MainAxisSize.min, // Use minimum space needed
                          children: [
                            Text(
                              medication.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp, // Smaller font size
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),

                            SizedBox(height: 6.h), // Slightly increased spacing
                            // Timing with icon
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12.sp, // Smaller icon
                                  color: Colors.grey.shade500,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  medication.timing,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp, // Smaller font size
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status indicator or Edit/Delete buttons
                      if (_isEditMode)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button
                            GestureDetector(
                              onTap: () => _editMedication(medication),
                              child: Container(
                                width: 32.w, // Smaller size
                                height: 32.h, // Smaller size
                                decoration: BoxDecoration(
                                  color: Color(0xFF0066FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Color(0xFF0066FF),
                                  size: 16.sp, // Smaller icon
                                ),
                              ),
                            ),

                            SizedBox(width: 6.w), // Reduced spacing
                            // Delete button
                            GestureDetector(
                              onTap: () => _deleteMedication(medication),
                              child: Container(
                                width: 32.w, // Smaller size
                                height: 32.h, // Smaller size
                                decoration: BoxDecoration(
                                  color: Color(0xFFEF4444).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: Color(0xFFEF4444),
                                  size: 16.sp, // Smaller icon
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        // Active status indicator (only shown when not in edit mode)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w, // Reduced padding
                            vertical: 2.h, // Reduced padding
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 10.sp, // Smaller icon
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Active',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.sp, // Smaller font size
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Enhanced impressive empty state widget
  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state title with gradient
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [Color(0xFF0F67FE), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                child: Text(
                  'Start Your Medication Journey',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        Colors.white, // This color is replaced by the gradient
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 16.h),

              // Empty state description
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Track your medications, set reminders, and never miss a dose. Your health journey starts with one simple step.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 32.h),

              // Benefits section without shadows
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildBenefitItem(
                      icon: Icons.notifications_active,
                      color: Color(0xFF10B981),
                      title: 'Never Miss a Dose',
                      description:
                          'Set reminders and get notifications when it\'s time to take your medication.',
                    ),
                    SizedBox(height: 12.h),
                    _buildBenefitItem(
                      icon: Icons.insights,
                      color: Color(0xFF0F67FE),
                      title: 'Track Your Progress',
                      description:
                          'Monitor your medication adherence and see your health improvements over time.',
                    ),
                    SizedBox(height: 12.h),
                    _buildBenefitItem(
                      icon: Icons.health_and_safety,
                      color: Color(0xFFF59E0B),
                      title: 'Improve Your Health',
                      description:
                          'Stay on top of your treatment plan for better health outcomes.',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Add medication button without animation
              GestureDetector(
                onTap: _navigateToAddMedication,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 32.w,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F67FE), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Add Your First Medication',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build benefit items
  Widget _buildBenefitItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
