import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
import '../models/focus_session.dart';
import 'storage_service.dart';

/// Service for handling the reward system (unlocking plants)
class RewardService {
  final StorageService _storageService;

  RewardService(this._storageService);

  /// Process a completed focus session and potentially unlock rewards
  Future<Plant?> processCompletedSession(FocusSession session) async {
    // Only process completed sessions
    if (!session.completed) return null;

    // Get a plant that can be unlocked with this session duration
    final potentialPlant =
        PlantDatabase.getPlantForDuration(session.actualMinutes);

    if (potentialPlant == null) return null;

    // Check if this plant is already unlocked
    if (_storageService.isPlantUnlocked(potentialPlant.id)) {
      // Try to find another plant of similar or lower rarity that isn't unlocked
      final alternativePlant = _findAlternativePlant(session.actualMinutes);
      if (alternativePlant != null &&
          !_storageService.isPlantUnlocked(alternativePlant.id)) {
        return await _unlockPlant(alternativePlant);
      }
      return null; // No new plant to unlock
    }

    // Unlock the plant
    return await _unlockPlant(potentialPlant);
  }

  /// Unlock a specific plant
  Future<Plant> _unlockPlant(Plant plant) async {
    final unlockedPlant = Plant(
      id: plant.id,
      name: plant.name,
      description: plant.description,
      imagePath: plant.imagePath,
      unlockedAt: DateTime.now(),
      requiredMinutes: plant.requiredMinutes,
      rarity: plant.rarity,
    );

    await _storageService.savePlant(unlockedPlant);
    return unlockedPlant;
  }

  /// Find an alternative plant to unlock if the primary choice is already unlocked
  Plant? _findAlternativePlant(int sessionMinutes) {
    final availablePlants = PlantDatabase.allPlants
        .where((plant) =>
            plant.requiredMinutes <= sessionMinutes &&
            !_storageService.isPlantUnlocked(plant.id))
        .toList();

    if (availablePlants.isEmpty) return null;

    // Sort by required minutes (descending) to get the "best" plant first
    availablePlants
        .sort((a, b) => b.requiredMinutes.compareTo(a.requiredMinutes));

    return availablePlants.first;
  }

  /// Get all plants that can potentially be unlocked
  List<Plant> getAllAvailablePlants() {
    return PlantDatabase.allPlants;
  }

  /// Get plants filtered by rarity
  List<Plant> getPlantsByRarity(PlantRarity rarity) {
    return PlantDatabase.allPlants
        .where((plant) => plant.rarity == rarity)
        .toList();
  }

  /// Get the next plant that can be unlocked (motivation feature)
  Plant? getNextUnlockablePlant() {
    final unlockedPlants = _storageService.getUnlockedPlants();
    final unlockedIds = unlockedPlants.map((p) => p.id).toSet();

    final availablePlants = PlantDatabase.allPlants
        .where((plant) => !unlockedIds.contains(plant.id))
        .toList();

    if (availablePlants.isEmpty) return null;

    // Sort by required minutes to get the "easiest" next unlock
    availablePlants
        .sort((a, b) => a.requiredMinutes.compareTo(b.requiredMinutes));

    return availablePlants.first;
  }

  /// Get progress towards next plant unlock
  Map<String, dynamic>? getProgressToNextPlant() {
    final nextPlant = getNextUnlockablePlant();
    if (nextPlant == null) return null;

    final totalMinutes =
        int.parse(_storageService.totalFocusHours.split('.')[0]) * 60;
    final remainingMinutes = (nextPlant.requiredMinutes - totalMinutes)
        .clamp(0, nextPlant.requiredMinutes);
    final progress = totalMinutes / nextPlant.requiredMinutes;

    return {
      'plant': nextPlant,
      'progress': progress.clamp(0.0, 1.0),
      'remainingMinutes': remainingMinutes,
      'totalRequired': nextPlant.requiredMinutes,
    };
  }

  /// Check if user deserves a bonus plant (special achievements)
  Plant? checkForBonusRewards() {
    final stats = _storageService.getStats();
    final currentStreak = stats['currentStreak'] as int;
    final totalSessions = stats['completedSessions'] as int;

    // Streak-based rewards
    if (currentStreak == 7 &&
        !_storageService.isPlantUnlocked('bonus_week_streak')) {
      return Plant(
        id: 'bonus_week_streak',
        name: 'Streak Champion',
        description:
            '7 days of consistent focus! You earned this special plant.',
        imagePath: 'assets/plants/streak_champion.png',
        unlockedAt: DateTime.now(),
        requiredMinutes: 0, // Bonus plant
        rarity: PlantRarity.epic,
      );
    }

    // Session milestone rewards
    if (totalSessions == 50 &&
        !_storageService.isPlantUnlocked('bonus_fifty_sessions')) {
      return Plant(
        id: 'bonus_fifty_sessions',
        name: 'Dedication Bloom',
        description:
            '50 focus sessions completed! Your dedication is blooming.',
        imagePath: 'assets/plants/dedication_bloom.png',
        unlockedAt: DateTime.now(),
        requiredMinutes: 0,
        rarity: PlantRarity.rare,
      );
    }

    return null;
  }
}

/// Provider for reward service
final rewardServiceProvider = Provider<RewardService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return RewardService(storageService);
});

/// Provider for next unlockable plant
final nextPlantProvider = Provider<Plant?>((ref) {
  final rewardService = ref.watch(rewardServiceProvider);
  return rewardService.getNextUnlockablePlant();
});

/// Provider for progress to next plant
final nextPlantProgressProvider = Provider<Map<String, dynamic>?>((ref) {
  final rewardService = ref.watch(rewardServiceProvider);
  return rewardService.getProgressToNextPlant();
});
