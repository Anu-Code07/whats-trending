import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/domain/entities/story.dart';

class ImpactPill extends StatelessWidget {
  const ImpactPill({super.key, required this.impact});

  final ImpactLevel impact;

  Color get _dotColor {
    return switch (impact) {
      ImpactLevel.critical => AppColors.impactCritical,
      ImpactLevel.high => AppColors.impactHigh,
      ImpactLevel.medium => AppColors.relevanceMid,
      ImpactLevel.low => AppColors.textTertiary,
    };
  }

  String get _label {
    return switch (impact) {
      ImpactLevel.critical => 'Critical',
      ImpactLevel.high => 'High',
      ImpactLevel.medium => 'Medium',
      ImpactLevel.low => 'Low',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
