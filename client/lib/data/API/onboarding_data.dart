import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';

Future<void> updateUserHealthProfile(WidgetRef ref) async {

  // dart(NOTE:) Onboarding data is being sent to backend successfully if access token is available
  final onboardingState = ref.read(onboardingProvider);

  try {
    // ✅ Retrieve Access Token from SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    final String accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyNzEzNzA0Zi0wZTk2LTQxY2ItYjhlNC04NDMwOTVlMjg5MDMiLCJlbWFpbCI6bnVsbCwiaWF0IjoxNzQ0MDE5Njc0LCJleHAiOjE3NDQwMjMyNzR9.LfaL3AqoTHJ6oCqfLHbG88m10YjV9vCw48ayRGAvWlc"; // Replace with actual token retrieval logic

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

    // ✅ Convert data to JSON
    final String jsonData = jsonEncode(requestData);

    // ✅ Send PATCH request to backend
    final response = await http.patch(
      Uri.parse("http://192.168.11.196:4000/api/profiles"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken", // Attach token
      },
      body: jsonData,
    );

    // ignore: avoid_print
    print("response: $response");

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
