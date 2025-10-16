import 'package:flutter/material.dart';
import '../services/timer_service.dart';

/// Timer control buttons (Start, Pause, Resume, Reset, Stop)
class TimerControls extends StatelessWidget {
  final TimerStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onStop;

  const TimerControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Secondary action button (Reset/Stop)
        if (_shouldShowSecondaryButton()) ...[
          _buildSecondaryButton(context),
          const SizedBox(width: 20),
        ],

        // Primary action button (Start/Pause/Resume)
        _buildPrimaryButton(context),
      ],
    );
  }

  /// Build the main action button
  Widget _buildPrimaryButton(BuildContext context) {
    IconData icon;
    String label;
    VoidCallback onPressed;
    Color backgroundColor = Theme.of(context).primaryColor;

    switch (status) {
      case TimerStatus.initial:
      case TimerStatus.cancelled:
        icon = Icons.play_arrow;
        label = 'Start Focus';
        onPressed = onStart;
        break;
      case TimerStatus.running:
        icon = Icons.pause;
        label = 'Pause';
        onPressed = onPause;
        break;
      case TimerStatus.paused:
        icon = Icons.play_arrow;
        label = 'Resume';
        onPressed = onResume;
        break;
      case TimerStatus.completed:
        icon = Icons.refresh;
        label = 'New Session';
        onPressed = onReset;
        backgroundColor = Colors.green;
        break;
    }

    return _buildControlButton(
      context: context,
      icon: icon,
      label: label,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      isPrimary: true,
    );
  }

  /// Build secondary button (Reset/Stop)
  Widget _buildSecondaryButton(BuildContext context) {
    if (status == TimerStatus.running || status == TimerStatus.paused) {
      return _buildControlButton(
        context: context,
        icon: Icons.stop,
        label: 'Stop',
        onPressed: onStop,
        backgroundColor: Colors.grey[600]!,
        isPrimary: false,
      );
    } else if (status == TimerStatus.completed) {
      return _buildControlButton(
        context: context,
        icon: Icons.refresh,
        label: 'Reset',
        onPressed: onReset,
        backgroundColor: Colors.grey[600]!,
        isPrimary: false,
      );
    }

    return const SizedBox.shrink();
  }

  /// Check if secondary button should be shown
  bool _shouldShowSecondaryButton() {
    return status == TimerStatus.running ||
        status == TimerStatus.paused ||
        status == TimerStatus.completed;
  }

  /// Build a control button with consistent styling
  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required bool isPrimary,
  }) {
    final size = isPrimary ? 72.0 : 56.0;
    final iconSize = isPrimary ? 32.0 : 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular button
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(size / 2),
              onTap: onPressed,
              child: Icon(
                icon,
                size: iconSize,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: isPrimary ? 16 : 14,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }
}
