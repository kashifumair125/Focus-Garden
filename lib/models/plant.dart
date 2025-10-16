import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// This annotation generates a Hive adapter for local storage
part 'plant.g.dart';

@HiveType(typeId: 1)
class Plant extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imagePath; // Path to plant image (for now, we'll use icons)

  @HiveField(4)
  final DateTime unlockedAt;

  @HiveField(5)
  final int requiredMinutes; // How many focus minutes needed to unlock

  @HiveField(6)
  final PlantRarity rarity;

  @HiveField(7)
  final String? animationPath; // Path to Lottie animation file

  Plant({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.unlockedAt,
    required this.requiredMinutes,
    required this.rarity,
    this.animationPath,
  });

  // Get color based on rarity
  Color get rarityColor {
    switch (rarity) {
      case PlantRarity.common:
        return Colors.grey;
      case PlantRarity.uncommon:
        return Colors.green;
      case PlantRarity.rare:
        return Colors.blue;
      case PlantRarity.epic:
        return Colors.purple;
      case PlantRarity.legendary:
        return Colors.orange;
    }
  }

  // Get icon based on plant (for now, using material icons as placeholders)
  IconData get icon {
    // Simple mapping - you can expand this or use actual image assets
    if (name.toLowerCase().contains('flower')) {
      return Icons.local_florist;
    } else if (name.toLowerCase().contains('tree')) {
      return Icons.park;
    } else if (name.toLowerCase().contains('cactus')) {
      return Icons.filter_vintage;
    } else if (name.toLowerCase().contains('fern')) {
      return Icons.eco;
    }
    return Icons.local_florist; // Default
  }
}

@HiveType(typeId: 2)
enum PlantRarity {
  @HiveField(0)
  common,

  @HiveField(1)
  uncommon,

  @HiveField(2)
  rare,

  @HiveField(3)
  epic,

  @HiveField(4)
  legendary,
}

// Pre-defined plants that can be unlocked
// This would normally come from a JSON file or be more dynamic
class PlantDatabase {
  static final List<Plant> allPlants = [
    // Common plants (5-15 minutes)
    Plant(
      id: 'daisy_001',
      name: 'White Daisy',
      description: 'A simple, cheerful flower for your first focus session.',
      imagePath: 'assets/plants/daisy.png',
      unlockedAt: DateTime.now(),
      requiredMinutes: 5,
      rarity: PlantRarity.common,
      animationPath: 'assets/animations/plant_growing.json',
    ),
    Plant(
      id: 'sprout_001',
      name: 'Green Sprout',
      description: 'The beginning of something beautiful.',
      imagePath: 'assets/plants/sprout.png',
      unlockedAt: DateTime.now(),
      requiredMinutes: 10,
      rarity: PlantRarity.common,
    ),

    // Uncommon plants (20-30 minutes)
    Plant(
      id: 'sunflower_001',
      name: 'Sunflower',
      description: 'Bright and cheerful, always facing the sun.',
      imagePath: 'assets/plants/sunflower.png',
      unlockedAt: DateTime.now(),
      requiredMinutes: 25,
      rarity: PlantRarity.uncommon,
    ),
    Plant(
      id: 'fern_001',
      name: 'Forest Fern',
      description: 'An elegant plant from the deep forest.',
      imagePath: 'assets/plants/fern.png',
      unlockedAt: DateTime.now(),
      requiredMinutes: 30,
      rarity: PlantRarity.uncommon,
    ),

    // Rare plants (45+ minutes)
    Plant(
      id: 'rose_001',
      name: 'Red Rose',
      description: 'A beautiful rose earned through dedication.',
      imagePath: 'assets/plants/rose.png',
      unlockedAt: DateTime.now(),
      requiredMinutes: 45,
      rarity: PlantRarity.rare,
      animationPath: 'assets/animations/celebration.json',
    ),
    Plant(
      id: 'tree_001',
      name: 'Oak Sapling',
      description: 'Strong and steady, like your focus habits.',
      imagePath: 'assets/plants/oak_tree.png',
      unlockedAt: DateTime.now(),
      requiredMinutes: 60,
      rarity: PlantRarity.rare,
      animationPath: 'assets/animations/plant_growing.json',
    ),

    // Epic plants (90+ minutes)
    Plant(
      id: 'orchid_001',
      name: 'Purple Orchid',
      description: 'A rare and exotic beauty.',
      imagePath: 'assets/plants/orchid.png',
      unlockedAt: DateTime.now(),
      requiredMinutes: 90,
      rarity: PlantRarity.epic,
    ),

    // Legendary plants (120+ minutes)
    Plant(
      id: 'bonsai_001',
      name: 'Ancient Bonsai',
      description: 'A masterpiece of patience and dedication.',
      imagePath: 'assets/plants/bonsai.png',
      unlockedAt: DateTime.now(),
      requiredMinutes: 120,
      rarity: PlantRarity.legendary,
    ),
  ];

  /// Get a plant that can be unlocked based on session duration
  static Plant? getPlantForDuration(int minutes) {
    // Find plants that can be unlocked with this duration
    final availablePlants =
        allPlants.where((plant) => plant.requiredMinutes <= minutes).toList();

    if (availablePlants.isEmpty) return null;

    // For now, return a random plant from available ones
    // Later you might want more sophisticated logic (checking what's already unlocked, etc.)
    availablePlants.shuffle();
    return availablePlants.first;
  }
}
