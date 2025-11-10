import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_profile_service.dart';
import '../widgets/welcome_dialog.dart';
import 'main_navigation.dart';

/// Wrapper widget that handles onboarding and main navigation
class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  bool _checkedOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Check onboarding status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  void _checkOnboarding() {
    setState(() {
      _checkedOnboarding = true;
    });

    // Show welcome dialog if user hasn't completed onboarding
    if (ref.read(needsOnboardingProvider)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const WelcomeDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedOnboarding) {
      // Show a simple loading indicator while checking
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        ),
      );
    }

    return const MainNavigation();
  }
}
