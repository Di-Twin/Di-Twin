import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:client/features/medication_management/presentation/widgets/medication_management_alert.dart';
import 'package:flutter/material.dart';

/// Service for managing medication alerts
class MedicationAlertService {
  static final MedicationAlertService _instance = MedicationAlertService._internal();
  
  /// Get the singleton instance
  factory MedicationAlertService() => _instance;
  MedicationAlertService._internal();

  final List<Map<String, dynamic>> _queue = [];
  bool _isShowingAlert = false;

  /// Add a medication to the queue
  void addToQueue({
    required BuildContext context,
    required String medicationName,
    required String dosage,
    required String instructions,
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
    VoidCallback? onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
  }) {
    _queue.add({
      'context': context,
      'medicationName': medicationName,
      'dosage': dosage,
      'instructions': instructions,
      'backgroundImagePath': backgroundImagePath,
      'onTake': onTake,
      'onSkip': onSkip,
      'onReschedule': onReschedule,
    });

    // Start showing alerts if not already showing
    if (!_isShowingAlert) {
      _showNextAlert();
    }
  }

  /// Add a medication entity to the queue
  void addMedicationToQueue({
    required BuildContext context,
    required Medication medication,
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
    VoidCallback? onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
  }) {
    addToQueue(
      context: context,
      medicationName: medication.name,
      dosage: medication.dosage ?? "Default dosage",
      instructions: medication.instruction ?? "",
      backgroundImagePath: backgroundImagePath,
      onTake: onTake,
      onSkip: onSkip,
      onReschedule: onReschedule,
    );
  }

  // Show the next alert in the queue
  void _showNextAlert() {
    if (_queue.isEmpty) {
      _isShowingAlert = false;
      return;
    }

    _isShowingAlert = true;
    final medication = _queue.removeAt(0);

    showDialog(
      context: medication['context'],
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return MedicationManagementAlert(
          medicationName: medication['medicationName'],
          dosage: medication['dosage'],
          instructions: medication['instructions'],
          backgroundImagePath: medication['backgroundImagePath'],
          onTake: medication['onTake'],
          onSkip: medication['onSkip'],
          onReschedule: medication['onReschedule'],
        );
      },
    ).then((value) {
      // Show the next alert after this one is closed
      _showNextAlert();
    });
  }
}

/// Extension methods for Medication entity
extension MedicationAlertExtension on Medication {
  /// Show an alert for this medication
  Future<String?> showAlert(
    BuildContext context, {
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
    VoidCallback? onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return MedicationManagementAlert.fromMedication(
          medication: this,
          backgroundImagePath: backgroundImagePath,
          onTake: onTake ?? () {},
          onSkip: onSkip,
          onReschedule: onReschedule,
        );
      },
    );
  }
  
  /// Add this medication to the alert queue
  void addToAlertQueue(
    BuildContext context, {
    String backgroundImagePath = 'assets/images/medication_management_alert.png',
    VoidCallback? onTake,
    VoidCallback? onSkip,
    VoidCallback? onReschedule,
  }) {
    MedicationAlertService().addMedicationToQueue(
      context: context,
      medication: this,
      backgroundImagePath: backgroundImagePath,
      onTake: onTake,
      onSkip: onSkip,
      onReschedule: onReschedule,
    );
  }
}
