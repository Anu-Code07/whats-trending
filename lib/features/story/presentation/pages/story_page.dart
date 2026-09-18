import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/category_visuals.dart';
import '../../../../core/theme/ns_palette.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/ns_screen.dart';
import '../../../../shared/widgets/signal_badge.dart';
import '../../../../shared/widgets/story_art.dart';
import '../../../../shared/widgets/story_card.dart';
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
    return NsScreen(
      dark: true,
      child: BlocBuilder<StoryBloc, StoryState>(
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
      ),
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
    final ns = context.ns;
    final visual = CategoryVisuals.of(story.category);
    final timeAgo = _formatTimeAgo(story.publishedAt);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: ns.background,
          leading: _CircleAction(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          actions: [
            _CircleAction(
              icon: story.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              onTap: () => context.read<StoryBloc>().add(const ToggleSave()),
            ),
            _CircleAction(
              icon: Icons.ios_share_rounded,
              onTap: () {
                Clipboard.setData(ClipboardData(text: story.primarySourceUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: StoryArt(
              story: story,
              height: 240,
              borderRadius: 0,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(visual.icon, size: 14, color: visual.color),
                    const SizedBox(width: 6),
                    Text(
                      story.category.toUpperCase(),
                      style: theme.labelSmall?.copyWith(
                        color: visual.color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text('  ·  $timeAgo', style: theme.labelSmall?.copyWith(color: ns.textTertiary)),
                    const Spacer(),
                    SignalBadge(percent: story.relevancePercent),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  story.title,
                  style: theme.displayLarge?.copyWith(fontSize: 28, height: 1.15),
                ),
                const SizedBox(height: 12),
                Text(
                  story.summary,
                  style: theme.bodyMedium?.copyWith(color: ns.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openUrl(story.primarySourceUrl),
                  child: Text(
                    story.primarySourceName,
                    style: theme.bodySmall?.copyWith(
                      color: NsPalette.accentBright,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _WhyCard(text: story.whyItMatters),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatCell(label: 'Read time', value: '${_readMinutes(story)} min'),
                    _StatCell(label: 'Impact', value: _impactLabel(story.impact)),
                    _StatCell(label: 'Sources', value: '${story.sourceCount}'),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  story.deepExplanation ?? story.summary,
                  style: theme.bodyMedium?.copyWith(height: 1.6, color: ns.textPrimary),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openUrl(story.primarySourceUrl),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Read original'),
                  ),
                ),
                const SizedBox(height: 20),
                _DepthSelector(
                  currentDepth: depth,
                  onChanged: (d) => context.read<StoryBloc>().add(ChangeStoryDepth(depth: d)),
                ),
                if (story.sources.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text('Sources', style: theme.titleMedium),
                  const SizedBox(height: 12),
                  ...story.sources.map((s) {
                    return GestureDetector(
                      onTap: s.url.isNotEmpty ? () => _openUrl(s.url) : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: ns.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ns.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(s.name, style: theme.bodySmall)),
                            if (s.url.isNotEmpty)
                              Icon(Icons.open_in_new_rounded, size: 14, color: ns.textTertiary),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 28),
                Text('Keep exploring', style: theme.titleMedium),
                const SizedBox(height: 12),
                if (loadingRelated)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: NsPalette.accent),
                    ),
                  )
                else
                  ...related.map(
                    (s) => StoryCard(
                      story: s,
                      compact: true,
                      onTap: () => context.pushReplacement('/story/${s.id}'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.35),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  const _WhyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final ns = context.ns;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ns.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NsPalette.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: NsPalette.accent),
              SizedBox(width: 8),
              Text(
                'Why it matters',
                style: TextStyle(
                  color: NsPalette.accentBright,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ns.textSecondary,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: ns.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ns.border),
        ),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ns.textTertiary)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
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
    final ns = context.ns;
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
                  color: isSelected ? NsPalette.accentMuted : ns.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? NsPalette.accent : ns.border),
                ),
                child: Text(
                  d.$2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected ? NsPalette.accentBright : ns.textSecondary,
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

String _formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return DateFormat('MMM d').format(date);
}

int _readMinutes(Story story) {
  final words = story.summary.split(RegExp(r'\s+')).length;
  return (words / 40).clamp(2, 12).round();
}

String _impactLabel(ImpactLevel impact) {
  return switch (impact) {
    ImpactLevel.critical => 'Critical',
    ImpactLevel.high => 'High',
    ImpactLevel.medium => 'Medium',
    ImpactLevel.low => 'Low',
  };
}
