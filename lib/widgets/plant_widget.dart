import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../models/plant.dart';

/// Widget to display a plant (either as image or animation)
class PlantWidget extends StatefulWidget {
  final Plant plant;
  final double size;
  final bool showAnimation; // Show Lottie animation or static image
  final bool showParticles; // Show particle effects

  const PlantWidget({
    super.key,
    required this.plant,
    this.size = 80,
    this.showAnimation = false,
    this.showParticles = false,
  });

  @override
  State<PlantWidget> createState() => _PlantWidgetState();
}

class _PlantWidgetState extends State<PlantWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    if (widget.showAnimation) {
      _glowController.repeat(reverse: true);
    }
    if (widget.showParticles) {
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Particle effects
        if (widget.showParticles)
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size * 1.5, widget.size * 1.5),
                painter: ParticlePainter(
                  animation: _particleAnimation.value,
                  color: widget.plant.rarityColor,
                ),
              );
            },
          ),

        // Main plant container with enhanced styling
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    widget.plant.rarityColor.withOpacity(0.2),
                    widget.plant.rarityColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.plant.rarityColor.withOpacity(
                    0.3 + (_glowAnimation.value * 0.3),
                  ),
                  width: 2 + (_glowAnimation.value * 1),
                ),
                boxShadow: widget.showAnimation
                    ? [
                        BoxShadow(
                          color: widget.plant.rarityColor.withOpacity(
                            0.3 + (_glowAnimation.value * 0.2),
                          ),
                          blurRadius: 10 + (_glowAnimation.value * 5),
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: _buildPlantContent(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlantContent() {
    // Try to show Lottie animation first
    if (widget.showAnimation && widget.plant.animationPath != null) {
      return Lottie.asset(
        widget.plant.animationPath!,
        fit: BoxFit.cover,
        animate: true,
        repeat: true,
      );
    }

    // Try to show static image
    if (widget.plant.imagePath.isNotEmpty &&
        widget.plant.imagePath != 'assets/plants/${widget.plant.id}.png') {
      return Image.asset(
        widget.plant.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if image fails to load
          return Icon(
            widget.plant.icon,
            size: widget.size * 0.5,
            color: widget.plant.rarityColor,
          );
        },
      );
    }

    // Fallback to icon
    return Icon(
      widget.plant.icon,
      size: widget.size * 0.5,
      color: widget.plant.rarityColor,
    );
  }
}

/// Custom painter for particle effects around plants
class ParticlePainter extends CustomPainter {
  final double animation;
  final Color color;

  ParticlePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw floating particles
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (animation * 2 * math.pi);
      final distance = radius * (0.3 + (animation * 0.7));

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final particleSize = 2 + (math.sin(animation * math.pi + i) * 1);

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint
          ..color = color
              .withOpacity(0.4 + (math.sin(animation * math.pi + i) * 0.3)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
