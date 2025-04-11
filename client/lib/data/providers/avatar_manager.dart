import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_svg/flutter_svg.dart';

// A singleton service to manage avatar across the app
class AvatarManager {
  static final AvatarManager _instance = AvatarManager._internal();
  
  factory AvatarManager() {
    return _instance;
  }
  
  AvatarManager._internal();
  
  // Stream controller to notify listeners when avatar changes
  final ValueNotifier<Map<String, dynamic>?> avatarData = ValueNotifier(null);
  
  // Initialize the avatar manager
  Future<void> initialize() async {
    await loadSavedAvatar();
  }
  
  // Load saved avatar information
  Future<void> loadSavedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('user_avatar_data');
    
    if (savedData != null) {
      final data = jsonDecode(savedData);
      avatarData.value = data;
    }
  }
  
  // Get avatar widget based on saved data
  Widget getAvatarWidget({
    double? size,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    final data = avatarData.value;
    final double avatarSize = size ?? 60.0;
    
    if (data == null) {
      // Return default avatar if no saved data
      return CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, size: avatarSize * 0.6, color: Colors.grey[600]),
      );
    }
    
    if (data['type'] == 'local_image') {
      final imagePath = data['path'];
      final file = File(imagePath);
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: Image.file(
          file,
          width: avatarSize,
          height: avatarSize,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => placeholder ?? Icon(Icons.error),
        ),
      );
    } else if (data['type'] == 'predefined_avatar') {
      final index = data['index'];
      final avatarUrl = 'https://api.dicebear.com/9.x/identicon/svg?seed=User${index + 1}';
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: SvgPicture.network(
          avatarUrl,
          width: avatarSize,
          height: avatarSize,
          fit: fit,
          placeholderBuilder: (context) => placeholder ?? CircularProgressIndicator(),
        ),
      );
    }
    
    // Fallback default avatar
    return CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: avatarSize * 0.6, color: Colors.grey[600]),
    );
  }
  
  // Get avatar file path (if it's a local image)
  Future<String?> getAvatarFilePath() async {
    final data = avatarData.value;
    
    if (data != null && data['type'] == 'local_image') {
      return data['path'];
    }
    
    return null;
  }
  
  // Get avatar URL (if it's a predefined avatar)
  String? getAvatarUrl() {
    final data = avatarData.value;
    
    if (data != null && data['type'] == 'predefined_avatar') {
      final index = data['index'];
      return 'https://api.dicebear.com/9.x/identicon/svg?seed=User${index + 1}';
    }
    
    return null;
  }
  
  // Clear saved avatar
  Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_avatar_data');
    avatarData.value = null;
  }
}