import 'package:meta/meta.dart';

import '../../../core/constants/app_constants.dart';

/// A mantra to chant, together with the size of the mala used for it.
@immutable
class Mantra {
  const Mantra({
    required this.id,
    required this.name,
    required this.malaSize,
    this.description,
    this.isBuiltIn = false,
    this.sortOrder = 0,
    this.malaBase = 0,
  });

  final String id;

  /// The mantra itself, exactly as it is chanted, in whatever script the
  /// user wrote it: राम, ॐ नमः शिवाय, Waheguru.
  final String name;

  /// An optional note: a meaning, a source, a reminder of why.
  final String? description;

  /// Beads in one mala for this mantra.
  final int malaSize;

  final bool isBuiltIn;
  final int sortOrder;

  /// Lifetime beads that do not count toward malas, raised whenever the user
  /// resets the mala in progress. Keeping it here means a reset never has to
  /// delete history: totals stay intact while the bead position moves.
  final int malaBase;

  static final _devanagari = RegExp('[ऀ-ॿ]');

  /// Whether the mantra needs the Devanagari typeface to render well.
  bool get isDevanagari => _devanagari.hasMatch(name);

  bool get hasDescription => description != null && description!.isNotEmpty;

  Mantra copyWith({
    String? id,
    String? name,
    Object? description = _sentinel,
    int? malaSize,
    bool? isBuiltIn,
    int? sortOrder,
    int? malaBase,
  }) {
    return Mantra(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description == _sentinel
          ? this.description
          : description as String?,
      malaSize: malaSize ?? this.malaSize,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
      malaBase: malaBase ?? this.malaBase,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'mala_size': malaSize,
    'is_built_in': isBuiltIn ? 1 : 0,
    'sort_order': sortOrder,
    'mala_base': malaBase,
  };

  /// Also reads rows and backups from before mantras had a description,
  /// when a mantra carried a Latin name plus optional Devanagari and
  /// transliteration. See [fromLegacy].
  factory Mantra.fromMap(Map<String, Object?> map) {
    final (name, description) = map.containsKey('description')
        ? (map['name'] as String, map['description'] as String?)
        : fromLegacy(
            name: map['name'] as String,
            devanagari: map['devanagari'] as String?,
            transliteration: map['transliteration'] as String?,
          );
    return Mantra(
      id: map['id'] as String,
      name: name,
      description: description,
      malaSize: (map['mala_size'] as int?) ?? AppConstants.defaultMalaSize,
      isBuiltIn: (map['is_built_in'] as int? ?? 0) == 1,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      malaBase: (map['mala_base'] as int?) ?? 0,
    );
  }

  /// The old three fields as the new two. The Devanagari, when there was
  /// any, is what was shown on the counter, so it becomes the mantra; the
  /// Latin name the user typed is kept as its description rather than lost.
  static (String, String?) fromLegacy({
    required String name,
    String? devanagari,
    String? transliteration,
  }) {
    String? clean(String? s) =>
        (s == null || s.trim().isEmpty) ? null : s.trim();
    final script = clean(devanagari);
    if (script == null) return (name, clean(transliteration));
    return (script, clean(transliteration) ?? clean(name));
  }

  @override
  bool operator ==(Object other) =>
      other is Mantra &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.malaSize == malaSize &&
      other.isBuiltIn == isBuiltIn &&
      other.sortOrder == sortOrder &&
      other.malaBase == malaBase;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    malaSize,
    isBuiltIn,
    sortOrder,
    malaBase,
  );

  @override
  String toString() => 'Mantra($id, $name, mala $malaSize, base $malaBase)';
}

const Object _sentinel = Object();
