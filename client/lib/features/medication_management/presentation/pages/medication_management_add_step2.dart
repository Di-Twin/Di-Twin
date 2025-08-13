import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client/features/medication_management/presentation/providers/medication_api_provider.dart';
import 'package:client/features/medication_management/domain/usecases/create_medication_usecase.dart';

class MedicationDose {
  final TimeOfDay time;
  final String mealTiming; // 'before', 'after', 'with', 'none'

  MedicationDose({
    required this.time,
    this.mealTiming = 'none',
  });

  MedicationDose copyWith({
    TimeOfDay? time,
    String? mealTiming,
  }) {
    return MedicationDose(
      time: time ?? this.time,
      mealTiming: mealTiming ?? this.mealTiming,
    );
  }
}

class AddMedicationPage extends ConsumerStatefulWidget {
  const AddMedicationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends ConsumerState<AddMedicationPage>
    with TickerProviderStateMixin {
  final TextEditingController _medicationNameController = TextEditingController();
  double _dosage = 1.0;
  DateTime _startDate = DateTime.now();
  int _durationDays = 30;
  bool _autoReminder = true;
  double _dailyFrequency = 1.0;
  String _frequencyType = 'daily'; // 'daily', 'weekly', 'monthly'
  List<bool> _selectedWeekDays = List.filled(7, false); // For weekly frequency
  List<MedicationDose> _doses = [
    MedicationDose(time: const TimeOfDay(hour: 9, minute: 0)),
  ];
  bool _isLoading = false;

  final List<int> _durationOptions = [7, 14, 30, 60, 90];
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();

    // Initialize with Monday selected for weekly
    _selectedWeekDays[0] = true;
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _updateFrequency(double frequency) {
    HapticFeedback.lightImpact();
    setState(() {
      _dailyFrequency = frequency;
      _updateDosesList();
    });
  }

  void _updateFrequencyType(String type) {
    HapticFeedback.lightImpact();
    setState(() {
      _frequencyType = type;
      if (type == 'daily') {
        _dailyFrequency = 1.0;
      } else if (type == 'weekly') {
        _dailyFrequency = 1.0;
        // Reset week days selection
        _selectedWeekDays = List.filled(7, false);
        _selectedWeekDays[0] = true; // Default to Monday
      }
      _updateDosesList();
    });
  }

  void _updateDosesList() {
    final int dosesCount = _frequencyType == 'daily'
        ? _dailyFrequency.round()
        : _dailyFrequency.round();

    if (dosesCount > _doses.length) {
      // Add more doses with default times
      final defaultTimes = [
        const TimeOfDay(hour: 9, minute: 0),   // Morning
        const TimeOfDay(hour: 14, minute: 0),  // Afternoon
        const TimeOfDay(hour: 19, minute: 0),  // Evening
        const TimeOfDay(hour: 22, minute: 0),  // Night
      ];

      while (_doses.length < dosesCount) {
        _doses.add(MedicationDose(
          time: defaultTimes[_doses.length % defaultTimes.length],
        ));
      }
    } else if (dosesCount < _doses.length) {
      // Remove excess doses
      _doses = _doses.take(dosesCount).toList();
    }
  }

  void _updateDoseTime(int index, TimeOfDay time) {
    setState(() {
      _doses[index] = _doses[index].copyWith(time: time);
    });
  }

  void _updateDoseMealTiming(int index, String mealTiming) {
    HapticFeedback.selectionClick();
    setState(() {
      _doses[index] = _doses[index].copyWith(mealTiming: mealTiming);
    });
  }

  void _toggleWeekDay(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedWeekDays[index] = !_selectedWeekDays[index];
      // Ensure at least one day is selected
      if (!_selectedWeekDays.any((selected) => selected)) {
        _selectedWeekDays[index] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMedicationNameSection(),
                      SizedBox(height: 32.h),
                      _buildDosageSection(),
                      SizedBox(height: 32.h),
                      _buildFrequencySection(),
                      SizedBox(height: 32.h),
                      if (_frequencyType == 'weekly') ...[
                        _buildWeekDaysSection(),
                        SizedBox(height: 32.h),
                      ],
                      _buildScheduleSection(),
                      SizedBox(height: 32.h),
                      _buildDurationSection(),
                      SizedBox(height: 32.h),
                      _buildReminderSection(),
                      SizedBox(height: 40.h),
                      _buildAddButton(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E2639),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Step 2 of 2',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Medication Details',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Set up your medication schedule and preferences',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationNameSection() {
    return _buildSection(
      title: 'Medication Name',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: _medicationNameController,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF242E49),
          ),
          decoration: InputDecoration(
            hintText: 'Enter medication name',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade500,
              fontSize: 16.sp,
            ),
            prefixIcon: Icon(
              Icons.medical_information_outlined,
              color: Colors.grey.shade600,
              size: 22.r,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 18.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDosageSection() {
    return _buildSection(
      title: 'Dosage per intake',
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${_dosage == _dosage.toInt() ? _dosage.toInt() : _dosage} ${_dosage == 1 ? 'tablet' : 'tablets'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF242E49),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF0F67FE),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: const Color(0xFF0F67FE),
                overlayColor: const Color(0xFF0F67FE).withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                trackHeight: 4,
              ),
              child: Slider(
                value: _dosage,
                min: 0.5,
                max: 5.0,
                divisions: 9, // 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _dosage = value;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0.5',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  '5.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySection() {
    return _buildSection(
      title: 'Frequency',
      child: Column(
        children: [
          // Frequency Type Selection
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _updateFrequencyType('daily'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _frequencyType == 'daily' ? const Color(0xFF0F67FE) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          'Daily',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _frequencyType == 'daily' ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _updateFrequencyType('weekly'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _frequencyType == 'weekly' ? const Color(0xFF0F67FE) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          'Weekly',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _frequencyType == 'weekly' ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Frequency Slider
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _frequencyType == 'daily' ? 'Times per day' : 'Times per selected days',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${_dailyFrequency.toInt()} ${_dailyFrequency.toInt() == 1 ? 'time' : 'times'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF242E49),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF0F67FE),
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: const Color(0xFF0F67FE),
                    overlayColor: const Color(0xFF0F67FE).withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _dailyFrequency,
                    min: 1.0,
                    max: 4.0,
                    divisions: 3,
                    onChanged: _updateFrequency,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '4',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysSection() {
    return _buildSection(
      title: 'Select Days',
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              'Choose which days of the week to take medication',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final isSelected = _selectedWeekDays[index];
                return GestureDetector(
                  onTap: () => _toggleWeekDay(index),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _weekDays[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return _buildSection(
      title: 'Daily Schedule',
      child: Column(
        children: List.generate(_dailyFrequency.round(), (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildDoseScheduleCard(index),
          );
        }),
      ),
    );
  }

  Widget _buildDoseScheduleCard(int index) {
    final dose = _doses[index];
    final doseLabels = ['First', 'Second', 'Third', 'Fourth'];
    final doseLabel = index < doseLabels.length ? doseLabels[index] : '${index + 1}th';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: _getDoseColor(index),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '$doseLabel Dose',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF242E49),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Time Selection
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                color: Colors.grey.shade600,
                size: 20.r,
              ),
              SizedBox(width: 12.w),
              Text(
                'Time',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _selectDoseTime(context, index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    _formatTime(dose.time),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF242E49),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Meal Timing Selection
          Row(
            children: [
              Icon(
                Icons.restaurant_outlined,
                color: Colors.grey.shade600,
                size: 20.r,
              ),
              SizedBox(width: 12.w),
              Text(
                'Meal timing',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: _buildMealOption(index, 'before', 'Before meal'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMealOption(index, 'after', 'After meal'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMealOption(index, 'none', 'No meal'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealOption(int doseIndex, String mealTiming, String label) {
    final isSelected = _doses[doseIndex].mealTiming == mealTiming;

    return GestureDetector(
      onTap: () => _updateDoseMealTiming(doseIndex, mealTiming),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF242E49),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDoseColor(int index) {
    final colors = [
      const Color(0xFF0F67FE), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF8B5CF6), // Purple
    ];
    return colors[index % colors.length];
  }

  Widget _buildDurationSection() {
    return _buildSection(
      title: 'Duration',
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey.shade600,
                  size: 20.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Start Date',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _selectStartDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      DateFormat('MMM d, yyyy').format(_startDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF242E49),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Duration',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: _durationOptions.map((days) {
                final isSelected = _durationDays == days;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _durationDays = days;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      '$days days',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF242E49),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 16.r,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'End date: ${DateFormat('MMM d, yyyy').format(_startDate.add(Duration(days: _durationDays)))}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: Colors.grey.shade600,
            size: 24.r,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Reminder',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF242E49),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Get notified at scheduled times',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoReminder,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _autoReminder = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF0F67FE),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF242E49),
          ),
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isLoading ? "Adding..." : "Add Medication",
        iconPath: 'images/SignInAddIcon.png',
        onPressed: _isLoading ? null : _saveMedication,
        height: 50.h,
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectDoseTime(BuildContext context, int doseIndex) async {
    HapticFeedback.lightImpact();
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _doses[doseIndex].time,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F67FE),
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFF0F67FE);
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF242E49);
              }),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (selectedTime != null) {
      _updateDoseTime(doseIndex, selectedTime);
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    HapticFeedback.lightImpact();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F67FE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF242E49),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F67FE)),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: const Color(0xFF0F67FE),
              headerForegroundColor: Colors.white,
              weekdayStyle: const TextStyle(color: Color(0xFF242E49)),
              dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF242E49);
              }),
              dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFF0F67FE);
                }
                return null;
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_medicationNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a medication name');
      return;
    }

    // Validate weekly selection
    if (_frequencyType == 'weekly' && !_selectedWeekDays.any((selected) => selected)) {
      _showErrorSnackBar('Please select at least one day of the week');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    try {
      final actions = ref.read(medicationActionsProvider);

      // Convert times to 24-hour format for API
      final timings = _doses.map((dose) {
        final hour = dose.time.hour.toString().padLeft(2, '0');
        final minute = dose.time.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }).toList();

      final endDate = _startDate.add(Duration(days: _durationDays));

      // For API compatibility, use the first dose's meal timing
      final firstDoseMealTiming = _doses.isNotEmpty ? _doses[0].mealTiming : 'none';
      final afterFood = firstDoseMealTiming == 'after';

      // Create frequency string based on type
      String frequencyString;
      if (_frequencyType == 'daily') {
        frequencyString = '${_dailyFrequency.toInt()}x per day';
      } else {
        final selectedDays = _selectedWeekDays.asMap().entries
            .where((entry) => entry.value)
            .map((entry) => _weekDays[entry.key])
            .join(', ');
        frequencyString = '${_dailyFrequency.toInt()}x per day on $selectedDays';
      }

      final params = CreateMedicationParams(
        medicationName: _medicationNameController.text.trim(),
        afterFood: afterFood,
        frequency: frequencyString,
        timings: timings,
        reminder: _autoReminder,
        dose: '${_dosage == _dosage.toInt() ? _dosage.toInt() : _dosage} unit${_dosage > 1 ? 's' : ''}',
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
      );

      final result = await actions.createMedication(params);

      if (result != null) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Medication added successfully!',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );

        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar('Failed to add medication. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
