import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/repositories/feed_repository_impl.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/story_card.dart';

class BriefPage extends StatefulWidget {
  const BriefPage({super.key});

  @override
  State<BriefPage> createState() => _BriefPageState();
}

class _BriefPageState extends State<BriefPage> {
  List<Story> _topStories = [];
  List<Story> _missedStories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBrief();
  }

  Future<void> _loadBrief() async {
    final repo = FeedRepositoryImpl();
    final brief = await repo.getDailyBrief();
    setState(() {
      _topStories = brief.topStories;
      _missedStories = brief.missedStories;
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
                  Text('Your Tech Brief', style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 28),
                  Text('Top 5 things you should know', style: Theme.of(context).textTheme.headlineMedium),
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
                  final story = _topStories[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 12),
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.accent,
                              ),
                        ),
                      ),
                      Expanded(
                        child: StoryCard(
                          story: story,
                          compact: true,
                          onTap: () => context.push('/story/${story.id}'),
                        ),
                      ),
                    ],
                  );
                },
                childCount: _topStories.length,
              ),
            ),
          ),
          if (_missedStories.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Text(
                  'You might have missed',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final story = _missedStories[index];
                    return StoryCard(
                      story: story,
                      compact: true,
                      onTap: () => context.push('/story/${story.id}'),
                    );
                  },
                  childCount: _missedStories.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
