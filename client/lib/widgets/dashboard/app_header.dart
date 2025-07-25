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

  @override
  void initState() {
    super.initState();
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
        throw Exception('Access token not found');
      }

      final response = await http.get(
        Uri.parse('https://test-prod-f427.onrender.com/api/profiles'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final score = data['health_score'] ?? 0;
        
        if (mounted) {
          setState(() {
            _healthScore = score;
          });
        }
      } else {
        throw Exception('Failed to fetch health score: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching health score: $e');
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

          Container(
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
}