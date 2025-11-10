import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_screen.dart';
import 'garden_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import '../services/navigation_service.dart';

/// Main navigation widget with bottom navigation bar
class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final navigationService = ref.read(navigationProvider.notifier);

    // List of screens for each tab
    final screens = const [
      TimerScreen(),
      GardenScreen(),
      StatsScreen(),
      SettingsScreen(),
    ];

    // Navigation bar items
    final navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.timer_outlined),
        activeIcon: Icon(Icons.timer),
        label: 'Focus',
        tooltip: 'Focus Timer',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_florist_outlined),
        activeIcon: Icon(Icons.local_florist),
        label: 'Garden',
        tooltip: 'Your Plant Garden',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Stats',
        tooltip: 'Your Statistics',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Settings',
        tooltip: 'App Settings',
      ),
    ];

    return Scaffold(
      // Display the current screen
      body: screens[currentIndex],

      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // Add subtle shadow above the navigation bar
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => navigationService.switchToTab(index),
          type: BottomNavigationBarType.fixed,
          items: navItems,

          // Styling
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          elevation: 0, // We're using custom shadow above

          // Typography
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),

      // Optional: Add floating action button for quick timer start
      // (commented out for now, but you can enable it later)
      /*
      floatingActionButton: _currentIndex == 0 
        ? FloatingActionButton(
            onPressed: () {
              // Quick start timer functionality
            },
            child: const Icon(Icons.play_arrow),
            backgroundColor: Theme.of(context).primaryColor,
            tooltip: 'Quick Start',
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      */
    );
  }
}
