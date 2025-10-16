import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/focus_session.dart';
import '../models/plant.dart';

/// Service for handling all local storage operations
class StorageService {
  // Hive boxes
  static const String _sessionsBoxName = 'sessions';
  static const String _plantsBoxName = 'plants';
  static const String _statsBoxName = 'stats';
  static const String _settingsBoxName = 'settings';

  // Box references
  Box<FocusSession> get _sessionsBox =>
      Hive.box<FocusSession>(_sessionsBoxName);
  Box<Plant> get _plantsBox => Hive.box<Plant>(_plantsBoxName);
  Box get _statsBox => Hive.box(_statsBoxName);
  Box get _settingsBox => Hive.box(_settingsBoxName);

  // === FOCUS SESSIONS ===

  /// Save a completed focus session
  Future<void> saveFocusSession(FocusSession session) async {
    await _sessionsBox.add(session);
    await _updateStats();
  }

  /// Get all focus sessions
  List<FocusSession> getAllSessions() {
    return _sessionsBox.values.toList();
  }

  /// Get sessions from today
  List<FocusSession> getTodaySessions() {
    final now = DateTime.now();
    return _sessionsBox.values
        .where((session) =>
            session.startTime.year == now.year &&
            session.startTime.month == now.month &&
            session.startTime.day == now.day)
        .toList();
  }

  /// Get sessions from the last N days
  List<FocusSession> getRecentSessions(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _sessionsBox.values
        .where((session) => session.startTime.isAfter(cutoff))
        .toList();
  }

  // === PLANTS (REWARDS) ===

  /// Save an unlocked plant
  Future<void> savePlant(Plant plant) async {
    await _plantsBox.put(plant.id, plant);
  }

  /// Get all unlocked plants
  List<Plant> getUnlockedPlants() {
    return _plantsBox.values.toList();
  }

  /// Check if a specific plant is unlocked
  bool isPlantUnlocked(String plantId) {
    return _plantsBox.containsKey(plantId);
  }

  /// Get plant by ID
  Plant? getPlant(String plantId) {
    return _plantsBox.get(plantId);
  }

  // === STATS ===

  /// Update overall statistics (called automatically after saving sessions)
  Future<void> _updateStats() async {
    final allSessions = getAllSessions();

    // Calculate total focus time in minutes
    final totalMinutes = allSessions
        .where((session) => session.completed)
        .fold<int>(0, (sum, session) => sum + session.actualMinutes);

    // Count completed sessions
    final completedSessions =
        allSessions.where((session) => session.completed).length;

    // Calculate current streak
    final currentStreak = _calculateCurrentStreak();

    // Calculate longest streak
    final longestStreak = _calculateLongestStreak();

    // Save stats
    await _statsBox.put('totalMinutes', totalMinutes);
    await _statsBox.put('completedSessions', completedSessions);
    await _statsBox.put('currentStreak', currentStreak);
    await _statsBox.put('longestStreak', longestStreak);
    await _statsBox.put('lastUpdated', DateTime.now().toIso8601String());
  }

  /// Calculate current streak of consecutive days with completed sessions
  int _calculateCurrentStreak() {
    final allSessions =
        getAllSessions().where((session) => session.completed).toList();

    if (allSessions.isEmpty) return 0;

    // Sort by date (newest first)
    allSessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    // Group sessions by day
    final Map<String, List<FocusSession>> sessionsByDay = {};
    for (final session in allSessions) {
      final dayKey =
          '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
      sessionsByDay[dayKey] = sessionsByDay[dayKey] ?? [];
      sessionsByDay[dayKey]!.add(session);
    }

    final sortedDays = sessionsByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final dayKey in sortedDays) {
      final parts = dayKey.split('-');
      final dayDate = DateTime(
        int.parse(parts[0]), // year
        int.parse(parts[1]), // month
        int.parse(parts[2]), // day
      );

      // Check if this day is consecutive
      final daysDifference = currentDate.difference(dayDate).inDays;

      if (daysDifference == streak) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate the longest streak ever achieved
  int _calculateLongestStreak() {
    // This is a simplified version - you might want to implement a more sophisticated algorithm
    final currentLongest =
        _statsBox.get('longestStreak', defaultValue: 0) as int;
    final current = _calculateCurrentStreak();
    return currentLongest > current ? currentLongest : current;
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    return {
      'totalMinutes': _statsBox.get('totalMinutes', defaultValue: 0),
      'completedSessions': _statsBox.get('completedSessions', defaultValue: 0),
      'currentStreak': _statsBox.get('currentStreak', defaultValue: 0),
      'longestStreak': _statsBox.get('longestStreak', defaultValue: 0),
      'lastUpdated': _statsBox.get('lastUpdated'),
    };
  }

  /// Get total focus hours as a formatted string
  String get totalFocusHours {
    final totalMinutes = _statsBox.get('totalMinutes', defaultValue: 0) as int;
    final hours = totalMinutes / 60;
    return hours.toStringAsFixed(1);
  }

  /// Get total completed sessions count
  int get completedSessionsCount {
    return _statsBox.get('completedSessions', defaultValue: 0) as int;
  }

  /// Get current streak
  int get currentStreak {
    return _statsBox.get('currentStreak', defaultValue: 0) as int;
  }

  // === SETTINGS ===

  /// Save user preference
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get user preference
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Get default timer duration (in minutes)
  int get defaultTimerDuration {
    return getSetting('defaultTimerDuration', defaultValue: 25) ?? 25;
  }

  /// Set default timer duration
  Future<void> setDefaultTimerDuration(int minutes) async {
    await saveSetting('defaultTimerDuration', minutes);
  }

  // === UTILITY METHODS ===

  /// Clear all data (useful for testing or reset functionality)
  Future<void> clearAllData() async {
    await _sessionsBox.clear();
    await _plantsBox.clear();
    await _statsBox.clear();
    // Don't clear settings by default
  }

  /// Get app statistics for debugging
  Map<String, dynamic> getDebugInfo() {
    return {
      'totalSessions': _sessionsBox.length,
      'unlockedPlants': _plantsBox.length,
      'settings': _settingsBox.toMap(),
      'stats': getStats(),
    };
  }
}

/// Provider for storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider for statistics (reactive)
final statsProvider = Provider<Map<String, dynamic>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getStats();
});

/// Provider for unlocked plants (reactive)
final unlockedPlantsProvider = Provider<List<Plant>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getUnlockedPlants();
});
