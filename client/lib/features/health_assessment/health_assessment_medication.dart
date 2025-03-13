import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// Provider for medication state
final medicationsProvider = StateNotifierProvider<MedicationsNotifier, MedicationsState>((ref) {
  return MedicationsNotifier();
});

// State class for medications
class MedicationsState {
  final List<Medication> medications;
  final List<String> selectedMedications;
  final bool isSearching;
  
  MedicationsState({
    required this.medications,
    required this.selectedMedications,
    this.isSearching = false,
  });

  MedicationsState copyWith({
    List<Medication>? medications,
    List<String>? selectedMedications,
    bool? isSearching,
  }) {
    return MedicationsState(
      medications: medications ?? this.medications,
      selectedMedications: selectedMedications ?? this.selectedMedications,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

// Notifier for medication state
class MedicationsNotifier extends StateNotifier<MedicationsState> {
  MedicationsNotifier() : super(MedicationsState(
    medications: [
      Medication(name: 'Abilify', isSelected: false),
      Medication(name: 'Abilify Maintena', isSelected: true),
      Medication(name: 'Abiraterone', isSelected: false),
      Medication(name: 'Acetaminophen', isSelected: true),
      Medication(name: 'Actemra', isSelected: false),
      Medication(name: 'Axpelliarmus', isSelected: false),
      Medication(name: 'Aspirin', isSelected: true),
      Medication(name: 'Ibuprofen', isSelected: true),
    ],
    selectedMedications: ['Aspirin', 'Ibuprofen'],
  ));

  void toggleMedication(String name) {
    final updatedMedications = state.medications.map((med) {
      if (med.name == name) {
        return Medication(name: med.name, isSelected: !med.isSelected);
      }
      return med;
    }).toList();

    final selectedMeds = updatedMedications
        .where((med) => med.isSelected)
        .map((med) => med.name)
        .toList();

    state = state.copyWith(
      medications: updatedMedications,
      selectedMedications: selectedMeds,
    );
  }

  void removeMedication(String name) {
    final updatedMedications = state.medications.map((med) {
      if (med.name == name) {
        return Medication(name: med.name, isSelected: false);
      }
      return med;
    }).toList();

    final selectedMeds = state.selectedMedications
        .where((med) => med != name)
        .toList();

    state = state.copyWith(
      medications: updatedMedications,
      selectedMedications: selectedMeds,
    );
  }

  void toggleSearch() {
    state = state.copyWith(isSearching: !state.isSearching);
  }
}

// Medication model
class Medication {
  final String name;
  final bool isSelected;

  Medication({required this.name, required this.isSelected});
}

class HealthAssessmentMedication extends ConsumerWidget {
  const HealthAssessmentMedication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationsProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              // Back button and progress bar
              Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chevron_left,
                        size: 28.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF1B283A),
                        minHeight: 8.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              // Title
              Text(
                'What medications do\nyou take?',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1B283A),
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              // Alphabet selection or search bar
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: state.isSearching 
                    ? _buildSearchBar(ref)
                    : _buildAlphabetSelector(ref),
              ),
              SizedBox(height: 10.h),
              // Medication list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: state.medications.length,
                  itemBuilder: (context, index) {
                    final medication = state.medications[index];
                    return _MedicationItem(
                      medication: medication,
                      onToggle: () => ref.read(medicationsProvider.notifier).toggleMedication(medication.name),
                    );
                  },
                ),
              ),
              // Selected medications section
              if (state.selectedMedications.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    children: [
                      Text(
                        'Selected:',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade600,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Wrap(
                          spacing: 8.w,
                          children: state.selectedMedications
                              .map((med) => _SelectedMedicationChip(
                                    name: med,
                                    onRemove: () => ref.read(medicationsProvider.notifier).removeMedication(med),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // AI Scan button
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                width: double.infinity,
                height: 60.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FF),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AI Scan',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.blue,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    const Icon(Icons.add, color: Colors.blue),
                  ],
                ),
              ),
              // Continue button
              Container(
                margin: EdgeInsets.only(bottom: 20.h),
                width: double.infinity,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    const Icon(Icons.add, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlphabetSelector(WidgetRef ref) {
    return Container(
      key: const ValueKey('alphabet'),
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAlphabetButton('A', true),
                _buildAlphabetButton('B', false),
                _buildAlphabetButton('C', false),
                _buildAlphabetButton('...', false),
                _buildAlphabetButton('X', false),
                _buildAlphabetButton('Y', false),
                _buildAlphabetButton('Z', false),
              ],
            ),
          ),
          Container(
            width: 60.w,
            height: 60.h,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFEEEEEE)),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.search, size: 24.sp),
              onPressed: () => ref.read(medicationsProvider.notifier).toggleSearch(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlphabetButton(String letter, bool isActive) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1B283A) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.plusJakartaSans(
            color: isActive ? Colors.white : const Color(0xFF1B283A),
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      key: const ValueKey('search'),
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search medications...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              ),
            ),
          ),
          Container(
            width: 60.w,
            height: 60.h,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFEEEEEE)),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.close, size: 24.sp),
              onPressed: () => ref.read(medicationsProvider.notifier).toggleSearch(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationItem extends StatelessWidget {
  final Medication medication;
  final VoidCallback onToggle;

  const _MedicationItem({
    required this.medication,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: ListTile(
        title: Text(
          medication.name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: medication.isSelected ? Colors.blue : Colors.grey.shade300,
              width: 2,
            ),
            color: medication.isSelected ? Colors.blue : Colors.transparent,
          ),
          child: medication.isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
        onTap: onToggle,
      ),
    );
  }
}

class _SelectedMedicationChip extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const _SelectedMedicationChip({
    required this.name,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 5.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16.sp),
          ),
        ],
      ),
    );
  }
}