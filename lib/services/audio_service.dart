import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service to handle audio feedback for the app
class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  AudioService._() {
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    // Set a moderate volume
    await _audioPlayer.setVolume(0.7);
  }

  /// Enable or disable sound effects
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play plant unlock sound
  Future<void> playPlantUnlock() async {
    try {
      await HapticFeedback.lightImpact();
      if (_soundEnabled) {
        await _audioPlayer.play(AssetSource('sounds/plant_unlock.mp3'));
      }
      if (kDebugMode) {
        print('🔊 Playing plant unlock sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing plant unlock sound: $e');
      }
    }
  }

  /// Play timer completion sound
  Future<void> playTimerComplete() async {
    try {
      await HapticFeedback.mediumImpact();
      if (_soundEnabled) {
        await _audioPlayer.play(AssetSource('sounds/timer_complete.mp3'));
      }
      if (kDebugMode) {
        print('🔊 Playing timer complete sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing timer complete sound: $e');
      }
    }
  }

  /// Play gentle notification sound
  Future<void> playNotification() async {
    try {
      await HapticFeedback.selectionClick();
      if (kDebugMode) {
        print('🔊 Playing notification sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing notification sound: $e');
      }
    }
  }

  /// Play success celebration
  Future<void> playCelebration() async {
    try {
      await HapticFeedback.heavyImpact();
      if (kDebugMode) {
        print('🎉 Playing celebration sound');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing celebration sound: $e');
      }
    }
  }

  /// Play button tap sound
  Future<void> playButtonTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing button tap: $e');
      }
    }
  }

  /// Dispose of resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
