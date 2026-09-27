/// How the counter draws the mala in progress.
enum MalaStyle {
  /// A string of beads with the Sumeru and tassel.
  beads,

  /// A single smooth progress ring.
  ring;

  static MalaStyle? tryParse(String? name) =>
      MalaStyle.values.where((s) => s.name == name).firstOrNull;
}
