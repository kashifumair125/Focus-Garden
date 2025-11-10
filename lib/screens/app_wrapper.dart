import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/user_profile_service.dart';
import '../widgets/welcome_dialog.dart';
import 'main_navigation.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';

/// Wrapper widget that handles splash, onboarding, and main navigation
class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

enum AppState {
  splash,
  onboarding,
  nameInput,
  main,
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  AppState _currentState = AppState.splash;

  @override
  void initState() {
    super.initState();
    // Splash screen will call _onSplashComplete when done
  }

  void _onSplashComplete() {
    setState(() {
      // Check if user has seen onboarding
      final settingsBox = Hive.box('settings');
      final hasSeenOnboarding = settingsBox.get('hasSeenOnboarding', defaultValue: false) as bool;

      if (!hasSeenOnboarding) {
        _currentState = AppState.onboarding;
      } else {
        _checkNameInput();
      }
    });
  }

  void _onOnboardingComplete() {
    // Mark onboarding as seen
    final settingsBox = Hive.box('settings');
    settingsBox.put('hasSeenOnboarding', true);

    setState(() {
      _checkNameInput();
    });
  }

  void _checkNameInput() {
    // Check if user needs to input their name
    if (ref.read(needsOnboardingProvider)) {
      _currentState = AppState.nameInput;
      // Show welcome dialog after a short delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
    } else {
      _currentState = AppState.main;
    }
  }

  void _showWelcomeDialog() {
    if (mounted && _currentState == AppState.nameInput) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const WelcomeDialog(),
      ).then((_) {
        // After dialog is closed, move to main app
        if (mounted) {
          setState(() {
            _currentState = AppState.main;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case AppState.splash:
        return SplashScreen(onComplete: _onSplashComplete);

      case AppState.onboarding:
        return OnboardingScreen(onComplete: _onOnboardingComplete);

      case AppState.nameInput:
      case AppState.main:
        return const MainNavigation();
    }
  }
}
