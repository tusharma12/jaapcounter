import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/utils/day_key.dart';
import 'package:japmala/features/jaap/data/jaap_repository.dart';
import 'package:japmala/features/jaap/domain/jaap_entry.dart';
import 'package:japmala/features/jaap/domain/mala_math.dart';
import 'package:japmala/features/mantras/data/mantra_repository.dart';
import 'package:japmala/features/mantras/domain/mantra.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/test_harness.dart';

void main() {
  late Database db;
  late TestClock clock;
  late JaapRepository jaap;
  late MantraRepository mantras;
  late Mantra ram;

  setUp(() async {
    db = await openTestDatabase();
    clock = TestClock(DateTime(2026, 9, 3, 9));
    jaap = JaapRepository(db, clock: clock.call);
    mantras = MantraRepository(db);
    ram = (await mantras.byId('builtin.ram'))!;
    addTearDown(db.close);
  });

  group('recording beads', () {
    test('a single tap records one bead', () async {
      final lifetime = await jaap.addBeads(mantraId: ram.id);

      expect(lifetime, 1);
      expect(await jaap.dayTotal(clock.today, mantraId: ram.id), 1);
    });

    test('100 rapid taps record exactly 100 beads', () async {
      for (var i = 0; i < 100; i++) {
        clock.advance(const Duration(milliseconds: 40));
        await jaap.addBeads(mantraId: ram.id);
      }

      expect(await jaap.lifetimeFor(ram.id), 100);
      expect(await jaap.dayTotal(clock.today, mantraId: ram.id), 100);
    });

    test('100 concurrent taps record exactly 100 beads', () async {
      // The screen does not wait for the database, so writes can be in flight
      // at the same time. Not one of them may be lost.
      await Future.wait([
        for (var i = 0; i < 100; i++) jaap.addBeads(mantraId: ram.id),
      ]);

      expect(await jaap.lifetimeFor(ram.id), 100);
    });

    test('rapid taps coalesce into one ledger row', () async {
      for (var i = 0; i < 50; i++) {
        clock.advance(const Duration(milliseconds: 50));
        await jaap.addBeads(mantraId: ram.id);
      }

      expect(await jaap.entryCount(), 1);
      expect(await jaap.lifetimeFor(ram.id), 50);
    });

    test('a pause longer than the window starts a new row', () async {
      await jaap.addBeads(mantraId: ram.id);
      clock.advance(const Duration(minutes: 5));
      await jaap.addBeads(mantraId: ram.id);

      expect(await jaap.entryCount(), 2);
      expect(await jaap.lifetimeFor(ram.id), 2);
    });

    test('manual entries are kept separate from tapped ones', () async {
      await jaap.addBeads(mantraId: ram.id);
      await jaap.addBeads(
        mantraId: ram.id,
        delta: 108,
        source: JaapSource.manual,
      );
      await jaap.addBeads(mantraId: ram.id);

      expect(await jaap.lifetimeFor(ram.id), 110);
      final entries = await jaap.allEntries();
      expect(entries.where((e) => e.source == JaapSource.manual).length, 1);
      expect(
        entries.firstWhere((e) => e.source == JaapSource.manual).count,
        108,
      );
    });

    test('a physical counter entry is recorded with its own source', () async {
      await jaap.addBeads(
        mantraId: ram.id,
        delta: 216,
        source: JaapSource.physicalCounter,
      );

      final entries = await jaap.allEntries();
      expect(entries.single.source, JaapSource.physicalCounter);
      expect(await jaap.lifetimeFor(ram.id), 216);
    });

    test('beads are attributed to the mantra they were counted on', () async {
      final radha = (await mantras.byId('builtin.radha'))!;
      await jaap.addBeads(mantraId: ram.id, delta: 27);
      await jaap.addBeads(mantraId: radha.id, delta: 54);

      expect(await jaap.lifetimeFor(ram.id), 27);
      expect(await jaap.lifetimeFor(radha.id), 54);
      expect(await jaap.lifetimeTotal(), 81);
      expect(await jaap.totalsByMantra(), {ram.id: 27, radha.id: 54});
    });

    test('a bead counted before midnight belongs to that day', () async {
      clock.set(DateTime(2026, 9, 3, 23, 59));
      await jaap.addBeads(mantraId: ram.id);
      clock.set(DateTime(2026, 9, 4, 0, 1));
      await jaap.addBeads(mantraId: ram.id);

      expect(await jaap.dayTotal('2026-09-03', mantraId: ram.id), 1);
      expect(await jaap.dayTotal('2026-09-04', mantraId: ram.id), 1);
      expect(await jaap.entryCount(), 2, reason: 'rows never span two days');
    });
  });

  group('undo', () {
    test('removes exactly one bead from a coalesced row', () async {
      await jaap.addBeads(mantraId: ram.id, delta: 5);

      expect(await jaap.undoLastBead(mantraId: ram.id), isTrue);
      expect(await jaap.lifetimeFor(ram.id), 4);
      expect(await jaap.entryCount(), 1);
    });

    test('deletes the row when its last bead is undone', () async {
      await jaap.addBeads(mantraId: ram.id);

      expect(await jaap.undoLastBead(mantraId: ram.id), isTrue);
      expect(await jaap.lifetimeFor(ram.id), 0);
      expect(await jaap.entryCount(), 0);
    });

    test('reports nothing to undo on an empty ledger', () async {
      expect(await jaap.undoLastBead(mantraId: ram.id), isFalse);
    });

    test('does not touch another mantra', () async {
      final radha = (await mantras.byId('builtin.radha'))!;
      await jaap.addBeads(mantraId: radha.id, delta: 3);
      await jaap.addBeads(mantraId: ram.id, delta: 3);

      await jaap.undoLastBead(mantraId: radha.id);

      expect(await jaap.lifetimeFor(radha.id), 2);
      expect(await jaap.lifetimeFor(ram.id), 3);
    });

    test('undoing back past a reset leaves a consistent position', () async {
      await jaap.addBeads(mantraId: ram.id, delta: 40);
      await jaap.resetCurrentMala(ram);
      expect((await mantras.byId(ram.id))!.malaBase, 40);

      await jaap.undoLastBead(mantraId: ram.id);

      final after = (await mantras.byId(ram.id))!;
      expect(await jaap.lifetimeFor(ram.id), 39);
      expect(
        after.malaBase,
        39,
        reason: 'the reset base is pulled back to the ledger total',
      );
      final position = MalaMath.position(
        lifetimeJaap: await jaap.lifetimeFor(ram.id),
        malaSize: after.malaSize,
        malaBase: after.malaBase,
      );
      expect(position.beadsInCurrentMala, 0);
    });
  });

  group('resetting the current mala', () {
    test('clears the beads in progress and keeps the totals', () async {
      await jaap.addBeads(mantraId: ram.id, delta: 150);

      final base = await jaap.resetCurrentMala((await mantras.byId(ram.id))!);

      expect(base, 42, reason: '150 beads is one mala plus 42');
      expect(await jaap.lifetimeFor(ram.id), 150);
      expect(await jaap.dayTotal(clock.today, mantraId: ram.id), 150);
    });
  });

  group('aggregation', () {
    test('totals by day only include days with Jaap', () async {
      clock.set(DateTime(2026, 9, 1, 8));
      await jaap.addBeads(mantraId: ram.id, delta: 108);
      clock.set(DateTime(2026, 9, 3, 8));
      await jaap.addBeads(mantraId: ram.id, delta: 54);

      final totals = await jaap.totalsByDay();

      expect(totals, {'2026-09-01': 108, '2026-09-03': 54});
    });

    test('a day range excludes what falls outside it', () async {
      for (final day in [1, 2, 3, 4]) {
        clock.set(DateTime(2026, 9, day, 8));
        await jaap.addBeads(mantraId: ram.id, delta: 10);
      }

      final totals = await jaap.totalsByDay(
        fromDay: '2026-09-02',
        toDay: '2026-09-03',
      );

      expect(totals.keys, ['2026-09-02', '2026-09-03']);
    });

    test('the first recorded day is reported for the calendar', () async {
      clock.set(DateTime(2026, 7, 19, 8));
      await jaap.addBeads(mantraId: ram.id);
      clock.set(DateTime(2026, 9, 3, 8));
      await jaap.addBeads(mantraId: ram.id);

      expect(await jaap.firstRecordedDay(), '2026-07-19');
    });

    test('deleting a day removes only that day', () async {
      clock.set(DateTime(2026, 9, 2, 8));
      await jaap.addBeads(mantraId: ram.id, delta: 20);
      clock.set(DateTime(2026, 9, 3, 8));
      await jaap.addBeads(mantraId: ram.id, delta: 30);

      await jaap.deleteDay('2026-09-03');

      expect(await jaap.lifetimeFor(ram.id), 20);
      expect(await jaap.dayTotal('2026-09-02', mantraId: ram.id), 20);
    });

    test('deleting everything also clears mala reset bases', () async {
      await jaap.addBeads(mantraId: ram.id, delta: 40);
      await jaap.resetCurrentMala((await mantras.byId(ram.id))!);

      await jaap.deleteAllEntries();

      expect(await jaap.lifetimeTotal(), 0);
      expect((await mantras.byId(ram.id))!.malaBase, 0);
    });
  });

  group('sessions', () {
    test('a session records the beads counted inside it', () async {
      final session = await jaap.startSession(ram.id);
      await jaap.addBeads(mantraId: ram.id, delta: 30, sessionId: session.id);
      clock.advance(const Duration(minutes: 12));

      final ended = await jaap.endSession(session.id);

      expect(ended!.count, 30);
      expect(ended.isRunning, isFalse);
      expect(ended.elapsedAt(clock()).inMinutes, 12);
    });

    test('beads outside a session are not counted in it', () async {
      final session = await jaap.startSession(ram.id);
      await jaap.addBeads(mantraId: ram.id, delta: 10, sessionId: session.id);
      await jaap.addBeads(mantraId: ram.id, delta: 7);

      final ended = await jaap.endSession(session.id);

      expect(ended!.count, 10);
      expect(await jaap.lifetimeFor(ram.id), 17);
    });
  });

  group('day keys', () {
    test('a key round-trips through parsing', () {
      final date = DateTime(2026, 9, 3);
      expect(DayKeys.parse(DayKeys.of(date)), date);
    });

    test('a range crosses month and year boundaries', () {
      expect(
        DayKeys.keysInRange(DateTime(2026, 12, 30), DateTime(2027, 1, 2)),
        ['2026-12-30', '2026-12-31', '2027-01-01', '2027-01-02'],
      );
    });

    test('the week starts on Monday', () {
      // 2026-09-03 is a Thursday.
      expect(
        DayKeys.of(DayKeys.startOfWeek(DateTime(2026, 9, 3))),
        '2026-08-31',
      );
    });
  });
}
