import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/timer_service.dart';
import '../services/storage_service.dart';
import '../services/reward_service.dart';
import '../services/audio_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final timerService = ref.read(timerProvider.notifier);

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
                    },
                    onPause: timerService.pause,
                    onResume: timerService.resume,
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

    // Check for plant rewards
    final rewardService = ref.read(rewardServiceProvider);
    final unlockedPlant = await rewardService.processCompletedSession(session);

    // Show reward popup if plant was unlocked
    if (unlockedPlant != null && mounted) {
      // Play plant unlock sound
      await AudioService.instance.playPlantUnlock();
      _showRewardPopup(unlockedPlant);
    } else if (mounted) {
      // Show simple completion message
      _showCompletionMessage();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Focus session completed! 🎉'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
