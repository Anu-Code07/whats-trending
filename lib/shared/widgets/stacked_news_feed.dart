import 'package:flutter/material.dart';
import '../../features/home/domain/entities/story.dart';
import 'news_card.dart';

/// Overlapping card feed — matches the E-News home screen stack layout.
class StackedNewsFeed extends StatelessWidget {
  const StackedNewsFeed({
    super.key,
    required this.stories,
    required this.onTap,
    this.onSave,
  });

  final List<Story> stories;
  final void Function(Story story) onTap;
  final void Function(Story story)? onSave;

  static const _overlap = 88.0;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final story = stories[index];
          return Transform.translate(
            offset: Offset(0, index == 0 ? 0 : -_overlap * index),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: index == stories.length - 1 ? 120 : 0,
              ),
              child: NewsCard(
                story: story,
                colorIndex: index,
                featured: index == 0,
                onTap: () => onTap(story),
                onSave: onSave != null ? () => onSave!(story) : null,
              ),
            ),
          );
        },
        childCount: stories.length,
      ),
    );
  }
}
