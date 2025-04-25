import 'package:client/features/medication_management/data/models/medication_time_slot_model.dart';
import 'package:client/features/medication_management/domain/entities/medication_schedule.dart';

class MedicationScheduleModel extends MedicationSchedule {
  MedicationScheduleModel({
    required super.date,
    required List<MedicationTimeSlotModel> super.timeSlots,
  });

  factory MedicationScheduleModel.fromJson(String date, List<dynamic> json) {
    return MedicationScheduleModel(
      date: date,
      timeSlots: json
          .map((timeSlot) => MedicationTimeSlotModel.fromJson(timeSlot))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'timeSlots': timeSlots
          .map((timeSlot) => (timeSlot as MedicationTimeSlotModel).toJson())
          .toList(),
    };
  }

  factory MedicationScheduleModel.fromEntity(MedicationSchedule schedule) {
    return MedicationScheduleModel(
      date: schedule.date,
      timeSlots: schedule.timeSlots
          .map((timeSlot) => MedicationTimeSlotModel.fromEntity(timeSlot))
          .toList(),
    );
  }
}
