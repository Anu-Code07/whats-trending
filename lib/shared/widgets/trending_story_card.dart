import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/domain/entities/story.dart';

class TrendingStoryCard extends StatelessWidget {
  const TrendingStoryCard({
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: rank <= 3
                ? AppColors.accent.withValues(alpha: 0.25)
                : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RankNumber(rank: rank),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryTag(label: story.category),
                      if (story.isHot) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.trending_up, size: 14, color: AppColors.relevanceHigh),
                      ],
                      const Spacer(),
                      if (story.trendScore > 1)
                        Text(
                          '${story.trendScore}x',
                          style: theme.labelSmall?.copyWith(
                            color: AppColors.relevanceHigh,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    story.title,
                    style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    story.summary,
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        story.primarySourceName,
                        style: theme.labelSmall?.copyWith(color: AppColors.accent),
                      ),
                      Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
                      Text(
                        _formatTime(story.publishedAt),
                        style: theme.labelSmall?.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('MMM d').format(date);
  }
}

class _RankNumber extends StatelessWidget {
  const _RankNumber({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isTop = rank <= 3;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isTop ? AppColors.accentMuted : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: isTop ? AppColors.accent : AppColors.textTertiary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentMuted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.accent,
              fontSize: 10,
            ),
      ),
    );
  }
}
