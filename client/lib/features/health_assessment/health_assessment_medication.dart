import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:client/widgets/ProgressBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/onboarding_provider.dart';

class HealthAssessmentMedication extends ConsumerStatefulWidget {
  const HealthAssessmentMedication({super.key});

  @override
  ConsumerState<HealthAssessmentMedication> createState() =>
      _HealthAssessmentMedicationState();
}

class _HealthAssessmentMedicationState
    extends ConsumerState<HealthAssessmentMedication> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Determine if it's a small device
    final isSmallDevice = screenWidth < 360 || screenHeight < 600;

    // Responsive spacing
    final horizontalPadding = screenWidth * 0.06;
    final verticalSpacing = screenHeight * 0.02;
    final titleSpacing = screenHeight * 0.03;

    // Responsive font sizing
    final titleSize = isSmallDevice ? 20.0 : 24.0;
    final normalTextSize = isSmallDevice ? 14.0 : 16.0;
    final smallTextSize = isSmallDevice ? 10.0 : 12.0;

    // Responsive component sizing
    final backButtonSize = screenWidth * 0.12;
    final listTilePadding = screenWidth * 0.04;
    final checkboxSize = screenWidth * 0.06;

    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    final List<String> allMedications = [
      'Abilify',
      'Acetaminophen',
      'Aspirin',
      'Baclofen',
      'Ciprofloxacin',
      'Diazepam',
      'Enalapril',
      'Fluoxetine',
      'Gabapentin',
      'Ibuprofen',
      'Insulin',
      'Metformin',
      'Omeprazole',
      'Prednisone',
      'Ramipril',
      'Simvastatin',
      'Tramadol',
      'Warfarin',
      'Xanax',
      'Zoloft',
    ];

    final List<String> filteredMedications =
        allMedications
            .where(
              (med) => med.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: verticalSpacing),
              // Back button and progress bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: backButtonSize,
                      height: backButtonSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: backButtonSize * 0.4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  const Expanded(
                    child: ProgressBar(totalSteps: 7, currentStep: 6),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: normalTextSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: titleSpacing),
              // Title
              Text(
                'What medications do\nyou take?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: verticalSpacing),

              // Search bar
              _buildSearchBar(context, normalTextSize),

              SizedBox(height: verticalSpacing * 0.8),

              // Medication list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredMedications.length,
                  itemBuilder: (context, index) {
                    final med = filteredMedications[index];
                    final isSelected =
                        onboardingState.medications?.contains(med) ?? false;

                    return GestureDetector(
                      onTap: () {
                        onboardingNotifier.toggleMedication(med);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: verticalSpacing * 0.4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: listTilePadding,
                          ),
                          title: Text(
                            med,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: normalTextSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Container(
                            width: checkboxSize,
                            height: checkboxSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                width: 2,
                              ),
                              color:
                                  isSelected ? Colors.blue : Colors.transparent,
                            ),
                            child:
                                isSelected
                                    ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: checkboxSize * 0.66,
                                    )
                                    : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: verticalSpacing),

              // Selected medications section
              if (onboardingState.medications != null &&
                  onboardingState.medications!.isNotEmpty) ...[
                Text(
                  'Selected:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: smallTextSize + 2,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.4),

                // Horizontal Scrollable Medications List
                SizedBox(
                  height: screenHeight * 0.04,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          onboardingState.medications!
                              .map(
                                (med) => Padding(
                                  padding: EdgeInsets.only(
                                    right: screenWidth * 0.02,
                                  ),
                                  child: _buildSelectedMedicationChip(
                                    med,
                                    smallTextSize,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),

                SizedBox(height: verticalSpacing),
              ],

              // Continue button
              Padding(
                padding: EdgeInsets.only(bottom: verticalSpacing),
                child: CustomButton(
                  text: "Continue",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: () {
                    Navigator.pushNamed(context, '/questions/allergy');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double fontSize) {
    final size = MediaQuery.of(context).size;
    final searchBarHeight = size.height * 0.06;

    return Container(
      height: searchBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: size.width * 0.03),
          Icon(Icons.search, color: Colors.grey, size: searchBarHeight * 0.4),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize,
                color: const Color(0xFF1B283A),
              ),
              decoration: InputDecoration(
                hintText: 'Search medications...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: fontSize,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: searchBarHeight * 0.3,
                ),
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.02),
                child: Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: searchBarHeight * 0.36,
                ),
              ),
            ),
          SizedBox(width: size.width * 0.01),
        ],
      ),
    );
  }

  Widget _buildSelectedMedicationChip(String name, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              ref.read(onboardingProvider.notifier).toggleMedication(name);
            },
            child: Icon(
              Icons.close,
              size: fontSize,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
