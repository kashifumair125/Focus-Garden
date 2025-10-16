import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/focus_session.dart';
import 'models/plant.dart';
import 'screens/main_navigation.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters for our custom models
  Hive.registerAdapter(FocusSessionAdapter());
  Hive.registerAdapter(PlantAdapter());

  // Open boxes for local storage
  await Hive.openBox<FocusSession>('sessions');
  await Hive.openBox<Plant>('plants');
  await Hive.openBox('settings');
  await Hive.openBox('stats');

  runApp(
    // Wrap the entire app with ProviderScope for Riverpod state management
    const ProviderScope(child: FocusGardenApp()),
  );
}

class FocusGardenApp extends StatelessWidget {
  const FocusGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Garden',
      theme: ThemeData(
        // Modern, clean color scheme inspired by nature/gardening
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF4CAF50), // Green
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),

        // Clean typography
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32), // Dark green
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF424242), // Dark grey
          ),
        ),

        // Card design (use defaults for maximum SDK compatibility)

        // Button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        useMaterial3: true,
      ),

      // Set the main navigation as home
      home: const MainNavigation(),

      // Remove debug banner for cleaner look
      debugShowCheckedModeBanner: false,
    );
  }
}
