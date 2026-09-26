/// Layout tokens. Whitespace is generous and consistent everywhere.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 40;

  /// Standard horizontal page padding.
  static const double page = 20;
}

abstract final class Radii {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 140);
  static const medium = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);
  static const celebration = Duration(milliseconds: 1600);
}

abstract final class Sizes {
  /// Minimum tappable edge, per platform accessibility guidance.
  static const double minTouch = 48;
  static const double navBarHeight = 64;
}
