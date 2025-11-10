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
      setState(() {
        _currentState = AppState.nameInput;
      });
      // Show welcome dialog after a short delay to ensure context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentState == AppState.nameInput) {
          _showWelcomeDialog();
        }
      });
    } else {
      setState(() {
        _currentState = AppState.main;
      });
    }
  }

  void _showWelcomeDialog() {
    if (mounted && _currentState == AppState.nameInput) {
      // Use a small delay to ensure the scaffold is fully built
      Future.delayed(const Duration(milliseconds: 100), () {
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
          }).catchError((error) {
            // If dialog fails, still move to main app
            if (mounted) {
              setState(() {
                _currentState = AppState.main;
              });
            }
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
        // Show a blank scaffold while waiting for dialog
        // The dialog will be shown via addPostFrameCallback
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );

      case AppState.main:
        return const MainNavigation();
    }
  }
}
