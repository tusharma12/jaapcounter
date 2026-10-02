import 'package:meta/meta.dart';

import '../../mantras/domain/mantra.dart';
import '../domain/mala_math.dart';

/// Everything the counter screen needs, in one immutable snapshot.
@immutable
class JaapState {
  const JaapState({
    required this.mantra,
    required this.lifetime,
    required this.todayTotal,
    required this.dailyGoal,
    required this.day,
    this.undoAvailable = false,
    this.sessionId,
    this.sessionStartedAt,
    this.sessionCount = 0,
    this.malaCompletions = 0,
    this.milestone,
    this.milestoneCount = 0,
  });

  final Mantra mantra;

  /// Every bead ever counted for this mantra.
  final int lifetime;

  /// Beads counted for this mantra today.
  final int todayTotal;

  final int dailyGoal;

  /// The day [todayTotal] belongs to, so a rollover past midnight is noticed.
  final String day;

  final bool undoAvailable;

  final String? sessionId;
  final DateTime? sessionStartedAt;
  final int sessionCount;

  /// Increments each time a mala is finished. The screen watches this to run
  /// the completion animation exactly once per mala.
  final int malaCompletions;

  /// The lifetime Jaap milestone most recently reached while counting, and
  /// how many have been reached this run, so the screen celebrates each once.
  final int? milestone;
  final int milestoneCount;

  bool get sessionRunning => sessionId != null;

  MalaPosition get position => MalaMath.position(
    lifetimeJaap: lifetime,
    malaSize: mantra.malaSize,
    malaBase: mantra.malaBase,
  );

  int get todayMalas => MalaMath.malasIn(todayTotal, mantra.malaSize);

  double get goalFraction =>
      dailyGoal <= 0 ? 0 : (todayTotal / dailyGoal).clamp(0.0, 1.0);

  bool get goalReached => dailyGoal > 0 && todayTotal >= dailyGoal;

  int get goalRemaining =>
      dailyGoal <= 0 ? 0 : (dailyGoal - todayTotal).clamp(0, dailyGoal);

  JaapState copyWith({
    Mantra? mantra,
    int? lifetime,
    int? todayTotal,
    int? dailyGoal,
    String? day,
    bool? undoAvailable,
    Object? sessionId = _sentinel,
    Object? sessionStartedAt = _sentinel,
    int? sessionCount,
    int? malaCompletions,
    int? milestone,
    int? milestoneCount,
  }) {
    return JaapState(
      mantra: mantra ?? this.mantra,
      lifetime: lifetime ?? this.lifetime,
      todayTotal: todayTotal ?? this.todayTotal,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      day: day ?? this.day,
      undoAvailable: undoAvailable ?? this.undoAvailable,
      sessionId: sessionId == _sentinel ? this.sessionId : sessionId as String?,
      sessionStartedAt: sessionStartedAt == _sentinel
          ? this.sessionStartedAt
          : sessionStartedAt as DateTime?,
      sessionCount: sessionCount ?? this.sessionCount,
      malaCompletions: malaCompletions ?? this.malaCompletions,
      milestone: milestone ?? this.milestone,
      milestoneCount: milestoneCount ?? this.milestoneCount,
    );
  }
}

const Object _sentinel = Object();
