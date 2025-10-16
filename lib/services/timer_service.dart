import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum for different timer states
enum TimerStatus {
  initial, // Timer hasn't started
  running, // Timer is actively counting down
  paused, // Timer is paused
  completed, // Timer finished successfully
  cancelled, // Timer was cancelled/reset
}

/// Timer state model
class TimerState {
  final int totalSeconds; // Original duration
  final int remainingSeconds; // Time left
  final TimerStatus status;
  final DateTime? startTime;

  const TimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.status,
    this.startTime,
  });

  /// Create initial timer state
  TimerState.initial(int minutes)
      : totalSeconds = minutes * 60,
        remainingSeconds = minutes * 60,
        status = TimerStatus.initial,
        startTime = null;

  /// Copy this state with modifications
  TimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    TimerStatus? status,
    DateTime? startTime,
  }) {
    return TimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
    );
  }

  // Helper getters
  int get elapsedSeconds => totalSeconds - remainingSeconds;
  int get totalMinutes => totalSeconds ~/ 60;
  int get remainingMinutes => remainingSeconds ~/ 60;
  int get remainingSecondsDisplay => remainingSeconds % 60;
  double get progress => totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;
  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isCompleted => status == TimerStatus.completed;

  /// Format remaining time as MM:SS
  String get formattedTime {
    final minutes = remainingMinutes;
    final seconds = remainingSecondsDisplay;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Timer service that handles all timer logic
class TimerService extends Notifier<TimerState> {
  Timer? _timer;

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const TimerState(
      totalSeconds: 1500, // Default 25 minutes (Pomodoro style)
      remainingSeconds: 1500,
      status: TimerStatus.initial,
    );
  }

  /// Set timer duration (in minutes)
  void setDuration(int minutes) {
    // Only allow setting duration when timer is not running
    if (state.isRunning) return;

    state = TimerState.initial(minutes);
  }

  /// Start the timer
  void start() {
    if (state.isRunning) return;

    state = state.copyWith(
      status: TimerStatus.running,
      startTime: state.startTime ?? DateTime.now(),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      } else {
        // Timer completed!
        _completeTimer();
      }
    });
  }

  /// Pause the timer
  void pause() {
    if (!state.isRunning) return;

    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// Resume the timer (same as start when paused)
  void resume() {
    if (!state.isPaused) return;
    start();
  }

  /// Reset the timer to initial state
  void reset() {
    _timer?.cancel();
    state = TimerState.initial(state.totalMinutes);
  }

  /// Stop the timer (mark as cancelled)
  void stop() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.cancelled);
  }

  /// Complete the timer (private method)
  void _completeTimer() {
    _timer?.cancel();
    state = state.copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
    );
  }

  // Cleanup is handled via ref.onDispose in build()
}

/// Provider for the timer service
final timerProvider =
    NotifierProvider<TimerService, TimerState>(TimerService.new);

/// Convenience providers for common timer properties
final remainingTimeProvider = Provider<String>((ref) {
  return ref.watch(timerProvider).formattedTime;
});

final progressProvider = Provider<double>((ref) {
  return ref.watch(timerProvider).progress;
});

final timerStatusProvider = Provider<TimerStatus>((ref) {
  return ref.watch(timerProvider).status;
});
