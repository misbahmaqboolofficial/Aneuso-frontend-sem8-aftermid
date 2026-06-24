import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Material 3 star selector (1–5) with optional label for selected value.
class StarRatingSelector extends StatelessWidget {
  const StarRatingSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 40,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.textMuted,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  static String labelFor(int stars) {
    switch (stars) {
      case 1:
        return 'Poor';
      case 2:
        return 'Bad';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            final filled = star <= value;
            return IconButton(
              splashRadius: size * 0.7,
              onPressed: () => onChanged(star),
              icon: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size,
                color: filled ? activeColor : inactiveColor,
              ),
            );
          }),
        ),
        if (value >= 1 && value <= 5)
          Text(
            labelFor(value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );
  }
}
