import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../models/focus_session.dart';

/// Statistics screen showing user's focus data and achievements
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final storageService = ref.watch(storageServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Your Progress',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key metrics cards
            _buildKeyMetrics(context, stats),

            const SizedBox(height: 24),

            // Recent activity
            _buildRecentActivity(context, storageService),

            const SizedBox(height: 24),

            // Achievements section
            _buildAchievements(context, stats),

            const SizedBox(height: 24),

            // Weekly overview
            _buildWeeklyOverview(context, storageService),
          ],
        ),
      ),
    );
  }

  /// Build key metrics cards (total hours, sessions, streak)
  Widget _buildKeyMetrics(BuildContext context, Map<String, dynamic> stats) {
    final totalMinutes = stats['totalMinutes'] as int;
    final completedSessions = stats['completedSessions'] as int;
    final currentStreak = stats['currentStreak'] as int;
    final longestStreak = stats['longestStreak'] as int;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Focus Hours',
                '${(totalMinutes / 60).toStringAsFixed(1)}h',
                Icons.schedule,
                Colors.blue,
                subtitle: '$totalMinutes minutes total',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Sessions',
                '$completedSessions',
                Icons.check_circle,
                Colors.green,
                subtitle: 'completed',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Current Streak',
                '$currentStreak',
                Icons.local_fire_department,
                currentStreak > 0 ? Colors.orange : Colors.grey,
                subtitle: 'days in a row',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Best Streak',
                '$longestStreak',
                Icons.emoji_events,
                Colors.amber,
                subtitle: 'days record',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual metric card
  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build recent activity section
  Widget _buildRecentActivity(
      BuildContext context, StorageService storageService) {
    final recentSessions = storageService.getRecentSessions(7);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentSessions.isEmpty)
              _buildEmptyState('No recent sessions', Icons.timer_off)
            else
              ...recentSessions
                  .take(5)
                  .map((session) => _buildSessionItem(session))
                  .toList(),
          ],
        ),
      ),
    );
  }

  /// Build individual session item
  Widget _buildSessionItem(FocusSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Completion indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: session.completed ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 12),

          // Session info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.formattedDuration,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatSessionDate(session.startTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Plant indicator (if unlocked)
          if (session.plantUnlocked != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_florist,
                    size: 12,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Plant!',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build achievements section
  Widget _buildAchievements(BuildContext context, Map<String, dynamic> stats) {
    final achievements = _getAchievements(stats);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (achievements.isEmpty)
              _buildEmptyState(
                  'Complete sessions to earn achievements!', Icons.star_outline)
            else
              ...achievements
                  .map((achievement) => _buildAchievementItem(achievement))
                  .toList(),
          ],
        ),
      ),
    );
  }

  /// Build individual achievement item
  Widget _buildAchievementItem(Achievement achievement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: achievement.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Achievement info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Date earned
          Text(
            _formatDate(achievement.earnedAt),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Build weekly overview section
  Widget _buildWeeklyOverview(
      BuildContext context, StorageService storageService) {
    final weekSessions = storageService.getRecentSessions(7);
    final weeklyMinutes = weekSessions
        .where((s) => s.completed)
        .fold<int>(0, (sum, session) => sum + session.actualMinutes);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_view_week,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWeekStat(
                    'Total Time',
                    '${(weeklyMinutes / 60).toStringAsFixed(1)}h',
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWeekStat(
                    'Sessions',
                    '${weekSessions.where((s) => s.completed).length}',
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWeekStat(
                    'Average',
                    weekSessions.isNotEmpty
                        ? '${(weeklyMinutes / weekSessions.where((s) => s.completed).length).round()}m'
                        : '0m',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build weekly stat item
  Widget _buildWeekStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
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

  /// Build empty state widget
  Widget _buildEmptyState(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Get achievements based on stats
  List<Achievement> _getAchievements(Map<String, dynamic> stats) {
    final achievements = <Achievement>[];
    final totalMinutes = stats['totalMinutes'] as int;
    final completedSessions = stats['completedSessions'] as int;
    final currentStreak = stats['currentStreak'] as int;

    // First session achievement
    if (completedSessions >= 1) {
      achievements.add(Achievement(
        title: 'First Focus',
        description: 'Completed your first focus session',
        icon: Icons.play_arrow,
        color: Colors.green,
        earnedAt: DateTime.now(),
      ));
    }

    // Hour milestone
    if (totalMinutes >= 60) {
      achievements.add(Achievement(
        title: 'One Hour Focused',
        description: 'Accumulated 1 hour of focus time',
        icon: Icons.schedule,
        color: Colors.blue,
        earnedAt: DateTime.now(),
      ));
    }

    // Session milestone
    if (completedSessions >= 10) {
      achievements.add(Achievement(
        title: 'Dedicated Focuser',
        description: 'Completed 10 focus sessions',
        icon: Icons.star,
        color: Colors.purple,
        earnedAt: DateTime.now(),
      ));
    }

    // Streak achievement
    if (currentStreak >= 3) {
      achievements.add(Achievement(
        title: 'Streak Master',
        description: 'Maintained a 3-day focus streak',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        earnedAt: DateTime.now(),
      ));
    }

    return achievements;
  }

  /// Format session date
  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today ${_formatTime(date)}';
    } else if (difference == 1) {
      return 'Yesterday ${_formatTime(date)}';
    } else {
      return '${difference} days ago';
    }
  }

  /// Format time
  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $amPm';
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

/// Achievement model
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime earnedAt;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.earnedAt,
  });
}
