import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/domain/entities/story.dart';

class TrendingCarousel extends StatelessWidget {
  const TrendingCarousel({
    super.key,
    required this.stories,
    required this.onStoryTap,
  });

  final List<Story> stories;
  final void Function(Story story) onStoryTap;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final story = stories[index];
          return _CarouselCard(
            story: story,
            onTap: () => onStoryTap(story),
          );
        },
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.story, required this.onTap});
  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, size: 14, color: AppColors.impactHigh),
                const SizedBox(width: 4),
                Text(
                  'Rising',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.impactHigh,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  story.category,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                story.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              story.primarySourceName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
