import 'package:meta/meta.dart';

/// Where the user stands on the mala, derived from the ledger.
@immutable
class MalaPosition {
  const MalaPosition({
    required this.beadsInCurrentMala,
    required this.malaSize,
    required this.completedMalas,
    required this.lifetimeJaap,
  });

  /// Beads counted in the mala currently in progress, `0 ..< malaSize`.
  final int beadsInCurrentMala;
  final int malaSize;

  /// Malas finished since the last mala reset.
  final int completedMalas;

  /// Every bead ever counted for this mantra, including ones discarded from
  /// mala accounting by a reset.
  final int lifetimeJaap;

  double get fraction =>
      malaSize <= 0 ? 0 : (beadsInCurrentMala / malaSize).clamp(0.0, 1.0);

  int get beadsRemaining => (malaSize - beadsInCurrentMala).clamp(0, malaSize);

  static const empty = MalaPosition(
    beadsInCurrentMala: 0,
    malaSize: 108,
    completedMalas: 0,
    lifetimeJaap: 0,
  );
}

/// The counting engine, deliberately free of Flutter and of storage.
///
/// Given a lifetime total, the mala size and the reset base, it answers where
/// the beads sit. Both the live counter and the statistics screens go through
/// here so they can never disagree.
abstract final class MalaMath {
  static MalaPosition position({
    required int lifetimeJaap,
    required int malaSize,
    int malaBase = 0,
  }) {
    final size = malaSize < 1 ? 1 : malaSize;
    final total = lifetimeJaap < 0 ? 0 : lifetimeJaap;
    // A base above the lifetime total can only come from an undo that crossed
    // a reset; treat the ledger as authoritative and clamp.
    final base = malaBase.clamp(0, total);
    final progress = total - base;
    return MalaPosition(
      beadsInCurrentMala: progress % size,
      malaSize: size,
      completedMalas: progress ~/ size,
      lifetimeJaap: total,
    );
  }

  /// Malas represented by a bare count — used for lifetime and per-period
  /// statistics, where reset bases do not apply.
  static int malasIn(int jaap, int malaSize) {
    if (malaSize < 1) return 0;
    return (jaap < 0 ? 0 : jaap) ~/ malaSize;
  }

  /// True when adding [delta] beads finishes at least one mala.
  static bool crossesMala({
    required int beadsBefore,
    required int delta,
    required int malaSize,
  }) {
    if (malaSize < 1) return false;
    return (beadsBefore + delta) ~/ malaSize > beadsBefore ~/ malaSize;
  }

  /// The new [Mantra.malaBase] after the user resets the mala in progress:
  /// the partial beads stop counting toward malas but stay in the totals.
  static int baseAfterMalaReset({
    required int lifetimeJaap,
    required int malaSize,
    required int malaBase,
  }) {
    final p = position(
      lifetimeJaap: lifetimeJaap,
      malaSize: malaSize,
      malaBase: malaBase,
    );
    return (malaBase.clamp(0, lifetimeJaap) + p.beadsInCurrentMala)
        .clamp(0, lifetimeJaap);
  }
}
