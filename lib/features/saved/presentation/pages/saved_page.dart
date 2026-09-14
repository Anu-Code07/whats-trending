import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/news_card.dart';
import '../../../../shared/widgets/stacked_saved_cards.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<Story> _saved = [];
  List<Story> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final saved = await ServiceLocator.feedRepository.getSavedStories();
    setState(() {
      _saved = saved;
      _filtered = saved;
      _loading = false;
    });
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _saved
          : _saved.where((s) {
              return s.title.toLowerCase().contains(q) ||
                  s.summary.toLowerCase().contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.textPrimary)),
      );
    }

    if (_saved.isEmpty) {
      return const Scaffold(
        body: EmptyState(
          title: 'Nothing saved yet',
          subtitle: 'Bookmark stories to read them later.',
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved News',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search news',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_searchController.text.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StackedSavedCards(
                  stories: _saved,
                  onTap: (s) => context.push('/story/${s.id}'),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final story = _filtered[index];
                  return NewsCard(
                    story: story,
                    colorIndex: index,
                    compact: true,
                    onTap: () => context.push('/story/${story.id}'),
                  );
                },
                childCount: _filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
