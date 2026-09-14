import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/impact_pill.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/relevance_badge.dart';
import '../../../../shared/widgets/trending_story_card.dart';
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
        return Scaffold(
          body: switch (state) {
            StoryInitial() || StoryLoading() => const LoadingSkeleton(count: 1),
            StoryError(message: final msg) => Center(child: Text(msg)),
            StoryLoaded(story: final story, depth: final depth) => _StoryContent(
                story: story,
                depth: depth,
                related: _related,
                loadingRelated: _loadingRelated,
              ),
          },
        );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final gradient = _categoryGradient(story.category);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              onPressed: () => context.read<StoryBloc>().add(const ToggleSave()),
              icon: Icon(
                story.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                color: story.isSaved ? AppColors.accent : Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: story.primarySourceUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
              },
              icon: const Icon(Icons.share_outlined, color: Colors.white),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (story.isHot)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.trending_up, size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text('TRENDING', style: theme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            Text(story.category, style: theme.labelSmall?.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RelevanceBadge(percent: story.relevancePercent),
                    const SizedBox(width: 8),
                    ImpactPill(impact: story.impact),
                    if (story.trendScore > 1) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.relevanceHigh.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${story.trendScore}x trend',
                          style: theme.labelSmall?.copyWith(color: AppColors.relevanceHigh),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(story.title, style: theme.displayLarge?.copyWith(fontSize: 26)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _openUrl(story.primarySourceUrl),
                      child: Text(
                        story.primarySourceName,
                        style: theme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.accent.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
                    Text(
                      DateFormat('MMM d, h:mm a').format(story.publishedAt),
                      style: theme.bodySmall?.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openUrl(story.primarySourceUrl),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Read original article'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _DepthSelector(
                  currentDepth: depth,
                  onChanged: (d) => context.read<StoryBloc>().add(ChangeStoryDepth(depth: d)),
                ),
                const SizedBox(height: 24),
                _Section(title: 'What happened?', child: Text(story.summary, style: theme.bodyMedium)),
                const SizedBox(height: 24),
                _Section(
                  title: 'Why it matters',
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                    ),
                    child: Text(story.whyItMatters, style: theme.bodyMedium),
                  ),
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Your relevance',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${story.relevancePercent}%',
                        style: theme.headlineMedium?.copyWith(color: AppColors.relevanceHigh),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.relevanceExplanation,
                        style: theme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (story.sources.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Sources',
                    child: Column(
                      children: story.sources.map((s) {
                        return GestureDetector(
                          onTap: s.url.isNotEmpty ? () => _openUrl(s.url) : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                _SourceTypeBadge(type: s.contentType),
                                const SizedBox(width: 10),
                                Expanded(child: Text(s.name, style: theme.bodySmall)),
                                if (s.url.isNotEmpty)
                                  const Icon(Icons.open_in_new, size: 14, color: AppColors.textTertiary),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text('Keep exploring', style: theme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Related stories in ${story.category}',
                  style: theme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                if (loadingRelated)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ))
                else if (related.isEmpty)
                  Text('No related stories', style: theme.bodySmall?.copyWith(color: AppColors.textTertiary))
                else
                  ...related.asMap().entries.map((e) {
                    return TrendingStoryCard(
                      story: e.value,
                      rank: e.key + 1,
                      onTap: () => context.pushReplacement('/story/${e.value.id}'),
                    );
                  }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _categoryGradient(String category) {
    return switch (category.toLowerCase()) {
      'models' => [const Color(0xFF6366F1), const Color(0xFF4338CA)],
      'tools' => [const Color(0xFF0EA5E9), const Color(0xFF0369A1)],
      'startups' => [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'regulation' => [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
      'research' => [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      _ => [const Color(0xFF1C1C2E), const Color(0xFF0A0A0B)],
    };
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
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
                  color: isSelected ? AppColors.accentMuted : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                ),
                child: Text(
                  d.$2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected ? AppColors.accent : AppColors.textSecondary,
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

class _SourceTypeBadge extends StatelessWidget {
  const _SourceTypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      'official' => AppColors.relevanceHigh,
      'community' => AppColors.relevanceMid,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(type, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}
