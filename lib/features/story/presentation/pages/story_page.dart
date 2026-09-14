import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/news_card.dart' show CardActionIcon, LiveBadge, NewsCard, PublisherRow;
import '../bloc/story_bloc.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key, required this.storyId});

  final String storyId;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  List<Story> _related = [];
  bool _loadingRelated = true;

  @override
  void initState() {
    super.initState();
    _loadRelated();
  }

  Future<void> _loadRelated() async {
    final related = await ServiceLocator.feedRepository.getRelatedStories(widget.storyId);
    if (mounted) {
      setState(() {
        _related = related;
        _loadingRelated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        return switch (state) {
          StoryInitial() || StoryLoading() => const Scaffold(
              backgroundColor: AppColors.cardCream,
              body: LoadingSkeleton(count: 1),
            ),
          StoryError(message: final msg) => Scaffold(
              backgroundColor: AppColors.cardCream,
              body: Center(child: Text(msg, style: TextStyle(color: AppColors.cardText))),
            ),
          StoryLoaded(story: final story, depth: final depth) => _StoryContent(
              story: story,
              depth: depth,
              related: _related,
              loadingRelated: _loadingRelated,
            ),
        };
      },
    );
  }
}

class _StoryContent extends StatelessWidget {
  const _StoryContent({
    required this.story,
    required this.depth,
    required this.related,
    required this.loadingRelated,
  });

  final Story story;
  final String depth;
  final List<Story> related;
  final bool loadingRelated;

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _timeLabel(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inHours < 1) return 'Updated ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${DateFormat('MMM d').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardCream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.cardText),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.read<StoryBloc>().add(const ToggleSave()),
                      icon: Icon(
                        story.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        color: AppColors.cardText,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: story.primarySourceUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied')),
                        );
                      },
                      icon: const Icon(Icons.share_outlined, color: AppColors.cardText),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (story.isBreaking || story.isHot)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LiveBadge(),
                    ),
                  Text(
                    story.title,
                    style: AppTheme.cardHeadline(context).copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _timeLabel(story.publishedAt),
                    style: AppTheme.cardBody(context).copyWith(color: AppColors.cardTextMuted),
                  ),
                  const SizedBox(height: 20),
                  PublisherRow(sourceName: story.primarySourceName),
                  const SizedBox(height: 24),
                  _FeaturedImage(category: story.category),
                  const SizedBox(height: 24),
                  Text(story.summary, style: AppTheme.cardBody(context)),
                  const SizedBox(height: 20),
                  Text(
                    'Why it matters',
                    style: AppTheme.cardHeadline(context).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(story.whyItMatters, style: AppTheme.cardBody(context)),
                  const SizedBox(height: 24),
                  _DepthSelector(
                    currentDepth: depth,
                    onChanged: (d) => context.read<StoryBloc>().add(ChangeStoryDepth(depth: d)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openUrl(story.primarySourceUrl),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Read original'),
                    ),
                  ),
                  if (story.sources.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text('Sources', style: AppTheme.cardHeadline(context).copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    ...story.sources.map((s) => _SourceTile(
                          name: s.name,
                          onTap: s.url.isNotEmpty ? () => _openUrl(s.url) : null,
                        )),
                  ],
                  const SizedBox(height: 32),
                  Text('Related', style: AppTheme.cardHeadline(context).copyWith(fontSize: 18)),
                  const SizedBox(height: 16),
                  if (loadingRelated)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.cardText),
                    ))
                  else if (related.isEmpty)
                    Text('No related stories', style: AppTheme.cardBody(context))
                  else
                    ...related.asMap().entries.map((e) {
                      return NewsCard(
                        story: e.value,
                        colorIndex: e.key,
                        compact: true,
                        onTap: () => context.pushReplacement('/story/${e.value.id}'),
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.cardCream,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CardActionIcon(icon: Icons.thumb_up_outlined, onTap: () {}),
            const SizedBox(width: 32),
            CardActionIcon(
              icon: story.isSaved ? Icons.bookmark : Icons.bookmark_outline,
              filled: story.isSaved,
              onTap: () => context.read<StoryBloc>().add(const ToggleSave()),
            ),
            const SizedBox(width: 32),
            CardActionIcon(
              icon: Icons.share_outlined,
              onTap: () {
                Clipboard.setData(ClipboardData(text: story.primarySourceUrl));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedImage extends StatelessWidget {
  const _FeaturedImage({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBlue,
            AppColors.cardPink.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_categoryIcon(category), size: 48, color: AppColors.cardText.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(
              category,
              style: AppTheme.cardBody(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.cardText.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'models' => Icons.psychology_outlined,
      'tools' => Icons.build_outlined,
      'startups' => Icons.rocket_launch_outlined,
      'regulation' => Icons.gavel_outlined,
      'research' => Icons.science_outlined,
      _ => Icons.article_outlined,
    };
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.name, this.onTap});
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(name, style: AppTheme.cardBody(context).copyWith(color: AppColors.cardText))),
            if (onTap != null)
              const Icon(Icons.open_in_new, size: 16, color: AppColors.cardTextSecondary),
          ],
        ),
      ),
    );
  }
}

class _DepthSelector extends StatelessWidget {
  const _DepthSelector({required this.currentDepth, required this.onChanged});
  final String currentDepth;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const depths = [('quick', '30 sec'), ('normal', '3 min'), ('deep', '10 min')];
    return Row(
      children: depths.map((d) {
        final isSelected = currentDepth == d.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: d.$1 != 'deep' ? 8 : 0),
            child: GestureDetector(
              onTap: () => onChanged(d.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardText : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  d.$2,
                  textAlign: TextAlign.center,
                  style: AppTheme.cardBody(context).copyWith(
                    color: isSelected ? Colors.white : AppColors.cardTextSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
