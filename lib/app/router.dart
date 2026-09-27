import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/backup/presentation/backup_screen.dart';
import '../features/jaap/presentation/jaap_screen.dart';
import '../features/mantras/presentation/mantras_screen.dart';
import '../features/meditation/presentation/blackout_screen.dart';
import '../features/meditation/presentation/meditation_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/sadhana/presentation/sadhana_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stories/presentation/stories_screen.dart';
import '../features/stories/presentation/story_screen.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/jaap',
    // Read, not watch: the router is built once, and the check runs on every
    // navigation, so a completed onboarding takes effect without rebuilding it.
    redirect: (context, state) {
      final onboarded = ref.read(settingsProvider).onboardingComplete;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !atOnboarding) return '/onboarding';
      if (onboarded && atOnboarding) return '/jaap';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Full-screen experiences sit above the tabs.
      GoRoute(
        path: '/meditation',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const MeditationScreen(),
      ),
      GoRoute(
        path: '/blackout',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const BlackoutScreen(),
      ),
      GoRoute(
        path: '/mantras',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const MantrasScreen(),
      ),
      GoRoute(
        path: '/sadhana',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SadhanaScreen(),
      ),
      GoRoute(
        path: '/reminders',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/backup',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const AboutScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jaap',
                builder: (context, state) => const JaapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stories',
                builder: (context, state) => const StoriesScreen(),
                routes: [
                  GoRoute(
                    path: 'favourites',
                    builder: (context, state) => const FavouriteStoriesScreen(),
                  ),
                  GoRoute(
                    path: ':storyId',
                    builder: (context, state) =>
                        StoryScreen(storyId: state.pathParameters['storyId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
