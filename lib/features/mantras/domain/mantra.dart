import 'package:meta/meta.dart';

import '../../../core/constants/app_constants.dart';

/// A name to chant, together with the size of the mala used for it.
@immutable
class Mantra {
  const Mantra({
    required this.id,
    required this.name,
    required this.malaSize,
    this.devanagari,
    this.transliteration,
    this.isBuiltIn = false,
    this.sortOrder = 0,
    this.malaBase = 0,
  });

  final String id;

  /// Latin name, always present — used for accessibility and sorting.
  final String name;

  /// The mantra in Devanagari, shown as the hero text when available.
  final String? devanagari;
  final String? transliteration;

  /// Beads in one mala for this mantra.
  final int malaSize;

  final bool isBuiltIn;
  final int sortOrder;

  /// Lifetime beads that do not count toward malas, raised whenever the user
  /// resets the mala in progress. Keeping it here means a reset never has to
  /// delete history: totals stay intact while the bead position moves.
  final int malaBase;

  /// What to render large on the counter.
  String get display => (devanagari != null && devanagari!.isNotEmpty)
      ? devanagari!
      : name;

  bool get hasDevanagari => devanagari != null && devanagari!.isNotEmpty;

  /// A one-line subtitle: transliteration if we have one, else the Latin name.
  String get subtitle =>
      (transliteration != null && transliteration!.isNotEmpty)
      ? transliteration!
      : name;

  Mantra copyWith({
    String? id,
    String? name,
    Object? devanagari = _sentinel,
    Object? transliteration = _sentinel,
    int? malaSize,
    bool? isBuiltIn,
    int? sortOrder,
    int? malaBase,
  }) {
    return Mantra(
      id: id ?? this.id,
      name: name ?? this.name,
      devanagari: devanagari == _sentinel
          ? this.devanagari
          : devanagari as String?,
      transliteration: transliteration == _sentinel
          ? this.transliteration
          : transliteration as String?,
      malaSize: malaSize ?? this.malaSize,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
      malaBase: malaBase ?? this.malaBase,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'devanagari': devanagari,
    'transliteration': transliteration,
    'mala_size': malaSize,
    'is_built_in': isBuiltIn ? 1 : 0,
    'sort_order': sortOrder,
    'mala_base': malaBase,
  };

  factory Mantra.fromMap(Map<String, Object?> map) => Mantra(
    id: map['id'] as String,
    name: map['name'] as String,
    devanagari: map['devanagari'] as String?,
    transliteration: map['transliteration'] as String?,
    malaSize: (map['mala_size'] as int?) ?? AppConstants.defaultMalaSize,
    isBuiltIn: (map['is_built_in'] as int? ?? 0) == 1,
    sortOrder: (map['sort_order'] as int?) ?? 0,
    malaBase: (map['mala_base'] as int?) ?? 0,
  );

  @override
  bool operator ==(Object other) =>
      other is Mantra &&
      other.id == id &&
      other.name == name &&
      other.devanagari == devanagari &&
      other.transliteration == transliteration &&
      other.malaSize == malaSize &&
      other.isBuiltIn == isBuiltIn &&
      other.sortOrder == sortOrder &&
      other.malaBase == malaBase;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    devanagari,
    transliteration,
    malaSize,
    isBuiltIn,
    sortOrder,
    malaBase,
  );

  @override
  String toString() => 'Mantra($id, $name, mala $malaSize, base $malaBase)';
}

const Object _sentinel = Object();
