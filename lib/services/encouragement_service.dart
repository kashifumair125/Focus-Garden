import 'dart:math';

/// Service for providing encouraging and motivational messages
class EncouragementService {
  static final EncouragementService instance = EncouragementService._();
  EncouragementService._();

  final _random = Random();

  /// Get a personalized message when starting a focus session
  String getStartMessage(String userName, {int? sessionCount}) {
    final messages = [
      "Let's do this, $userName! 🚀",
      "Time to focus, $userName! You've got this! 💪",
      "Ready to grow your garden, $userName? 🌱",
      "$userName, let's make this session count! ✨",
      "Focus mode activated, $userName! 🎯",
      "Your plants are waiting, $userName! 🌸",
      "Let's cultivate some focus, $userName! 🌿",
      "$userName, time to bloom! 🌺",
      "Another step towards greatness, $userName! 🌟",
      "Your future self will thank you, $userName! 💚",
    ];

    if (sessionCount != null && sessionCount > 0) {
      messages.addAll([
        "Session #${sessionCount + 1}, $userName! Keep it going! 🔥",
        "$userName, that's ${sessionCount + 1} sessions! Incredible! 🎉",
      ]);
    }

    return messages[_random.nextInt(messages.length)];
  }

  /// Get a message when completing a focus session
  String getCompletionMessage(String userName, int minutesCompleted,
      {int? streak}) {
    final messages = [
      "Amazing work, $userName! $minutesCompleted minutes of pure focus! ⭐",
      "$userName, you did it! $minutesCompleted minutes completed! 🎉",
      "Fantastic job, $userName! $minutesCompleted focused minutes! 💎",
      "Way to go, $userName! $minutesCompleted minutes of productivity! 🌟",
      "$userName crushed it! $minutesCompleted minutes done! 💪",
      "Beautiful focus, $userName! $minutesCompleted minutes! 🌸",
      "$userName, you're on fire! $minutesCompleted minutes! 🔥",
      "Brilliant session, $userName! $minutesCompleted minutes! ✨",
    ];

    if (streak != null && streak > 1) {
      messages.addAll([
        "$userName, $minutesCompleted minutes done! That's $streak days in a row! 🔥",
        "Incredible $userName! $minutesCompleted min & $streak day streak! 🌟",
      ]);
    }

    return messages[_random.nextInt(messages.length)];
  }

  /// Get a message when unlocking a new plant
  String getPlantUnlockMessage(String userName, String plantName,
      {String? rarity}) {
    final messages = [
      "Congratulations $userName! You unlocked $plantName! 🌱✨",
      "$userName, meet your new friend: $plantName! 🎉",
      "Your garden grows, $userName! Welcome $plantName! 🌸",
      "$userName discovered $plantName! Amazing! 🌟",
      "A new bloom, $userName! Say hello to $plantName! 🌺",
      "$userName, your dedication earned you $plantName! 💚",
    ];

    if (rarity != null) {
      messages.addAll([
        "Wow $userName! You unlocked a $rarity $plantName! 🎊",
        "$userName found a $rarity treasure: $plantName! ✨",
      ]);
    }

    return messages[_random.nextInt(messages.length)];
  }

  /// Get a message when achieving a milestone
  String getMilestoneMessage(String userName, String milestone) {
    final messages = [
      "🎉 $userName achieved: $milestone!",
      "Milestone unlocked, $userName! $milestone! 🏆",
      "$userName, you did it! $milestone achieved! 🌟",
      "Incredible, $userName! $milestone completed! ⭐",
      "Way to go, $userName! $milestone! 💎",
    ];

    return messages[_random.nextInt(messages.length)];
  }

  /// Get a message for daily streaks
  String getStreakMessage(String userName, int streakDays) {
    if (streakDays == 1) {
      return "Great start, $userName! Day 1 complete! 🌱";
    } else if (streakDays == 7) {
      return "One week streak, $userName! You're incredible! 🔥";
    } else if (streakDays == 30) {
      return "30 DAYS, $userName! You're a focus master! 👑";
    } else if (streakDays == 100) {
      return "100 DAY STREAK, $userName! Legendary! 🏆✨";
    } else if (streakDays % 10 == 0) {
      return "$streakDays day streak, $userName! Unstoppable! 🚀";
    }

    final messages = [
      "$userName, that's $streakDays days in a row! 🔥",
      "$streakDays day streak, $userName! Keep it up! ⭐",
      "Consistency is key, $userName! $streakDays days! 💪",
      "$userName's on a $streakDays day roll! Amazing! 🌟",
    ];

    return messages[_random.nextInt(messages.length)];
  }

  /// Get a motivational message when user is idle
  String getIdleMotivationMessage(String userName) {
    final messages = [
      "Ready to focus, $userName? 🌱",
      "$userName, your garden is waiting! 🌸",
      "Time to grow, $userName? 🌿",
      "Let's make today count, $userName! ✨",
      "$userName, start a session and bloom! 🌺",
      "Your focus creates beauty, $userName! 🌻",
      "Every session matters, $userName! 💚",
      "$userName, what will you accomplish today? 🎯",
    ];

    return messages[_random.nextInt(messages.length)];
  }

  /// Get a progress update message
  String getProgressMessage(String userName, int sessionsCompleted,
      double totalHours) {
    final messages = [
      "$userName: $sessionsCompleted sessions, ${totalHours.toStringAsFixed(1)} hours! 📊",
      "Stats check, $userName: $sessionsCompleted sessions completed! 💎",
      "$userName's focus journey: ${totalHours.toStringAsFixed(1)} hours! ⏰",
      "Amazing progress, $userName! $sessionsCompleted sessions! 🌟",
    ];

    return messages[_random.nextInt(messages.length)];
  }

  /// Get a themed message based on time of day
  String getTimeBasedMessage(String userName) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      final messages = [
        "Good morning, $userName! Let's make today amazing! ☀️",
        "Rise and shine, $userName! Time to focus! 🌅",
        "Morning focus, $userName! You've got this! ☕",
      ];
      return messages[_random.nextInt(messages.length)];
    } else if (hour >= 12 && hour < 17) {
      final messages = [
        "Good afternoon, $userName! Keep that momentum! 🌤️",
        "Afternoon boost, $userName! Stay focused! ⚡",
        "Midday session, $userName? Let's do it! 🎯",
      ];
      return messages[_random.nextInt(messages.length)];
    } else if (hour >= 17 && hour < 21) {
      final messages = [
        "Good evening, $userName! Finish strong! 🌆",
        "Evening focus, $userName! Make it count! 🌙",
        "Wrapping up the day, $userName? Perfect! ✨",
      ];
      return messages[_random.nextInt(messages.length)];
    } else {
      final messages = [
        "Night owl, $userName? Let's focus! 🦉",
        "Late night session, $userName! Impressive! 🌙",
        "Burning the midnight oil, $userName? 🕯️",
      ];
      return messages[_random.nextInt(messages.length)];
    }
  }

  /// Get a random fun fact about focus or plants
  String getFunFact() {
    final facts = [
      "🧠 Deep work sessions boost brain plasticity!",
      "🌱 Like plants, focus grows with consistent care!",
      "⏰ The average person loses focus every 8 seconds!",
      "🌳 Pomodoro technique was named after a tomato timer!",
      "💡 Focused work is 3x more productive than distracted work!",
      "🌸 Plants reduce stress by up to 37%!",
      "🎯 Flow state can make time feel slower!",
      "🌿 Green environments boost focus by 15%!",
      "⭐ Top performers practice deep focus daily!",
      "🌺 Your brain loves routine and rituals!",
    ];

    return facts[_random.nextInt(facts.length)];
  }

  /// Get an encouraging message when user pauses
  String getPauseMessage(String userName) {
    final messages = [
      "Taking a break, $userName? You've earned it! 🌿",
      "Rest is part of growth, $userName! 🌱",
      "$userName, come back stronger! 💪",
      "Brief pause, big impact later, $userName! ⏸️",
    ];

    return messages[_random.nextInt(messages.length)];
  }

  /// Get a message when resuming from pause
  String getResumeMessage(String userName) {
    final messages = [
      "Back at it, $userName! Let's finish strong! 💪",
      "Welcome back, $userName! You've got this! 🚀",
      "$userName returns! The garden awaits! 🌱",
      "Recharged and ready, $userName? Let's go! ⚡",
    ];

    return messages[_random.nextInt(messages.length)];
  }
}
