import 'package:client/features/medication_management/domain/entities/medication.dart';
import 'package:client/features/medication_management/domain/entities/medication_schedule.dart';
import 'package:client/features/medication_management/domain/entities/medication_time_slot.dart';
import 'package:client/features/medication_management/domain/usecases/get_medication_schedule_for_date_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/get_medication_schedules_usecase.dart';
import 'package:client/features/medication_management/domain/usecases/update_medication_status_usecase.dart';
import 'package:client/features/medication_management/presentation/widgets/medication_management_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum MedicationStatus {
  none, // No medications for this day
  complete, // All medications taken
  partial, // Some medications taken
  incomplete, // No medications taken
}

class MedicationProvider extends ChangeNotifier {
  final GetMedicationSchedulesUseCase getMedicationSchedulesUseCase;
  final GetMedicationScheduleForDateUseCase getMedicationScheduleForDateUseCase;
  final UpdateMedicationStatusUseCase updateMedicationStatusUseCase;

  MedicationProvider({
    required this.getMedicationSchedulesUseCase,
    required this.getMedicationScheduleForDateUseCase,
    required this.updateMedicationStatusUseCase,
  });

  // State variables
  List<DateTime> _dateRange = [];
  DateTime _selectedDate = DateTime.now();
  int _selectedDateIndex = 0;
  double _dayProgress = 0.0;
  bool _isLoading = false;
  String _errorMessage = '';

  // Medication data
  List<MedicationSchedule> _medicationSchedules = [];
  MedicationSchedule? _currentSchedule;
  List<MedicationTimeSlot> _currentMedicationSchedule = [];

  // Getters
  List<DateTime> get dateRange => _dateRange;
  DateTime get selectedDate => _selectedDate;
  int get selectedDateIndex => _selectedDateIndex;
  double get dayProgress => _dayProgress;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<MedicationTimeSlot> get currentMedicationSchedule => _currentMedicationSchedule;

  // Initialize provider
  Future<void> initialize() async {
    _generateDateRange();
    await _loadMedicationSchedules();
    await loadMedicationScheduleForDate(_selectedDate);
    _calculateDayProgress();
    _startDayProgressTimer();
  }

  void _generateDateRange() {
    final startDate = DateTime.now().subtract(const Duration(days: 15));
    _dateRange = List.generate(
      31,
          (index) => startDate.add(Duration(days: index)),
    );

    _selectedDateIndex = _dateRange.indexWhere(
          (date) => _isSameDay(date, DateTime.now()),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  Future<void> _loadMedicationSchedules() async {
    _isLoading = true;
    notifyListeners();

    final result = await getMedicationSchedulesUseCase();

    result.fold(
            (failure) {
          _errorMessage = 'Failed to load medication schedules';
          _isLoading = false;
        },
            (schedules) {
          _medicationSchedules = schedules;
          _isLoading = false;
        }
    );

    notifyListeners();
  }

  Future<void> loadMedicationScheduleForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final result = await getMedicationScheduleForDateUseCase(dateStr);

    result.fold(
            (failure) {
          _errorMessage = 'Failed to load medication schedule for date';
          _currentMedicationSchedule = [];
          _isLoading = false;
        },
            (schedule) {
          _currentSchedule = schedule;
          _currentMedicationSchedule = schedule.timeSlots;
          _isLoading = false;
        }
    );

    notifyListeners();
  }

  Future<bool> updateMedicationStatus(String medicationId, bool taken) async {
    final result = await updateMedicationStatusUseCase(medicationId, taken);

    bool success = false;
    result.fold(
            (failure) {
          _errorMessage = 'Failed to update medication status';
        },
            (updated) {
          if (updated) {
            // Update local state
            _updateLocalMedicationStatus(medicationId, taken);
            success = true;
          }
        }
    );

    notifyListeners();
    return success;
  }

  void _updateLocalMedicationStatus(String medicationId, bool taken) {
    if (_currentSchedule != null) {
      for (var i = 0; i < _currentMedicationSchedule.length; i++) {
        final timeSlot = _currentMedicationSchedule[i];
        for (var j = 0; j < timeSlot.medications.length; j++) {
          if (timeSlot.medications[j].id == medicationId) {
            final updatedMedication = timeSlot.medications[j].copyWith(taken: taken);
            final updatedMedications = List<Medication>.from(timeSlot.medications);
            updatedMedications[j] = updatedMedication;

            final updatedTimeSlot = timeSlot.copyWith(medications: updatedMedications);
            final updatedTimeSlots = List<MedicationTimeSlot>.from(_currentMedicationSchedule);
            updatedTimeSlots[i] = updatedTimeSlot;

            _currentMedicationSchedule = updatedTimeSlots;
            break;
          }
        }
      }
    }
  }

  void selectDate(int index) {
    if (index >= 0 && index < _dateRange.length) {
      _selectedDateIndex = index;
      _selectedDate = _dateRange[index];
      loadMedicationScheduleForDate(_selectedDate);

      // Extend date range if needed
      if (index < 2 && _dateRange.first.difference(DateTime.now()).inDays > -15) {
        _extendDateRangeBackward();
      } else if (index > _dateRange.length - 3 &&
          _dateRange.last.difference(DateTime.now()).inDays < 15) {
        _extendDateRangeForward();
      }
    }
  }

  void _extendDateRangeBackward() {
    final earliestDate = _dateRange.first;
    final daysToAdd = List.generate(
      5,
          (i) => earliestDate.subtract(Duration(days: i + 1)),
    ).reversed.toList();

    _dateRange.insertAll(0, daysToAdd);
    _selectedDateIndex += daysToAdd.length;
    notifyListeners();
  }

  void _extendDateRangeForward() {
    final latestDate = _dateRange.last;
    final daysToAdd = List.generate(
      5,
          (i) => latestDate.add(Duration(days: i + 1)),
    );

    _dateRange.addAll(daysToAdd);
    notifyListeners();
  }

  void _calculateDayProgress() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final totalDayMinutes = 24 * 60;
    final minutesPassed = now.difference(startOfDay).inMinutes;

    _dayProgress = (minutesPassed / totalDayMinutes).clamp(0.0, 1.0);
    notifyListeners();
  }

  void _startDayProgressTimer() {
    // This would be implemented with a real timer in a stateful widget
    // For the provider, we'll just expose the method
  }

  // Calculate timeline progress based on current time
  double calculateTimelineProgress() {
    // If selected date is in the past, return 1.0 (100%)
    if (_selectedDate.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    )) {
      return 1.0;
    }

    // If selected date is in the future, return 0.0 (0%)
    if (_selectedDate.isAfter(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    )) {
      return 0.0;
    }

    // If today, return current progress through the day
    return _dayProgress;
  }

  // Check if a time slot is currently active (within 15 minutes)
  bool isTimeSlotActive(String timeStr) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final timeSlotDateTime = _parseTimeSlot(today, timeStr);

    final diff = now.difference(timeSlotDateTime).inMinutes.abs();
    return diff <= 15; // Within 15 minutes
  }

  // Check if a medication time has passed
  bool isTimeSlotPassed(String timeStr) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final timeSlotDateTime = _parseTimeSlot(today, timeStr);

    return now.isAfter(timeSlotDateTime);
  }

  DateTime _parseTimeSlot(String dateStr, String timeStr) {
    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
    final timeParts = timeStr.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  // Get medication status for a specific date
  MedicationStatus getMedicationStatusForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Find the schedule for this date
    final scheduleForDate = _medicationSchedules.firstWhere(
          (schedule) => schedule.date == dateStr,
      orElse: () => MedicationSchedule(date: dateStr, timeSlots: []),
    );

    if (scheduleForDate.timeSlots.isEmpty) {
      return MedicationStatus.none;
    }

    int totalMedications = 0;
    int takenMedications = 0;

    for (var timeSlot in scheduleForDate.timeSlots) {
      for (var medication in timeSlot.medications) {
        totalMedications++;
        if (medication.taken) {
          takenMedications++;
        }
      }
    }

    // If all medications are taken
    if (takenMedications == totalMedications) {
      return MedicationStatus.complete;
    }

    // If some medications are taken
    if (takenMedications > 0) {
      return MedicationStatus.partial;
    }

    // If no medications are taken
    return MedicationStatus.incomplete;
  }

  void checkForMedicationAlerts(BuildContext context) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    // Assuming _medicationDatabase is replaced by _medicationSchedules and _currentMedicationSchedule
    // We need to adapt the logic to work with the existing data structure.
    // This is a placeholder and needs to be adjusted based on the actual data structure.

    if (_currentSchedule != null) {
      for (var timeSlot in _currentSchedule!.timeSlots) {
        final timeSlotTime = DateFormat('HH:mm').format(DateTime(now.year, now.month, now.day, int.parse(timeSlot.time.split(':')[0]), int.parse(timeSlot.time.split(':')[1]))); // Assuming time is stored as HH:mm
        final timeSlotDateTime = _parseTimeSlot(today, timeSlotTime);

        final diff = timeSlotDateTime.difference(now);
        if (diff.inMinutes.abs() <= 5 && diff.inMinutes > -10) {
          for (var medication in timeSlot.medications) {
            if (medication.taken) continue;

            _showMedicationAlert(context, medication);
          }
        }
      }
    }
  }

  void _showMedicationAlert(BuildContext context, Medication medication) {
    if (medication.alertShown == true) return;

    medication.alertShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MedicationManagementAlert(
          medicationName: medication.name,
          dosage: medication.dosage ?? "No dosage specified",
          instructions: medication.instruction ?? "",
        );
      },
    ).then((value) {
      if (value == 'take') {
        updateMedicationStatus(medication.id, true);
      } else if (value == 'reschedule') {
        // Handle reschedule logic
      }

      Future.delayed(const Duration(minutes: 30), () {
        medication.alertShown = false;
      });
    });
  }
}
