import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/services/shortcut_service.dart';
import '../features/jaap/presentation/auto_jaap_actions.dart';
import '../features/jaap/presentation/auto_jaap_controller.dart';
import '../features/jaap/presentation/jaap_controller.dart';
import '../features/reminders/presentation/reminder_controllers.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/app_themes.dart';

class JapMalaApp extends ConsumerWidget {
  const JapMalaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Naam Jap Counter – Smaran',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      // A fixed colour theme is handed in as both, so the device's light/dark
      // setting cannot swap it out.
      theme: settings.themeId == AppThemeId.system
          ? AppTheme.light()
          : AppTheme.forId(settings.themeId),
      darkTheme: settings.themeId == AppThemeId.system
          ? AppTheme.dark()
          : AppTheme.forId(settings.themeId),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      builder: (context, child) =>
          _AppLifecycle(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Watches the app's lifecycle so nothing is lost when it goes away, and so
/// the counter notices a day that turned over while it was in the background.
class _AppLifecycle extends ConsumerStatefulWidget {
  const _AppLifecycle({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppLifecycle> createState() => _AppLifecycleState();
}

class _AppLifecycleState extends ConsumerState<_AppLifecycle>
    with WidgetsBindingObserver {
  bool _remindersSynced = false;
  bool _goalDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(jaapControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Beads acknowledged on screen must be on disk before we lose the
        // process. Auto Jaap stops too: it should never count unseen.
        ref.read(autoJaapProvider.notifier).stop();
        controller.flushPendingWrites();
      case AppLifecycleState.resumed:
        controller.refreshForResume();
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// A home screen shortcut, whether it launched the app or woke it. The
  /// router's own redirect still sends a user who has not finished
  /// onboarding there first.
  void _openShortcut(String type) {
    if (type != ShortcutService.blackout) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      if (router.state.matchedLocation != '/blackout') router.push('/blackout');
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Auto Jaap reached the day's goal and is waiting for an answer. Shown
  /// from here, above whichever counting screen it happened on.
  Future<void> _askAboutGoal() async {
    // The overlay's context sits inside the navigator, so a dialog can find
    // it; the navigator's own context cannot.
    final context = ref
        .read(routerProvider)
        .routerDelegate
        .navigatorKey
        .currentState
        ?.overlay
        ?.context;
    if (context == null || _goalDialogOpen) return;
    _goalDialogOpen = true;
    final keepGoing = await showGoalReachedDialog(context);
    _goalDialogOpen = false;
    final auto = ref.read(autoJaapProvider.notifier);
    if (!ref.read(autoJaapProvider).awaitingGoalChoice) return;
    if (keepGoing) {
      auto.continueAfterGoal();
    } else {
      auto.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(autoJaapProvider.select((s) => s.awaitingGoalChoice), (
      was,
      now,
    ) {
      if (now) {
        _askAboutGoal();
      } else if (_goalDialogOpen) {
        // Answered another way, such as Auto Jaap stopping as the app went to
        // the background: the question no longer applies.
        ref
            .read(routerProvider)
            .routerDelegate
            .navigatorKey
            .currentState
            ?.pop(false);
      }
    });
    // Reminder and shortcut text is handed to the platform, so it is
    // refreshed once per launch in the app's current language.
    if (!_remindersSynced) {
      _remindersSynced = true;
      final l10n = AppL10n.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(remindersProvider.notifier)
            .reschedule(RemindersScreen.copyFrom(l10n));
        ref
            .read(shortcutServiceProvider)
            .register(
              blackoutLabel: l10n.blackoutMode,
              onSelected: _openShortcut,
            );
      });
    }
    return widget.child;
  }
}
