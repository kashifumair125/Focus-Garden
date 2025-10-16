import 'package:hive/hive.dart';

// This annotation generates a Hive adapter for local storage
// Run: flutter packages pub run build_runner build
part 'focus_session.g.dart';

@HiveType(typeId: 0)
class FocusSession extends HiveObject {
  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final DateTime endTime;

  @HiveField(2)
  final int durationMinutes; // Planned duration

  @HiveField(3)
  final int actualMinutes; // Actual completed time

  @HiveField(4)
  final bool completed; // Did user complete the full session?

  @HiveField(5)
  final String? plantUnlocked; // What plant was unlocked (if any)

  FocusSession({
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.actualMinutes,
    required this.completed,
    this.plantUnlocked,
  });

  // Helper methods for easy data access

  /// Get the duration of this session as a formatted string
  String get formattedDuration {
    final hours = actualMinutes ~/ 60;
    final minutes = actualMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Check if this session was completed today
  bool get wasCompletedToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    if (durationMinutes == 0) return 0.0;
    return (actualMinutes / durationMinutes).clamp(0.0, 1.0);
  }
}
