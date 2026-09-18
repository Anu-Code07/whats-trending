import 'package:flutter/material.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/theme/ns_palette.dart';

class InterestTile extends StatelessWidget {
  const InterestTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisuals.of(label);
    final ns = context.ns;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [NsPalette.accentBright, NsPalette.accentDeep],
                )
              : null,
          color: selected ? null : ns.surface,
          border: Border.all(
            color: selected ? Colors.transparent : ns.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: NsPalette.accent.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              visual.icon,
              size: 26,
              color: selected ? Colors.white : visual.color,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? Colors.white : ns.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
