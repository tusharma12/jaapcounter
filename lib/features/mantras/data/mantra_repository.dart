import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/built_in_mantras.dart';
import '../../../core/utils/ids.dart';
import '../domain/mantra.dart';

/// Reads and writes the mantra library.
class MantraRepository {
  MantraRepository(this._db, {IdFactory? idFactory})
    : _newId = idFactory ?? newId;

  final Database _db;
  final IdFactory _newId;

  static const String _table = 'mantras';

  Future<List<Mantra>> all() async {
    final rows = await _db.query(
      _table,
      orderBy: 'is_built_in DESC, sort_order ASC, name ASC',
    );
    final mantras = rows.map(Mantra.fromMap).toList();
    return mantras.isEmpty ? [BuiltInMantras.fallback] : mantras;
  }

  Future<Mantra?> byId(String id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Mantra.fromMap(rows.first);
  }

  /// Creates a custom mantra and returns it, so callers can immediately
  /// activate what the user just added.
  Future<Mantra> create({
    required String name,
    String? description,
    int malaSize = AppConstants.defaultMalaSize,
  }) async {
    final nextOrder = await _nextSortOrder();
    final mantra = Mantra(
      id: _newId(),
      name: name.trim(),
      description: _clean(description),
      malaSize: malaSize.clamp(
        AppConstants.minMalaSize,
        AppConstants.maxMalaSize,
      ),
      sortOrder: nextOrder,
    );
    await _db.insert(_table, mantra.toMap());
    return mantra;
  }

  Future<void> update(Mantra mantra) async {
    await _db.update(
      _table,
      mantra.toMap(),
      where: 'id = ?',
      whereArgs: [mantra.id],
    );
  }

  /// Deletes a custom mantra. Built-in mantras are refused outright, which is
  /// what keeps a stray swipe from emptying the library.
  Future<void> delete(String id) async {
    final mantra = await byId(id);
    if (mantra == null) return;
    if (mantra.isBuiltIn) {
      throw const BuiltInMantraDeletionError();
    }
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// Replaces the whole library, then makes sure the built-ins are present.
  /// Used by restore, where a backup from an older version may be missing
  /// mantras this version ships with.
  Future<void> replaceAll(List<Mantra> mantras) async {
    await _db.transaction((txn) async {
      await txn.delete(_table);
      final batch = txn.batch();
      for (final mantra in mantras) {
        batch.insert(
          _table,
          mantra.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> _nextSortOrder() async {
    final result = await _db.rawQuery(
      'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next FROM $_table',
    );
    return (result.first['next'] as int?) ?? 0;
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

class BuiltInMantraDeletionError implements Exception {
  const BuiltInMantraDeletionError();

  @override
  String toString() => 'Built-in mantras cannot be deleted';
}
