import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/domain/entities/story.dart';

class StackedSavedCards extends StatelessWidget {
  const StackedSavedCards({
    super.key,
    required this.stories,
    required this.onTap,
  });

  final List<Story> stories;
  final void Function(Story story) onTap;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    final visible = stories.take(4).toList();
    final stackHeight = 120.0 + (visible.length - 1) * 28.0;

    return SizedBox(
      height: stackHeight + 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = visible.length - 1; i >= 0; i--)
            Positioned(
              top: i * 28.0,
              left: 0,
              right: 0,
              child: _StackedCard(
                story: visible[i],
                colorIndex: i,
                onTap: () => onTap(visible[i]),
                isTop: i == 0,
              ),
            ),
        ],
      ),
    );
  }
}

class _StackedCard extends StatelessWidget {
  const _StackedCard({
    required this.story,
    required this.colorIndex,
    required this.onTap,
    required this.isTop,
  });

  final Story story;
  final int colorIndex;
  final VoidCallback onTap;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColorForIndex(colorIndex),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story.title,
              style: AppTheme.cardHeadline(context).copyWith(fontSize: isTop ? 20 : 17),
              maxLines: isTop ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isTop) ...[
              const SizedBox(height: 8),
              Text(
                story.primarySourceName,
                style: AppTheme.cardBody(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.cardText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
