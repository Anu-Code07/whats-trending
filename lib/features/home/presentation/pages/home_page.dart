import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/category_tabs.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/news_page_header.dart';
import '../../../../shared/widgets/stacked_news_feed.dart';
import '../../../home/domain/entities/story.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Trending';
  List<String> _categories = ['Trending'];

  List<Story> _filterStories(List<Story> stories) {
    if (_selectedCategory == 'Trending') return stories;
    return stories.where((s) => s.category == _selectedCategory).toList();
  }

  void _updateCategories(List<Story> stories) {
    final cats = stories.map((s) => s.category).toSet().toList()..sort();
    _categories = ['Trending', ...cats];
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Trending';
    }
  }

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
          HomeLoaded(feed: final feed) => _buildFeed(context, feed),
        };
      },
    );
  }

  Widget _buildFeed(BuildContext context, FeedData feed) {
    _updateCategories(feed.stories);
    final stories = _filterStories(feed.stories);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(const RefreshHomeFeed());
          await Future.delayed(const Duration(milliseconds: 800));
        },
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
                    NewsPageHeader(onMenuTap: () => _showMenu(context)),
                    const SizedBox(height: 28),
                    CategoryTabs(
                      categories: _categories,
                      selected: _selectedCategory,
                      onSelected: (cat) => setState(() => _selectedCategory = cat),
                      style: CategoryTabStyle.underline,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            StackedNewsFeed(
              stories: stories,
              onTap: (story) => context.push('/story/${story.id}'),
              onSave: (story) => context.read<HomeBloc>().add(
                    ToggleStorySave(
                      storyId: story.id,
                      isSaved: story.isSaved,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuTile(
              icon: Icons.explore_outlined,
              label: 'Discover',
              onTap: () {
                Navigator.pop(ctx);
                context.push('/discover');
              },
            ),
            _MenuTile(
              icon: Icons.wb_sunny_outlined,
              label: 'Daily Brief',
              onTap: () {
                Navigator.pop(ctx);
                context.push('/brief');
              },
            ),
            _MenuTile(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {
                Navigator.pop(ctx);
                context.push('/profile');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
    );
  }
}
