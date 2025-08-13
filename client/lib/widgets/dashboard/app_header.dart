import 'package:client/features/activity_management/presentation/pages/activity_calories_tracker_page.dart';
import 'package:client/features/activity_management/presentation/pages/activity_stats_page.dart';
import 'package:client/features/activity_management/presentation/pages/activity_steps_page.dart';
import 'package:client/features/activity_management/presentation/pages/activity_today_page.dart';
import 'package:client/features/activity_management/presentation/pages/my_activities_page.dart';
import 'package:client/features/food_management/presentation/pages/food_intelligence_page.dart';
import 'package:client/features/food_management/presentation/pages/nutrition_tracking_screen.dart';
import 'package:client/features/health_stats/smart_health_analysis.dart';
import 'package:client/features/water_intake/presentation/pages/water_intake_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/data/providers/user_profile_provider.dart';
import 'package:client/data/API/user_profile_data.dart';
import 'package:client/data/API/health_score_data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class AppHeader extends StatefulWidget {
  final int? healthScore;
  const AppHeader({
    super.key,
    this.healthScore,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  final UserProvider _userProvider = UserProvider();
  final HealthScoreService _healthScoreService = HealthScoreService();
  UserData? _userData;
  String? _cachedAvatarUrl;
  File? _cachedAvatarFile;
  bool _isCustomAvatar = false;
  int? _healthScore;
  bool _isLoading = true;
  String _errorMessage = '';

  // Add these variables at the top of _AppHeaderState class
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _searchModules = [
  {
    'title': 'Food Intelligence',
    'subtitle': 'Track your nutrition and meals',
    'icon': Icons.restaurant,
    'color': const Color(0xFF10B981),
    'route': '/food-intelligence',
    'pageBuilder': () => const FoodIntelligencePage(),
  },
  {
    'title': 'Activity - Calories Tracker',
    'subtitle': 'Monitor calories burned',
    'icon': Icons.local_fire_department,
    'color': const Color(0xFFEF4444),
    'route': '/activity-calories',
    'pageBuilder': () => const ActivityCaloriesTrackerPage(),
  },
  {
    'title': 'Activity - Steps Tracker',
    'subtitle': 'Track your daily steps',
    'icon': Icons.directions_walk,
    'color': const Color(0xFF3B82F6),
    'route': '/activity-steps',
    'pageBuilder': () => const ActivityStepsPage(),
  },
  {
    'title': 'Water Intake',
    'subtitle': 'Stay hydrated throughout the day',
    'icon': Icons.water_drop,
    'color': const Color(0xFF06B6D4),
    'route': '/water-intake',
    'pageBuilder': () => const WaterIntakePage(),
  },
  {
    'title': 'Nutrition Tracking',
    'subtitle': 'Detailed nutrition analysis',
    'icon': Icons.analytics,
    'color': const Color(0xFF8B5CF6),
    'route': '/nutrition-tracking',
    'pageBuilder': () => const NutritionTrackingPage(),
  },
  {
    'title': 'Activity Today',
    'subtitle': 'View today\'s activities',
    'icon': Icons.today,
    'color': const Color(0xFFF59E0B),
    'route': '/activity-today',
    'pageBuilder': () => const ActivityTodayPage(),
  },
  {
    'title': 'My Activities',
    'subtitle': 'Monthly activity overview',
    'icon': Icons.calendar_month,
    'color': const Color(0xFF84CC16),
    'route': '/my-activities',
    'pageBuilder': () => const ActivityTodayPage(),
  },
  {
    'title': 'Smart Health Analysis',
    'subtitle': 'AI-powered health insights',
    'icon': Icons.health_and_safety,
    'color': const Color(0xFFEC4899),
    'route': '/smart-health',
    'pageBuilder': () => const SmartHealthAnalysisScreen(),
  },
];

// Dynamic navigation method
void _navigateToModule(String route) {
  try {
    // Find the module configuration
    final module = _searchModules.firstWhere(
      (m) => m['route'] == route,
      orElse: () => {},
    );

    if (module.isEmpty || module['pageBuilder'] == null) {
      // _showErrorSnackBar('Module not available yet');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => module['pageBuilder'](),
      ),
    );
  } catch (e) {
    developer.log('Navigation error for route $route: $e', name: 'AppHeader');
    // _showErrorSnackBar('Failed to navigate to module');
  }
}

  List<Map<String, dynamic>> _filteredModules = [];

  @override
  void initState() {
    super.initState();
    _filteredModules = _searchModules;
    _loadCachedData();
    _fetchUserData();
    _fetchHealthScore();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if using custom image first
      final isCustomImage = prefs.getBool('isCustomImage') ?? false;

      if (isCustomImage) {
        final cachedAvatarPath = prefs.getString('uploadedImagePath');
        if (cachedAvatarPath != null && cachedAvatarPath.isNotEmpty) {
          final file = File(cachedAvatarPath);
          if (file.existsSync()) {
            if (mounted) {
              setState(() {
                _cachedAvatarFile = file;
                _isCustomAvatar = true;
              });
            }
            developer.log('Loaded cached avatar file: $cachedAvatarPath', name: 'AppHeader');
          }
        }
      } else {
        final cachedAvatarUrl = prefs.getString('selectedAvatarUrl');
        if (cachedAvatarUrl != null && cachedAvatarUrl.isNotEmpty) {
          if (mounted) {
            setState(() {
              _cachedAvatarUrl = cachedAvatarUrl;
              _isCustomAvatar = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await _userProvider.getUser();
      final prefs = await SharedPreferences.getInstance();

      if (mounted) {
        setState(() {
          _userData = response.data;
          _isLoading = false;
          _errorMessage = '';
        });

        if (_userData?.firstName != null) {
          await prefs.setString('user_first_name', _userData!.firstName);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load user data';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _fetchHealthScore() async {
    if (widget.healthScore != null) {
      debugPrint('[HealthScore] Using provided widget.healthScore: ${widget.healthScore}');
      if (mounted) {
        setState(() {
          _healthScore = widget.healthScore;
        });
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('[HealthScore] Access token not found in SharedPreferences');
      }

      debugPrint('[HealthScore] Fetching health score from backend...');
      final response = await http.get(
        Uri.parse('https://test-prod-f427.onrender.com/api/profiles'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('[HealthScore] Response status: ${response.statusCode}');
      debugPrint('[HealthScore] Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[HealthScore] Decoded JSON: $data');

        if (data.containsKey('health_score')) {
          debugPrint('[HealthScore] Found health_score key with value: ${data['health_score']}');
        } else {
          debugPrint('[HealthScore] health_score key NOT FOUND in response.');
        }

        final score = data['data']['health_score'] ?? 0;

        if (mounted) {
          setState(() {
            _healthScore = score;
          });
        }
      } else {
        throw Exception('[HealthScore] Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[HealthScore] Error fetching health score: $e');
      if (mounted) {
        setState(() {
          _healthScore = 88; // Default fallback value
        });
      }
    }
  }


  String _getFormattedDate() {
    return DateFormat('EEE, d MMM y').format(DateTime.now());
  }

  String _getPlanName() {
    if (_userData?.userPlan == null || _userData!.userPlan!.isEmpty) {
      return 'Beta Member';
    }
    return '${_userData!.userPlan![0].toUpperCase()}${_userData!.userPlan!.substring(1)} Member';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _getFormattedDate(),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildAvatarImage(),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userData?.firstName != null
                              ? 'Hi, ${_userData!.firstName}!'
                              : 'Hi, User!',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('👋🏻', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _healthScore != null
                              ? '$_healthScore%'
                              : widget.healthScore != null
                              ? '${widget.healthScore}%'
                              : '88%',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.bolt, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _isLoading ? 'Member' : _getPlanName(),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: _showSearchBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white70, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Search Di-Twin...',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_isCustomAvatar && _cachedAvatarFile != null) {
      return Image.file(
        _cachedAvatarFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 40, color: Color(0xFF1E293B));
        },
      );
    } else if (!_isCustomAvatar && _cachedAvatarUrl != null) {
      return Image.network(
        _cachedAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 40, color: Color(0xFF1E293B));
        },
      );
    } else {
      return const Icon(Icons.person, size: 40, color: Color(0xFF1E293B));
    }
  }

  void _showSearchBottomSheet() {
    _searchController.clear();
    _filteredModules = _searchModules;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        'Search Di-Twin',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setModalState(() {
                          if (value.isEmpty) {
                            _filteredModules = _searchModules;
                          } else {
                            _filteredModules = _searchModules
                                .where((module) =>
                            module['title']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                                module['subtitle']
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search modules...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Results
                Expanded(
                  child: _filteredModules.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No modules found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredModules.length,
                    itemBuilder: (context, index) {
                      final module = _filteredModules[index];
                      return _buildModuleItem(module, context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModuleItem(Map<String, dynamic> module, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _navigateToModule(module['route']);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: module['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  module['icon'],
                  color: module['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['title'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module['subtitle'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _navigateToModule(String route) {
  //   switch (route) {
  //     case '/food-intelligence':
  //       Navigator.pushNamed(context, '/food-intelligence');
  //       break;
  //     case '/activity-calories':
  //       Navigator.pushNamed(context, '/activity-calories');
  //       break;
  //     case '/activity-steps':
  //       Navigator.pushNamed(context, '/activity-steps');
  //       break;
  //     case '/water-intake':
  //       Navigator.pushNamed(context, '/water-intake');
  //       break;
  //     case '/nutrition-tracking':
  //       Navigator.pushNamed(context, '/nutrition-tracking');
  //       break;
  //     case '/activity-today':
  //       Navigator.pushNamed(context, '/activity-today');
  //       break;
  //     case '/my-activities':
  //       Navigator.pushNamed(context, '/my-activities');
  //       break;
  //     case '/smart-health':
  //       Navigator.pushNamed(context, '/smart-health');
  //       break;
  //     default:
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Module not available yet'),
  //           backgroundColor: const Color(0xFF64748B),
  //         ),
  //       );
  //   }
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
