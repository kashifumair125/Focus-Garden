import 'dart:math';

/// Service to provide motivational quotes
class QuotesService {
  static final QuotesService _instance = QuotesService._();
  static QuotesService get instance => _instance;

  QuotesService._();

  final List<Map<String, String>> _quotes = [
    {
      'text': 'Focus is the art of knowing what to ignore.',
      'author': 'James Clear',
    },
    {
      'text': 'The successful warrior is the average person, with laser-like focus.',
      'author': 'Bruce Lee',
    },
    {
      'text': 'Concentrate all your thoughts upon the work at hand. The sun\'s rays do not burn until brought to a focus.',
      'author': 'Alexander Graham Bell',
    },
    {
      'text': 'Where focus goes, energy flows.',
      'author': 'Tony Robbins',
    },
    {
      'text': 'It is during our darkest moments that we must focus to see the light.',
      'author': 'Aristotle',
    },
    {
      'text': 'The key to success is to focus our conscious mind on things we desire not things we fear.',
      'author': 'Brian Tracy',
    },
    {
      'text': 'Lack of direction, not lack of time, is the problem. We all have twenty-four hour days.',
      'author': 'Zig Ziglar',
    },
    {
      'text': 'You can\'t depend on your eyes when your imagination is out of focus.',
      'author': 'Mark Twain',
    },
    {
      'text': 'One reason so few of us achieve what we truly want is that we never direct our focus.',
      'author': 'Tony Robbins',
    },
    {
      'text': 'Your life is controlled by what you focus on.',
      'author': 'Tony Robbins',
    },
    {
      'text': 'Energy flows where attention goes.',
      'author': 'Michael Beckwith',
    },
    {
      'text': 'Starve your distractions. Feed your focus.',
      'author': 'Unknown',
    },
    {
      'text': 'The difference between successful people and others is how long they spend time feeling sorry for themselves.',
      'author': 'Barbara Corcoran',
    },
    {
      'text': 'It\'s not about having time. It\'s about making time.',
      'author': 'Unknown',
    },
    {
      'text': 'Focus on being productive instead of busy.',
      'author': 'Tim Ferriss',
    },
    {
      'text': 'The secret of change is to focus all of your energy not on fighting the old, but on building the new.',
      'author': 'Socrates',
    },
    {
      'text': 'What you stay focused on will grow.',
      'author': 'Roy T. Bennett',
    },
    {
      'text': 'The most important thing is to be able to think and focus on one thing at a time.',
      'author': 'Warren Buffett',
    },
    {
      'text': 'Deep work is the ability to focus without distraction on a cognitively demanding task.',
      'author': 'Cal Newport',
    },
    {
      'text': 'Your mind is for having ideas, not holding them.',
      'author': 'David Allen',
    },
    {
      'text': 'Discipline is choosing between what you want now and what you want most.',
      'author': 'Abraham Lincoln',
    },
    {
      'text': 'Success is the product of daily habits—not once-in-a-lifetime transformations.',
      'author': 'James Clear',
    },
    {
      'text': 'You don\'t have to be great to start, but you have to start to be great.',
      'author': 'Zig Ziglar',
    },
    {
      'text': 'Small daily improvements over time lead to stunning results.',
      'author': 'Robin Sharma',
    },
    {
      'text': 'The journey of a thousand miles begins with a single step.',
      'author': 'Lao Tzu',
    },
    {
      'text': 'Don\'t watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson',
    },
    {
      'text': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'text': 'Believe you can and you\'re halfway there.',
      'author': 'Theodore Roosevelt',
    },
    {
      'text': 'The future depends on what you do today.',
      'author': 'Mahatma Gandhi',
    },
    {
      'text': 'Excellence is not a destination; it is a continuous journey that never ends.',
      'author': 'Brian Tracy',
    },
  ];

  /// Get a random motivational quote
  Map<String, String> getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  /// Get quote based on time of day
  Map<String, String> getTimeBasedQuote() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      // Morning quotes - focus on starting strong
      final morningQuotes = _quotes.where((q) =>
        q['text']!.toLowerCase().contains('start') ||
        q['text']!.toLowerCase().contains('begin') ||
        q['text']!.toLowerCase().contains('journey')
      ).toList();

      if (morningQuotes.isNotEmpty) {
        return morningQuotes[Random().nextInt(morningQuotes.length)];
      }
    } else if (hour < 18) {
      // Afternoon quotes - focus on persistence
      final afternoonQuotes = _quotes.where((q) =>
        q['text']!.toLowerCase().contains('keep') ||
        q['text']!.toLowerCase().contains('continue') ||
        q['text']!.toLowerCase().contains('persist')
      ).toList();

      if (afternoonQuotes.isNotEmpty) {
        return afternoonQuotes[Random().nextInt(afternoonQuotes.length)];
      }
    }

    // Evening or fallback - any quote
    return getRandomQuote();
  }

  /// Get quote based on user's progress/situation
  Map<String, String> getContextualQuote({
    required int currentStreak,
    required int totalSessions,
    bool justCompletedSession = false,
  }) {
    if (justCompletedSession) {
      // Celebration quotes
      return {
        'text': 'Great job! Another step towards mastery.',
        'author': 'Focus Garden',
      };
    }

    if (currentStreak >= 7) {
      // High streak - encouragement to maintain
      return {
        'text': 'Consistency is the key to excellence. Keep your streak alive!',
        'author': 'Focus Garden',
      };
    }

    if (totalSessions == 0) {
      // First time user
      return {
        'text': 'The journey of a thousand miles begins with a single step.',
        'author': 'Lao Tzu',
      };
    }

    if (currentStreak == 0 && totalSessions > 5) {
      // Lost streak - motivation to restart
      return {
        'text': 'Fall seven times, stand up eight. Start your new streak today!',
        'author': 'Japanese Proverb',
      };
    }

    // Default to random
    return getRandomQuote();
  }

  /// Get all quotes (for browsing)
  List<Map<String, String>> getAllQuotes() {
    return List.unmodifiable(_quotes);
  }
}
