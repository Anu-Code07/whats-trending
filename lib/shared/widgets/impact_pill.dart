import 'package:flutter/material.dart';
import '../../core/theme/ns_palette.dart';
import '../../features/home/domain/entities/story.dart';

class ImpactPill extends StatelessWidget {
  const ImpactPill({super.key, required this.impact});

  final ImpactLevel impact;

  Color get _dotColor {
    return switch (impact) {
      ImpactLevel.critical => NsPalette.impactCritical,
      ImpactLevel.high => NsPalette.impactHigh,
      ImpactLevel.medium => NsPalette.warning,
      ImpactLevel.low => const Color(0xFF9A9AA8),
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
    final ns = context.ns;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ns.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ns.border),
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
                  color: ns.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
