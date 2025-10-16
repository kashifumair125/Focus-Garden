import 'package:flutter/material.dart';
import '../models/plant.dart';

/// Popup dialog shown when user unlocks a new plant
class RewardPopup extends StatefulWidget {
  final Plant plant;
  final VoidCallback onContinue;

  const RewardPopup({
    super.key,
    required this.plant,
    required this.onContinue,
  });

  @override
  State<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends State<RewardPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildDialogContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with celebration
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.plant.rarityColor.withOpacity(0.8),
                  widget.plant.rarityColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Celebration icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Plant Unlocked!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Plant details
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Plant icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.plant.rarityColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.plant.rarityColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.plant.icon,
                    size: 50,
                    color: widget.plant.rarityColor,
                  ),
                ),

                const SizedBox(height: 20),

                // Plant name
                Text(
                  widget.plant.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(height: 8),

                // Rarity badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.plant.rarityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.plant.rarityColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    widget.plant.rarity.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.plant.rarityColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Plant description
                Text(
                  widget.plant.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.plant.rarityColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Add to Garden',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // View garden button
                TextButton(
                  onPressed: () {
                    widget.onContinue();
                    // Could navigate to garden tab here
                  },
                  child: Text(
                    'View Garden',
                    style: TextStyle(
                      color: widget.plant.rarityColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
