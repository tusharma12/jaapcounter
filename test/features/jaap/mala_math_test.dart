import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/features/jaap/domain/mala_math.dart';

void main() {
  group('MalaMath.position', () {
    test('an empty ledger sits at the start of the first mala', () {
      final position = MalaMath.position(lifetimeJaap: 0, malaSize: 108);

      expect(position.beadsInCurrentMala, 0);
      expect(position.completedMalas, 0);
      expect(position.fraction, 0);
      expect(position.beadsRemaining, 108);
    });

    test('the bead before the end of a mala has not completed it', () {
      final position = MalaMath.position(lifetimeJaap: 107, malaSize: 108);

      expect(position.beadsInCurrentMala, 107);
      expect(position.completedMalas, 0);
      expect(position.beadsRemaining, 1);
    });

    test('the last bead completes the mala and starts the next at zero', () {
      final position = MalaMath.position(lifetimeJaap: 108, malaSize: 108);

      expect(position.beadsInCurrentMala, 0);
      expect(position.completedMalas, 1);
    });

    test('counts through many malas', () {
      final position = MalaMath.position(lifetimeJaap: 270, malaSize: 108);

      expect(position.completedMalas, 2);
      expect(position.beadsInCurrentMala, 54);
      expect(position.lifetimeJaap, 270);
    });

    test('a mala reset moves the bead position but keeps the total', () {
      // 50 beads counted, then reset, then a full mala.
      final base = MalaMath.baseAfterMalaReset(
        lifetimeJaap: 50,
        malaSize: 108,
        malaBase: 0,
      );
      expect(base, 50);

      final afterReset = MalaMath.position(
        lifetimeJaap: 50,
        malaSize: 108,
        malaBase: base,
      );
      expect(afterReset.beadsInCurrentMala, 0);
      expect(afterReset.completedMalas, 0);
      expect(afterReset.lifetimeJaap, 50, reason: 'recorded Jaap is not lost');

      final later = MalaMath.position(
        lifetimeJaap: 158,
        malaSize: 108,
        malaBase: base,
      );
      expect(later.completedMalas, 1);
      expect(later.beadsInCurrentMala, 0);
      expect(later.lifetimeJaap, 158);
    });

    test('a reset keeps malas already completed', () {
      final base = MalaMath.baseAfterMalaReset(
        lifetimeJaap: 250,
        malaSize: 108,
        malaBase: 0,
      );

      final position = MalaMath.position(
        lifetimeJaap: 250,
        malaSize: 108,
        malaBase: base,
      );
      expect(position.completedMalas, 2);
      expect(position.beadsInCurrentMala, 0);
    });

    test('a base above the lifetime total is clamped to the ledger', () {
      final position = MalaMath.position(
        lifetimeJaap: 40,
        malaSize: 108,
        malaBase: 90,
      );

      expect(position.beadsInCurrentMala, 0);
      expect(position.completedMalas, 0);
    });

    test('custom mala sizes divide correctly', () {
      expect(
        MalaMath.position(lifetimeJaap: 55, malaSize: 27).completedMalas,
        2,
      );
      expect(
        MalaMath.position(lifetimeJaap: 55, malaSize: 27).beadsInCurrentMala,
        1,
      );
      expect(
        MalaMath.position(lifetimeJaap: 54, malaSize: 54).completedMalas,
        1,
      );
    });

    test('a nonsensical mala size cannot divide by zero', () {
      final position = MalaMath.position(lifetimeJaap: 10, malaSize: 0);

      expect(position.malaSize, 1);
      expect(position.completedMalas, 10);
    });
  });

  group('MalaMath.crossesMala', () {
    test('detects the bead that completes a mala', () {
      expect(
        MalaMath.crossesMala(beadsBefore: 107, delta: 1, malaSize: 108),
        isTrue,
      );
      expect(
        MalaMath.crossesMala(beadsBefore: 106, delta: 1, malaSize: 108),
        isFalse,
      );
    });

    test('detects a manual entry that spans a mala boundary', () {
      expect(
        MalaMath.crossesMala(beadsBefore: 100, delta: 20, malaSize: 108),
        isTrue,
      );
    });
  });

  group('MalaMath.malasIn', () {
    test('counts whole malas only', () {
      expect(MalaMath.malasIn(323, 108), 2);
      expect(MalaMath.malasIn(324, 108), 3);
      expect(MalaMath.malasIn(0, 108), 0);
      expect(MalaMath.malasIn(-5, 108), 0);
    });
  });
}
