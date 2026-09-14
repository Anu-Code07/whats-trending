import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/domain/entities/story.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.story,
    required this.colorIndex,
    required this.onTap,
    this.onSave,
    this.compact = false,
    this.featured = false,
  });

  final Story story;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool compact;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.cardColorForIndex(colorIndex);
    final radius = featured ? 32.0 : 28.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(featured ? 24 : compact ? 16 : 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: featured ? 0.35 : 0.25),
              blurRadius: featured ? 32 : 24,
              offset: Offset(0, featured ? 12 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.isBreaking || story.isHot)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LiveBadge(),
              ),
            Text(
              story.title,
              style: AppTheme.cardHeadline(context).copyWith(
                fontSize: featured ? 24 : compact ? 18 : 22,
              ),
              maxLines: featured ? 4 : compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _timeLabel(story.publishedAt),
              style: AppTheme.cardBody(context).copyWith(
                fontSize: 12,
                color: AppColors.cardTextMuted,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 16),
              PublisherRow(sourceName: story.primarySourceName),
              const SizedBox(height: 14),
              Text(
                story.summary,
                style: AppTheme.cardBody(context),
                maxLines: featured ? 4 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                CardActionIcon(
                  icon: Icons.thumb_up_outlined,
                  onTap: () => HapticFeedback.lightImpact(),
                ),
                const SizedBox(width: 16),
                CardActionIcon(
                  icon: story.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  filled: story.isSaved,
                  onTap: onSave,
                ),
                const SizedBox(width: 16),
                CardActionIcon(
                  icon: Icons.share_outlined,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: story.primarySourceUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inHours < 1) return 'Updated ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${DateFormat('MMM d').format(date)}';
  }
}

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.live,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Live',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PublisherRow extends StatelessWidget {
  const PublisherRow({super.key, required this.sourceName});

  final String sourceName;

  @override
  Widget build(BuildContext context) {
    final initial = sourceName.isNotEmpty ? sourceName[0].toUpperCase() : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.cardText.withValues(alpha: 0.12),
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.cardText,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Published by $sourceName',
            style: AppTheme.cardBody(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.cardText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Follow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class CardActionIcon extends StatelessWidget {
  const CardActionIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: 22,
        color: filled ? AppColors.cardText : AppColors.cardTextSecondary,
      ),
    );
  }
}
