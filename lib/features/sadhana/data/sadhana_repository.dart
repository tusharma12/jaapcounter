import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/day_key.dart';
import '../../../core/utils/ids.dart';
import '../domain/sadhana.dart';

/// Stores the daily goal and the Sankalp (the vow with a fixed length).
class SadhanaRepository {
  SadhanaRepository(this._db, {Clock? clock, IdFactory? idFactory})
    : _now = clock ?? systemClock,
      _newId = idFactory ?? newId;

  final Database _db;
  final Clock _now;
  final IdFactory _newId;

  static const String _table = 'sadhanas';

  Future<Sadhana?> active() async {
    final rows = await _db.query(
      _table,
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : Sadhana.fromMap(rows.first);
  }

  Future<List<Sadhana>> all() async {
    final rows = await _db.query(_table, orderBy: 'created_at DESC');
    return rows.map(Sadhana.fromMap).toList();
  }

  /// Starts a vow, retiring any vow already running — one active Sadhana at a
  /// time keeps "today's goal" unambiguous.
  Future<Sadhana> create({
    required String mantraId,
    required int dailyGoal,
    int? durationDays,
    bool reminderEnabled = false,
    int? reminderMinutes,
    DateTime? startAt,
  }) async {
    final now = startAt ?? _now();
    final sadhana = Sadhana(
      id: _newId(),
      mantraId: mantraId,
      dailyGoal: dailyGoal.clamp(1, 1000000),
      startDay: DayKeys.of(now),
      durationDays: durationDays?.clamp(1, AppConstants.maxSankalpDays),
      reminderEnabled: reminderEnabled,
      reminderMinutes: reminderMinutes,
      createdAt: now,
    );

    await _db.transaction((txn) async {
      await txn.update(_table, {'is_active': 0}, where: 'is_active = 1');
      await txn.insert(_table, sadhana.toMap());
    });
    return sadhana;
  }

  Future<void> update(Sadhana sadhana) async {
    await _db.update(
      _table,
      sadhana.toMap(),
      where: 'id = ?',
      whereArgs: [sadhana.id],
    );
  }

  /// Retires a vow while keeping it in history.
  Future<void> end(String id, {DateTime? at}) async {
    await _db.update(
      _table,
      {'is_active': 0, 'ended_day': DayKeys.of(at ?? _now())},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() => _db.delete(_table);

  Future<void> replaceAll(List<Sadhana> sadhanas) async {
    await _db.transaction((txn) async {
      await txn.delete(_table);
      final batch = txn.batch();
      for (final s in sadhanas) {
        batch.insert(
          _table,
          s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}
