import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/theme/ns_palette.dart';
import '../../features/home/domain/entities/story.dart';
import 'signal_badge.dart';
import 'story_art.dart';

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
    if (compact) {
      return _CompactStoryCard(story: story, onTap: onTap);
    }
    return _FeedStoryCard(story: story, onTap: onTap, onSave: onSave);
  }
}

class _FeedStoryCard extends StatelessWidget {
  const _FeedStoryCard({
    required this.story,
    required this.onTap,
    this.onSave,
  });

  final Story story;
  final VoidCallback onTap;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final ns = context.ns;
    final timeAgo = _formatTimeAgo(story.publishedAt);
    final visual = CategoryVisuals.of(story.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: ns.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ns.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: ns.cardShadow,
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: StoryArt(story: story, height: 148, borderRadius: 16),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(visual.icon, size: 13, color: visual.color),
                      const SizedBox(width: 6),
                      Text(
                        story.category.toUpperCase(),
                        style: theme.labelSmall?.copyWith(
                          color: visual.color,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        '  ·  $timeAgo',
                        style: theme.labelSmall?.copyWith(color: ns.textTertiary),
                      ),
                      const Spacer(),
                      SignalBadge(percent: story.relevancePercent),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    story.title,
                    style: theme.titleMedium?.copyWith(fontSize: 18, height: 1.25),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.summary,
                    style: theme.bodySmall?.copyWith(color: ns.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (story.whyItMatters.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _WhyItMattersBox(text: story.whyItMatters),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Read time  ${_readMinutes(story)} min',
                        style: theme.labelSmall?.copyWith(color: ns.textTertiary),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Impact  ${_impactLabel(story.impact)}',
                        style: theme.labelSmall?.copyWith(color: ns.textTertiary),
                      ),
                      const Spacer(),
                      Text(
                        '${story.sourceCount} sources',
                        style: theme.labelSmall?.copyWith(color: ns.textTertiary),
                      ),
                      if (onSave != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onSave,
                          child: Icon(
                            story.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                            size: 20,
                            color: story.isSaved ? NsPalette.accent : ns.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStoryCard extends StatelessWidget {
  const _CompactStoryCard({required this.story, required this.onTap});

  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final ns = context.ns;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StoryThumb(story: story, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: theme.titleMedium?.copyWith(fontSize: 15, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${story.category.toUpperCase()}  ·  ${_formatTimeAgo(story.publishedAt)}',
                    style: theme.labelSmall?.copyWith(
                      color: ns.textTertiary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhyItMattersBox extends StatelessWidget {
  const _WhyItMattersBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: NsPalette.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.auto_awesome, size: 14, color: NsPalette.accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why it matters',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NsPalette.accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ns.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return DateFormat('MMM d').format(date);
}

int _readMinutes(Story story) {
  final words = story.summary.split(RegExp(r'\s+')).length;
  return (words / 40).clamp(2, 12).round();
}

String _impactLabel(ImpactLevel impact) {
  return switch (impact) {
    ImpactLevel.critical => 'Critical',
    ImpactLevel.high => 'High',
    ImpactLevel.medium => 'Medium',
    ImpactLevel.low => 'Low',
  };
}
