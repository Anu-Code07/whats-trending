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
import '../../shared/widgets/floating_nav_bar.dart';

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
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/story/:id',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final storyId = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => ServiceLocator.createStoryBloc(storyId),
              child: StoryPage(storyId: storyId),
            );
          },
        ),
        GoRoute(
          path: '/discover',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, __) => const DiscoverPage(),
        ),
        GoRoute(
          path: '/brief',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, __) => const BriefPage(),
        ),
        GoRoute(
          path: '/profile',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, __) => const ProfilePage(),
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
            GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
            GoRoute(path: '/saved', builder: (_, __) => const SavedPage()),
          ],
        ),
      ],
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  int _currentIndex(BuildContext context) {
    return switch (GoRouterState.of(context).matchedLocation) {
      '/' => 0,
      '/search' => 1,
      '/saved' => 2,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: child,
      extendBody: true,
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex(context),
        onTap: (i) => context.go(['/', '/search', '/saved'][i]),
      ),
    );
  }
}
