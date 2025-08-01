import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
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

class _AddMedicationPageState extends ConsumerState<AddMedicationPage> {
  final TextEditingController _medicationNameController = TextEditingController();
  int _dosage = 1;
  DateTime _startDate = DateTime.now();
  int _durationDays = 30;
  bool _autoReminder = true;
  int _dailyFrequency = 1;
  List<MedicationDose> _doses = [
    MedicationDose(time: const TimeOfDay(hour: 9, minute: 0)),
  ];
  bool _isLoading = false;

  final List<int> _frequencyOptions = [1, 2, 3, 4];
  final List<int> _durationOptions = [7, 14, 30, 60, 90];

  @override
  void dispose() {
    _medicationNameController.dispose();
    super.dispose();
  }

  void _updateFrequency(int frequency) {
    setState(() {
      _dailyFrequency = frequency;

      // Adjust doses list based on frequency
      if (frequency > _doses.length) {
        // Add more doses with default times
        final defaultTimes = [
          const TimeOfDay(hour: 9, minute: 0),   // Morning
          const TimeOfDay(hour: 14, minute: 0),  // Afternoon
          const TimeOfDay(hour: 19, minute: 0),  // Evening
          const TimeOfDay(hour: 22, minute: 0),  // Night
        ];

        while (_doses.length < frequency) {
          _doses.add(MedicationDose(
            time: defaultTimes[_doses.length % defaultTimes.length],
          ));
        }
      } else if (frequency < _doses.length) {
        // Remove excess doses
        _doses = _doses.take(frequency).toList();
      }
    });
  }

  void _updateDoseTime(int index, TimeOfDay time) {
    setState(() {
      _doses[index] = _doses[index].copyWith(time: time);
    });
  }

  void _updateDoseMealTiming(int index, String mealTiming) {
    setState(() {
      _doses[index] = _doses[index].copyWith(mealTiming: mealTiming);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
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
                  _buildScheduleSection(),
                  SizedBox(height: 32.h),
                  _buildDurationSection(),
                  SizedBox(height: 32.h),
                  _buildReminderSection(),
                  SizedBox(height: 40.h),
                  _buildAddButton(),
                  SizedBox(height: 20.h),
                ],
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20.r,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Add Medication',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Step 2 of 2 - Medication Details',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Medication Name'),
        SizedBox(height: 12.h),
        Container(
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
      ],
    );
  }

  Widget _buildDosageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Dosage per intake'),
        SizedBox(height: 12.h),
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
                    'Amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '$_dosage ${_dosage == 1 ? 'tablet' : 'tablets'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF242E49),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  final isSelected = _dosage == value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _dosage = value;
                      });
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          value.toString(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
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
      ],
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('How many times per day?'),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _frequencyOptions.map((frequency) {
              final isSelected = _dailyFrequency == frequency;
              return GestureDetector(
                onTap: () => _updateFrequency(frequency),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0F67FE) : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        frequency.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'time${frequency > 1 ? 's' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Daily Schedule'),
        SizedBox(height: 8.h),
        Text(
          'Set specific times and meal preferences for each dose',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 16.h),
        ...List.generate(_dailyFrequency, (index) {
          return _buildDoseScheduleCard(index);
        }),
      ],
    );
  }

  Widget _buildDoseScheduleCard(int index) {
    final dose = _doses[index];
    final doseLabels = ['First', 'Second', 'Third', 'Fourth'];
    final doseLabel = index < doseLabels.length ? doseLabels[index] : '${index + 1}th';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Duration'),
        SizedBox(height: 12.h),
        Container(
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
      ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF242E49),
      ),
    );
  }

  Widget _buildAddButton() {
    return CustomButton(
      text: _isLoading ? "Adding..." : "Add Medication",
      iconPath: 'images/SignInAddIcon.png',
      onPressed: _isLoading ? null : _saveMedication,
      height: 50.h,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectDoseTime(BuildContext context, int doseIndex) async {
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

      final params = CreateMedicationParams(
        medicationName: _medicationNameController.text.trim(),
        afterFood: afterFood,
        frequency: '${_dailyFrequency}x per day',
        timings: timings,
        reminder: _autoReminder,
        dose: '${_dosage} unit${_dosage > 1 ? 's' : ''}',
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
      );

      final result = await actions.createMedication(params);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Medication added successfully',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.green,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: Colors.red,
      ),
    );
  }
}
