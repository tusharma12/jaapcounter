import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/day_key.dart';
import '../../../core/utils/ids.dart';
import '../../mantras/domain/mantra.dart';
import '../domain/jaap_entry.dart';
import '../domain/jaap_session.dart';
import '../domain/mala_math.dart';

/// The persistence half of the counting engine.
///
/// Beads are written to an append-only ledger. Consecutive taps increment one
/// row rather than inserting thousands, but every single bead still goes
/// through a write, so a tap that has been acknowledged on screen is a tap
/// that survives the app being killed.
class JaapRepository {
  JaapRepository(this._db, {Clock? clock, IdFactory? idFactory})
    : _now = clock ?? systemClock,
      _newId = idFactory ?? newId;

  final Database _db;
  final Clock _now;
  final IdFactory _newId;

  static const String _table = 'jaap_entries';

  // ---------------------------------------------------------------- writing

  /// Records [delta] beads and returns the mantra's new lifetime total.
  Future<int> addBeads({
    required String mantraId,
    int delta = 1,
    JaapSource source = JaapSource.tap,
    String? sessionId,
    DateTime? at,
  }) async {
    if (delta <= 0) return lifetimeFor(mantraId);
    final now = at ?? _now();
    final day = DayKeys.of(now);

    return _db.transaction<int>((txn) async {
      final existing = await _coalescibleRow(
        txn,
        mantraId: mantraId,
        day: day,
        source: source,
        sessionId: sessionId,
        now: now,
      );

      if (existing != null) {
        await txn.rawUpdate(
          'UPDATE $_table SET count = count + ?, timestamp = ? WHERE id = ?',
          [delta, now.millisecondsSinceEpoch, existing['id']],
        );
      } else {
        final entry = JaapEntry(
          id: _newId(),
          mantraId: mantraId,
          count: delta,
          day: day,
          timestamp: now,
          source: source,
          sessionId: sessionId,
        );
        await txn.insert(_table, entry.toMap());
      }

      return _sum(txn, where: 'mantra_id = ?', args: [mantraId]);
    });
  }

  /// A row the incoming beads can join: same mantra, same day, same origin and
  /// recent enough that it is still the same stretch of chanting. Manual and
  /// imported entries are never merged, so they stay auditable.
  Future<Map<String, Object?>?> _coalescibleRow(
    DatabaseExecutor txn, {
    required String mantraId,
    required String day,
    required JaapSource source,
    required String? sessionId,
    required DateTime now,
  }) async {
    if (source != JaapSource.tap && source != JaapSource.auto) return null;

    final cutoff = now
        .subtract(AppConstants.ledgerCoalesceWindow)
        .millisecondsSinceEpoch;
    final rows = await txn.query(
      _table,
      where:
          'mantra_id = ? AND day = ? AND source = ? AND timestamp >= ? '
          'AND session_id IS ${sessionId == null ? 'NULL' : '?'}',
      whereArgs: [mantraId, day, source.name, cutoff, ?sessionId],
      orderBy: 'timestamp DESC, rowid DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Removes the most recent bead for [mantraId]. Returns false when there is
  /// nothing left to undo.
  Future<bool> undoLastBead({required String mantraId}) async {
    return _db.transaction<bool>((txn) async {
      final rows = await txn.query(
        _table,
        where: 'mantra_id = ?',
        whereArgs: [mantraId],
        orderBy: 'timestamp DESC, rowid DESC',
        limit: 1,
      );
      if (rows.isEmpty) return false;

      final entry = JaapEntry.fromMap(rows.first);
      if (entry.count > 1) {
        await txn.update(
          _table,
          {'count': entry.count - 1},
          where: 'id = ?',
          whereArgs: [entry.id],
        );
      } else {
        await txn.delete(_table, where: 'id = ?', whereArgs: [entry.id]);
      }

      // An undo that crosses a mala reset would leave the reset base above the
      // lifetime total; pull it back so the ledger stays authoritative.
      final lifetime = await _sum(
        txn,
        where: 'mantra_id = ?',
        args: [mantraId],
      );
      await txn.rawUpdate(
        'UPDATE mantras SET mala_base = ? WHERE id = ? AND mala_base > ?',
        [lifetime, mantraId, lifetime],
      );
      return true;
    });
  }

  /// Resets the mala in progress without touching a single recorded bead:
  /// the partial beads simply stop counting toward malas.
  Future<int> resetCurrentMala(Mantra mantra) async {
    final lifetime = await lifetimeFor(mantra.id);
    final base = MalaMath.baseAfterMalaReset(
      lifetimeJaap: lifetime,
      malaSize: mantra.malaSize,
      malaBase: mantra.malaBase,
    );
    await _db.update(
      'mantras',
      {'mala_base': base},
      where: 'id = ?',
      whereArgs: [mantra.id],
    );
    return base;
  }

  Future<int> deleteDay(String day, {String? mantraId}) async {
    final where = StringBuffer('day = ?');
    final args = <Object?>[day];
    if (mantraId != null) {
      where.write(' AND mantra_id = ?');
      args.add(mantraId);
    }
    return _db.delete(_table, where: where.toString(), whereArgs: args);
  }

  Future<void> deleteAllEntries() async {
    await _db.transaction((txn) async {
      await txn.delete(_table);
      await txn.delete('sessions');
      await txn.rawUpdate('UPDATE mantras SET mala_base = 0');
    });
  }

  // ---------------------------------------------------------------- reading

  Future<int> lifetimeFor(String mantraId) =>
      _sum(_db, where: 'mantra_id = ?', args: [mantraId]);

  Future<int> lifetimeTotal() => _sum(_db);

  Future<int> dayTotal(String day, {String? mantraId}) {
    if (mantraId == null) return _sum(_db, where: 'day = ?', args: [day]);
    return _sum(_db, where: 'day = ? AND mantra_id = ?', args: [day, mantraId]);
  }

  /// Daily totals keyed by day, for goals, streaks, charts and the heatmap.
  /// Days without Jaap are simply absent.
  Future<Map<String, int>> totalsByDay({
    String? fromDay,
    String? toDay,
    String? mantraId,
  }) async {
    final where = <String>[];
    final args = <Object?>[];
    if (fromDay != null) {
      where.add('day >= ?');
      args.add(fromDay);
    }
    if (toDay != null) {
      where.add('day <= ?');
      args.add(toDay);
    }
    if (mantraId != null) {
      where.add('mantra_id = ?');
      args.add(mantraId);
    }

    final rows = await _db.rawQuery(
      'SELECT day, SUM(count) AS total FROM $_table'
      '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}'
      ' GROUP BY day ORDER BY day ASC',
      args,
    );
    return {
      for (final row in rows) row['day'] as String: (row['total'] as int?) ?? 0,
    };
  }

  Future<Map<String, int>> totalsByMantra({
    String? fromDay,
    String? toDay,
  }) async {
    final where = <String>[];
    final args = <Object?>[];
    if (fromDay != null) {
      where.add('day >= ?');
      args.add(fromDay);
    }
    if (toDay != null) {
      where.add('day <= ?');
      args.add(toDay);
    }
    final rows = await _db.rawQuery(
      'SELECT mantra_id, SUM(count) AS total FROM $_table'
      '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}'
      ' GROUP BY mantra_id',
      args,
    );
    return {
      for (final row in rows)
        row['mantra_id'] as String: (row['total'] as int?) ?? 0,
    };
  }

  Future<String?> firstRecordedDay() async {
    final rows = await _db.rawQuery('SELECT MIN(day) AS day FROM $_table');
    return rows.isEmpty ? null : rows.first['day'] as String?;
  }

  Future<List<JaapEntry>> allEntries() async {
    final rows = await _db.query(_table, orderBy: 'timestamp ASC');
    return rows.map(JaapEntry.fromMap).toList();
  }

  Future<int> entryCount() async {
    final rows = await _db.rawQuery('SELECT COUNT(*) AS c FROM $_table');
    return (rows.first['c'] as int?) ?? 0;
  }

  // --------------------------------------------------------------- sessions

  Future<JaapSession> startSession(String mantraId) async {
    final session = JaapSession(
      id: _newId(),
      mantraId: mantraId,
      startedAt: _now(),
    );
    await _db.insert('sessions', session.toMap());
    return session;
  }

  Future<JaapSession?> endSession(String sessionId) async {
    final rows = await _db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final count = await _sum(_db, where: 'session_id = ?', args: [sessionId]);
    final ended = JaapSession.fromMap(
      rows.first,
    ).copyWith(endedAt: _now(), count: count);
    await _db.update(
      'sessions',
      ended.toMap(),
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return ended;
  }

  Future<List<JaapSession>> recentSessions({int limit = 20}) async {
    final rows = await _db.query(
      'sessions',
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return rows.map(JaapSession.fromMap).toList();
  }

  // ----------------------------------------------------------------- backup

  Future<List<JaapSession>> allSessions() async {
    final rows = await _db.query('sessions', orderBy: 'started_at ASC');
    return rows.map(JaapSession.fromMap).toList();
  }

  Future<void> replaceAllSessions(List<JaapSession> sessions) async {
    await _db.transaction((txn) async {
      await txn.delete('sessions');
      final batch = txn.batch();
      for (final session in sessions) {
        batch.insert(
          'sessions',
          session.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> replaceAllEntries(List<JaapEntry> entries) async {
    await _db.transaction((txn) async {
      await txn.delete(_table);
      final batch = txn.batch();
      for (final entry in entries) {
        batch.insert(
          _table,
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> _sum(
    DatabaseExecutor executor, {
    String? where,
    List<Object?> args = const [],
  }) async {
    final rows = await executor.rawQuery(
      'SELECT COALESCE(SUM(count), 0) AS total FROM $_table'
      '${where == null ? '' : ' WHERE $where'}',
      args,
    );
    return (rows.first['total'] as int?) ?? 0;
  }
}
