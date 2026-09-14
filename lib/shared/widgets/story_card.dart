import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/domain/entities/story.dart';
import 'impact_pill.dart';
import 'relevance_badge.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    this.onSave,
    this.compact = false,
  });

  final Story story;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final timeAgo = _formatTimeAgo(story.publishedAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: story.relevancePercent >= 90
                ? AppColors.relevanceHigh.withValues(alpha: 0.2)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RelevanceBadge(percent: story.relevancePercent),
                const Spacer(),
                if (story.isBreaking)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.impactCritical.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'BREAKING',
                      style: theme.labelSmall?.copyWith(
                        color: AppColors.impactCritical,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              story.title,
              style: theme.titleMedium,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (!compact) ...[
              const SizedBox(height: 8),
              Text(
                story.summary,
                style: theme.bodySmall?.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _CategoryChip(label: story.category),
                const SizedBox(width: 8),
                Text(
                  '${story.sourceCount} sources',
                  style: theme.labelSmall?.copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(width: 8),
                Text('·', style: TextStyle(color: AppColors.textTertiary)),
                const SizedBox(width: 8),
                Text(
                  timeAgo,
                  style: theme.labelSmall?.copyWith(color: AppColors.textTertiary),
                ),
                const Spacer(),
                ImpactPill(impact: story.impact),
                if (onSave != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onSave,
                    child: Icon(
                      story.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                      size: 20,
                      color: story.isSaved ? AppColors.accent : AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(date);
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.accent,
            ),
      ),
    );
  }
}
