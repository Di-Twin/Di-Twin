class MedicationService {
  // Base URL for API calls
  final String _baseUrl = 'https://api.example.com/medications';

  // Save medication to the backend
  Future<Map<String, dynamic>> saveMedication({
    required String medicationName,
    required bool afterFood,
    required String frequency,
    required List<String> timings,
    required bool reminder,
    required String dose,
    required String startDate,
    required String endDate,
  }) async {
    try {
      // In a real app, this would be an API call
      // For now, we'll simulate a successful response
      await Future.delayed(Duration(seconds: 1));

      // Mock response
      final mockResponse = {
        'id': 'med_${DateTime.now().millisecondsSinceEpoch}',
        'name': medicationName,
        'afterFood': afterFood,
        'frequency': frequency,
        'timings': timings,
        'reminder': reminder,
        'dose': dose,
        'startDate': startDate,
        'endDate': endDate,
        'createdAt': DateTime.now().toIso8601String(),
      };

      return mockResponse;
    } catch (e) {
      throw Exception('Failed to save medication: $e');
    }
  }

  // Add medication to the backend
  Future<Map<String, dynamic>> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String notes,
  }) async {
    try {
      // In a real app, this would be an API call
      // For now, we'll simulate a successful response
      await Future.delayed(Duration(seconds: 1));

      // Mock response
      final mockResponse = {
        'id': 'med_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'notes': notes,
        'createdAt': DateTime.now().toIso8601String(),
      };

      return mockResponse;
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  // Get all medications
  Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      // In a real app, this would be an API call
      // For now, we'll return mock data
      await Future.delayed(Duration(seconds: 1));

      return [
        {
          'id': 'med_1',
          'name': 'Amoxicillin',
          'afterFood': true,
          'frequency': '3x Per Day',
          'timings': ['9:00 AM', '2:00 PM', '9:00 PM'],
          'reminder': true,
          'dose': '1 unit',
          'startDate': DateTime.now().toIso8601String(),
          'endDate': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        },
        {
          'id': 'med_2',
          'name': 'Lisinopril',
          'afterFood': false,
          'frequency': '1x Per Day',
          'timings': ['8:00 AM'],
          'reminder': true,
          'dose': '2 units',
          'startDate': DateTime.now().toIso8601String(),
          'endDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
        },
      ];
    } catch (e) {
      throw Exception('Failed to get medications: $e');
    }
  }

  // Update medication status (taken/not taken)
  Future<bool> updateMedicationStatus(String medicationId, bool taken) async {
    try {
      // In a real app, this would be an API call
      await Future.delayed(Duration(milliseconds: 500));

      // Mock successful update
      return true;
    } catch (e) {
      throw Exception('Failed to update medication status: $e');
    }
  }

  // Delete medication
  Future<bool> deleteMedication(String medicationId) async {
    try {
      // In a real app, this would be an API call
      await Future.delayed(Duration(milliseconds: 800));

      // Mock successful deletion
      return true;
    } catch (e) {
      throw Exception('Failed to delete medication: $e');
    }
  }
}
