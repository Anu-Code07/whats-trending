import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _groqKeyController;
  bool _showKey = false;
  bool _keySaved = false;
  bool _hasGroqKey = false;
  bool _loadingKey = true;

  @override
  void initState() {
    super.initState();
    _groqKeyController = TextEditingController();
    _loadGroqKey();
  }

  Future<void> _loadGroqKey() async {
    final storage = ServiceLocator.storage;
    final hasKey = await storage.hasGroqKey();
    if (hasKey) {
      final key = await storage.getGroqApiKey();
      _groqKeyController.text = _maskKey(key ?? '');
    }
    setState(() {
      _hasGroqKey = hasKey;
      _loadingKey = false;
    });
  }

  String _maskKey(String key) {
    if (key.length <= 8) return '••••••••';
    return '${key.substring(0, 4)}${'•' * (key.length - 8)}${key.substring(key.length - 4)}';
  }

  @override
  void dispose() {
    _groqKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveGroqKey() async {
    final raw = _groqKeyController.text.trim();
    if (raw.contains('•')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your full Groq API key')),
      );
      return;
    }
    await ServiceLocator.storage.setGroqApiKey(raw);
    setState(() {
      _keySaved = true;
      _hasGroqKey = raw.isNotEmpty;
      if (_hasGroqKey) _groqKeyController.text = _maskKey(raw);
    });
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _keySaved = false);
    });
  }

  Future<void> _clearGroqKey() async {
    await ServiceLocator.storage.setGroqApiKey(null);
    _groqKeyController.clear();
    setState(() => _hasGroqKey = false);
  }

  @override
  Widget build(BuildContext context) {
    final storage = ServiceLocator.storage;
    final name = storage.userName;
    final interests = storage.interests;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: 0.4),
                              AppColors.accent.withValues(alpha: 0.1),
                            ],
                          ),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.accent,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: Theme.of(context).textTheme.headlineMedium),
                            Text(
                              'Your Tech DNA',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('Your interests', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: interests.map((t) => Chip(label: Text(t))).toList(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 18, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text('AI Intelligence', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Groq key stored in secure storage (Keychain / Keystore). Only sent to Groq.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingKey)
                    const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  else ...[
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _groqKeyController,
                        obscureText: !_showKey,
                        onTap: () {
                          if (_groqKeyController.text.contains('•')) {
                            _groqKeyController.clear();
                          }
                        },
                        style: Theme.of(context).textTheme.bodySmall,
                        decoration: InputDecoration(
                          hintText: 'gsk_...',
                          hintStyle: TextStyle(color: AppColors.textTertiary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showKey ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                            onPressed: () => setState(() => _showKey = !_showKey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _saveGroqKey,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(_keySaved ? 'Saved securely ✓' : 'Save key'),
                          ),
                        ),
                        if (_hasGroqKey) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _clearGroqKey,
                            icon: const Icon(Icons.delete_outline, color: AppColors.impactCritical),
                          ),
                        ],
                      ],
                    ),
                    if (_hasGroqKey)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user, size: 14, color: AppColors.relevanceHigh),
                            const SizedBox(width: 6),
                            Text(
                              'Key stored in secure enclave',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.relevanceHigh,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 28),
                  Text('Settings', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.tune,
                    title: 'Content depth',
                    subtitle: storage.contentDepth == 'deep' ? '10 minutes' : '3 minutes',
                  ),
                  _SettingsTile(
                    icon: Icons.phone_android,
                    title: 'Storage',
                    subtitle: 'Profile local · API key encrypted',
                  ),
                  const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}
