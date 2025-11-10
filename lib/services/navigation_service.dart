import 'package:riverpod/riverpod.dart';

/// Service for managing app navigation state
class NavigationService extends Notifier<int> {
  @override
  int build() => 0; // Start at timer tab (index 0)

  /// Switch to a specific tab by index
  void switchToTab(int index) {
    if (index >= 0 && index <= 3) {
      state = index;
    }
  }

  /// Switch to Timer tab
  void goToTimer() => switchToTab(0);

  /// Switch to Garden tab
  void goToGarden() => switchToTab(1);

  /// Switch to Stats tab
  void goToStats() => switchToTab(2);

  /// Switch to Settings tab
  void goToSettings() => switchToTab(3);
}

/// Provider for navigation state
final navigationProvider = NotifierProvider<NavigationService, int>(NavigationService.new);
