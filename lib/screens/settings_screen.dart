import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/theme_service.dart';
import '../services/gamification_service.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';

/// Settings screen for app configuration
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _soundEnabled;
  late bool _notificationsEnabled;
  late bool _hapticEnabled;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box('settings');
    _soundEnabled = box.get('soundEnabled', defaultValue: true) as bool;
    _notificationsEnabled = box.get('notificationsEnabled', defaultValue: true) as bool;
    _hapticEnabled = box.get('hapticEnabled', defaultValue: true) as bool;
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final box = Hive.box('settings');
    await box.put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeServiceProvider);
    final themeService = ref.read(themeServiceProvider.notifier);
    final userLevel = ref.watch(gamificationServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          _buildSectionHeader('Appearance'),
          _buildThemeSection(currentTheme, themeService, userLevel),

          const SizedBox(height: 24),

          // Sound & Haptics Section
          _buildSectionHeader('Sound & Haptics'),
          _buildSoundSection(),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildNotificationsSection(),

          const SizedBox(height: 24),

          // Timer Defaults Section
          _buildSectionHeader('Timer Defaults'),
          _buildTimerSection(),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          _buildAboutSection(),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader('Data'),
          _buildDataSection(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeSection(
    GardenTheme currentTheme,
    ThemeService themeService,
    UserLevel userLevel,
  ) {
    final themes = themeService.getThemesWithUnlockStatus(userLevel.level);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.palette, color: currentTheme.primaryColor),
            title: const Text('Garden Theme'),
            subtitle: Text(currentTheme.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(themes, themeService),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sounds for timer and rewards'),
            value: _soundEnabled,
            onChanged: (value) async {
              setState(() => _soundEnabled = value);
              await _saveSetting('soundEnabled', value);
              AudioService.instance.setSoundEnabled(value);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate on interactions'),
            value: _hapticEnabled,
            onChanged: (value) async {
              setState(() => _hapticEnabled = value);
              await _saveSetting('hapticEnabled', value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reminders and updates'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await _saveSetting('notificationsEnabled', value);
              if (value) {
                await NotificationService.instance.initialize();
              }
            },
          ),
          if (_notificationsEnabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Daily Reminder'),
              subtitle: const Text('Set time for daily focus reminder'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showReminderTimePicker,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    final box = Hive.box('settings');
    final defaultDuration = box.get('defaultTimerDuration', defaultValue: 25) as int;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Default Duration'),
            subtitle: Text('$defaultDuration minutes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDurationPicker(defaultDuration),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Open Source'),
            subtitle: const Text('View on GitHub'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open GitHub link
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Rate Focus Garden'),
            subtitle: const Text('Share your feedback'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open store rating
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_download, color: Colors.blue),
            title: const Text('Export Data'),
            subtitle: const Text('Backup your progress'),
            onTap: () {
              _showSnackBar('Export feature coming soon!');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Reset app and delete all progress'),
            onTap: _confirmClearData,
          ),
        ],
      ),
    );
  }

  void _showThemePicker(List<GardenTheme> themes, ThemeService themeService) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor,
                    ),
                    title: Text(theme.name),
                    subtitle: Text(
                      theme.isUnlocked
                          ? theme.description
                          : 'Unlock at level ${theme.requiredLevel}',
                    ),
                    trailing: theme.isUnlocked
                        ? const Icon(Icons.chevron_right)
                        : const Icon(Icons.lock, color: Colors.grey),
                    enabled: theme.isUnlocked,
                    onTap: theme.isUnlocked
                        ? () async {
                            await themeService.setTheme(theme.id);
                            if (mounted) {
                              Navigator.pop(context);
                              _showSnackBar('Theme changed to ${theme.name}');
                            }
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderTimePicker() async {
    final box = Hive.box('settings');
    final savedHour = box.get('reminderHour', defaultValue: 9) as int;
    final savedMinute = box.get('reminderMinute', defaultValue: 0) as int;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: savedHour, minute: savedMinute),
    );

    if (picked != null) {
      await box.put('reminderHour', picked.hour);
      await box.put('reminderMinute', picked.minute);
      await NotificationService.instance.scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
        title: '🌱 Time to Focus!',
        body: 'Ready to grow your garden?',
      );
      _showSnackBar('Daily reminder set for ${picked.format(context)}');
    }
  }

  void _showDurationPicker(int currentDuration) {
    final durations = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default Timer Duration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...durations.map((duration) {
              return RadioListTile<int>(
                title: Text('$duration minutes'),
                value: duration,
                groupValue: currentDuration,
                onChanged: (value) async {
                  if (value != null) {
                    await _saveSetting('defaultTimerDuration', value);
                    if (mounted) {
                      Navigator.pop(context);
                      _showSnackBar('Default duration set to $value minutes');
                    }
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your progress, plants, and statistics. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear all data
              await Hive.box('sessions').clear();
              await Hive.box('plants').clear();
              await Hive.box('stats').clear();
              await Hive.box('settings').clear();

              if (mounted) {
                Navigator.pop(context);
                _showSnackBar('All data cleared');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
