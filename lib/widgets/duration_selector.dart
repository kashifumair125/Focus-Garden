import 'package:flutter/material.dart';

/// Widget for selecting focus session duration
class DurationSelector extends StatefulWidget {
  final int initialDuration; // In minutes
  final Function(int) onDurationChanged; // Callback with selected minutes

  const DurationSelector({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
  });

  @override
  State<DurationSelector> createState() => _DurationSelectorState();
}

class _DurationSelectorState extends State<DurationSelector> {
  late int selectedDuration;

  // Predefined duration options (in minutes)
  final List<int> quickOptions = [5, 15, 25, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    selectedDuration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Focus Duration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
            ),

            const SizedBox(height: 16),

            // Quick options - constrained to prevent overflow
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: quickOptions
                    .map((duration) => _buildQuickOption(duration))
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Custom duration slider
            _buildCustomDurationSection(),
          ],
        ),
      ),
    );
  }

  /// Build quick duration option chips
  Widget _buildQuickOption(int minutes) {
    final isSelected = selectedDuration == minutes;

    return GestureDetector(
      onTap: () => _selectDuration(minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          '${minutes}m',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Build custom duration slider section
  Widget _buildCustomDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with proper constraints
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Custom Duration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${selectedDuration} min',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 12),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: selectedDuration.toDouble(),
            min: 5,
            max: 120,
            divisions: 23, // 5-minute increments
            onChanged: (value) {
              final roundedValue =
                  (value / 5).round() * 5; // Round to nearest 5
              _selectDuration(roundedValue);
            },
          ),
        ),

        // Helper text with proper constraints
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '2 hours',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Select a duration and notify parent
  void _selectDuration(int minutes) {
    setState(() {
      selectedDuration = minutes;
    });
    widget.onDurationChanged(minutes);
  }
}
