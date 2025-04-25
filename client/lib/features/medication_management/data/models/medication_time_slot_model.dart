import 'package:client/features/medication_management/data/models/medication_model.dart';
import 'package:client/features/medication_management/domain/entities/medication_time_slot.dart';

class MedicationTimeSlotModel extends MedicationTimeSlot {
  MedicationTimeSlotModel({
    required super.time,
    required super.displayTime,
    required List<MedicationModel> super.medications,
  });

  factory MedicationTimeSlotModel.fromJson(Map<String, dynamic> json) {
    return MedicationTimeSlotModel(
      time: json['time'],
      displayTime: json['displayTime'],
      medications: (json['medications'] as List)
          .map((medication) => MedicationModel.fromJson(medication))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'displayTime': displayTime,
      'total': medications.length,
      'medications': medications
          .map((medication) => (medication as MedicationModel).toJson())
          .toList(),
    };
  }

  factory MedicationTimeSlotModel.fromEntity(MedicationTimeSlot timeSlot) {
    return MedicationTimeSlotModel(
      time: timeSlot.time,
      displayTime: timeSlot.displayTime,
      medications: timeSlot.medications
          .map((medication) => MedicationModel.fromEntity(medication))
          .toList(),
    );
  }
}
