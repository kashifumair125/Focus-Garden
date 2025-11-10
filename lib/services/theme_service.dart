import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Garden theme model
class GardenTheme {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final int requiredLevel;
  final bool isUnlocked;

  GardenTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardColor,
    this.requiredLevel = 0,
    this.isUnlocked = true,
  });

  ThemeData toThemeData() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryColor.withOpacity(0.9),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryColor.withOpacity(0.9),
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: Color(0xFF424242),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
}

/// Service to manage app themes
class ThemeService extends Notifier<GardenTheme> {
  @override
  GardenTheme build() {
    return _loadSavedTheme();
  }

  static GardenTheme _getDefaultTheme() {
    return availableThemes.first;
  }

  GardenTheme _loadSavedTheme() {
    final box = Hive.box('settings');
    final savedThemeId = box.get('currentTheme', defaultValue: 'classic') as String;
    final theme = availableThemes.firstWhere(
      (t) => t.id == savedThemeId,
      orElse: () => _getDefaultTheme(),
    );
    return theme;
  }

  /// Switch to a different theme
  Future<void> setTheme(String themeId) async {
    final theme = availableThemes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => _getDefaultTheme(),
    );

    if (!theme.isUnlocked) {
      throw Exception('Theme is locked');
    }

    state = theme;
    final box = Hive.box('settings');
    await box.put('currentTheme', themeId);
  }

  /// Check if theme is unlocked based on user level
  bool isThemeUnlocked(String themeId, int userLevel) {
    final theme = availableThemes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => _getDefaultTheme(),
    );
    return userLevel >= theme.requiredLevel;
  }

  /// Get all available themes with unlock status
  List<GardenTheme> getThemesWithUnlockStatus(int userLevel) {
    return availableThemes.map((theme) {
      return GardenTheme(
        id: theme.id,
        name: theme.name,
        description: theme.description,
        primaryColor: theme.primaryColor,
        secondaryColor: theme.secondaryColor,
        backgroundColor: theme.backgroundColor,
        cardColor: theme.cardColor,
        requiredLevel: theme.requiredLevel,
        isUnlocked: userLevel >= theme.requiredLevel,
      );
    }).toList();
  }

  /// List of all available themes
  static final List<GardenTheme> availableThemes = [
    GardenTheme(
      id: 'classic',
      name: 'Classic Garden',
      description: 'The original fresh green theme',
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF81C784),
      backgroundColor: const Color(0xFFF8F9FA),
      cardColor: Colors.white,
      requiredLevel: 0,
    ),
    GardenTheme(
      id: 'forest',
      name: 'Forest Retreat',
      description: 'Deep forest greens and earthy tones',
      primaryColor: const Color(0xFF2E7D32),
      secondaryColor: const Color(0xFF66BB6A),
      backgroundColor: const Color(0xFFF1F8F4),
      cardColor: const Color(0xFFFAFDFC),
      requiredLevel: 5,
    ),
    GardenTheme(
      id: 'sakura',
      name: 'Sakura Blossoms',
      description: 'Soft pink cherry blossom theme',
      primaryColor: const Color(0xFFE91E63),
      secondaryColor: const Color(0xFFF48FB1),
      backgroundColor: const Color(0xFFFCE4EC),
      cardColor: const Color(0xFFFFF8FA),
      requiredLevel: 10,
    ),
    GardenTheme(
      id: 'ocean',
      name: 'Ocean Breeze',
      description: 'Cool blue waters and sea foam',
      primaryColor: const Color(0xFF0288D1),
      secondaryColor: const Color(0xFF4FC3F7),
      backgroundColor: const Color(0xFFE1F5FE),
      cardColor: const Color(0xFFF8FCFF),
      requiredLevel: 15,
    ),
    GardenTheme(
      id: 'sunset',
      name: 'Sunset Garden',
      description: 'Warm orange and purple twilight colors',
      primaryColor: const Color(0xFFFF6F00),
      secondaryColor: const Color(0xFFFFB74D),
      backgroundColor: const Color(0xFFFFF3E0),
      cardColor: const Color(0xFFFFFAF5),
      requiredLevel: 20,
    ),
    GardenTheme(
      id: 'lavender',
      name: 'Lavender Fields',
      description: 'Calming purple lavender theme',
      primaryColor: const Color(0xFF7B1FA2),
      secondaryColor: const Color(0xFFBA68C8),
      backgroundColor: const Color(0xFFF3E5F5),
      cardColor: const Color(0xFFFAF7FC),
      requiredLevel: 25,
    ),
    GardenTheme(
      id: 'autumn',
      name: 'Autumn Harvest',
      description: 'Rich autumn colors and golden leaves',
      primaryColor: const Color(0xFFE65100),
      secondaryColor: const Color(0xFFFF8A65),
      backgroundColor: const Color(0xFFFBE9E7),
      cardColor: const Color(0xFFFFF8F6),
      requiredLevel: 30,
    ),
    GardenTheme(
      id: 'midnight',
      name: 'Midnight Garden',
      description: 'Dark theme with moonlit colors',
      primaryColor: const Color(0xFF1A237E),
      secondaryColor: const Color(0xFF5C6BC0),
      backgroundColor: const Color(0xFFE8EAF6),
      cardColor: const Color(0xFFF5F6FA),
      requiredLevel: 40,
    ),
    GardenTheme(
      id: 'zen',
      name: 'Zen Garden',
      description: 'Minimalist sand and stone colors',
      primaryColor: const Color(0xFF795548),
      secondaryColor: const Color(0xFFA1887F),
      backgroundColor: const Color(0xFFEFEBE9),
      cardColor: const Color(0xFFFAF8F7),
      requiredLevel: 50,
    ),
  ];
}

/// Provider for theme service
final themeServiceProvider = NotifierProvider<ThemeService, GardenTheme>(ThemeService.new);

/// Provider for current theme data
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final gardenTheme = ref.watch(themeServiceProvider);
  return gardenTheme.toThemeData();
});
