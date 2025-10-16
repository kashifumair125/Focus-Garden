import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service to handle audio feedback for the app
class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();

  AudioService._();

  /// Play plant unlock sound
  Future<void> playPlantUnlock() async {
    try {
      await HapticFeedback.lightImpact();
      // Note: For actual audio playback, you would use audioplayers package
      // await AudioPlayer().play(AssetSource('sounds/plant_unlock.mp3'));
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
      // Note: For actual audio playback, you would use audioplayers package
      // await AudioPlayer().play(AssetSource('sounds/timer_complete.mp3'));
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
}
