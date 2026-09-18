import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/ns_palette.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/discover_rank_row.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/ns_segmented_tabs.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool _loading = true;
  List<Story> _allStories = [];
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    final repo = ServiceLocator.feedRepository;
    final stories = await repo.getTrendingFeed(forceRefresh: refresh);
    if (!mounted) return;
    setState(() {
      _allStories = stories;
      _loading = false;
    });
  }

  List<Story> get _visible {
    final copy = List<Story>.from(_allStories);
    if (_tab == 1) {
      copy.sort((a, b) => b.sourceCount.compareTo(a.sourceCount));
    } else if (_tab == 2) {
      copy.sort((a, b) => a.primarySourceName.compareTo(b.primarySourceName));
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingSkeleton());

    final ns = context.ns;
    final stories = _visible;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _load(refresh: true),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Discover', style: Theme.of(context).textTheme.displayLarge),
                                const SizedBox(height: 4),
                                Text(
                                  'Explore what\'s trending',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: ns.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/search'),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ns.surface,
                                border: Border.all(color: ns.border),
                              ),
                              child: Icon(Icons.search_rounded, color: ns.textSecondary, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      NsSegmentedTabs(
                        labels: const ['Trending', 'Most Read', 'Top Sources'],
                        index: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                    ],
                  ),
                ),
              ),
              if (stories.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    title: 'Nothing trending yet',
                    subtitle: 'Pull to refresh for the latest tech signal.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final story = stories[index];
                        return Column(
                          children: [
                            DiscoverRankRow(
                              story: story,
                              rank: index + 1,
                              onTap: () => context.push('/story/${story.id}'),
                            ),
                            if (index != stories.length - 1)
                              Divider(height: 1, color: ns.border),
                          ],
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
