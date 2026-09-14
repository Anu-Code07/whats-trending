import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;
  final Set<String> _selectedInterests = {'AI', 'React', 'Flutter', 'Programming'};

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setStringList('interests', _selectedInterests.toList());
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step > 0)
                IconButton(
                  onPressed: () => setState(() => _step--),
                  icon: const Icon(Icons.arrow_back),
                ),
              const Spacer(),
              if (_step == 0) ...[
                Text(
                  'Know what\nmatters in tech.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pulse collects technology news, clusters duplicate stories, '
                  'and personalizes what matters to you.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ] else if (_step == 1) ...[
                Text('What interests you?', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  'Select topics to personalize your feed. You can change these anytime.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.availableInterests.map((interest) {
                        final selected = _selectedInterests.contains(interest);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedInterests.remove(interest);
                              } else {
                                _selectedInterests.add(interest);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.accentMuted : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? AppColors.accent : AppColors.border,
                              ),
                            ),
                            child: Text(
                              interest,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: selected ? AppColors.accent : AppColors.textSecondary,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else ...[
                Text('You\'re all set', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
                const SizedBox(height: 16),
                Text(
                  'Your personalized feed is ready. Pulse will learn from what you read and continuously improve your experience.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text('${_selectedInterests.length} interests selected', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        _selectedInterests.join(' · '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      _complete();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_step < 2 ? 'Continue' : 'Start exploring'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
