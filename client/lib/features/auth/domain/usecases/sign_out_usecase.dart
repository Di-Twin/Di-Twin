import 'package:client/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Map<String, dynamic>> execute() async {
    // First clear all manual entry data from cache
    await _clearManualEntryData();
    
    // Then proceed with regular sign out
    return repository.signOut();
  }
  
  Future<void> _clearManualEntryData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all manual health data
      await prefs.remove('manual_steps');
      await prefs.remove('manual_heart_rate');
      await prefs.remove('manual_calories');
      await prefs.remove('manual_sleep_hours');
      await prefs.remove('manual_entry_last_updated');
      await prefs.remove('using_manual_entry');
      
      // Clear watch connection status
      await prefs.remove('watch_connected');
      await prefs.remove('watch_type');
    } catch (e) {
      // Just log the error but don't interrupt sign out process
      print('Error clearing manual entry data: $e');
    }
  }
}
