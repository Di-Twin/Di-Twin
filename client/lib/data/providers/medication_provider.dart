import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicationService {
  // Replace with your actual API URL
  final String baseUrl = 'https://test-prod-f427.onrender.com';

  // Method to create or update a medication
  Future<Map<String, dynamic>> saveMedication({
    String? id,
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
      // Prepare the request body
      final Map<String, dynamic> body = {
        if (id != null) 'id': id,
        'medicationName': medicationName,
        'afterFood': afterFood,
        'frequency': frequency,
        'timings': timings,
        'reminder': reminder,
        'dose': dose,
        'startDate': startDate,
        'endDate': endDate,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if required
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4ZjgyMTA1ZS1iNWJhLTQwNmUtOTFkNi1hMTlkMmU5ODk0YzgiLCJtb2JpbGUiOiIrOTE3ODQyOTAwMTU1IiwiaWF0IjoxNzQ1Mzg2NzI1LCJleHAiOjE3NDUzOTAzMjV9.8rp5AxWYP1Z0e8NikZlpIZ77OJ-qNT05w9LwRwyP5uE',  
        },
        body: jsonEncode(body),
      );

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if the request was successful
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Failed to save medication');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
