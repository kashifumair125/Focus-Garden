import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/focus_session.dart';
import 'models/plant.dart';
import 'screens/main_navigation.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters for our custom models
  Hive.registerAdapter(FocusSessionAdapter());
  Hive.registerAdapter(PlantAdapter());
  Hive.registerAdapter(PlantRarityAdapter());

  // Open boxes for local storage
  await Hive.openBox<FocusSession>('sessions');
  await Hive.openBox<Plant>('plants');
  await Hive.openBox('settings');
  await Hive.openBox('stats');

  // Initialize notifications
  await NotificationService.instance.initialize();

  runApp(
    // Wrap the entire app with ProviderScope for Riverpod state management
    const ProviderScope(child: FocusGardenApp()),
  );
}

class FocusGardenApp extends ConsumerWidget {
  const FocusGardenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider for reactive theme changes
    final themeData = ref.watch(currentThemeDataProvider);

    return MaterialApp(
      title: 'Focus Garden',
      theme: themeData,

      // Set the main navigation as home
      home: const MainNavigation(),

      // Remove debug banner for cleaner look
      debugShowCheckedModeBanner: false,
    );
  }
}
