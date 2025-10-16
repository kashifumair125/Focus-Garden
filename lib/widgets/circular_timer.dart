import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Circular progress timer widget that shows remaining time and progress
class CircularTimer extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String timeRemaining; // Formatted time string (MM:SS)
  final bool isRunning;
  final int totalMinutes;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.timeRemaining,
    required this.isRunning,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Progress circle
            SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  progress: progress,
                  isRunning: isRunning,
                ),
              ),
            ),

            // Center content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Time display
                Text(
                  timeRemaining,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color:
                        isRunning ? const Color(0xFF2E7D32) : Colors.grey[600],
                    fontFeatures: const [
                      FontFeature.tabularFigures()
                    ], // Monospace numbers
                  ),
                ),

                const SizedBox(height: 8),

                // Duration info
                Text(
                  '${totalMinutes} minute${totalMinutes != 1 ? 's' : ''} focus',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 16),

                // Status indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get color based on timer state
  Color _getStatusColor() {
    if (progress >= 1.0) return Colors.green;
    if (isRunning) return const Color(0xFF4CAF50);
    return Colors.grey;
  }

  /// Get status text based on timer state
  String _getStatusText() {
    if (progress >= 1.0) return 'Completed!';
    if (isRunning) return 'Focusing...';
    return 'Ready to focus';
  }
}

/// Custom painter for the circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isRunning;

  CircularProgressPainter({
    required this.progress,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background track
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = isRunning ? const Color(0xFF4CAF50) : Colors.grey[400]!
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (-90 degrees) clockwise
    const startAngle = -math.pi / 2; // Top of circle
    final sweepAngle = 2 * math.pi * progress; // Full circle = 2π

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Optional: Add a subtle glow effect when running
    if (isRunning && progress > 0) {
      final glowPaint = Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0.3)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRunning != isRunning;
  }
}
