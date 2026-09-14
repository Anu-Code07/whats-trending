import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/brief/presentation/pages/brief_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/saved/presentation/pages/saved_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/story/presentation/pages/story_page.dart';
import '../di/service_locator.dart';
import '../theme/app_colors.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final complete = prefs.getBool('onboarding_complete') ?? false;
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
          path: '/search',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, __) => const SearchPage(),
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
            GoRoute(
              path: '/discover',
              builder: (_, __) => const DiscoverPage(),
            ),
            GoRoute(
              path: '/brief',
              builder: (_, __) => const BriefPage(),
            ),
            GoRoute(
              path: '/saved',
              builder: (_, __) => const SavedPage(),
            ),
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfilePage(),
            ),
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
    final location = GoRouterState.of(context).matchedLocation;
    return switch (location) {
      '/' => 0,
      '/discover' => 1,
      '/brief' => 2,
      '/saved' => 3,
      '/profile' => 4,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex(context),
          onTap: (index) {
            final path = switch (index) {
              0 => '/',
              1 => '/discover',
              2 => '/brief',
              3 => '/saved',
              4 => '/profile',
              _ => '/',
            };
            context.go(path);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), activeIcon: Icon(Icons.wb_sunny), label: 'Brief'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'Saved'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
