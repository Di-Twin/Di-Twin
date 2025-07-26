import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/water_intake.dart';
import '../../../../utils/token_manager.dart';
import 'dart:developer' as developer;

class WaterIntakeProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  WaterIntake _todayIntake = WaterIntake(
    date: DateTime.now(),
    totalAmount: 0,
    goalAmount: 2000,
    entries: [],
  );
  List<WaterIntake> _weeklyData = [];
  List<WaterIntake> _monthlyData = [];
  Map<String, dynamic> _stats = {};
  int _currentStreak = 0;
  double _weeklyAverage = 0.0;
  double _weeklyCompletionRate = 0.0;
  double _monthlyAverage = 0.0;
  int _missedDays = 0;
  String _mostHydratedDay = '';
  String _leastHydratedDay = '';

  // Dashboard data for fitness tracker integration
  Map<String, dynamic> _dashboardData = {};

  // Drawer frequency tracking
  List<String> _dailySlots = [];
  Map<String, bool> _completedSlots = {};
  Timer? _drawerTimer;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  WaterIntake get todayIntake => _todayIntake;
  List<WaterIntake> get weeklyData => _weeklyData;
  List<WaterIntake> get monthlyData => _monthlyData;
  Map<String, dynamic> get stats => _stats;
  Map<String, dynamic> get dashboardData => _dashboardData;
  double get progressPercentage => (_todayIntake.totalAmount / _todayIntake.goalAmount * 100).clamp(0, 100);
  int get currentStreak => _currentStreak;
  double get weeklyAverage => _weeklyAverage;
  double get weeklyCompletionRate => _weeklyCompletionRate;
  double get monthlyAverage => _monthlyAverage;
  int get missedDays => _missedDays;
  String get mostHydratedDay => _mostHydratedDay;
  String get leastHydratedDay => _leastHydratedDay;
  List<String> get dailySlots => _dailySlots;
  Map<String, bool> get completedSlots => _completedSlots;

  // API base URL
  static const String _baseUrl = 'https://test-prod-f427.onrender.com/api';

  // Initialize provider
  Future<void> initialize() async {
    developer.log('🚀 Initializing WaterIntakeProvider', name: 'WaterIntakeProvider');
    await _loadCachedData();
    _generateDailySlots();
    _startDrawerTimer();
    // Run API calls in parallel but don't let them block the UI
    _fetchDataInBackground();
  }

  // Generate daily slots based on goal
  void _generateDailySlots() {
    final goal = _todayIntake.goalAmount;
    if (goal <= 1000) {
      _dailySlots = ['Morning', 'Evening'];
    } else if (goal <= 1500) {
      _dailySlots = ['Morning', 'Afternoon', 'Evening'];
    } else if (goal <= 2500) {
      _dailySlots = ['Morning', 'Lunch', 'Afternoon', 'Evening'];
    } else {
      _dailySlots = ['Morning', 'Mid-Morning', 'Lunch', 'Afternoon', 'Evening'];
    }

    // Initialize completed slots
    for (String slot in _dailySlots) {
      _completedSlots[slot] = false;
    }
    _loadSlotProgress();
    developer.log('✅ Generated ${_dailySlots.length} daily slots for ${goal}ml goal', name: 'WaterIntakeProvider');
  }

  // Start timer to check for drawer triggers
  void _startDrawerTimer() {
    _drawerTimer?.cancel();
    _drawerTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkDrawerTrigger();
    });
  }

  // Check if drawer should be triggered
  bool _checkDrawerTrigger() {
    final now = DateTime.now();
    final hour = now.hour;
    String? currentSlot;

    if (hour >= 6 && hour < 10) {
      currentSlot = 'Morning';
    } else if (hour >= 10 && hour < 12) {
      currentSlot = 'Mid-Morning';
    } else if (hour >= 12 && hour < 14) {
      currentSlot = 'Lunch';
    } else if (hour >= 14 && hour < 18) {
      currentSlot = 'Afternoon';
    } else if (hour >= 18 && hour < 22) {
      currentSlot = 'Evening';
    }

    if (currentSlot != null &&
        _dailySlots.contains(currentSlot) &&
        !(_completedSlots[currentSlot] ?? false)) {
      developer.log('🔔 Drawer should be triggered for slot: $currentSlot', name: 'WaterIntakeProvider');
      return true;
    }
    return false;
  }

  // Get current slot that needs completion
  String? getCurrentIncompleteSlot() {
    final now = DateTime.now();
    final hour = now.hour;
    String? currentSlot;

    if (hour >= 6 && hour < 10) {
      currentSlot = 'Morning';
    } else if (hour >= 10 && hour < 12) {
      currentSlot = 'Mid-Morning';
    } else if (hour >= 12 && hour < 14) {
      currentSlot = 'Lunch';
    } else if (hour >= 14 && hour < 18) {
      currentSlot = 'Afternoon';
    } else if (hour >= 18 && hour < 22) {
      currentSlot = 'Evening';
    }

    if (currentSlot != null &&
        _dailySlots.contains(currentSlot) &&
        !(_completedSlots[currentSlot] ?? false)) {
      return currentSlot;
    }
    return null;
  }

  // Mark slot as completed
  Future<void> markSlotCompleted(String slot) async {
    _completedSlots[slot] = true;
    await _saveSlotProgress();
    notifyListeners();
    developer.log('✅ Marked slot as completed: $slot', name: 'WaterIntakeProvider');
  }

  // Save slot progress to local storage
  Future<void> _saveSlotProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('water_slots_$today', json.encode(_completedSlots));
    } catch (e) {
      developer.log('❌ Error saving slot progress: $e', name: 'WaterIntakeProvider');
    }
  }

  // Load slot progress from local storage
  Future<void> _loadSlotProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final slotsData = prefs.getString('water_slots_$today');
      if (slotsData != null) {
        final slots = Map<String, bool>.from(json.decode(slotsData));
        _completedSlots.addAll(slots);
      }
    } catch (e) {
      developer.log('❌ Error loading slot progress: $e', name: 'WaterIntakeProvider');
    }
  }

  // Fetch data in background
  Future<void> _fetchDataInBackground() async {
    try {
      await Future.wait([
        fetchTodayIntake(),
        fetchMonthlyData(),
      ]);
    } catch (e) {
      developer.log('❌ Error in background fetch: $e', name: 'WaterIntakeProvider');
    }
  }

  // Load cached data for instant display
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cached today's intake
      final cachedTodayData = prefs.getString('water_intake_today');
      if (cachedTodayData != null) {
        final data = json.decode(cachedTodayData);
        _todayIntake = WaterIntake.fromJson(data);
        notifyListeners();
        developer.log('✅ Loaded cached water intake data', name: 'WaterIntakeProvider');
      }

      // Load cached goal
      final cachedGoal = prefs.getDouble('water_intake_goal');
      if (cachedGoal != null) {
        _todayIntake = _todayIntake.copyWith(goalAmount: cachedGoal);
        notifyListeners();
      }

      // Load cached stats
      final cachedStats = prefs.getString('water_intake_stats');
      if (cachedStats != null) {
        final statsData = json.decode(cachedStats);
        _currentStreak = statsData['streak'] ?? 0;
        _weeklyAverage = (statsData['weekly_avg'] ?? 0).toDouble();
        _weeklyCompletionRate = (statsData['weekly_completion_rate'] ?? 0).toDouble();
        _monthlyAverage = (statsData['monthly_avg'] ?? 0).toDouble();
        _missedDays = statsData['missed_days'] ?? 0;
        _mostHydratedDay = statsData['most_hydrated_day'] ?? '';
        _leastHydratedDay = statsData['least_hydrated_day'] ?? '';
        notifyListeners();
      }

      // Load cached dashboard data
      final cachedDashboard = prefs.getString('water_dashboard_data');
      if (cachedDashboard != null) {
        _dashboardData = json.decode(cachedDashboard);
        notifyListeners();
      }
    } catch (e) {
      developer.log('❌ Error loading cached water intake data: $e', name: 'WaterIntakeProvider');
    }
  }

  // Cache data
  Future<void> _cacheData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cache today's intake
      await prefs.setString('water_intake_today', json.encode(_todayIntake.toJson()));

      // Cache goal
      await prefs.setDouble('water_intake_goal', _todayIntake.goalAmount);

      // Cache stats
      final statsData = {
        'streak': _currentStreak,
        'weekly_avg': _weeklyAverage,
        'weekly_completion_rate': _weeklyCompletionRate,
        'monthly_avg': _monthlyAverage,
        'missed_days': _missedDays,
        'most_hydrated_day': _mostHydratedDay,
        'least_hydrated_day': _leastHydratedDay,
      };
      await prefs.setString('water_intake_stats', json.encode(statsData));

      // Cache dashboard data
      await prefs.setString('water_dashboard_data', json.encode(_dashboardData));

      // Cache timestamp
      await prefs.setInt('water_intake_cache_time', DateTime.now().millisecondsSinceEpoch);

      developer.log('✅ Cached water intake data', name: 'WaterIntakeProvider');
    } catch (e) {
      developer.log('❌ Error caching water intake data: $e', name: 'WaterIntakeProvider');
    }
  }

  // Fetch today's water intake using the API
  Future<void> fetchTodayIntake() async {
    try {
      developer.log('🔄 Fetching today\'s water intake', name: 'WaterIntakeProvider');

      final accessToken = await TokenManager.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available. Please log in again.');
      }

      developer.log('📡 Making API request to: $_baseUrl/client/health/water-dashboard', name: 'WaterIntakeProvider');

      final response = await http.get(
        Uri.parse('$_baseUrl/client/health/water-dashboard'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log('📡 API Response Status: ${response.statusCode}', name: 'WaterIntakeProvider');
      developer.log('📡 API Response Body: ${response.body}', name: 'WaterIntakeProvider');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update dashboard data for fitness tracker
        _dashboardData = data;

        // Parse the API response according to the provided format
        _todayIntake = WaterIntake(
          date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
          totalAmount: (data['total_water_taken'] ?? 0).toDouble(),
          goalAmount: (data['target_water_ml'] ?? 2000).toDouble(),
          entries: [
            if ((data['total_water_taken'] ?? 0) > 0)
              WaterIntakeEntry(
                id: 'today-total',
                amount: (data['total_water_taken'] ?? 0).toDouble(),
                timestamp: DateTime.now(),
                note: '',
              )
          ],
        );

        // Update stats from API response
        _currentStreak = data['streak'] ?? 0;
        _weeklyAverage = (data['weekly_avg'] ?? 0).toDouble();
        _weeklyCompletionRate = ((data['weekly_completion_rate'] ?? 0) * 100).toDouble();

        // Regenerate slots if goal changed
        if (_dailySlots.isEmpty || _todayIntake.goalAmount != (await _getStoredGoal())) {
          _generateDailySlots();
        }

        await _cacheData();
        _error = null;
        notifyListeners();

        developer.log('✅ Fetched today\'s water intake: ${_todayIntake.totalAmount}ml', name: 'WaterIntakeProvider');
      } else if (response.statusCode == 404) {
        // No data for today - this is normal for new users
        _todayIntake = WaterIntake(
          date: DateTime.now(),
          totalAmount: 0,
          goalAmount: await _getStoredGoal(),
          entries: [],
        );

        // Set default dashboard data
        _dashboardData = {
          'date': DateTime.now().toIso8601String().split('T')[0],
          'total_water_taken': 0,
          'target_water_ml': _todayIntake.goalAmount,
          'streak': 0,
          'weekly_avg': 0,
          'weekly_completion_rate': 0,
        };

        _currentStreak = 0;
        _weeklyAverage = 0.0;
        _weeklyCompletionRate = 0.0;

        _generateDailySlots();
        await _cacheData();
        _error = null;
        notifyListeners();

        developer.log('ℹ️ No water intake data for today (404)', name: 'WaterIntakeProvider');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        throw Exception('Server error (${response.statusCode}). Please try again later.');
      }
    } catch (e) {
      developer.log('❌ Error fetching today\'s water intake: $e', name: 'WaterIntakeProvider');

      if (e.toString().contains('TimeoutException') || e.toString().contains('SocketException')) {
        _error = 'Network connection error. Please check your internet connection.';
      } else {
        _error = e.toString();
      }
      notifyListeners();
    }
  }

  // Fetch monthly data using the API
  Future<void> fetchMonthlyData() async {
    try {
      developer.log('🔄 Fetching monthly water data', name: 'WaterIntakeProvider');

      final accessToken = await TokenManager.getAccessToken();
      if (accessToken == null) {
        developer.log('⚠️ No access token for monthly data', name: 'WaterIntakeProvider');
        return;
      }

      final now = DateTime.now();
      final monthlyUrl = '$_baseUrl/client/health/water-monthly/${now.year}/${now.month}';

      developer.log('📡 Making API request to: $monthlyUrl', name: 'WaterIntakeProvider');

      final response = await http.get(
        Uri.parse(monthlyUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log('📡 Monthly API Response Status: ${response.statusCode}', name: 'WaterIntakeProvider');
      developer.log('📡 Monthly API Response Body: ${response.body}', name: 'WaterIntakeProvider');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse monthly data according to the provided API format
        _monthlyAverage = (data['monthly_avg'] ?? 0).toDouble();
        _mostHydratedDay = data['most_hydrated_day'] ?? '';
        _leastHydratedDay = data['least_hydrated_day'] ?? '';
        _missedDays = data['missed_days'] ?? 0;

        // Convert daily intake to monthly data
        final dailyIntake = data['daily_intake'] as List? ?? [];
        _monthlyData = dailyIntake.map((item) {
          return WaterIntake(
            date: DateTime.parse(item['date']),
            totalAmount: (item['water_ml'] ?? 0).toDouble(),
            goalAmount: _todayIntake.goalAmount,
            entries: [
              if ((item['water_ml'] ?? 0) > 0)
                WaterIntakeEntry(
                  id: 'day-${item['date']}',
                  amount: (item['water_ml'] ?? 0).toDouble(),
                  timestamp: DateTime.parse(item['date']),
                  note: '',
                )
            ],
          );
        }).toList();

        await _cacheData();
        notifyListeners();

        developer.log('✅ Fetched monthly water intake data: ${_monthlyData.length} days', name: 'WaterIntakeProvider');
      } else if (response.statusCode == 404) {
        // No monthly data available
        _monthlyAverage = 0.0;
        _mostHydratedDay = '';
        _leastHydratedDay = '';
        _missedDays = 0;
        _monthlyData = [];

        developer.log('ℹ️ No monthly data available (404)', name: 'WaterIntakeProvider');
      } else {
        developer.log('⚠️ Failed to fetch monthly data: ${response.statusCode}', name: 'WaterIntakeProvider');
      }
    } catch (e) {
      developer.log('❌ Error fetching monthly data: $e', name: 'WaterIntakeProvider');
    }
  }

  // Add water intake
  Future<bool> addWaterIntake(double amount, {String? slot}) async {
    if (amount <= 0) {
      throw Exception('Please enter a valid amount');
    }

    try {
      _isSubmitting = true;
      notifyListeners();

      developer.log('🔄 Adding water intake: ${amount}ml for slot: $slot', name: 'WaterIntakeProvider');

      final accessToken = await TokenManager.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available. Please log in again.');
      }

      // Optimistically update UI
      final newEntry = WaterIntakeEntry(
        amount: amount,
        timestamp: DateTime.now(),
        note: slot ?? '',
      );

      final oldTotalAmount = _todayIntake.totalAmount;
      final oldEntries = List<WaterIntakeEntry>.from(_todayIntake.entries);

      _todayIntake = _todayIntake.copyWith(
        totalAmount: _todayIntake.totalAmount + amount,
        entries: [..._todayIntake.entries, newEntry],
      );

      // Update dashboard data
      _dashboardData['total_water_taken'] = _todayIntake.totalAmount;

      // Mark slot as completed if provided
      if (slot != null && _dailySlots.contains(slot)) {
        await markSlotCompleted(slot);
      }

      notifyListeners();
      await _cacheData();

      developer.log('📡 Making API request to add water intake', name: 'WaterIntakeProvider');

      // Send to server
      final response = await http.post(
        Uri.parse('$_baseUrl/client/health/water-intake'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount_ml': amount,
          'timestamp': DateTime.now().toIso8601String(),
          'note': slot ?? '',
        }),
      ).timeout(const Duration(seconds: 30));

      developer.log('📡 Add water intake response: ${response.statusCode}', name: 'WaterIntakeProvider');

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Revert optimistic update on failure
        _todayIntake = _todayIntake.copyWith(
          totalAmount: oldTotalAmount,
          entries: oldEntries,
        );

        _dashboardData['total_water_taken'] = oldTotalAmount;

        if (slot != null) {
          _completedSlots[slot] = false;
          await _saveSlotProgress();
        }

        notifyListeners();
        await _cacheData();

        if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please log in again.');
        } else {
          throw Exception('Failed to save water intake. Please try again.');
        }
      }

      // Refresh data after successful addition
      await fetchTodayIntake();

      developer.log('✅ Added water intake: ${amount}ml', name: 'WaterIntakeProvider');
      return true;
    } catch (e) {
      developer.log('❌ Error adding water intake: $e', name: 'WaterIntakeProvider');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Update daily goal
  Future<void> updateGoal(double newGoal) async {
    if (newGoal <= 0) {
      throw Exception('Please enter a valid goal amount');
    }

    try {
      developer.log('🔄 Updating daily goal: ${newGoal}ml', name: 'WaterIntakeProvider');

      final accessToken = await TokenManager.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available. Please log in again.');
      }

      // Optimistically update UI
      final oldGoal = _todayIntake.goalAmount;
      _todayIntake = _todayIntake.copyWith(goalAmount: newGoal);

      // Update dashboard data
      _dashboardData['target_water_ml'] = newGoal;

      // Regenerate slots for new goal
      _generateDailySlots();
      notifyListeners();
      await _cacheData();

      // Send to server
      final response = await http.put(
        Uri.parse('$_baseUrl/client/health/water-goal'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'goal_amount_ml': newGoal,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        // Revert on failure
        _todayIntake = _todayIntake.copyWith(goalAmount: oldGoal);
        _dashboardData['target_water_ml'] = oldGoal;
        _generateDailySlots();
        notifyListeners();
        await _cacheData();

        if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please log in again.');
        } else {
          throw Exception('Failed to update goal. Please try again.');
        }
      }

      // Store goal locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('water_intake_goal', newGoal);

      developer.log('✅ Updated daily goal: ${newGoal}ml', name: 'WaterIntakeProvider');
    } catch (e) {
      developer.log('❌ Error updating daily goal: $e', name: 'WaterIntakeProvider');
      rethrow;
    }
  }

  // Get stored goal
  Future<double> _getStoredGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble('water_intake_goal') ?? 2000.0;
    } catch (e) {
      return 2000.0;
    }
  }

  // Get weekly data for backward compatibility
  List<DailyWaterIntake> getWeeklyData() {
    return _weeklyData.map((waterIntake) => DailyWaterIntake(
      date: waterIntake.date,
      intakes: waterIntake.entries,
      goalAmount: waterIntake.goalAmount,
    )).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        fetchTodayIntake(),
        fetchMonthlyData(),
      ]);
    } catch (e) {
      developer.log('❌ Error refreshing data: $e', name: 'WaterIntakeProvider');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _drawerTimer?.cancel();
    super.dispose();
  }
}

// Helper classes for backward compatibility
class DailyWaterIntake {
  final DateTime date;
  final List<WaterIntakeEntry> intakes;
  final double goalAmount;

  DailyWaterIntake({
    required this.date,
    required this.intakes,
    required this.goalAmount,
  });
}
