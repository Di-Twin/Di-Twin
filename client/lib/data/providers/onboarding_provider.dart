import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the state class for onboarding data
class OnboardingState {
  final String goal;
  final String gender;
  final double weight_kg;
  final double height_cm;
  final int age;
  final List<String>? medications; // ✅ Can be null
  final List<String>? medical_conditions; // ✅ Can be null

  OnboardingState({
    this.goal = '',
    this.gender = '',
    this.weight_kg = 0.0,
    this.height_cm = 0.0,
    this.age = 0,
    this.medications, // ✅ Nullable medications
    this.medical_conditions, // ✅ Nullable medical conditions
  });
  // CopyWith method to update specific fields while keeping others unchanged
  OnboardingState copyWith({
    String? goal,
    String? gender,
    double? weight_kg,
    double? height_cm,
    int? age,
    List<String>? medications,
    List<String>? medical_conditions,
  }) {
    return OnboardingState(
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      weight_kg: weight_kg ?? this.weight_kg,
      height_cm: height_cm ?? this.height_cm,
      age: age ?? this.age,
      medications:
          medications ?? this.medications, // ✅ Keep existing medications
      medical_conditions:
          medical_conditions ??
          this.medical_conditions, // ✅ Keep existing conditions
    );
  }
}

// StateNotifier to manage the onboarding state
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  // ✅ Update goal
  void updateGoal(String goal) {
    state = state.copyWith(goal: goal);
    print("✅ Goal updated: ${state.goal}");
  }

  // ✅ Update gender with validation
  void updateGender(String gender) {
    if (gender == 'male' || gender == 'female') {
      state = state.copyWith(gender: gender);
      print("✅ Gender updated: ${state.gender}");
    } else {
      print("⚠️ Invalid gender value: $gender");
    }
  }

  // ✅ Update weight in kilograms
  void updateWeightKg(double weightKg) {
    if (weightKg > 0) {
      state = state.copyWith(
        weight_kg: double.parse(weightKg.toStringAsFixed(2)),
      );
      print("✅ Weight updated: ${state.weight_kg} kg");
    } else {
      print("⚠️ Invalid weight value: $weightKg");
    }
  }

  // ✅ Update height in centimeters
  void updateHeightCm(double heightCm) {
    if (heightCm > 0) {
      state = state.copyWith(
        height_cm: double.parse(heightCm.toStringAsFixed(2)),
      );
      print("✅ Height updated: ${state.height_cm} cm");
    } else {
      print("⚠️ Invalid height value: $heightCm");
    }
  }

  // ✅ Update age
  void updateAge(int age) {
    if (age > 0 && age < 80) {
      state = state.copyWith(age: age);
      print("✅ Age updated: ${state.age}");
    } else {
      print("⚠️ Invalid age value: $age");
    }
  }

  // ✅ Add or remove medications
  void toggleMedication(String medication) {
    final List<String> currentMedications = List.from(state.medications ?? []);

    if (currentMedications.contains(medication)) {
      currentMedications.remove(medication);
    } else {
      currentMedications.add(medication);
    }

    state = state.copyWith(medications: currentMedications);
    print("✅ Medications updated: ${state.medications}");
  }

  // ✅ Add or remove medical conditions
  void toggleMedicalCondition(String condition) {
    final List<String> currentConditions = List.from(
      state.medical_conditions ?? [],
    );

    if (currentConditions.contains(condition)) {
      currentConditions.remove(condition);
    } else {
      currentConditions.add(condition);
    }

    state = state.copyWith(medical_conditions: currentConditions);
    print("✅ Medical Conditions updated: ${state.medical_conditions}");
  }
}

// Global provider for onboarding state
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });
