import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:client/features/medication_management/presentation/pages/medication_management_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationManagementListPage extends StatefulWidget {
  const MedicationManagementListPage({Key? key}) : super(key: key);

  @override
  State<MedicationManagementListPage> createState() => _MedicationManagementListPageState();
}

class _MedicationManagementListPageState extends State<MedicationManagementListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchFocused = false;

  // Sample medications data - replace with actual data from provider
  final List<Medication> _allMedications = [
    Medication(
      id: "1",
      name: 'Aspirin',
      timing: 'After Food',
      dosage: '100mg',
      frequency: 'daily',
      timings: ['08:00', '20:00'],
      startDate: '2023-01-01',
      endDate: '2023-12-31',
      reminder: true,
      color: const Color(0xFF4285F4),
    ),
    Medication(
      id: "2",
      name: 'Metformin',
      timing: 'After meals',
      dosage: '850mg',
      frequency: 'daily',
      timings: ['08:00', '14:00', '20:00'],
      startDate: '2023-01-01',
      endDate: '2023-12-31',
      reminder: true,
      color: const Color(0xFF34A853),
    ),
    Medication(
      id: "3",
      name: 'Lisinopril',
      timing: 'Before Food',
      dosage: '10mg',
      frequency: 'daily',
      timings: ['08:00'],
      startDate: '2023-01-01',
      endDate: '2023-12-31',
      reminder: false,
      color: const Color(0xFFEA4335),
    ),
    Medication(
      id: "4",
      name: 'Atorvastatin',
      timing: 'After Food',
      dosage: '20mg',
      frequency: 'daily',
      timings: ['20:00'],
      startDate: '2023-01-01',
      endDate: '2023-12-31',
      reminder: true,
      color: const Color(0xFFFBBC04),
    ),
    Medication(
      id: "5",
      name: 'Omeprazole',
      timing: 'Before Food',
      dosage: '20mg',
      frequency: 'daily',
      timings: ['08:00'],
      startDate: '2023-01-01',
      endDate: '2023-12-31',
      reminder: true,
      color: const Color(0xFF9C27B0),
    ),
    Medication(
      id: "6",
      name: 'Vitamin D3',
      timing: 'After Food',
      dosage: '1000IU',
      frequency: 'daily',
      timings: ['09:00'],
      startDate: '2023-01-01',
      endDate: '2023-12-31',
      reminder: true,
      color: const Color(0xFF00BCD4),
    ),
    Medication(
      id: "7",
      name: 'Calcium',
      timing: 'Before Food',
      dosage: '500mg',
      frequency: 'twice daily',
      timings: ['08:00', '20:00'],
      startDate: '2023-01-01',
      endDate: '2023-12-31',
      reminder: false,
      color: const Color(0xFF795548),
    ),
    Medication(
      id: "8",
      name: 'Iron Supplement',
      timing: 'After Food',
      dosage: '65mg',
      frequency: 'daily',
      timings: ['12:00'],
      startDate: '2023-01-01',
      endDate: '2023-12-31',
      reminder: true,
      color: const Color(0xFF607D8B),
    ),
  ];

  List<Medication> get _filteredMedications {
    if (_searchQuery.isEmpty) {
      return _allMedications;
    }
    return _allMedications.where((medication) =>
    medication.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        medication.timing.toLowerCase().contains(_searchQuery.toLowerCase())
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

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 400.0;

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
                child: _isSearchFocused ? _buildSearchView() : _buildNormalView(),
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
              child: CustomActivityHeader(
                title: 'Medications',
                score: _allMedications.length.toString(),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalView() {
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

              SizedBox(height: 8.h),
            ],
          ),
        ),

        // Scrollable Medications List Only
        Expanded(
          child: _filteredMedications.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: _filteredMedications.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _MedicationCard(
                medication: _filteredMedications[index],
                onTap: () => _showMedicationDetails(_filteredMedications[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchView() {
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
                  '${_filteredMedications.length} result${_filteredMedications.length != 1 ? 's' : ''} found',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            // Search Results
            _filteredMedications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredMedications.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _MedicationCard(
                  medication: _filteredMedications[index],
                  onTap: () => _showMedicationDetails(_filteredMedications[index]),
                );
              },
            ),

            SizedBox(height: 100.h), // Bottom padding
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

  void _showMedicationDetails(Medication medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CompactMedicationDetailSheet(medication: medication),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTap;

  const _MedicationCard({
    required this.medication,
    required this.onTap,
  });

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
                    medication.color.withOpacity(0.7),
                    medication.color,
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
                          medication.name,
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
                    '${medication.timings.join(', ')} • ${medication.timing}',
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
                          color: medication.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          medication.dosage,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: medication.color,
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
  final Medication medication;

  const _CompactMedicationDetailSheet({required this.medication});

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
                        medication.color.withOpacity(0.7),
                        medication.color,
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
                        medication.name,
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
                              color: medication.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              medication.dosage,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: medication.color,
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
                      color: medication.color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: medication.color, size: 20.sp),
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
                                  color: medication.color,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${medication.timings.join(', ')} • ${medication.timing}',
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit ${medication.name}')),
                      );
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
                      side: BorderSide(color: medication.color, width: 1.5),
                      foregroundColor: medication.color,
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
                      _showDeleteConfirmation(context, medication);
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

  void _showDeleteConfirmation(BuildContext context, Medication medication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Delete Medication',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${medication.name}?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${medication.name} deleted')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String timing;
  final String dosage;
  final String frequency;
  final List<String> timings;
  final String startDate;
  final String endDate;
  final bool reminder;
  final Color color;

  const Medication({
    required this.id,
    required this.name,
    required this.timing,
    required this.dosage,
    required this.frequency,
    required this.timings,
    required this.startDate,
    required this.endDate,
    required this.reminder,
    required this.color,
  });
}
