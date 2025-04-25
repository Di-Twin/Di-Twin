import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/errors/failures.dart';
import '../models/activity_stat_model.dart';

abstract class ActivityStatsRemoteDataSource {
  Future<List<ActivityStatModel>> getActivityStats();
}

class ActivityStatsRemoteDataSourceImpl implements ActivityStatsRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  
  ActivityStatsRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });
  
  @override
  Future<List<ActivityStatModel>> getActivityStats() async {
    try {
      // In a real app, this would fetch data from an API
      // For now, we'll return mock data that matches the original implementation
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      return [
        ActivityStatModel(
          name: 'Yoga',
          value: 72,
          color: const Color(0xFF1E293B),
        ),
        ActivityStatModel(
          name: 'Jogging',
          value: 48,
          color: const Color(0xFF3B82F6),
        ),
        ActivityStatModel(
          name: 'Biking',
          value: 11,
          color: const Color(0xFFEF4444),
        ),
        ActivityStatModel(
          name: 'Hiking',
          value: 8,
          color: const Color(0xFF8B5CF6),
        ),
        ActivityStatModel(
          name: 'Tennis',
          value: 21,
          color: const Color(0xFF94A3B8),
        ),
      ];
    } catch (e) {
      throw ServerFailure();
    }
  }
}
