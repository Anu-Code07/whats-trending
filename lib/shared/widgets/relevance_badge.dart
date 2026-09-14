import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RelevanceBadge extends StatelessWidget {
  const RelevanceBadge({super.key, required this.percent});

  final int percent;

  Color get _color {
    if (percent >= 90) return AppColors.relevanceHigh;
    if (percent >= 75) return AppColors.relevanceMid;
    return AppColors.textSecondary;
  }

  String get _emoji {
    if (percent >= 95) return '🔥';
    if (percent >= 90) return '🧠';
    if (percent >= 85) return '🚀';
    return '🔐';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$_emoji $percent% relevant',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
