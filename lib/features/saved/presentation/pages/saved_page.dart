import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/ns_palette.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/ns_segmented_tabs.dart';
import '../../../../shared/widgets/story_card.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<Story> _saved = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await ServiceLocator.feedRepository.getSavedStories();
    if (!mounted) return;
    setState(() {
      _saved = saved;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: NsPalette.accent))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saved', style: Theme.of(context).textTheme.displayLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Your tech library',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ns.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 18),
                          NsSegmentedTabs(
                            labels: const ['Articles', 'Briefings', 'Collections'],
                            index: _tab,
                            onChanged: (i) => setState(() => _tab = i),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  if (_saved.isEmpty || _tab != 0)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        title: _tab == 0 ? 'Nothing saved yet' : 'Coming soon',
                        subtitle: _tab == 0
                            ? 'Save stories from your feed to build a library.'
                            : 'Briefings and collections land here as you save more.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final story = _saved[index];
                            return StoryCard(
                              story: story,
                              compact: true,
                              onTap: () => context.push('/story/${story.id}'),
                            );
                          },
                          childCount: _saved.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
