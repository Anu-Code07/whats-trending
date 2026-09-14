import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/repositories/feed_repository_impl.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/story_card.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<Story> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = FeedRepositoryImpl();
    final saved = await repo.getSavedStories();
    setState(() {
      _saved = saved;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _saved.isEmpty
              ? const EmptyState(
                  title: 'Nothing saved yet',
                  subtitle: 'Save stories to read later, learn, or build ideas from.',
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Saved', style: Theme.of(context).textTheme.displayLarge),
                            const SizedBox(height: 4),
                            Text(
                              '${_saved.length} stories',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final story = _saved[index];
                            return StoryCard(
                              story: story,
                              onTap: () => context.push('/story/${story.id}'),
                            );
                          },
                          childCount: _saved.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
    );
  }
}
