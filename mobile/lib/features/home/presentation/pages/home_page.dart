import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/story_card.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return switch (state) {
          HomeInitial() || HomeLoading() => const Scaffold(
              body: LoadingSkeleton(),
            ),
          HomeError(message: final msg) => Scaffold(
              body: EmptyState(
                title: 'Something went wrong',
                subtitle: msg,
                actionLabel: 'Retry',
                onAction: () => context.read<HomeBloc>().add(const LoadHomeFeed()),
              ),
            ),
          HomeLoaded(feed: final feed) => Scaffold(
              body: RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(const RefreshHomeFeed());
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                color: AppColors.accent,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        feed.greeting,
                                        style: Theme.of(context).textTheme.displayLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Know what matters in tech.',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => context.push('/search'),
                                  icon: const Icon(Icons.search, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            if (feed.sinceLastChecked.isNotEmpty) ...[
                              const SizedBox(height: 28),
                              _SinceLastCheckedSection(
                                stories: feed.sinceLastChecked,
                                onStoryTap: (id) => context.push('/story/$id'),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Text(
                              'For you',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${feed.stories.length} important things happening',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final story = feed.stories[index];
                            return StoryCard(
                              story: story,
                              onTap: () => context.push('/story/${story.id}'),
                              onSave: () => context.read<HomeBloc>().add(
                                    ToggleStorySave(
                                      storyId: story.id,
                                      isSaved: story.isSaved,
                                    ),
                                  ),
                            );
                          },
                          childCount: feed.stories.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
        };
      },
    );
  }
}

class _SinceLastCheckedSection extends StatelessWidget {
  const _SinceLastCheckedSection({
    required this.stories,
    required this.onStoryTap,
  });

  final List stories;
  final void Function(String id) onStoryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Since you last checked',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${stories.length} important things happened',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          ...stories.take(3).map((story) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onStoryTap(story.id),
                child: Row(
                  children: [
                    Text(
                      '${story.relevancePercent}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.relevanceHigh,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        story.title,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
