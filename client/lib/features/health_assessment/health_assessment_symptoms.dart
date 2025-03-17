import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:client/widgets/ProgressBar.dart';

class SymptomsSelectionPage extends StatefulWidget {
  const SymptomsSelectionPage({super.key});

  @override
  State<SymptomsSelectionPage> createState() => _SymptomsSelectionPageState();
}

class _SymptomsSelectionPageState extends State<SymptomsSelectionPage> {
  final List<String> _availableSymptoms = [
    'Headache',
    'Muscle Fatigue',
    'Asthma',
    'Fever',
    'Cough',
  ];

  // Keep track of all symptoms (predefined + user-entered)
  final List<String> _allSymptoms = [];
  final List<String> _selectedSymptoms = [];
  final int _maxSelections = 10;

  int currentStep = 0;
  final int totalSteps = 5;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize all symptoms with available ones
    _allSymptoms.addAll(_availableSymptoms);
    // Initialize all available symptoms as selected by default
    _selectedSymptoms.addAll(_availableSymptoms);
  }

  void _toggleSelection(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
        // We don't remove from _allSymptoms, so it remains available
      } else if (_selectedSymptoms.length < _maxSelections) {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  void _onSymptomTyped(String value) {
    if (value.isNotEmpty) {
      setState(() {
        // Normalize the value to match case-insensitive search
        String normalizedValue = value.trim();

        // Check if it's already in all symptoms (case-insensitive)
        bool exists = _allSymptoms.any(
          (symptom) => symptom.toLowerCase() == normalizedValue.toLowerCase(),
        );

        if (!exists) {
          _allSymptoms.add(normalizedValue);

          // Add to selected symptoms if not already selected and under limit
          if (_selectedSymptoms.length < _maxSelections) {
            _selectedSymptoms.add(normalizedValue);
          }
        } else {
          // Find the existing symptom with proper casing
          String existingSymptom = _allSymptoms.firstWhere(
            (symptom) => symptom.toLowerCase() == normalizedValue.toLowerCase(),
          );

          // Add to selected if not already and under limit
          if (!_selectedSymptoms.contains(existingSymptom) &&
              _selectedSymptoms.length < _maxSelections) {
            _selectedSymptoms.add(existingSymptom);
          }
        }

        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      // This will dismiss the keyboard when tapping anywhere on the screen
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   SizedBox(height: 16.h),
                  _buildHeader(),
                  SizedBox(height: 40.h),
                  _buildTitle(),
                  SizedBox(height: 40.h),
                  _buildImage(),
                  SizedBox(height: 40.h),
                  _buildSymptomSelection(textTheme),
                  SizedBox(height: 50.h),
                  CustomButton(
                    text: "Continue",
                    iconPath: 'images/SignInAddIcon.png',
                    onPressed: () {
                      Navigator.pushNamed(context, '/loading');
                    },
                  ),
                  // Add extra space at the bottom to ensure content isn't hidden by keyboard
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(child: ProgressBar(totalSteps: 7, currentStep: 4)),
            SizedBox(width: 16.w),
            Text(
              'Skip',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Do you have any symptoms/allergy?',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 30.sp,
        fontWeight: FontWeight.w800,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildImage() {
    return Center(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('images/HealthAssessmentSymptoms.png'),
        ),
      ),
    );
  }

  Widget _buildSymptomSelection(TextTheme textTheme) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children:
                  _allSymptoms
                      .map((symptom) => _buildSymptomChip(symptom, textTheme))
                      .toList(),
            ),
            // Hidden TextField
            Opacity(
              opacity: 1,
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onSubmitted: _onSymptomTyped,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.list_alt, color: Colors.grey.shade400, size: 16),
                SizedBox(width: 4),
                Text(
                  '${_selectedSymptoms.length}/$_maxSelections',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: textTheme.bodySmall?.fontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomChip(String symptom, TextTheme textTheme) {
    final bool isSelected = _selectedSymptoms.contains(symptom);

    return GestureDetector(
      onTap: () => _toggleSelection(symptom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade400,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symptom,
              style: GoogleFonts.plusJakartaSans(
                fontSize: textTheme.bodyMedium?.fontSize,
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 4),
              Icon(Icons.check, size: 14, color: Colors.blue),
            ],
          ],
        ),
      ),
    );
  }
}
