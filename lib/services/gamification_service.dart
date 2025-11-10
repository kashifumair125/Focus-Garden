import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'storage_service.dart';

/// Model for user level and XP
class UserLevel {
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final String title;

  UserLevel({
    required this.level,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.title,
  });

  double get progress => currentXP / xpToNextLevel;

  // Calculate XP needed for a given level
  static int xpForLevel(int level) {
    // Exponential growth: base XP * level^1.5
    return (100 * (level * level * level / 100)).round();
  }

  // Get title based on level
  static String titleForLevel(int level) {
    if (level < 5) return 'Seedling';
    if (level < 10) return 'Sprout';
    if (level < 20) return 'Young Plant';
    if (level < 35) return 'Blooming Flower';
    if (level < 50) return 'Mature Tree';
    if (level < 75) return 'Ancient Oak';
    if (level < 100) return 'Forest Guardian';
    return 'Legendary Gardener';
  }
}

/// Service to handle gamification features (XP, levels, challenges)
class GamificationService extends Notifier<UserLevel> {
  StorageService get _storageService => ref.read(storageServiceProvider);

  @override
  UserLevel build() {
    return _loadCurrentLevel();
  }

  UserLevel _loadCurrentLevel() {
    final box = Hive.box('settings');
    final totalXP = box.get('totalXP', defaultValue: 0) as int;

    // Calculate level from total XP
    int level = 1;
    int xpForCurrentLevel = 0;

    while (xpForCurrentLevel + UserLevel.xpForLevel(level) <= totalXP) {
      xpForCurrentLevel += UserLevel.xpForLevel(level);
      level++;
    }

    final currentXP = totalXP - xpForCurrentLevel;
    final xpToNextLevel = UserLevel.xpForLevel(level);

    return UserLevel(
      level: level,
      currentXP: currentXP,
      xpToNextLevel: xpToNextLevel,
      title: UserLevel.titleForLevel(level),
    );
  }

  /// Award XP for completing a focus session
  Future<bool> awardXP(int minutes) async {
    final box = Hive.box('settings');

    // XP formula: base 10 XP per minute, with bonus for longer sessions
    int xpEarned = minutes * 10;

    // Bonus XP for longer sessions
    if (minutes >= 60) {
      xpEarned = (xpEarned * 1.5).round(); // 50% bonus for 1+ hour
    } else if (minutes >= 45) {
      xpEarned = (xpEarned * 1.3).round(); // 30% bonus for 45+ min
    } else if (minutes >= 25) {
      xpEarned = (xpEarned * 1.2).round(); // 20% bonus for 25+ min
    }

    final totalXP = box.get('totalXP', defaultValue: 0) as int;
    final newTotalXP = totalXP + xpEarned;
    await box.put('totalXP', newTotalXP);

    // Calculate new level
    final oldLevel = state.level;
    int level = 1;
    int xpForCurrentLevel = 0;

    while (xpForCurrentLevel + UserLevel.xpForLevel(level) <= newTotalXP) {
      xpForCurrentLevel += UserLevel.xpForLevel(level);
      level++;
    }

    final currentXP = newTotalXP - xpForCurrentLevel;
    final xpToNextLevel = UserLevel.xpForLevel(level);

    state = UserLevel(
      level: level,
      currentXP: currentXP,
      xpToNextLevel: xpToNextLevel,
      title: UserLevel.titleForLevel(level),
    );

    // Return true if leveled up
    return level > oldLevel;
  }

  /// Get total XP
  int getTotalXP() {
    final box = Hive.box('settings');
    return box.get('totalXP', defaultValue: 0) as int;
  }
}

/// Model for daily challenge
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int targetMinutes;
  final int targetSessions;
  final int xpReward;
  final DateTime date;
  bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetMinutes,
    required this.targetSessions,
    required this.xpReward,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'targetMinutes': targetMinutes,
    'targetSessions': targetSessions,
    'xpReward': xpReward,
    'date': date.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) => DailyChallenge(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    targetMinutes: json['targetMinutes'],
    targetSessions: json['targetSessions'],
    xpReward: json['xpReward'],
    date: DateTime.parse(json['date']),
    isCompleted: json['isCompleted'] ?? false,
  );
}

/// Service to manage daily challenges
class DailyChallengeService {
  final StorageService _storageService;

  DailyChallengeService(this._storageService);

  /// Get today's challenge (create if doesn't exist)
  DailyChallenge getTodaysChallenge() {
    final box = Hive.box('settings');
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final savedChallengeJson = box.get('dailyChallenge_$todayKey');

    if (savedChallengeJson != null) {
      return DailyChallenge.fromJson(Map<String, dynamic>.from(savedChallengeJson));
    }

    // Generate new challenge for today
    final challenge = _generateDailyChallenge(today);
    box.put('dailyChallenge_$todayKey', challenge.toJson());
    return challenge;
  }

  /// Generate a random daily challenge
  DailyChallenge _generateDailyChallenge(DateTime date) {
    final challenges = [
      {
        'title': 'Sprint Focus',
        'description': 'Complete 3 focus sessions today',
        'targetSessions': 3,
        'targetMinutes': 0,
        'xpReward': 150,
      },
      {
        'title': 'Deep Work',
        'description': 'Focus for 60 minutes total today',
        'targetSessions': 0,
        'targetMinutes': 60,
        'xpReward': 200,
      },
      {
        'title': 'Marathon Mind',
        'description': 'Complete a 45-minute focus session',
        'targetSessions': 1,
        'targetMinutes': 45,
        'xpReward': 180,
      },
      {
        'title': 'Consistency Champion',
        'description': 'Complete 5 focus sessions today',
        'targetSessions': 5,
        'targetMinutes': 0,
        'xpReward': 250,
      },
      {
        'title': 'Power Hour',
        'description': 'Focus for 90 minutes total today',
        'targetSessions': 0,
        'targetMinutes': 90,
        'xpReward': 300,
      },
    ];

    // Use day of year to get deterministic "random" challenge
    final index = date.day % challenges.length;
    final template = challenges[index];

    return DailyChallenge(
      id: 'daily_${date.year}_${date.month}_${date.day}',
      title: template['title'] as String,
      description: template['description'] as String,
      targetMinutes: template['targetMinutes'] as int,
      targetSessions: template['targetSessions'] as int,
      xpReward: template['xpReward'] as int,
      date: date,
    );
  }

  /// Check if today's challenge is complete
  bool checkChallengeProgress() {
    final challenge = getTodaysChallenge();
    if (challenge.isCompleted) return true;

    final todaySessions = _storageService.getTodaySessions();
    final completedSessions = todaySessions.where((s) => s.completed).toList();

    final totalMinutes = completedSessions.fold<int>(
      0, (sum, session) => sum + session.actualMinutes
    );

    bool meetsSessionTarget = challenge.targetSessions == 0 ||
                               completedSessions.length >= challenge.targetSessions;
    bool meetsMinutesTarget = challenge.targetMinutes == 0 ||
                               totalMinutes >= challenge.targetMinutes;

    final isComplete = meetsSessionTarget && meetsMinutesTarget;

    if (isComplete && !challenge.isCompleted) {
      _markChallengeComplete(challenge);
    }

    return isComplete;
  }

  /// Mark challenge as complete and award XP
  void _markChallengeComplete(DailyChallenge challenge) {
    final box = Hive.box('settings');
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    challenge.isCompleted = true;
    box.put('dailyChallenge_$todayKey', challenge.toJson());

    // Award bonus XP (handled separately)
  }

  /// Get progress towards today's challenge
  Map<String, dynamic> getChallengeProgress() {
    final challenge = getTodaysChallenge();
    final todaySessions = _storageService.getTodaySessions();
    final completedSessions = todaySessions.where((s) => s.completed).toList();

    final totalMinutes = completedSessions.fold<int>(
      0, (sum, session) => sum + session.actualMinutes
    );

    return {
      'challenge': challenge,
      'currentSessions': completedSessions.length,
      'currentMinutes': totalMinutes,
      'sessionProgress': challenge.targetSessions > 0
          ? (completedSessions.length / challenge.targetSessions).clamp(0.0, 1.0)
          : 1.0,
      'minuteProgress': challenge.targetMinutes > 0
          ? (totalMinutes / challenge.targetMinutes).clamp(0.0, 1.0)
          : 1.0,
    };
  }
}

/// Providers
final gamificationServiceProvider = NotifierProvider<GamificationService, UserLevel>(GamificationService.new);

final dailyChallengeServiceProvider = Provider<DailyChallengeService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DailyChallengeService(storage);
});

final todaysChallengeProvider = Provider<DailyChallenge>((ref) {
  final service = ref.watch(dailyChallengeServiceProvider);
  return service.getTodaysChallenge();
});

final challengeProgressProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(dailyChallengeServiceProvider);
  // Watch storage to trigger updates
  ref.watch(statsProvider);
  return service.getChallengeProgress();
});
