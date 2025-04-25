import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:flutter/material.dart';

class MedicationModel extends Medication {
  MedicationModel({
    required super.id,
    required super.name,
    required String super.dosage,
    required String super.instruction,
    required super.icon,
    required super.taken,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    IconData iconData;
    if (json['icon'] == 'medication') {
      iconData = Icons.medication;
    } else if (json['icon'] == 'medication_liquid') {
      iconData = Icons.medication_liquid;
    } else {
      iconData = Icons.medication;
    }

    return MedicationModel(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      instruction: json['instruction'],
      icon: iconData,
      taken: json['taken'],
    );
  }

  Map<String, dynamic> toJson() {
    String iconString;
    if (icon == Icons.medication) {
      iconString = 'medication';
    } else if (icon == Icons.medication_liquid) {
      iconString = 'medication_liquid';
    } else {
      iconString = 'medication';
    }

    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'instruction': instruction,
      'icon': iconString,
      'taken': taken,
    };
  }

  factory MedicationModel.fromEntity(Medication medication) {
    return MedicationModel(
      id: medication.id,
      name: medication.name,
      dosage: medication.dosage,
      instruction: medication.instruction,
      icon: medication.icon,
      taken: medication.taken,
    );
  }
}
