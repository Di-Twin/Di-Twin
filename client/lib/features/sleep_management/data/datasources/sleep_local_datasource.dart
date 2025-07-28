import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_entry_model.dart';
import 'dart:developer' as developer;

abstract class SleepLocalDataSource {
  Future<void> saveSleepEntry(SleepEntryModel sleepEntry);
  Future<SleepEntryModel?> getTodaysSleepEntry();
  Future<SleepEntryModel?> getLastNightSleepEntry();
  Future<List<SleepEntryModel>> getAllSleepEntries();
  Future<void> deleteSleepEntry(String id);
  Future<bool> hasSleepDataForDate(DateTime date);
}

class SleepLocalDataSourceImpl implements SleepLocalDataSource {
  static const String _sleepEntriesKey = 'sleep_entries';
  static const String _currentSleepKey = 'current_sleep_entry';

  @override
  Future<void> saveSleepEntry(SleepEntryModel sleepEntry) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing entries
      final entries = await getAllSleepEntries();

      // Remove existing entry with same ID if it exists
      entries.removeWhere((entry) => entry.id == sleepEntry.id);

      // Add new entry
      entries.add(sleepEntry);

      // Save back to preferences
      final entriesJson = entries.map((e) => e.toJson()).toList();
      await prefs.setString(_sleepEntriesKey, json.encode(entriesJson));

      // If this is an active sleep session, save it separately
      if (!sleepEntry.isCompleted) {
        await prefs.setString(_currentSleepKey, json.encode(sleepEntry.toJson()));
      } else {
        await prefs.remove(_currentSleepKey);
      }

      developer.log('✅ Sleep entry saved: ${sleepEntry.id}', name: 'SleepLocalDataSource');
    } catch (e) {
      developer.log('❌ Error saving sleep entry: $e', name: 'SleepLocalDataSource');
      throw Exception('Failed to save sleep entry: $e');
    }
  }

  @override
  Future<SleepEntryModel?> getTodaysSleepEntry() async {
    try {
      final today = DateTime.now();
      final entries = await getAllSleepEntries();

      // Look for today's sleep entry
      for (final entry in entries) {
        if (entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day) {
          return entry;
        }
      }

      // Check for current active sleep session
      final prefs = await SharedPreferences.getInstance();
      final currentSleepJson = prefs.getString(_currentSleepKey);
      if (currentSleepJson != null) {
        final currentSleep = SleepEntryModel.fromJson(json.decode(currentSleepJson));
        return currentSleep;
      }

      return null;
    } catch (e) {
      developer.log('❌ Error getting today\'s sleep entry: $e', name: 'SleepLocalDataSource');
      return null;
    }
  }

  @override
  Future<SleepEntryModel?> getLastNightSleepEntry() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final entries = await getAllSleepEntries();

      // Look for yesterday's completed sleep entry
      for (final entry in entries.reversed) {
        if (entry.date.year == yesterday.year &&
            entry.date.month == yesterday.month &&
            entry.date.day == yesterday.day &&
            entry.isCompleted) {
          return entry;
        }
      }

      return null;
    } catch (e) {
      developer.log('❌ Error getting last night\'s sleep entry: $e', name: 'SleepLocalDataSource');
      return null;
    }
  }

  @override
  Future<List<SleepEntryModel>> getAllSleepEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getString(_sleepEntriesKey);

      if (entriesJson == null) return [];

      final List<dynamic> entriesList = json.decode(entriesJson);
      return entriesList.map((json) => SleepEntryModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('❌ Error getting all sleep entries: $e', name: 'SleepLocalDataSource');
      return [];
    }
  }

  @override
  Future<void> deleteSleepEntry(String id) async {
    try {
      final entries = await getAllSleepEntries();
      entries.removeWhere((entry) => entry.id == id);

      final prefs = await SharedPreferences.getInstance();
      final entriesJson = entries.map((e) => e.toJson()).toList();
      await prefs.setString(_sleepEntriesKey, json.encode(entriesJson));

      // Also remove from current sleep if it matches
      final currentSleepJson = prefs.getString(_currentSleepKey);
      if (currentSleepJson != null) {
        final currentSleep = SleepEntryModel.fromJson(json.decode(currentSleepJson));
        if (currentSleep.id == id) {
          await prefs.remove(_currentSleepKey);
        }
      }

      developer.log('✅ Sleep entry deleted: $id', name: 'SleepLocalDataSource');
    } catch (e) {
      developer.log('❌ Error deleting sleep entry: $e', name: 'SleepLocalDataSource');
      throw Exception('Failed to delete sleep entry: $e');
    }
  }

  @override
  Future<bool> hasSleepDataForDate(DateTime date) async {
    try {
      final entries = await getAllSleepEntries();

      return entries.any((entry) =>
      entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day);
    } catch (e) {
      developer.log('❌ Error checking sleep data for date: $e', name: 'SleepLocalDataSource');
      return false;
    }
  }
}
