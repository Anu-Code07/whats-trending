import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _techDna = [
    ('AI', 0.92),
    ('Developer Tools', 0.86),
    ('Frontend', 0.84),
    ('Flutter', 0.73),
    ('Startups', 0.61),
  ];

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
                  Text('Your Tech DNA', style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Your personal knowledge profile',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 28),
                  ..._techDna.map((item) => _DnaBar(label: item.$1, score: item.$2)),
                  const SizedBox(height: 32),
                  Text('Top interests', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['React', 'AI', 'Flutter', 'TypeScript', 'Open Source']
                        .map((t) => Chip(label: Text(t)))
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  Text('Top companies', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['OpenAI', 'Vercel', 'GitHub']
                        .map((c) => Chip(label: Text(c)))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  _SettingsTile(icon: Icons.tune, title: 'Content depth', subtitle: '3 minutes'),
                  _SettingsTile(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Highly relevant only'),
                  _SettingsTile(icon: Icons.work_outline, title: 'Career mode', subtitle: 'Frontend Engineer'),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Reset personalization'),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DnaBar extends StatelessWidget {
  const _DnaBar({required this.label, required this.score});

  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '${(score * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              color: AppColors.accent,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
