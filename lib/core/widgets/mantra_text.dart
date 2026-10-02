import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import '../../features/mantras/domain/mantra.dart';
import '../../features/mantras/domain/mantra_names.dart';

/// Renders a mantra in the typeface its script needs, at a size that makes
/// it the most prominent thing on the screen.
class MantraText extends StatelessWidget {
  const MantraText(
    this.mantra, {
    required this.size,
    this.color,
    this.weight = FontWeight.w500,
    this.maxLines = 2,
    this.align = TextAlign.center,
    super.key,
  });

  final Mantra mantra;
  final double size;
  final Color? color;
  final FontWeight weight;
  final int maxLines;
  final TextAlign align;

  static bool _isLatin(String text) =>
      !text.runes.any((r) => r >= 0x0900 && r <= 0x0DFF);

  @override
  Widget build(BuildContext context) {
    final text = mantra.displayName(context);
    final style = Mantra.isDevanagariText(text)
        ? AppTypography.mantra(size: size, weight: weight, color: color)
        : TextStyle(
            fontFamily: AppTypography.ui,
            fontSize: size,
            height: 1.25,
            fontWeight: weight,
            color: color,
            // Tighter tracking suits Roman letters, but on Indic scripts any
            // letter spacing breaks the joined letters apart.
            letterSpacing: _isLatin(text) ? -0.4 : 0,
          );

    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}
