import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../models/plant.dart';
import '../widgets/plant_widget.dart';
import '../widgets/enhanced_ui.dart';

/// Garden screen showing all unlocked plants
class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedPlants = ref.watch(unlockedPlantsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Your Garden',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.local_florist),
              text: 'My Plants',
            ),
            Tab(
              icon: Icon(Icons.explore),
              text: 'Discover',
            ),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Plants tab
          _buildMyPlantsTab(unlockedPlants),

          // Discover tab (all available plants)
          _buildDiscoverTab(),
        ],
      ),
    );
  }

  /// Build the "My Plants" tab showing unlocked plants
  Widget _buildMyPlantsTab(List<Plant> plants) {
    if (plants.isEmpty) {
      return _buildEmptyGarden();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garden stats
          _buildGardenStats(plants),

          const SizedBox(height: 24),

          // Plants grid
          _buildPlantsGrid(plants, showUnlocked: true),
        ],
      ),
    );
  }

  /// Build the "Discover" tab showing all available plants
  Widget _buildDiscoverTab() {
    final allPlants = PlantDatabase.allPlants;
    final unlockedPlants = ref.watch(unlockedPlantsProvider);
    final unlockedIds = unlockedPlants.map((p) => p.id).toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discovery header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.explore,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Plant Discovery',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete focus sessions to unlock these beautiful plants!',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Plants by rarity sections
          ...PlantRarity.values.map((rarity) {
            final plantsInRarity =
                allPlants.where((plant) => plant.rarity == rarity).toList();

            if (plantsInRarity.isEmpty) return const SizedBox.shrink();

            return _buildRaritySection(rarity, plantsInRarity, unlockedIds);
          }).toList(),
        ],
      ),
    );
  }

  /// Build empty garden state
  Widget _buildEmptyGarden() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_florist_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Garden is Empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete your first focus session to unlock your first plant!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Switch to timer tab
                // This would require callback to parent navigation
              },
              icon: const Icon(Icons.timer),
              label: const Text('Start Focusing'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build garden statistics card
  Widget _buildGardenStats(List<Plant> plants) {
    final rarityCount = <PlantRarity, int>{};
    for (final plant in plants) {
      rarityCount[plant.rarity] = (rarityCount[plant.rarity] ?? 0) + 1;
    }

    return EnhancedCard(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_florist,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Garden Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Plants',
                  plants.length.toString(),
                  Icons.local_florist,
                  Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildStatItem(
                  'Rarest Plant',
                  _getRarestPlantName(plants),
                  Icons.star,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Get the rarest plant name in collection
  String _getRarestPlantName(List<Plant> plants) {
    if (plants.isEmpty) return 'None';

    plants.sort((a, b) => b.rarity.index.compareTo(a.rarity.index));
    return plants.first.name;
  }

  /// Build plants grid
  Widget _buildPlantsGrid(List<Plant> plants, {required bool showUnlocked}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return _buildPlantCard(plant, isUnlocked: showUnlocked);
      },
    );
  }

  /// Build rarity section for discover tab
  Widget _buildRaritySection(
      PlantRarity rarity, List<Plant> plants, Set<String> unlockedIds) {
    final rarityColor = plants.first.rarityColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: rarityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                rarity.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: rarityColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        // Plants grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            final isUnlocked = unlockedIds.contains(plant.id);
            return _buildPlantCard(plant, isUnlocked: isUnlocked);
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Build individual plant card
  Widget _buildPlantCard(Plant plant, {required bool isUnlocked}) {
    return EnhancedCard(
      elevation: isUnlocked ? 6 : 2,
      borderRadius: BorderRadius.circular(16),
      color: isUnlocked ? Colors.white : Colors.grey[50],
      enableHover: isUnlocked,
      onTap: isUnlocked
          ? () {
              // Play sound when tapping unlocked plants
              AudioService.instance.playNotification();
            }
          : null,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Plant widget with enhanced visuals
              PlantWidget(
                plant: plant,
                size: 80,
                showAnimation: isUnlocked, // Only animate unlocked plants
                showParticles: isUnlocked, // Show particles for unlocked plants
              ),

              const SizedBox(height: 12),

              // Plant name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  plant.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isUnlocked ? const Color(0xFF2E7D32) : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 4),

              // Requirement or unlock date
              Text(
                isUnlocked ? 'Unlocked!' : '${plant.requiredMinutes}m required',
                style: TextStyle(
                  fontSize: 12,
                  color: isUnlocked ? Colors.green[600] : Colors.grey[500],
                  fontWeight: isUnlocked ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),

          // Lock overlay for locked plants
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
