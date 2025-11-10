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
    // Check if user has seen onboarding
    final settingsBox = Hive.box('settings');
    final hasSeenOnboarding = settingsBox.get('hasSeenOnboarding', defaultValue: false) as bool;

    if (!hasSeenOnboarding) {
      setState(() {
        _currentState = AppState.onboarding;
      });
    } else {
      _checkNameInput();
    }
  }

  void _onOnboardingComplete() {
    // Mark onboarding as seen
    final settingsBox = Hive.box('settings');
    settingsBox.put('hasSeenOnboarding', true);
    _checkNameInput();
  }

  void _checkNameInput() {
    // Check if user needs to input their name
    final needsOnboarding = ref.read(needsOnboardingProvider);

    setState(() {
      if (needsOnboarding) {
        _currentState = AppState.nameInput;
      } else {
        _currentState = AppState.main;
      }
    });

    // Show welcome dialog after the frame is fully rendered
    // Use a delayed callback to ensure MainNavigation is fully laid out
    if (needsOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Add an additional delay to ensure layout is complete
        Future.delayed(const Duration(milliseconds: 300), () {
          _showWelcomeDialog();
        });
      });
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
