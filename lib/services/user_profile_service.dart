import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// User profile data
class UserProfile {
  final String name;
  final DateTime createdAt;
  final String? avatarEmoji;

  UserProfile({
    required this.name,
    required this.createdAt,
    this.avatarEmoji,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'avatarEmoji': avatarEmoji,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      avatarEmoji: json['avatarEmoji'] as String?,
    );
  }

  UserProfile copyWith({
    String? name,
    DateTime? createdAt,
    String? avatarEmoji,
  }) {
    return UserProfile(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    );
  }
}

/// Service for managing user profile
class UserProfileService extends Notifier<UserProfile?> {
  Box get _settingsBox => Hive.box('settings');

  static const String _profileKey = 'userProfile';

  @override
  UserProfile? build() {
    return _loadProfile();
  }

  /// Load user profile from storage
  UserProfile? _loadProfile() {
    final profileData = _settingsBox.get(_profileKey);
    if (profileData != null && profileData is Map) {
      try {
        return UserProfile.fromJson(Map<String, dynamic>.from(profileData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save user profile
  Future<void> saveProfile(String name, {String? avatarEmoji}) async {
    final profile = UserProfile(
      name: name.trim(),
      createdAt: state?.createdAt ?? DateTime.now(),
      avatarEmoji: avatarEmoji ?? state?.avatarEmoji ?? _getRandomEmoji(),
    );
    await _settingsBox.put(_profileKey, profile.toJson());
    state = profile;
  }

  /// Update user name
  Future<void> updateName(String name) async {
    if (state != null) {
      await saveProfile(name, avatarEmoji: state!.avatarEmoji);
    }
  }

  /// Update avatar emoji
  Future<void> updateAvatarEmoji(String emoji) async {
    if (state != null) {
      final updated = state!.copyWith(avatarEmoji: emoji);
      await _settingsBox.put(_profileKey, updated.toJson());
      state = updated;
    }
  }

  /// Check if user has completed onboarding (has a profile)
  bool get hasProfile => state != null && state!.name.isNotEmpty;

  /// Get user's first name only
  String get firstName {
    if (state == null) return 'Friend';
    final parts = state!.name.trim().split(' ');
    return parts.first;
  }

  /// Get a random emoji for avatar
  String _getRandomEmoji() {
    final emojis = ['🌱', '🌿', '🌸', '🌺', '🌻', '🌷', '🌼', '🪴', '🌳'];
    return emojis[DateTime.now().millisecond % emojis.length];
  }

  /// Clear profile (for testing/reset)
  Future<void> clearProfile() async {
    await _settingsBox.delete(_profileKey);
    state = null;
  }
}

/// Provider for user profile service
final userProfileProvider = NotifierProvider<UserProfileService, UserProfile?>(UserProfileService.new);

/// Helper provider to check if onboarding is needed
final needsOnboardingProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile == null || profile.name.isEmpty;
});
