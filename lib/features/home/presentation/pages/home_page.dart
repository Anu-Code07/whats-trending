import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/ns_palette.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/ns_segmented_tabs.dart';
import '../../../../shared/widgets/story_card.dart';
import '../../domain/entities/story.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _activeInterests = {};

  @override
  void initState() {
    super.initState();
    _activeInterests.addAll(ServiceLocator.storage.interests.take(6));
  }

  List<Story> _filtered(List<Story> stories) {
    final allInterests = ServiceLocator.storage.interests;
    if (_activeInterests.isEmpty || _activeInterests.length == allInterests.length) {
      return stories;
    }
    return stories.where((story) {
      final haystack = '${story.title} ${story.category} ${story.summary}'.toLowerCase();
      return _activeInterests.any((interest) => haystack.contains(interest.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return switch (state) {
          HomeInitial() || HomeLoading() => const Scaffold(body: LoadingSkeleton()),
          HomeError(message: final msg) => Scaffold(
              body: EmptyState(
                title: 'Something went wrong',
                subtitle: msg,
                actionLabel: 'Retry',
                onAction: () => context.read<HomeBloc>().add(const LoadHomeFeed()),
              ),
            ),
          HomeLoaded(feed: final feed) => _HomeLoadedView(
              feed: feed,
              activeInterests: _activeInterests,
              onToggleInterest: (interest) {
                setState(() {
                  if (_activeInterests.contains(interest)) {
                    _activeInterests.remove(interest);
                  } else {
                    _activeInterests.add(interest);
                  }
                });
              },
              stories: _filtered(feed.stories),
            ),
        };
      },
    );
  }
}

class _HomeLoadedView extends StatelessWidget {
  const _HomeLoadedView({
    required this.feed,
    required this.activeInterests,
    required this.onToggleInterest,
    required this.stories,
  });

  final FeedData feed;
  final Set<String> activeInterests;
  final ValueChanged<String> onToggleInterest;
  final List<Story> stories;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    final storage = ServiceLocator.storage;
    final interests = storage.interests;
    final hour = DateTime.now().hour;
    final isDay = hour >= 6 && hour < 18;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const RefreshHomeFeed());
            await Future<void>.delayed(const Duration(milliseconds: 700));
          },
          color: NsPalette.accent,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('E, d MMM').format(DateTime.now()),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ns.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                            size: 16,
                            color: isDay ? NsPalette.warning : NsPalette.accentBright,
                          ),
                          const Spacer(),
                          _RoundIconButton(
                            icon: Icons.search_rounded,
                            onTap: () => context.push('/search'),
                          ),
                          const SizedBox(width: 8),
                          _AvatarButton(
                            name: storage.userName,
                            onTap: () => context.push('/profile'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '${feed.greeting}.',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 28,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Here\'s what\'s happening in tech.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ns.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 20),
                      NsSegmentedTabs(
                        labels: const ['For You', 'Pulse', 'Trending', 'Saved'],
                        index: 0,
                        onChanged: (i) {
                          switch (i) {
                            case 1:
                              context.go('/pulse');
                            case 2:
                              context.go('/discover');
                            case 3:
                              context.go('/saved');
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: interests.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == interests.length) {
                              return CategoryChip(
                                label: '+',
                                onTap: () => context.push('/profile'),
                              );
                            }
                            final interest = interests[index];
                            return CategoryChip(
                              label: interest,
                              selected: activeInterests.contains(interest),
                              onTap: () => onToggleInterest(interest),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (stories.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'Nothing in this filter',
                    subtitle: 'Try another interest chip to see more stories.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final story = stories[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 280 + (index.clamp(0, 6) * 50)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 12 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: StoryCard(
                            story: story,
                            onTap: () => context.push('/story/${story.id}'),
                            onSave: () => context.read<HomeBloc>().add(
                                  ToggleStorySave(
                                    storyId: story.id,
                                    isSaved: story.isSaved,
                                  ),
                                ),
                          ),
                        );
                      },
                      childCount: stories.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ns.surface,
          border: Border.all(color: ns.border),
        ),
        child: Icon(icon, size: 18, color: ns.textSecondary),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [NsPalette.accentBright, NsPalette.accentDeep],
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'N',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
