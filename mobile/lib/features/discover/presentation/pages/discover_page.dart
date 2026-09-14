import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/story_card.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool _loading = true;
  List<dynamic> _stories = [];

  static const _trends = [
    ('AI Agents', 'rising', '↑↑'),
    ('MCP', 'rising', '↑↑'),
    ('Local LLMs', 'rising', '↑'),
    ('WebGPU', 'rising', '↑'),
    ('Flutter', 'stable', '→'),
    ('Crypto', 'falling', '↓'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final feed = await ServiceLocator.feedRepository.getFeed();
    setState(() {
      _stories = feed.stories;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingSkeleton());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final feed = await ServiceLocator.feedRepository.getFeed(forceRefresh: true);
          setState(() => _stories = feed.stories);
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
                    Text('Discover', style: Theme.of(context).textTheme.displayLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Live from 20+ tech sources',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 28),
                    Text('Trend Radar', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    _TrendRadar(trends: _trends),
                    const SizedBox(height: 28),
                    Text('Trending now', style: Theme.of(context).textTheme.headlineMedium),
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
                    final story = _stories[index];
                    return StoryCard(
                      story: story,
                      compact: true,
                      onTap: () => context.push('/story/${story.id}'),
                    );
                  },
                  childCount: _stories.take(5).length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _TrendRadar extends StatelessWidget {
  const _TrendRadar({required this.trends});
  final List<(String, String, String)> trends;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: trends.map((t) {
          final color = switch (t.$2) {
            'rising' => AppColors.relevanceHigh,
            'falling' => AppColors.impactCritical,
            _ => AppColors.textSecondary,
          };
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text(t.$1, style: Theme.of(context).textTheme.bodyMedium)),
                Text(t.$3, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
