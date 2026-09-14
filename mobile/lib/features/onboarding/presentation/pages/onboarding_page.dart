import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/northstar_logo.dart';
import '../widgets/onboarding_progress.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  static const _totalSteps = 4;

  late PageController _pageController;
  late AnimationController _fadeController;
  int _step = 0;
  final _nameController = TextEditingController();
  final Set<String> _selectedInterests = {'AI', 'Programming', 'Startups'};
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  bool get _canContinue {
    return switch (_step) {
      1 => _nameController.text.trim().length >= 2,
      2 => _selectedInterests.isNotEmpty,
      _ => true,
    };
  }

  Future<void> _next() async {
    if (!_canContinue) return;
    HapticFeedback.lightImpact();

    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      if (_step == 1) _nameFocus.requestFocus();
    } else {
      await ServiceLocator.storage.completeOnboarding(
        name: _nameController.text.trim(),
        interests: _selectedInterests.toList(),
      );
      if (mounted) context.go('/');
    }
  }

  void _back() {
    if (_step == 0) return;
    HapticFeedback.selectionClick();
    setState(() => _step--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1117),
              AppColors.background,
              Color(0xFF0A0E1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    if (_step > 0)
                      IconButton(
                        onPressed: _back,
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: OnboardingProgress(
                        currentStep: _step,
                        totalSteps: _totalSteps,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _WelcomeStep(),
                    _NameStep(
                      controller: _nameController,
                      focusNode: _nameFocus,
                    ),
                    _InterestsStep(
                      selected: _selectedInterests,
                      onToggle: (interest) {
                        setState(() {
                          if (_selectedInterests.contains(interest)) {
                            if (_selectedInterests.length > 1) {
                              _selectedInterests.remove(interest);
                            }
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                      },
                    ),
                    _ReadyStep(
                      name: _nameController.text.trim().isEmpty
                          ? 'there'
                          : _nameController.text.trim().split(' ').first,
                      interests: _selectedInterests,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _ContinueButton(
                      label: _step == _totalSteps - 1
                          ? 'Start exploring'
                          : 'Continue',
                      enabled: _canContinue,
                      onPressed: _next,
                    ),
                    if (_step == 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'No account needed · Your data stays on device',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 0: Welcome ─────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NorthstarLogo(size: 72),
          const SizedBox(height: 40),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.tagline,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            'Technology news, clustered into one story.\nExplained. Personalized. No noise.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _FeatureRow(
            icon: Icons.hub_outlined,
            text: '40 sources → 1 canonical story',
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.psychology_outlined,
            text: 'AI explains why it matters to you',
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.offline_bolt_outlined,
            text: 'Works offline · No login required',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

// ── Step 1: Name ────────────────────────────────────────────────

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What should we\ncall you?',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 12),
          Text(
            'Just your first name. We\'ll personalize your briefings.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: focusNode.hasFocus ? AppColors.accent : AppColors.border,
                width: focusNode.hasFocus ? 1.5 : 1,
              ),
              boxShadow: focusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
              textCapitalization: TextCapitalization.words,
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Stored locally on your device. Never shared.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Interests ───────────────────────────────────────────

class _InterestsStep extends StatelessWidget {
  const _InterestsStep({required this.selected, required this.onToggle});
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What do you\ncare about?',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 34),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pick at least one. We\'ll learn more as you read.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.availableInterests.map((interest) {
                  final isSelected = selected.contains(interest);
                  return GestureDetector(
                    onTap: () => onToggle(interest),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        interest,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${selected.length} selected',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Ready ───────────────────────────────────────────────

class _ReadyStep extends StatelessWidget {
  const _ReadyStep({required this.name, required this.interests});
  final String name;
  final Set<String> interests;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.3),
                  AppColors.accent.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.accent,
                      fontSize: 36,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'You\'re all set, $name',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your personalized tech feed is ready.\nWe\'ll surface what matters — nothing else.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Interests', value: '${interests.length}'),
                    Container(width: 1, height: 32, color: AppColors.border),
                    _StatItem(label: 'Sources', value: '20+'),
                    Container(width: 1, height: 32, color: AppColors.border),
                    _StatItem(label: 'Login', value: 'None'),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: interests.take(5).map((i) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        i,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.accent,
                            ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.accent)),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: enabled ? AppColors.accent : AppColors.surfaceElevated,
          disabledBackgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: enabled ? 0 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : AppColors.textTertiary,
              ),
            ),
            if (enabled) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
