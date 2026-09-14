import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/trending_carousel.dart';
import '../../../../shared/widgets/trending_hero_card.dart';
import '../../../../shared/widgets/trending_story_card.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool _loading = true;
  List<Story> _allStories = [];
  List<Story> _filtered = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    final repo = ServiceLocator.feedRepository;
    final stories = await repo.getTrendingFeed(forceRefresh: refresh);
    setState(() {
      _allStories = stories;
      _categories = ['All', ...repo.getCategories(stories)];
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    _filtered = _selectedCategory == 'All'
        ? _allStories
        : _allStories.where((s) => s.category == _selectedCategory).toList();
  }

  void _selectCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingSkeleton());

    final hero = _filtered.isNotEmpty ? _filtered.first : null;
    final ranked = _filtered.length > 1 ? _filtered.sublist(1) : <Story>[];
    final rising = _allStories.where((s) => s.isHot).take(6).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _load(refresh: true),
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
                        Icon(Icons.trending_up, color: AppColors.accent, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Trending',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live tech stories ranked by momentum',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (rising.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text('Rising fast', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
              ),
              SliverToBoxAdapter(
                child: TrendingCarousel(
                  stories: rising,
                  onStoryTap: (s) => context.push('/story/${s.id}'),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 0, 12),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => _selectCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.accent : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? AppColors.accent : AppColors.border,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (hero != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TrendingHeroCard(
                    story: hero,
                    rank: 1,
                    onTap: () => context.push('/story/${hero.id}'),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Top stories',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final story = ranked[index];
                    return TrendingStoryCard(
                      story: story,
                      rank: index + 2,
                      onTap: () => context.push('/story/${story.id}'),
                    );
                  },
                  childCount: ranked.length,
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
