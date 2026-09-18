import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/ns_palette.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/ns_screen.dart';
import '../../../../shared/widgets/story_card.dart';

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

    try {
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
    } catch (_) {
      setState(() {
        _results = [];
        _searched = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return NsScreen(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search stories, topics, companies…',
              border: InputBorder.none,
              hintStyle: TextStyle(color: ns.textTertiary),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
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
          actions: [
            IconButton(
              onPressed: () => _search(_controller.text),
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ),
        body: _searched
            ? _results.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ns.textSecondary,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final story = _results[index];
                      return StoryCard(
                        story: story,
                        compact: true,
                        onTap: () => context.push('/story/${story.id}'),
                      );
                    },
                  )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Try asking', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...[
                      'What are the biggest AI agent developments?',
                      'What changed in Flutter this month?',
                      'Show me everything about OpenAI',
                    ].map((q) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            _controller.text = q;
                            _search(q);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: ns.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: ns.border),
                            ),
                            child: Text(
                              q,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: ns.textSecondary,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}
