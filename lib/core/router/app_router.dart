import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/brief/presentation/pages/brief_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/saved/presentation/pages/saved_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/story/presentation/pages/story_page.dart';
import '../di/service_locator.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../shared/widgets/ns_bottom_nav.dart';
import '../../shared/widgets/ns_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: (context, state) {
        final complete = ServiceLocator.storage.isOnboardingComplete;
        final isOnboarding = state.matchedLocation == '/onboarding';

        if (!complete && !isOnboarding) return '/onboarding';
        if (complete && isOnboarding) return '/';
        if (state.matchedLocation == '/brief') return '/pulse';
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/search',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, __) => _fadePage(const SearchPage()),
        ),
        GoRoute(
          path: '/profile',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, __) => _fadePage(const ProfilePage()),
        ),
        GoRoute(
          path: '/story/:id',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final storyId = state.pathParameters['id']!;
            return _fadePage(
              BlocProvider(
                create: (_) => ServiceLocator.createStoryBloc(storyId),
                child: StoryPage(storyId: storyId),
              ),
            );
          },
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => _AppShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => BlocProvider(
                create: (_) => ServiceLocator.createHomeBloc()..add(const LoadHomeFeed()),
                child: const HomePage(),
              ),
            ),
            GoRoute(path: '/pulse', builder: (_, __) => const BriefPage()),
            GoRoute(path: '/discover', builder: (_, __) => const DiscoverPage()),
            GoRoute(path: '/saved', builder: (_, __) => const SavedPage()),
          ],
        ),
      ],
    );
  }
}

CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  int _currentIndex(BuildContext context) {
    return switch (GoRouterState.of(context).matchedLocation) {
      '/' => 0,
      '/pulse' => 1,
      '/discover' => 2,
      '/saved' => 3,
      _ => 0,
    };
  }

  bool _isDark(BuildContext context) {
    return GoRouterState.of(context).matchedLocation == '/pulse';
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return NsScreen(
      dark: dark,
      child: Scaffold(
        body: child,
        bottomNavigationBar: NsBottomNav(
          currentIndex: _currentIndex(context),
          onTap: (i) => context.go(['/', '/pulse', '/discover', '/saved'][i]),
        ),
      ),
    );
  }
}
