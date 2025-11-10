import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/timer_service.dart';
import '../services/storage_service.dart';
import '../services/reward_service.dart';
import '../services/audio_service.dart';
import '../services/gamification_service.dart';
import '../services/quotes_service.dart';
import '../services/user_profile_service.dart';
import '../services/encouragement_service.dart';
import '../models/focus_session.dart';
import '../models/plant.dart';
import '../widgets/circular_timer.dart';
import '../widgets/timer_controls.dart';
import '../widgets/duration_selector.dart';
import '../widgets/reward_popup.dart';
import '../widgets/plant_widget.dart';

/// Main timer screen where users start and manage focus sessions
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  DateTime? _sessionStartTime;
  String _motivationalQuote = '';
  String _quoteAuthor = '';

  @override
  void initState() {
    super.initState();
    _loadMotivationalQuote();
  }

  void _loadMotivationalQuote() {
    try {
      final stats = ref.read(statsProvider);
      final quote = QuotesService.instance.getContextualQuote(
        currentStreak: stats['currentStreak'] as int? ?? 0,
        totalSessions: stats['completedSessions'] as int? ?? 0,
      );
      if (mounted) {
        setState(() {
          _motivationalQuote = quote['text'] ?? '';
          _quoteAuthor = quote['author'] ?? '';
        });
      }
    } catch (e) {
      // Fallback to a default quote if there's an error
      if (mounted) {
        setState(() {
          _motivationalQuote = 'Focus is the art of knowing what to ignore.';
          _quoteAuthor = 'James Clear';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final timerState = ref.watch(timerProvider);
      final timerService = ref.read(timerProvider.notifier);
      final userLevel = ref.watch(gamificationServiceProvider);
      final challengeProgress = ref.watch(challengeProgressProvider);

      // Listen for timer completion
      ref.listen<TimerState>(timerProvider, (previous, current) {
        if (previous?.status != TimerStatus.completed &&
            current.status == TimerStatus.completed) {
          _onTimerCompleted(current);
        }
      });

      return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background
      appBar: AppBar(
        title: const Text(
          'Focus Timer',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  40,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // User level and XP display
                  _buildLevelCard(userLevel),
                  const SizedBox(height: 12),

                  // Daily challenge card
                  _buildDailyChallengeCard(challengeProgress),
                  const SizedBox(height: 12),

                  // Motivational quote
                  if (timerState.status == TimerStatus.initial)
                    _buildMotivationalQuote(),

                  const SizedBox(height: 12),

                  // Session info and next reward preview
                  _buildSessionInfo(),
                  const SizedBox(height: 20),

                  // Main timer circle - flexible size
                  Flexible(
                    flex: 3,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: CircularTimer(
                        progress: timerState.progress,
                        timeRemaining: timerState.formattedTime,
                        isRunning: timerState.isRunning,
                        totalMinutes: timerState.totalMinutes,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Duration selector (only show when not running)
                  if (timerState.status == TimerStatus.initial ||
                      timerState.status == TimerStatus.cancelled)
                    DurationSelector(
                      initialDuration: timerState.totalMinutes,
                      onDurationChanged: timerService.setDuration,
                    ),

                  if (timerState.status == TimerStatus.initial ||
                      timerState.status == TimerStatus.cancelled)
                    const SizedBox(height: 20),

                  // Timer controls
                  TimerControls(
                    status: timerState.status,
                    onStart: () {
                      _sessionStartTime = DateTime.now();
                      timerService.start();
                      _showStartMessage();
                    },
                    onPause: () {
                      timerService.pause();
                      _showPauseMessage();
                    },
                    onResume: () {
                      timerService.resume();
                      _showResumeMessage();
                    },
                    onReset: () {
                      _sessionStartTime = null;
                      timerService.reset();
                    },
                    onStop: timerService.stop,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    } catch (e) {
      // If there's an error in the providers, show an error screen
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Error: ${e.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Try to reload
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Build session info widget (shows current streak, next reward, etc.)
  Widget _buildSessionInfo() {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(statsProvider);
        final nextPlantProgress = ref.watch(nextPlantProgressProvider);
        final currentStreak = stats['currentStreak'] as int;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Current streak
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: currentStreak > 0 ? Colors.orange : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${currentStreak} day streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: currentStreak > 0
                            ? Colors.orange[700]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // Next plant preview (if available)
                if (nextPlantProgress != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildNextPlantPreview(nextPlantProgress),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build next plant preview widget
  Widget _buildNextPlantPreview(Map<String, dynamic> progressInfo) {
    final plant = progressInfo['plant'] as Plant;
    final progress = progressInfo['progress'] as double;
    final remainingMinutes = progressInfo['remainingMinutes'] as int;

    return Column(
      children: [
        Row(
          children: [
            // Use PlantWidget for better visuals
            PlantWidget(
              plant: plant,
              size: 40,
              showAnimation: false, // Don't animate locked plants
              showParticles: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next unlock: ${plant.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${remainingMinutes}m remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(plant.rarityColor),
        ),
      ],
    );
  }

  /// Handle timer completion - save session and show rewards
  Future<void> _onTimerCompleted(TimerState timerState) async {
    if (_sessionStartTime == null) return;

    // Play timer completion sound
    await AudioService.instance.playTimerComplete();

    // Create focus session
    final session = FocusSession(
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      durationMinutes: timerState.totalMinutes,
      actualMinutes: timerState.totalMinutes, // Full completion
      completed: true,
      plantUnlocked: null, // Will be set by reward service
    );

    // Save session
    final storageService = ref.read(storageServiceProvider);
    await storageService.saveFocusSession(session);

    // Award XP
    final gamificationService = ref.read(gamificationServiceProvider.notifier);
    final leveledUp = await gamificationService.awardXP(timerState.totalMinutes);

    // Check for plant rewards
    final rewardService = ref.read(rewardServiceProvider);
    final unlockedPlant = await rewardService.processCompletedSession(session);

    // Check daily challenge progress
    final challengeService = ref.read(dailyChallengeServiceProvider);
    final challengeComplete = challengeService.checkChallengeProgress();

    // Show rewards
    if (mounted) {
      if (leveledUp) {
        _showLevelUpDialog();
      } else if (unlockedPlant != null) {
        // Play plant unlock sound
        await AudioService.instance.playPlantUnlock();
        _showRewardPopup(unlockedPlant);
      } else if (challengeComplete) {
        _showChallengeCompleteMessage();
      } else {
        _showCompletionMessage();
      }

      // Load new quote for next session
      _loadMotivationalQuote();
    }

    // Reset session start time
    _sessionStartTime = null;
  }

  /// Show reward popup when plant is unlocked
  void _showRewardPopup(Plant plant) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RewardPopup(
        plant: plant,
        onContinue: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Show simple completion message when no new plant is unlocked
  void _showCompletionMessage() {
    final userProfile = ref.read(userProfileProvider);
    final userName = userProfile?.name ?? 'Friend';
    final stats = ref.read(statsProvider);
    final completedMinutes = ref.read(timerProvider).totalMinutes;
    final currentStreak = stats['currentStreak'] as int;

    final message = EncouragementService.instance.getCompletionMessage(
      userName,
      completedMinutes,
      streak: currentStreak > 0 ? currentStreak : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show encouraging message when user starts a session
  void _showStartMessage() {
    final userProfile = ref.read(userProfileProvider);
    final userName = userProfile?.name ?? 'Friend';
    final stats = ref.read(statsProvider);
    final sessionCount = stats['completedSessions'] as int;

    final message = EncouragementService.instance.getStartMessage(
      userName,
      sessionCount: sessionCount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.rocket_launch, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show message when user pauses
  void _showPauseMessage() {
    final userProfile = ref.read(userProfileProvider);
    final userName = userProfile?.name ?? 'Friend';
    final message = EncouragementService.instance.getPauseMessage(userName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show message when user resumes
  void _showResumeMessage() {
    final userProfile = ref.read(userProfileProvider);
    final userName = userProfile?.name ?? 'Friend';
    final message = EncouragementService.instance.getResumeMessage(userName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show level up dialog
  void _showLevelUpDialog() {
    final userLevel = ref.read(gamificationServiceProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.trending_up, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Text('Level Up!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations!\nYou\'ve reached level ${userLevel.level}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              userLevel.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  /// Show challenge complete message
  void _showChallengeCompleteMessage() {
    final challengeProgress = ref.read(challengeProgressProvider);
    final challenge = challengeProgress['challenge'] as DailyChallenge;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Daily Challenge Complete! +${challenge.xpReward} XP'),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Build level card
  Widget _buildLevelCard(UserLevel userLevel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${userLevel.level}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userLevel.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: userLevel.progress,
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${userLevel.currentXP} / ${userLevel.xpToNextLevel} XP',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build daily challenge card
  Widget _buildDailyChallengeCard(Map<String, dynamic> progressData) {
    final challenge = progressData['challenge'] as DailyChallenge;
    final sessionProgress = progressData['sessionProgress'] as double;
    final minuteProgress = progressData['minuteProgress'] as double;

    if (challenge.isCompleted) {
      return Card(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Daily Challenge Complete! 🎉',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final progress = challenge.targetSessions > 0 ? sessionProgress : minuteProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${challenge.xpReward} XP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build motivational quote card
  Widget _buildMotivationalQuote() {
    if (_motivationalQuote.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.format_quote, color: Colors.blue[700]),
            const SizedBox(height: 8),
            Text(
              _motivationalQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '- $_quoteAuthor',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
