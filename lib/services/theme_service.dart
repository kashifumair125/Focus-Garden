import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Garden theme model - now plant-based!
class GardenTheme {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color accentColor;
  final int requiredLevel;
  final bool isUnlocked;
  final String? associatedPlantId; // Link theme to specific plant
  final String emoji; // Plant emoji for theme

  GardenTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.accentColor,
    this.requiredLevel = 0,
    this.isUnlocked = true,
    this.associatedPlantId,
    required this.emoji,
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
    final savedThemeId =
        box.get('currentTheme', defaultValue: 'classic') as String;
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
        accentColor: theme.accentColor,
        requiredLevel: theme.requiredLevel,
        isUnlocked: userLevel >= theme.requiredLevel,
        associatedPlantId: theme.associatedPlantId,
        emoji: theme.emoji,
      );
    }).toList();
  }

  /// List of all available plant-based themes
  static final List<GardenTheme> availableThemes = [
    GardenTheme(
      id: 'classic',
      name: 'Green Sprout',
      description: 'Fresh green theme - unlock your first plant!',
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF81C784),
      accentColor: const Color(0xFF66BB6A),
      backgroundColor: const Color(0xFFF8F9FA),
      cardColor: Colors.white,
      requiredLevel: 0,
      associatedPlantId: 'green_sprout',
      emoji: '🌱',
    ),
    GardenTheme(
      id: 'daisy',
      name: 'White Daisy',
      description: 'Pure white daisy theme with soft accents',
      primaryColor: const Color(0xFF388E3C),
      secondaryColor: const Color(0xFFFFFDE7),
      accentColor: const Color(0xFFFFEB3B),
      backgroundColor: const Color(0xFFFFFFF9),
      cardColor: const Color(0xFFFFFFF),
      requiredLevel: 2,
      associatedPlantId: 'white_daisy',
      emoji: '🌼',
    ),
    GardenTheme(
      id: 'tulip',
      name: 'Pink Tulip',
      description: 'Soft pink tulip garden',
      primaryColor: const Color(0xFFEC407A),
      secondaryColor: const Color(0xFFF8BBD0),
      accentColor: const Color(0xFFFF4081),
      backgroundColor: const Color(0xFFFCE4EC),
      cardColor: const Color(0xFFFFF1F5),
      requiredLevel: 4,
      associatedPlantId: 'pink_tulip',
      emoji: '🌷',
    ),
    GardenTheme(
      id: 'sunflower',
      name: 'Sunflower',
      description: 'Bright and sunny sunflower theme',
      primaryColor: const Color(0xFFFFA000),
      secondaryColor: const Color(0xFFFFD54F),
      accentColor: const Color(0xFFFF6F00),
      backgroundColor: const Color(0xFFFFF8E1),
      cardColor: const Color(0xFFFFFBF0),
      requiredLevel: 6,
      associatedPlantId: 'sunflower',
      emoji: '🌻',
    ),
    GardenTheme(
      id: 'fern',
      name: 'Forest Fern',
      description: 'Deep forest fern theme',
      primaryColor: const Color(0xFF2E7D32),
      secondaryColor: const Color(0xFF66BB6A),
      accentColor: const Color(0xFF1B5E20),
      backgroundColor: const Color(0xFFF1F8F4),
      cardColor: const Color(0xFFFAFDFC),
      requiredLevel: 8,
      associatedPlantId: 'forest_fern',
      emoji: '🌿',
    ),
    GardenTheme(
      id: 'cactus',
      name: 'Desert Cactus',
      description: 'Warm desert cactus theme',
      primaryColor: const Color(0xFF689F38),
      secondaryColor: const Color(0xFFDCE775),
      accentColor: const Color(0xFF827717),
      backgroundColor: const Color(0xFFF9FBE7),
      cardColor: const Color(0xFFFFFFF3),
      requiredLevel: 10,
      associatedPlantId: 'desert_cactus',
      emoji: '🌵',
    ),
    GardenTheme(
      id: 'rose',
      name: 'Red Rose',
      description: 'Elegant red rose theme',
      primaryColor: const Color(0xFFC62828),
      secondaryColor: const Color(0xFFEF5350),
      accentColor: const Color(0xFF8E0000),
      backgroundColor: const Color(0xFFFFEBEE),
      cardColor: const Color(0xFFFFF5F5),
      requiredLevel: 15,
      associatedPlantId: 'red_rose',
      emoji: '🌹',
    ),
    GardenTheme(
      id: 'sakura',
      name: 'Cherry Blossom',
      description: 'Beautiful cherry blossom theme',
      primaryColor: const Color(0xFFE91E63),
      secondaryColor: const Color(0xFFF48FB1),
      accentColor: const Color(0xFFC2185B),
      backgroundColor: const Color(0xFFFCE4EC),
      cardColor: const Color(0xFFFFF8FA),
      requiredLevel: 18,
      associatedPlantId: 'cherry_blossom',
      emoji: '🌸',
    ),
    GardenTheme(
      id: 'oak',
      name: 'Oak Sapling',
      description: 'Strong oak tree theme',
      primaryColor: const Color(0xFF5D4037),
      secondaryColor: const Color(0xFF8D6E63),
      accentColor: const Color(0xFF3E2723),
      backgroundColor: const Color(0xFFEFEBE9),
      cardColor: const Color(0xFFFAF8F7),
      requiredLevel: 22,
      associatedPlantId: 'oak_sapling',
      emoji: '🌳',
    ),
    GardenTheme(
      id: 'orchid',
      name: 'Purple Orchid',
      description: 'Exotic purple orchid theme',
      primaryColor: const Color(0xFF7B1FA2),
      secondaryColor: const Color(0xFFBA68C8),
      accentColor: const Color(0xFF4A148C),
      backgroundColor: const Color(0xFFF3E5F5),
      cardColor: const Color(0xFFFAF7FC),
      requiredLevel: 28,
      associatedPlantId: 'purple_orchid',
      emoji: '🌺',
    ),
    GardenTheme(
      id: 'lotus',
      name: 'Lotus Flower',
      description: 'Serene lotus flower theme',
      primaryColor: const Color(0xFFAD1457),
      secondaryColor: const Color(0xFFF06292),
      accentColor: const Color(0xFF880E4F),
      backgroundColor: const Color(0xFFFCE4EC),
      cardColor: const Color(0xFFFFF9FC),
      requiredLevel: 35,
      associatedPlantId: 'lotus_flower',
      emoji: '🪷',
    ),
    GardenTheme(
      id: 'bonsai',
      name: 'Ancient Bonsai',
      description: 'Zen bonsai tree theme',
      primaryColor: const Color(0xFF4E342E),
      secondaryColor: const Color(0xFF8D6E63),
      accentColor: const Color(0xFF3E2723),
      backgroundColor: const Color(0xFFEFEBE9),
      cardColor: const Color(0xFFFAF8F7),
      requiredLevel: 45,
      associatedPlantId: 'ancient_bonsai',
      emoji: '🪴',
    ),
    GardenTheme(
      id: 'world_tree',
      name: 'World Tree',
      description: 'Legendary world tree theme',
      primaryColor: const Color(0xFF1B5E20),
      secondaryColor: const Color(0xFF4CAF50),
      accentColor: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFFE8F5E9),
      cardColor: const Color(0xFFF1F8E9),
      requiredLevel: 60,
      associatedPlantId: 'world_tree',
      emoji: '🌳',
    ),
  ];
}

/// Provider for theme service
final themeServiceProvider =
    StateNotifierProvider<ThemeService, GardenTheme>((ref) {
  return ThemeService();
});

/// Provider for current theme data
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final gardenTheme = ref.watch(themeServiceProvider);
  return gardenTheme.toThemeData();
});
