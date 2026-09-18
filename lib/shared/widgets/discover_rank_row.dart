import 'package:flutter/material.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/theme/ns_palette.dart';
import 'sparkline.dart';

class DiscoverRankRow extends StatelessWidget {
  const DiscoverRankRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rank,
    required this.seed,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int rank;
  final int seed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final ns = context.ns;
    final visual = CategoryVisuals.of(title);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                rank.toString().padLeft(2, '0'),
                style: theme.titleMedium?.copyWith(
                  color: ns.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(visual.icon, color: visual.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.labelSmall?.copyWith(color: ns.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Sparkline(seed: seed, color: visual.color),
          ],
        ),
      ),
    );
  }
}
