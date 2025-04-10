import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';

Future<void> updateUserHealthProfile(WidgetRef ref) async {
  final onboardingState = ref.read(onboardingProvider);

  try {
    // ✅ Retrieve Access Token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4ZjgyMTA1ZS1iNWJhLTQwNmUtOTFkNi1hMTlkMmU5ODk0YzgiLCJtb2JpbGUiOiIrOTE3ODQyOTAwMTU1IiwiaWF0IjoxNzQ0MzA5ODc0LCJleHAiOjE3NDQzMTM0NzR9.rEHxrfyDKb2-xj-v-STcraeAI2hLE5hvKTt8pI_4EyA");

    if (accessToken == null) {
      print("⚠️ Error: No Access Token Found.");
      return;
    }

    // ✅ Prepare request data (Include `medical_conditions`)
    final Map<String, dynamic> requestData = {
      "health_goals": onboardingState.goal,
      "gender": onboardingState.gender,
      "weight_kg": onboardingState.weight_kg,
      "height_cm": onboardingState.height_cm,
      "age": onboardingState.age,
      "medications": onboardingState.medications ?? [],
      "medical_conditions":
          onboardingState.medical_conditions ?? [], // ✅ Allergy Data Sent
    };

    print("📡 Sending Data: $requestData");

    // ✅ Convert data to JSON
    final String jsonData = jsonEncode(requestData);

    // ✅ Send PATCH request to backend
    final response = await http.patch(
      Uri.parse("https://test-prod-f427.onrender.com/api/profiles"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken", // Attach token
      },
      body: jsonData,
    );

    // ✅ Handle API Response
    if (response.statusCode == 200) {
      print("✅ Profile updated successfully: ${response.body}");
    } else {
      print("⚠️ Failed to update profile: ${response.statusCode}");
      print("📝 Response: ${response.body}");
    }
  } catch (e) {
    print("❌ Error updating profile: $e");
  }
}
