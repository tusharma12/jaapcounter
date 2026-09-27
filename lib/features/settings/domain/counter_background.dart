import 'package:flutter/material.dart';

/// What sits behind the counter. [photo] is a picture the user chose; the
/// others are gradients drawn in code, so they cost nothing to ship.
enum CounterBackground {
  none,
  dawn,
  dusk,
  lotus,
  forest,
  ocean,
  cosmos,
  photo;

  static CounterBackground? tryParse(String? name) =>
      CounterBackground.values.where((b) => b.name == name).firstOrNull;

  /// The gradients offered in the picker, in order.
  static const List<CounterBackground> presets = [
    dawn,
    dusk,
    lotus,
    forest,
    ocean,
    cosmos,
  ];

  /// Top-to-bottom colours for a preset; empty for [none] and [photo].
  List<Color> get colors => switch (this) {
    dawn => const [Color(0xFFFFE0B2), Color(0xFFFFAB91), Color(0xFFF48FB1)],
    dusk => const [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)],
    lotus => const [Color(0xFFFCE4EC), Color(0xFFF8BBD0), Color(0xFFE1BEE7)],
    forest => const [Color(0xFF0B3D2E), Color(0xFF1E5E3F), Color(0xFF6A994E)],
    ocean => const [Color(0xFF01386A), Color(0xFF0A6E8A), Color(0xFF4FB3BF)],
    cosmos => const [Color(0xFF0B0B2B), Color(0xFF2C1B5A), Color(0xFF5B2A86)],
    none || photo => const [],
  };
}
