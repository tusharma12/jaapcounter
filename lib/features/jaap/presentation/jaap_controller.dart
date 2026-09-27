import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_themes.dart';
import '../../../core/constants/built_in_mantras.dart';
import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/utils/day_key.dart';
import '../../mantras/domain/mantra_names.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../sadhana/presentation/sadhana_controllers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/jaap_entry.dart';
import '../domain/jaap_session.dart';
import '../domain/mala_math.dart';
import 'jaap_state.dart';

final jaapControllerProvider = AsyncNotifierProvider<JaapController, JaapState>(
  JaapController.new,
);

/// Drives the counter.
///
/// A tap updates the on-screen count synchronously and appends the write to a
/// serialised queue. That ordering matters: the user's thumb is faster than
/// SQLite, so the screen must never wait for a disk write, and the writes must
/// never overtake each other. Nothing is dropped - a hundred rapid taps
/// produce exactly a hundred recorded beads.
class JaapController extends AsyncNotifier<JaapState> {
  Future<void> _writes = Future<void>.value();
  Timer? _syncTimer;

  // Kept on the notifier rather than in state so they survive the rebuilds
  // that happen when the mantra or the goal changes.
  String? _sessionId;
  DateTime? _sessionStartedAt;
  int _sessionCount = 0;
  int _malaCompletions = 0;

  @override
  Future<JaapState> build() async {
    // Awaiting the list (rather than reading the derived provider alone) means
    // the counter never renders before the library is known.
    await ref.watch(mantraListProvider.future);
    final mantra = ref.watch(activeMantraProvider) ?? BuiltInMantras.fallback;
    final goal = ref.watch(dailyGoalProvider);

    final repo = ref.watch(jaapRepositoryProvider);
    final day = DayKeys.of(ref.watch(clockProvider)());
    final lifetime = await repo.lifetimeFor(mantra.id);
    final todayTotal = await repo.dayTotal(day, mantraId: mantra.id);

    ref.onDispose(() {
      _syncTimer?.cancel();
    });
    // The widget wears the app's theme, so a new theme repaints it too.
    ref.listen(settingsProvider.select((s) => s.themeId), (_, _) {
      unawaited(_publishToWidget());
    });
    // And it names a built-in mantra in the app's language.
    ref.listen(settingsProvider.select((s) => s.localeCode), (_, _) {
      unawaited(_publishToWidget());
    });

    return JaapState(
      mantra: mantra,
      lifetime: lifetime,
      todayTotal: todayTotal,
      dailyGoal: goal,
      day: day,
      undoAvailable: lifetime > 0,
      sessionId: _sessionId,
      sessionStartedAt: _sessionStartedAt,
      sessionCount: _sessionCount,
      malaCompletions: _malaCompletions,
    );
  }

  // ---------------------------------------------------------------- counting

  /// Records beads. Synchronous by design: the count on screen changes in the
  /// same frame as the tap.
  void count([int delta = 1, JaapSource source = JaapSource.tap]) {
    final current = state.value;
    if (current == null || delta <= 0) return;

    final now = ref.read(clockProvider)();
    final day = DayKeys.of(now);
    final rolledOver = day != current.day;

    final crossedMala = MalaMath.crossesMala(
      beadsBefore: current.position.beadsInCurrentMala,
      delta: delta,
      malaSize: current.mantra.malaSize,
    );
    if (crossedMala) _malaCompletions++;
    _sessionCount += delta;

    state = AsyncData(
      current.copyWith(
        lifetime: current.lifetime + delta,
        todayTotal: (rolledOver ? 0 : current.todayTotal) + delta,
        day: day,
        undoAvailable: true,
        sessionCount: _sessionCount,
        malaCompletions: _malaCompletions,
      ),
    );

    // The goal outranks the mala when one bead completes both.
    final before = rolledOver ? 0 : current.todayTotal;
    final goal = current.dailyGoal;
    final crossedGoal = goal > 0 && before < goal && before + delta >= goal;
    final feedback = ref.read(feedbackProvider);
    if (crossedGoal) {
      feedback.goalReached();
    } else if (crossedMala) {
      feedback.malaComplete();
    } else {
      feedback.bead();
    }

    final mantraId = current.mantra.id;
    final sessionId = _sessionId;
    _enqueue(
      () => ref
          .read(jaapRepositoryProvider)
          .addBeads(
            mantraId: mantraId,
            delta: delta,
            source: source,
            sessionId: sessionId,
            at: now,
          ),
    );
  }

  /// Removes the most recent bead. Returns false when there was nothing left.
  Future<bool> undo() async {
    final current = state.value;
    if (current == null) return false;

    await flushPendingWrites();
    final removed = await ref
        .read(jaapRepositoryProvider)
        .undoLastBead(mantraId: current.mantra.id);
    if (!removed) return false;

    if (_sessionCount > 0) _sessionCount--;
    await ref.read(feedbackProvider).removal();
    await _reloadFromLedger();
    return true;
  }

  /// Clears the mala in progress. Recorded Jaap is untouched - only the bead
  /// position moves - so totals and streaks are unaffected.
  Future<void> resetCurrentMala() async {
    final current = state.value;
    if (current == null) return;

    await flushPendingWrites();
    await ref.read(jaapRepositoryProvider).resetCurrentMala(current.mantra);
    await ref.read(feedbackProvider).removal();
    // The reset lives on the mantra, so the library is the thing to refresh.
    ref.invalidate(mantraListProvider);
    _notifyLedgerChanged();
  }

  /// Adds beads counted somewhere else - a physical mala, a hand counter.
  Future<void> addManualCount(
    int amount, {
    JaapSource source = JaapSource.manual,
  }) async {
    final current = state.value;
    if (current == null || amount <= 0) return;

    await flushPendingWrites();
    await ref
        .read(jaapRepositoryProvider)
        .addBeads(mantraId: current.mantra.id, delta: amount, source: source);
    await _reloadFromLedger();
  }

  // ---------------------------------------------------------------- sessions

  Future<void> startSession() async {
    final current = state.value;
    if (current == null || _sessionId != null) return;

    final session = await ref
        .read(jaapRepositoryProvider)
        .startSession(current.mantra.id);
    _sessionId = session.id;
    _sessionStartedAt = session.startedAt;
    _sessionCount = 0;
    state = AsyncData(
      current.copyWith(
        sessionId: session.id,
        sessionStartedAt: session.startedAt,
        sessionCount: 0,
      ),
    );
  }

  /// Ends the running session and returns it, so the screen can show a summary.
  Future<JaapSession?> endSession() async {
    final id = _sessionId;
    if (id == null) return null;

    await flushPendingWrites();
    final session = await ref.read(jaapRepositoryProvider).endSession(id);
    _sessionId = null;
    _sessionStartedAt = null;
    _sessionCount = 0;

    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          sessionId: null,
          sessionStartedAt: null,
          sessionCount: 0,
        ),
      );
    }
    return session;
  }

  // ------------------------------------------------------------- maintenance

  /// Re-reads the ledger. Called after any operation that changes history
  /// rather than appending to it.
  Future<void> _reloadFromLedger() async {
    final current = state.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    final repo = ref.read(jaapRepositoryProvider);
    final mantra =
        await ref.read(mantraRepositoryProvider).byId(current.mantra.id) ??
        current.mantra;
    final day = DayKeys.of(ref.read(clockProvider)());
    final lifetime = await repo.lifetimeFor(mantra.id);
    final todayTotal = await repo.dayTotal(day, mantraId: mantra.id);

    state = AsyncData(
      current.copyWith(
        mantra: mantra,
        lifetime: lifetime,
        todayTotal: todayTotal,
        day: day,
        undoAvailable: lifetime > 0,
      ),
    );
    _notifyLedgerChanged();
  }

  /// Called when the app comes back to the foreground: the calendar may have
  /// moved on, and another surface (a widget tap) may have added beads.
  Future<void> refreshForResume() async {
    await flushPendingWrites();
    await _reloadFromLedger();
  }

  void _enqueue(Future<void> Function() write) {
    _writes = _writes.then((_) => write()).catchError((
      Object error,
      StackTrace stack,
    ) {
      AppLogger.e('Failed to persist Jaap', error, stack);
    });
    _scheduleSync();
  }

  /// Waits for every queued write to reach the database. Called before any
  /// read-modify-write, and on app pause.
  Future<void> flushPendingWrites() => _writes;

  /// Derived screens and the home widget are refreshed a moment after the
  /// tapping stops, rather than on every bead.
  void _scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 600), () async {
      await flushPendingWrites();
      _notifyLedgerChanged();
    });
  }

  void _notifyLedgerChanged() {
    ref.read(ledgerRevisionProvider.notifier).bump();
    unawaited(_publishToWidget());
  }

  Future<void> _publishToWidget() async {
    final current = state.value;
    if (current == null) return;
    try {
      final streak = await ref.read(streakProvider.future);
      await ref
          .read(widgetServiceProvider)
          .publish(
            mantraDisplay: current.mantra.nameIn(
              ref.read(settingsProvider).localeCode ??
                  PlatformDispatcher.instance.locale.languageCode,
            ),
            beadsInCurrentMala: current.position.beadsInCurrentMala,
            malaSize: current.mantra.malaSize,
            todayTotal: current.todayTotal,
            todayMalas: current.todayMalas,
            streak: streak.current,
            palette: AppThemeSpec.of(
              ref.read(settingsProvider).themeId,
            )?.palette,
          );
    } on Object catch (error, stack) {
      AppLogger.e('Could not publish widget data', error, stack);
    }
  }
}
