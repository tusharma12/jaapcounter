import 'package:sqflite/sqflite.dart';

import '../../../core/utils/ids.dart';
import '../domain/reminder.dart';

class ReminderRepository {
  ReminderRepository(this._db, {IdFactory? idFactory})
    : _newId = idFactory ?? newId;

  final Database _db;
  final IdFactory _newId;

  static const String _table = 'reminders';

  Future<List<Reminder>> all() async {
    final rows = await _db.query(_table, orderBy: 'minutes ASC');
    return rows.map(Reminder.fromMap).toList();
  }

  Future<List<Reminder>> ofKind(ReminderKind kind) async {
    final rows = await _db.query(
      _table,
      where: 'kind = ?',
      whereArgs: [kind.name],
      orderBy: 'minutes ASC',
    );
    return rows.map(Reminder.fromMap).toList();
  }

  Future<Reminder> create({
    required int minutes,
    ReminderKind kind = ReminderKind.jaap,
    String? label,
  }) async {
    final reminder = Reminder(
      id: _newId(),
      minutes: minutes,
      kind: kind,
      label: label,
    );
    await _db.insert(_table, reminder.toMap());
    return reminder;
  }

  /// Creates or moves the single reminder of a given kind.
  Future<Reminder> upsertSingleton({
    required ReminderKind kind,
    required int minutes,
    required bool enabled,
  }) async {
    final existing = await ofKind(kind);
    if (existing.isEmpty) {
      final reminder = Reminder(
        id: _newId(),
        minutes: minutes,
        kind: kind,
        enabled: enabled,
      );
      await _db.insert(_table, reminder.toMap());
      return reminder;
    }
    final updated = existing.first.copyWith(minutes: minutes, enabled: enabled);
    await update(updated);
    return updated;
  }

  Future<void> update(Reminder reminder) async {
    await _db.update(
      _table,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> delete(String id) =>
      _db.delete(_table, where: 'id = ?', whereArgs: [id]);

  Future<void> replaceAll(List<Reminder> reminders) async {
    await _db.transaction((txn) async {
      await txn.delete(_table);
      final batch = txn.batch();
      for (final r in reminders) {
        batch.insert(
          _table,
          r.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}
