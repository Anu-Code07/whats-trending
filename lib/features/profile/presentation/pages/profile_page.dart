import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/ns_palette.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/ns_screen.dart';
import '../../../../shared/widgets/orb_backdrop.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final storage = ServiceLocator.storage;
    final name = storage.userName;
    final interests = storage.interests;
    final reads = storage.readStoryIds.length;
    final following = interests.length * 7;
    final signal = (55 + (interests.length * 4) + reads.clamp(0, 20)).clamp(40, 96).toInt();

    return NsScreen(
      dark: true,
      child: Builder(
        builder: (context) {
          final ns = context.ns;
          return Scaffold(
        body: OrbBackdrop(
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                            ),
                            const Spacer(),
                            Icon(Icons.settings_outlined, color: ns.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [NsPalette.accentBright, NsPalette.accentDeep],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'N',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: Theme.of(context).textTheme.headlineMedium),
                                  Text(
                                    '@${name.toLowerCase().replaceAll(' ', '')}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: ns.textTertiary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _Stat(value: '$following', label: 'Following'),
                            _Stat(value: '${interests.length}', label: 'Interests'),
                            _Stat(value: reads >= 1000 ? '${(reads / 1000).toStringAsFixed(1)}k' : '$reads', label: 'Reads'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Your signal', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'How well we understand your interests',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ns.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: signal / 100,
                            minHeight: 8,
                            color: NsPalette.accent,
                            backgroundColor: ns.surfaceElevated,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$signal%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: NsPalette.accentBright,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text('Interests', style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Text(
                              'Edit',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: NsPalette.accentBright,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...interests.map((t) => CategoryChip(label: t, filled: true)),
                            CategoryChip(label: '+', onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _SettingsTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: 'Daily Pulse',
                        ),
                        _SettingsTile(
                          icon: Icons.dark_mode_outlined,
                          title: 'Appearance',
                          subtitle: 'Dark',
                        ),
                        _SettingsTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: '',
                        ),
                        const SizedBox(height: 16),
                        _SettingsTile(
                          icon: Icons.rss_feed_rounded,
                          title: 'News source',
                          subtitle: 'WhatsTrending API',
                        ),
                        _SettingsTile(
                          icon: Icons.tune_rounded,
                          title: 'Content depth',
                          subtitle: storage.contentDepth == 'deep' ? '10 minutes' : '3 minutes',
                        ),
                        TextButton(
                          onPressed: () async {
                            await storage.resetPersonalization();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Personalization reset')),
                            );
                          },
                          child: const Text('Reset personalization'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.ns.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ns.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ns.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: ns.textSecondary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ns.textTertiary),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: ns.textTertiary),
        ],
      ),
    );
  }
}
