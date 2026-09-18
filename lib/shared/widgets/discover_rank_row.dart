import 'package:flutter/material.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/theme/ns_palette.dart';
import '../../features/home/domain/entities/story.dart';
import 'sparkline.dart';

class DiscoverRankRow extends StatelessWidget {
  const DiscoverRankRow({
    super.key,
    required this.story,
    required this.rank,
    required this.onTap,
  });

  final Story story;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final ns = context.ns;
    final visual = CategoryVisuals.of(story.category);
    final reads = ((story.trendScore * 2400) + (story.sourceCount * 380)).clamp(400, 99999);

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
                    story.category,
                    style: theme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${story.primarySourceName}  ·  ${_formatReads(reads)} reads',
                    style: theme.labelSmall?.copyWith(color: ns.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Sparkline(seed: story.id.hashCode, color: visual.color),
          ],
        ),
      ),
    );
  }

  String _formatReads(int reads) {
    if (reads >= 1000) {
      return '${(reads / 1000).toStringAsFixed(1)}k';
    }
    return '$reads';
  }
}
