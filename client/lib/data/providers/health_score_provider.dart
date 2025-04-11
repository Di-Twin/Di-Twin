// Create a new file: lib/data/providers/health_score_provider.dart
import 'package:flutter/material.dart';

class HealthScoreProvider extends ChangeNotifier {
  static final HealthScoreProvider _instance = HealthScoreProvider._internal();
  
  factory HealthScoreProvider() {
    return _instance;
  }
  
  HealthScoreProvider._internal();
  
  int _healthScore = 88; // Default value
  
  int get healthScore => _healthScore;
  
  void setHealthScore(int score) {
    _healthScore = score;
    notifyListeners();
  }
}