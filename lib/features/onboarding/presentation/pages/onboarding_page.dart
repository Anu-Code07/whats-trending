import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/ns_palette.dart';
import '../../../../shared/widgets/glass_stack_hero.dart';
import '../../../../shared/widgets/interest_tile.dart';
import '../../../../shared/widgets/ns_primary_button.dart';
import '../../../../shared/widgets/ns_screen.dart';
import '../../../../shared/widgets/orb_backdrop.dart';
import '../widgets/onboarding_progress.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _totalSteps = 4;

  late final PageController _pageController;
  int _step = 0;
  final _nameController = TextEditingController();
  final Set<String> _selectedInterests = {'AI', 'Startups', 'Programming'};
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
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
        duration: const Duration(milliseconds: 420),
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
    return NsScreen(
      dark: true,
      child: Scaffold(
        body: OrbBackdrop(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      if (_step > 0)
                        IconButton(
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        )
                      else
                        const SizedBox(width: 12),
                      if (_step > 0)
                        Expanded(
                          child: OnboardingProgress(
                            currentStep: _step,
                            totalSteps: _totalSteps,
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _WelcomeStep(onStart: _next),
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
                if (_step != 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: NsPrimaryButton(
                      label: _step == _totalSteps - 1 ? 'Start exploring' : 'Continue',
                      enabled: _canContinue,
                      onPressed: _next,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [NsPalette.accentBright, NsPalette.accentDeep],
                  ),
                ),
                child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                AppConstants.appName,
                style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Spacer(),
          Text(
            AppConstants.headline,
            style: theme.displayLarge?.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              height: 1.08,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppConstants.subtitle,
            style: theme.bodyMedium?.copyWith(
              color: context.ns.textSecondary,
              height: 1.5,
            ),
          ),
          const GlassStackHero(),
          NsPrimaryButton(
            label: 'Get Started',
            onPressed: onStart,
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'No account needed · Your data stays on device',
              style: theme.labelSmall?.copyWith(color: context.ns.textTertiary),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
                  color: ns.textSecondary,
                ),
          ),
          const SizedBox(height: 36),
          Container(
            decoration: BoxDecoration(
              color: ns.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: focusNode.hasFocus ? NsPalette.accent : ns.border,
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.words,
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: TextStyle(color: ns.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                prefixIcon: Icon(Icons.person_outline_rounded, color: ns.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestsStep extends StatelessWidget {
  const _InterestsStep({required this.selected, required this.onToggle});
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Your interests',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us learn what you care about',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ns.textSecondary),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: GridView.builder(
              itemCount: AppConstants.featuredInterests.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final interest = AppConstants.featuredInterests[index];
                return InterestTile(
                  label: interest,
                  selected: selected.contains(interest),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onToggle(interest);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(
              children: [
                Icon(Icons.swipe_rounded, size: 16, color: ns.textTertiary),
                const SizedBox(width: 8),
                Text(
                  'Tap to select  ·  ${selected.length} chosen',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ns.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyStep extends StatelessWidget {
  const _ReadyStep({required this.name, required this.interests});
  final String name;
  final Set<String> interests;

  @override
  Widget build(BuildContext context) {
    final ns = context.ns;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [NsPalette.accentBright, NsPalette.accentDeep],
              ),
              boxShadow: [
                BoxShadow(
                  color: NsPalette.accent.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'You\'re all set, $name',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your personalized tech feed is ready.\nReal signal. Less noise.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ns.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: interests.take(6).map((i) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NsPalette.accentMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  i,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NsPalette.accentBright,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
