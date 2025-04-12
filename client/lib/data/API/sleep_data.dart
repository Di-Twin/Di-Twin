// lib/data/API/sleep_data.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Sleep session model
class MonthlySleepSession {
  final String sessionId;
  final String dayId;
  final String date;
  final int duration;
  final double efficiencyScore;
  final int? sleepScore;
  final String startTime;
  final String endTime;

  MonthlySleepSession({
    required this.sessionId,
    required this.dayId,
    required this.date,
    required this.duration,
    required this.efficiencyScore,
    this.sleepScore,
    required this.startTime,
    required this.endTime,
  });

  factory MonthlySleepSession.fromJson(Map<String, dynamic> json) {
    return MonthlySleepSession(
      sessionId: json['sessionId'],
      dayId: json['dayId'],
      date: json['date'],
      duration: json['duration'],
      efficiencyScore: json['efficiencyScore'].toDouble(),
      sleepScore: json['sleepScore'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  String getDurationInHours() {
    final hours = duration / 3600;
    return '${hours.toStringAsFixed(1)}h';
  }

  String getSleepQuality() {
    if (efficiencyScore >= 85) {
      return 'Deep';
    } else if (efficiencyScore >= 75) {
      return 'Good';
    } else {
      return 'Light';
    }
  }
}

class MonthlySleepSummary {
  final int totalDays;
  final int totalSessions;
  final double averageDuration;
  final double averageEfficiency;
  final double averageScore;
  final String lastUpdated;

  MonthlySleepSummary({
    required this.totalDays,
    required this.totalSessions,
    required this.averageDuration,
    required this.averageEfficiency,
    required this.averageScore,
    required this.lastUpdated,
  });

  factory MonthlySleepSummary.fromJson(
    Map<String, dynamic> json,
    String lastUpdated,
  ) {
    return MonthlySleepSummary(
      totalDays: json['totalDays'],
      totalSessions: json['totalSessions'],
      averageDuration: json['averageDuration'].toDouble(),
      averageEfficiency: json['averageEfficiency'].toDouble(),
      averageScore: json['averageScore']?.toDouble() ?? 0.0,
      lastUpdated: lastUpdated,
    );
  }
}

class MonthlySleepResponse {
  final bool success;
  final String message;
  final List<MonthlySleepSession> sessions;
  final MonthlySleepSummary summary;

  MonthlySleepResponse({
    required this.success,
    required this.message,
    required this.sessions,
    required this.summary,
  });

  factory MonthlySleepResponse.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['data']['summary'];
    final lastUpdated = json['data']['lastUpdated'];

    return MonthlySleepResponse(
      success: json['success'],
      message: json['message'],
      sessions:
          (json['data']['days'] as List)
              .map((e) => MonthlySleepSession.fromJson(e))
              .toList(),
      summary: MonthlySleepSummary.fromJson(summaryJson, lastUpdated),
    );
  }

  Map<int, bool> generateActivityMap() {
    final Map<int, bool> map = {};
    for (var session in sessions) {
      final day = int.tryParse(session.date.split('-').last) ?? 1;
      map[day] = true;
    }
    return map;
  }

  List<MonthlySleepSession> getUniqueDays() {
    final Map<String, MonthlySleepSession> uniqueDays = {};
    for (var session in sessions) {
      if (!uniqueDays.containsKey(session.date)) {
        uniqueDays[session.date] = session;
      }
    }
    return uniqueDays.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }
}

class SleepStage {
  final String id;
  final String sessionId;
  final String userId;
  final String stageType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final DateTime createdAt;

  SleepStage({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.stageType,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.createdAt,
  });

  factory SleepStage.fromJson(Map<String, dynamic> json) {
    return SleepStage(
      id: json['id'],
      sessionId: json['sessionId'],
      userId: json['userId'],
      stageType: json['stageType'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationSeconds: json['durationSeconds'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class SleepSession {
  final String id;
  final String userId;
  final String dayId;
  final DateTime startTime;
  final DateTime endTime;
  final String sourceDevice;
  final int durationSeconds;
  final double efficiencyScore;
  final DateTime createdAt;
  final List<SleepStage> stages;

  // Getter to extract the date from startTime
  String get date => startTime.toIso8601String().split('T').first;

  SleepSession({
    required this.id,
    required this.userId,
    required this.dayId,
    required this.startTime,
    required this.endTime,
    required this.sourceDevice,
    required this.durationSeconds,
    required this.efficiencyScore,
    required this.createdAt,
    required this.stages,
  });

  factory SleepSession.fromJson(Map<String, dynamic> json) {
    return SleepSession(
      id: json['id'],
      userId: json['userId'],
      dayId: json['dayId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      sourceDevice: json['sourceDevice'],
      durationSeconds: json['durationSeconds'],
      efficiencyScore: json['efficiencyScore'],
      createdAt: DateTime.parse(json['createdAt']),
      stages:
          (json['stages'] as List)
              .map((stageJson) => SleepStage.fromJson(stageJson))
              .toList(),
    );
  }

  // Get percentage of each sleep stage
  Map<String, double> get stagePercentages {
    final Map<String, int> stageDurations = {};

    for (var stage in stages) {
      if (stageDurations.containsKey(stage.stageType)) {
        stageDurations[stage.stageType] =
            (stageDurations[stage.stageType] ?? 0) + stage.durationSeconds;
      } else {
        stageDurations[stage.stageType] = stage.durationSeconds;
      }
    }

    final Map<String, double> percentages = {};
    stageDurations.forEach((stageType, duration) {
      percentages[stageType] = (duration / durationSeconds) * 100;
    });

    return percentages;
  }

  // Get values for the bar graph (normalized values)
  Map<String, int> get stageValues {
    final Map<String, int> stageDurations = {
      'AWAKE': 0,
      'REM': 0,
      'LIGHT': 0,
      'DEEP': 0,
    };

    for (var stage in stages) {
      stageDurations[stage.stageType] =
          (stageDurations[stage.stageType] ?? 0) + stage.durationSeconds;
    }

    // Normalize values to fit the expected range for the bar graph (0-100)
    // You can adjust the normalization factor based on your UI needs
    final int maxValue = 100;
    final Map<String, int> normalized = {};
    stageDurations.forEach((stageType, duration) {
      // Calculate the percentage and then normalize to maxValue
      double percentage = (duration / durationSeconds) * 100;
      normalized[stageType] = (percentage).round();
    });

    return normalized;
  }
}

class SleepApiResponse {
  final bool success;
  final String message;
  final SleepSession data;

  SleepApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SleepApiResponse.fromJson(Map<String, dynamic> json) {
    return SleepApiResponse(
      success: json['success'],
      message: json['message'],
      data: SleepSession.fromJson(json['data']),
    );
  }
}

class SleepService {
  final String baseUrl = 'https://test-prod-f427.onrender.com/api';
  final String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJkYjJhMGI0YS1kYTNjLTRiNjQtOTYxNS0yYmIwOTBmYzg1OTEiLCJtb2JpbGUiOiIrOTE3ODQyOTAwMTU1IiwiaWF0IjoxNzQ0Mzk4NzE0LCJleHAiOjE3NDQ0MDIzMTR9.QzEYp3l_awC6x2NcATWzBcWCMbU8p_bTWnH_kvOp01o';

  Future<SleepApiResponse> getDailySleepData(String date) async {
  final url = '$baseUrl/sleep/daily/$date';
  debugPrint('[SleepService] Fetching daily sleep data for: $date');
  debugPrint('[SleepService] GET $url');

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('[SleepService] Response status: ${response.statusCode}');
    debugPrint('[SleepService] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      debugPrint('[SleepService] Parsed JSON: $jsonData');
      return SleepApiResponse.fromJson(jsonData);
    } else {
      debugPrint('[SleepService] Error status: ${response.statusCode}');
      throw Exception('Failed to load sleep data: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('[SleepService] Exception occurred: $e');
    throw Exception('Failed to fetch sleep data: $e');
  }
}


  Future<MonthlySleepResponse> getMonthlySleepData(int year, int month) async {
    try {
      final urls = Uri.parse('$baseUrl/sleep/monthly/$year/$month');
      final response = await http.get(
        urls,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final jsonData = jsonDecode(response.body);
      debugPrint('Parsed ${jsonData['data']['days'].length} sessions');
      debugPrint('Summary last updated: ${jsonData['data']['lastUpdated']}');

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      debugPrint("URL: $urls");

      if (response.statusCode == 200) {
        return MonthlySleepResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load sleep data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sleep data: $e');
    }
  }
}
