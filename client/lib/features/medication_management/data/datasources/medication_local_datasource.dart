import 'package:client/core/errors/exceptions.dart';
import 'package:client/features/medication_management/data/models/medication_model.dart';
import 'package:client/features/medication_management/data/models/medication_schedule_model.dart';
import 'package:intl/intl.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationScheduleModel>> getMedicationSchedules();
  Future<MedicationScheduleModel> getMedicationScheduleForDate(String date);
  Future<bool> updateMedicationStatus(String medicationId, bool taken);
  Future<bool> addMedication(MedicationModel medication, String date, String time);
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  // Mock database for medications
  final Map<String, List<Map<String, dynamic>>> _medicationDatabase = {
    '2025-04-04': [
      {
        'time': '09:43',
        'displayTime': '9:43 AM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_8am_20250330',
            'icon': 'medication',
            'taken': false,
          },
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_8am_20250330',
            'icon': 'medication_liquid',
            'taken': false,
          },
        ],
      },
      {
        'time': '09:00',
        'displayTime': '9:00 AM',
        'total': 5,
        'medications': [
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_9am_20250330',
            'icon': 'medication',
            'taken': true,
          },
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_9am_20250330',
            'icon': 'medication_liquid',
            'taken': false,
          },
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_9am_20250330_2',
            'icon': 'medication',
            'taken': true,
          },
        ],
      },
      {
        'time': '10:00',
        'displayTime': '10:00 AM',
        'total': 1,
        'medications': [
          {
            'name': 'Paracetamol',
            'dosage': '500mg',
            'instruction': 'With Water',
            'id': 'paracetamol_10am_20250330',
            'icon': 'medication',
            'taken': false,
          },
        ],
      },
      {
        'time': '13:00',
        'displayTime': '1:00 PM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_1pm_20250330',
            'icon': 'medication',
            'taken': false,
          },
          {
            'name': 'Vitamin D',
            'dosage': '2000 IU',
            'instruction': 'With Food',
            'id': 'vitamind_1pm_20250330',
            'icon': 'medication_liquid',
            'taken': false,
          },
        ],
      },
      {
        'time': '17:18',
        'displayTime': '5:18 PM',
        'total': 2,
        'medications': [
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_6pm_20250330',
            'icon': 'medication_liquid',
            'taken': false,
          },
          {
            'name': 'Vitamin C',
            'dosage': '500mg',
            'instruction': 'With Water',
            'id': 'vitaminc_6pm_20250330',
            'icon': 'medication',
            'taken': false,
          },
        ],
      },
      {
        'time': '22:00',
        'displayTime': '10:00 PM',
        'total': 1,
        'medications': [
          {
            'name': 'Melatonin',
            'dosage': '3mg',
            'instruction': 'Before Sleep',
            'id': 'melatonin_10pm_20250330',
            'icon': 'medication_liquid',
            'taken': false,
          },
        ],
      },
    ],
    '2025-03-29': [
      {
        'time': '08:00',
        'displayTime': '8:00 AM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_8am_20250329',
            'icon': 'medication',
            'taken': true,
          },
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_8am_20250329',
            'icon': 'medication_liquid',
            'taken': true,
          },
        ],
      },
      {
        'time': '13:00',
        'displayTime': '1:00 PM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_1pm_20250329',
            'icon': 'medication',
            'taken': true,
          },
          {
            'name': 'Vitamin D',
            'dosage': '2000 IU',
            'instruction': 'With Food',
            'id': 'vitamind_1pm_20250329',
            'icon': 'medication_liquid',
            'taken': true,
          },
        ],
      },
      {
        'time': '18:00',
        'displayTime': '6:00 PM',
        'total': 2,
        'medications': [
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_6pm_20250329',
            'icon': 'medication_liquid',
            'taken': true,
          },
          {
            'name': 'Vitamin C',
            'dosage': '500mg',
            'instruction': 'With Water',
            'id': 'vitaminc_6pm_20250329',
            'icon': 'medication',
            'taken': true,
          },
        ],
      },
    ],
    '2025-03-31': [
      {
        'time': '08:00',
        'displayTime': '8:00 AM',
        'total': 2,
        'medications': [
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_8am_20250331',
            'icon': 'medication',
            'taken': false,
          },
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_8am_20250331',
            'icon': 'medication_liquid',
            'taken': false,
          },
        ],
      },
      {
        'time': '11:55',
        'displayTime': '11:55 AM',
        'total': 1,
        'medications': [
          {
            'name': 'Amoxiciline',
            'dosage': '500mg',
            'instruction': 'Before Eating',
            'id': 'amoxicilline_1pm_20250331',
            'icon': 'medication',
            'taken': false,
          },
        ],
      },
      {
        'time': '20:05',
        'displayTime': '8:05 PM',
        'total': 3,
        'medications': [
          {
            'name': 'Losartan',
            'dosage': '50mg',
            'instruction': 'After Eating',
            'id': 'losartan_6pm_20250331',
            'icon': 'medication_liquid',
            'taken': false,
          },
          {
            'name': 'Vitamin C',
            'dosage': '500mg',
            'instruction': 'With Water',
            'id': 'vitaminc_6pm_20250331',
            'icon': 'medication',
            'taken': false,
          },
          {
            'name': 'Probuphine',
            'dosage': '80mg',
            'instruction': 'With Food',
            'id': 'probuphine_6pm_20250331',
            'icon': 'medication',
            'taken': false,
          },
        ],
      },
    ],
  };

  MedicationLocalDataSourceImpl() {
    _populateMoreDates();
  }

  void _populateMoreDates() {
    final DateTime now = DateTime.now();

    for (int i = -7; i <= 7; i++) {
      if (i == -1 || i == 0 || i == 1) continue;

      final DateTime date = DateTime(now.year, now.month, now.day + i);
      final String dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!_medicationDatabase.containsKey(dateKey)) {
        _medicationDatabase[dateKey] = [
          {
            'time': '08:00',
            'displayTime': '8:00 AM',
            'total': 2,
            'medications': [
              {
                'name': 'Amoxiciline',
                'dosage': '500mg',
                'instruction': 'Before Eating',
                'id': 'amoxicilline_8am_${DateFormat('yyyyMMdd').format(date)}',
                'icon': 'medication',
                'taken': false,
              },
              {
                'name': 'Losartan',
                'dosage': '50mg',
                'instruction': 'After Eating',
                'id': 'losartan_8am_${DateFormat('yyyyMMdd').format(date)}',
                'icon': 'medication_liquid',
                'taken': false,
              },
            ],
          },
          {
            'time': '18:00',
            'displayTime': '6:00 PM',
            'total': 2,
            'medications': [
              {
                'name': 'Losartan',
                'dosage': '50mg',
                'instruction': 'After Eating',
                'id': 'losartan_6pm_${DateFormat('yyyyMMdd').format(date)}',
                'icon': 'medication_liquid',
                'taken': false,
              },
              {
                'name': 'Vitamin C',
                'dosage': '500mg',
                'instruction': 'With Water',
                'id': 'vitaminc_6pm_${DateFormat('yyyyMMdd').format(date)}',
                'icon': 'medication',
                'taken': false,
              },
            ],
          },
        ];
      }
    }
  }

  @override
  Future<List<MedicationScheduleModel>> getMedicationSchedules() async {
    try {
      List<MedicationScheduleModel> schedules = [];
      
      _medicationDatabase.forEach((date, timeSlots) {
        schedules.add(MedicationScheduleModel.fromJson(date, timeSlots));
      });
      
      return schedules;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<MedicationScheduleModel> getMedicationScheduleForDate(String date) async {
    try {
      if (_medicationDatabase.containsKey(date)) {
        return MedicationScheduleModel.fromJson(date, _medicationDatabase[date]!);
      } else {
        // Return empty schedule if no data for this date
        return MedicationScheduleModel(date: date, timeSlots: []);
      }
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> updateMedicationStatus(String medicationId, bool taken) async {
    try {
      bool updated = false;
      
      _medicationDatabase.forEach((date, timeSlots) {
        for (var timeSlot in timeSlots) {
          for (var medication in timeSlot['medications']) {
            if (medication['id'] == medicationId) {
              medication['taken'] = taken;
              updated = true;
            }
          }
        }
      });
      
      return updated;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> addMedication(MedicationModel medication, String date, String time) async {
    try {
      if (!_medicationDatabase.containsKey(date)) {
        _medicationDatabase[date] = [];
      }
      
      // Find if there's already a time slot for this time
      var existingTimeSlotIndex = _medicationDatabase[date]!.indexWhere(
        (timeSlot) => timeSlot['time'] == time
      );
      
      if (existingTimeSlotIndex >= 0) {
        // Add to existing time slot
        _medicationDatabase[date]![existingTimeSlotIndex]['medications'].add(medication.toJson());
        _medicationDatabase[date]![existingTimeSlotIndex]['total'] = 
            _medicationDatabase[date]![existingTimeSlotIndex]['medications'].length;
      } else {
        // Create new time slot
        final displayTime = _formatDisplayTime(time);
        _medicationDatabase[date]!.add({
          'time': time,
          'displayTime': displayTime,
          'total': 1,
          'medications': [medication.toJson()],
        });
        
        // Sort time slots by time
        _medicationDatabase[date]!.sort((a, b) => a['time'].compareTo(b['time']));
      }
      
      return true;
    } catch (e) {
      throw CacheException();
    }
  }
  
  String _formatDisplayTime(String time) {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts[1];
    
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }
}
