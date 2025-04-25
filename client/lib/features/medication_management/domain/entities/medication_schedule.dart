import 'package:client/features/medication_management/domain/entities/medication_time_slot.dart';

class MedicationSchedule {
  final String date;
  final List<MedicationTimeSlot> timeSlots;

  MedicationSchedule({
    required this.date,
    required this.timeSlots,
  });

  MedicationSchedule copyWith({
    String? date,
    List<MedicationTimeSlot>? timeSlots,
  }) {
    return MedicationSchedule(
      date: date ?? this.date,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }
}
