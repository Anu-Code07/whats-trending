import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/repositories/feed_repository_impl.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/story_card.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool _loading = true;
  late List<dynamic> _stories;

  static const _trends = [
    ('AI Agents', 'rising', '↑↑'),
    ('MCP', 'rising', '↑↑'),
    ('Local LLMs', 'rising', '↑'),
    ('WebGPU', 'rising', '↑'),
    ('Flutter', 'stable', '→'),
    ('Crypto', 'falling', '↓'),
  ];

  static const _technologies = [
    'React', 'Flutter', 'TypeScript', 'Rust', 'Next.js', 'Kubernetes',
  ];

  static const _companies = [
    'OpenAI', 'Google', 'Apple', 'Microsoft', 'Anthropic', 'NVIDIA',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = FeedRepositoryImpl();
    final feed = await repo.getFeed();
    setState(() {
      _stories = feed.stories;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingSkeleton());

    return Scaffold(
      body: CustomScrollView(
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
                    'Explore beyond your feed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 28),
                  Text('Trend Radar', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  _TrendRadar(trends: _trends),
                  const SizedBox(height: 28),
                  Text('Technologies', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  _EntityGrid(items: _technologies),
                  const SizedBox(height: 28),
                  Text('Companies', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  _EntityGrid(items: _companies),
                  const SizedBox(height: 28),
                  Text('Trending', style: Theme.of(context).textTheme.headlineMedium),
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
                childCount: _stories.take(3).length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
                Text(
                  t.$3,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EntityGrid extends StatelessWidget {
  const _EntityGrid({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(item, style: Theme.of(context).textTheme.bodySmall),
        );
      }).toList(),
    );
  }
}
