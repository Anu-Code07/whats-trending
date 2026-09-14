import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/home/domain/entities/story.dart';

class TrendingHeroCard extends StatelessWidget {
  const TrendingHeroCard({
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
    final gradient = _categoryGradient(story.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                Icons.whatshot,
                size: 120,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _RankBadge(rank: rank),
                      const SizedBox(width: 8),
                      if (story.isHot)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'HOT',
                                style: theme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Text(
                        story.category,
                        style: theme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    story.title,
                    style: theme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        story.primarySourceName,
                        style: theme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        ' · ${_formatTime(story.publishedAt)}',
                        style: theme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      if (story.sourceCount > 1) ...[
                        Text(
                          ' · ${story.sourceCount} sources',
                          style: theme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
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

  List<Color> _categoryGradient(String category) {
    return switch (category.toLowerCase()) {
      'models' => [const Color(0xFF6366F1), const Color(0xFF4338CA)],
      'tools' => [const Color(0xFF0EA5E9), const Color(0xFF0369A1)],
      'startups' => [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'regulation' => [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
      'research' => [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      'industry' => [const Color(0xFF5E8BFF), const Color(0xFF1D4ED8)],
      _ => [const Color(0xFF1C1C2E), const Color(0xFF0A0A0B)],
    };
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(date);
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : Colors.white;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
