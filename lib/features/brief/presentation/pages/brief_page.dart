import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/category_visuals.dart';
import '../../../../core/theme/ns_palette.dart';
import '../../../home/domain/entities/story.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/orb_backdrop.dart';

class BriefPage extends StatefulWidget {
  const BriefPage({super.key});

  @override
  State<BriefPage> createState() => _BriefPageState();
}

class _BriefPageState extends State<BriefPage> {
  List<Story> _topStories = [];
  bool _loading = true;
  bool _playing = false;
  int _playIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBrief();
  }

  Future<void> _loadBrief() async {
    final brief = await ServiceLocator.feedRepository.getDailyBrief();
    if (!mounted) return;
    setState(() {
      _topStories = brief.topStories;
      _loading = false;
    });
  }

  Map<String, List<Story>> get _byCategory {
    final map = <String, List<Story>>{};
    for (final story in _topStories) {
      map.putIfAbsent(story.category, () => []).add(story);
    }
    return map;
  }

  int _playGeneration = 0;

  Future<void> _playBrief() async {
    if (_topStories.isEmpty) return;
    HapticFeedback.mediumImpact();
    final generation = ++_playGeneration;
    setState(() {
      _playing = true;
      _playIndex = 0;
    });
    for (var i = 0; i < _topStories.take(5).length; i++) {
      if (!mounted || !_playing || generation != _playGeneration) return;
      setState(() => _playIndex = i);
      await Future<void>.delayed(const Duration(seconds: 6));
    }
    if (mounted && generation == _playGeneration) {
      setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingSkeleton());

    final ns = context.ns;
    final theme = Theme.of(context).textTheme;
    final categories = _byCategory.entries.take(4).toList();
    final highlight = _topStories.isEmpty ? null : _topStories[_playIndex.clamp(0, _topStories.length - 1)];

    return Scaffold(
      body: OrbBackdrop(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pulse', style: theme.displayLarge),
                                const SizedBox(height: 4),
                                Text(
                                  'Your daily tech briefing',
                                  style: theme.bodySmall?.copyWith(color: ns.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('E, d MMM').format(DateTime.now()),
                            style: theme.bodySmall?.copyWith(color: ns.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ns.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: ns.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: NsPalette.accentMuted,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.graphic_eq, color: NsPalette.accentBright),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Today\'s Pulse', style: theme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_topStories.length} important things happened today.',
                                    style: theme.bodySmall?.copyWith(color: ns.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ...categories.map((entry) {
                        final visual = CategoryVisuals.of(entry.key);
                        final lead = entry.value.first;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => context.push('/story/${lead.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: ns.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: ns.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: visual.color.withValues(alpha: 0.16),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(visual.icon, color: visual.color, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(entry.key.toUpperCase(), style: theme.labelSmall?.copyWith(
                                          color: ns.textTertiary,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                        )),
                                        const SizedBox(height: 4),
                                        Text(
                                          lead.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '${entry.value.length} ${entry.value.length == 1 ? 'source' : 'stories'}',
                                          style: theme.labelSmall?.copyWith(color: ns.textTertiary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: ns.textTertiary),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Text('Top stories in 30 seconds', style: theme.titleMedium),
                      const SizedBox(height: 12),
                      if (highlight != null)
                        GestureDetector(
                          onTap: () {
                            if (_playing) {
                              setState(() {
                                _playing = false;
                                _playGeneration++;
                              });
                            } else {
                              _playBrief();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ns.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _playing
                                    ? NsPalette.accent.withValues(alpha: 0.5)
                                    : ns.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: CategoryVisuals.of(highlight.category).color.withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CategoryVisuals.of(highlight.category).icon,
                                    color: CategoryVisuals.of(highlight.category).color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        highlight.category,
                                        style: theme.labelSmall?.copyWith(color: ns.textTertiary),
                                      ),
                                      Text(
                                        highlight.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      if (_playing)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: LinearProgressIndicator(
                                            value: (_playIndex + 1) /
                                                (_topStories.take(5).length.clamp(1, 5)),
                                            color: NsPalette.accent,
                                            backgroundColor: ns.border,
                                            minHeight: 3,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [NsPalette.accentBright, NsPalette.accentDeep],
                                    ),
                                  ),
                                  child: Icon(
                                    _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
