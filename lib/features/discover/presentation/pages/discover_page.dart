import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/category_tabs.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/news_page_header.dart';
import '../../../../shared/widgets/stacked_news_feed.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool _loading = true;
  List<Story> _allStories = [];
  List<Story> _filtered = [];
  List<String> _categories = ['Trending'];
  String _selectedCategory = 'Trending';

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
      _categories = ['Trending', ...repo.getCategories(stories)];
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    _filtered = _selectedCategory == 'Trending'
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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        color: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NewsPageHeader(
                      title: 'Discover',
                      onMenuTap: () => context.pop(),
                    ),
                    const SizedBox(height: 28),
                    CategoryTabs(
                      categories: _categories,
                      selected: _selectedCategory,
                      onSelected: _selectCategory,
                      style: CategoryTabStyle.underline,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            StackedNewsFeed(
              stories: _filtered,
              onTap: (story) => context.push('/story/${story.id}'),
            ),
          ],
        ),
      ),
    );
  }
}
