import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class LeaderboardDataSource {
  Future<Map<String, dynamic>> getDailyLeaderboard(String date);
  Future<Map<String, dynamic>> getMonthlyLeaderboard(int year, int month);
}

class LeaderboardRemoteDataSource implements LeaderboardDataSource {
  final http.Client client;
  final String baseUrl;

  LeaderboardRemoteDataSource({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<Map<String, dynamic>> getDailyLeaderboard(String date) async {
    final uri = Uri.parse('$baseUrl/leaderboard/daily?date=$date');
    
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im5vdGhpbmcuZnV6QGdtYWlsLmNvbSIsInBhc3N3b3JkIjoicGFzc3dvcmQxMjMiLCJmaXJzdF9uYW1lIjoiTW9uZXNoIiwibGFzdF9uYW1lIjoiQiIsImlhdCI6MTc0NzgyMjM4NiwiZXhwIjoxNzQ3ODIzMjg2fQ.skyTSH1Vufg_ZWxsCL5J6rEUPcnKVUCQLhB-fAH9YSY',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch daily leaderboard');
      }
    } else {
      throw Exception('Failed to fetch daily leaderboard: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMonthlyLeaderboard(int year, int month) async {
    final uri = Uri.parse('$baseUrl/leaderboard/monthly?year=$year&month=$month');
    
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        // Include your authorization headers here
        // 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch monthly leaderboard');
      }
    } else {
      throw Exception('Failed to fetch monthly leaderboard: ${response.statusCode}');
    }
  }
}