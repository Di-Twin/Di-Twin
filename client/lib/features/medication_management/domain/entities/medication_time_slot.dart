import 'package:client/features/medication_management/domain/entities/medication.dart';

class MedicationTimeSlot {
  final String time;
  final String displayTime;
  final List<Medication> medications;

  MedicationTimeSlot({
    required this.time,
    required this.displayTime,
    required this.medications,
  });

  int get total => medications.length;

  MedicationTimeSlot copyWith({
    String? time,
    String? displayTime,
    List<Medication>? medications,
  }) {
    return MedicationTimeSlot(
      time: time ?? this.time,
      displayTime: displayTime ?? this.displayTime,
      medications: medications ?? this.medications,
    );
  }
}
