import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final String? dosage;
  final String? instruction;
  final IconData icon;
  bool taken;
  bool alertShown;

  Medication({
    required this.id,
    required this.name,
    this.dosage,
    this.instruction,
    required this.icon,
    this.taken = false,
    this.alertShown = false,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? instruction,
    IconData? icon,
    bool? taken,
    bool? alertShown,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instruction: instruction ?? this.instruction,
      icon: icon ?? this.icon,
      taken: taken ?? this.taken ?? this.taken,
      alertShown: alertShown ?? this.alertShown,
    );
  }
}
