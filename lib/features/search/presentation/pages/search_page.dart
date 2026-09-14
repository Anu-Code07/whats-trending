import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/news_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  List<Story> _results = [];
  bool _searched = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }

    final feed = await ServiceLocator.feedRepository.getFeed();
    final q = query.toLowerCase();
    final filtered = feed.stories.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.summary.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
    }).toList();

    setState(() {
      _results = filtered;
      _searched = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Search',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search news',
                      prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                    ),
                    onSubmitted: _search,
                    onChanged: (v) {
                      if (v.isEmpty) {
                        setState(() {
                          _results = [];
                          _searched = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (_searched && _results.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No stories found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final story = _results[index];
                    return NewsCard(
                      story: story,
                      colorIndex: index,
                      compact: true,
                      onTap: () => context.push('/story/${story.id}'),
                    );
                  },
                  childCount: _results.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
