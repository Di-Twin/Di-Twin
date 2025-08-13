import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/data/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateUserHealthProfile(WidgetRef ref) async {
  final onboardingState = ref.read(onboardingProvider);

  try {
    // ✅ Retrieve Access Token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      print("⚠️ No access token found. User might be logged out.");
      return;
    }

    // ✅ Prepare request data
    final Map<String, dynamic> requestData = {
      "health_goals": onboardingState.goal,
      "gender": onboardingState.gender,
      "weight_kg": onboardingState.weight_kg,
      "height_cm": onboardingState.height_cm,
      "age": onboardingState.age,
      "medications": onboardingState.medications ?? [],
      "medical_conditions": onboardingState.medical_conditions ?? [],
    };

    final String jsonData = jsonEncode(requestData);

    final response = await http.patch(
      Uri.parse("https://test-prod-f427.onrender.com/api/profiles"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonData,
    );

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
