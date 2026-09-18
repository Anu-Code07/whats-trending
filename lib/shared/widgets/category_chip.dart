import 'package:flutter/material.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/theme/ns_palette.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.filled = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    final visual = CategoryVisuals.of(label);
    final isOn = selected || filled;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isOn ? NsPalette.accent : ns.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOn ? NsPalette.accent : ns.border,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: NsPalette.accent.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              visual.icon,
              size: 14,
              color: isOn ? Colors.white : visual.color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isOn ? Colors.white : ns.textSecondary,
                    fontWeight: isOn ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
