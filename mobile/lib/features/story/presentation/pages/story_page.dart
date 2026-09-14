import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/impact_pill.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/relevance_badge.dart';
import '../bloc/story_bloc.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state) {
            StoryInitial() || StoryLoading() => const LoadingSkeleton(count: 1),
            StoryError(message: final msg) => Center(child: Text(msg)),
            StoryLoaded(story: final story, depth: final depth) => _StoryContent(
                story: story,
                depth: depth,
              ),
          },
        );
      },
    );
  }
}

class _StoryContent extends StatelessWidget {
  const _StoryContent({required this.story, required this.depth});

  final dynamic story;
  final String depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              onPressed: () => context.read<StoryBloc>().add(const ToggleSave()),
              icon: Icon(
                story.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                color: story.isSaved ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RelevanceBadge(percent: story.relevancePercent),
                    const SizedBox(width: 8),
                    ImpactPill(impact: story.impact),
                  ],
                ),
                const SizedBox(height: 16),
                Text(story.title, style: theme.displayLarge?.copyWith(fontSize: 26)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      story.primarySourceName,
                      style: theme.bodySmall?.copyWith(color: AppColors.accent),
                    ),
                    Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
                    Text(
                      DateFormat('MMM d, h:mm a').format(story.publishedAt),
                      style: theme.bodySmall?.copyWith(color: AppColors.textTertiary),
                    ),
                    Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
                    Text(
                      '${story.sourceCount} sources',
                      style: theme.bodySmall?.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DepthSelector(
                  currentDepth: depth,
                  onChanged: (d) => context.read<StoryBloc>().add(ChangeStoryDepth(depth: d)),
                ),
                const SizedBox(height: 24),
                _Section(title: 'What happened?', child: Text(story.summary, style: theme.bodyMedium)),
                const SizedBox(height: 24),
                _Section(
                  title: 'Why it matters',
                  child: Text(story.whyItMatters, style: theme.bodyMedium),
                ),
                if (story.whoShouldCare.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Who should care?',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: story.whoShouldCare
                          .map((c) => Chip(label: Text(c)))
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _Section(
                  title: 'Your relevance',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${story.relevancePercent}%',
                        style: theme.headlineMedium?.copyWith(color: AppColors.relevanceHigh),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.relevanceExplanation,
                        style: theme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (story.sources.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Sources',
                    child: Column(
                      children: story.sources.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              _SourceTypeBadge(type: s.contentType),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s.name, style: theme.bodySmall)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                if (story.timeline.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Timeline',
                    child: Column(
                      children: story.timeline.map((t) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.title, style: theme.bodySmall),
                                    Text(
                                      DateFormat('MMM d, h:mm a').format(t.occurredAt),
                                      style: theme.labelSmall?.copyWith(color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                if (story.communityReaction != null) ...[
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Community reaction',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opinion · ${story.communityReaction!.source}',
                            style: theme.labelSmall?.copyWith(color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: 8),
                          Text(story.communityReaction!.summary, style: theme.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: story.communityReaction!.themes
                                .map((t) => Chip(label: Text(t), visualDensity: VisualDensity.compact))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Build something with this'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppColors.accent),
                    foregroundColor: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DepthSelector extends StatelessWidget {
  const _DepthSelector({required this.currentDepth, required this.onChanged});

  final String currentDepth;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const depths = [
      ('quick', '30 sec'),
      ('normal', '3 min'),
      ('deep', '10 min'),
    ];

    return Row(
      children: depths.map((d) {
        final isSelected = currentDepth == d.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: d.$1 != 'deep' ? 8 : 0),
            child: GestureDetector(
              onTap: () => onChanged(d.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentMuted : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Text(
                  d.$2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SourceTypeBadge extends StatelessWidget {
  const _SourceTypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      'official' => AppColors.relevanceHigh,
      'community' => AppColors.relevanceMid,
      _ => AppColors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
