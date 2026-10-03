import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../mantras/domain/mantra.dart';
import '../../../mantras/domain/mantra_names.dart';

/// Sends the mantra drifting down the screen once for every bead counted.
///
/// It sits behind the counter and never takes a touch. Particles are capped,
/// so a burst of beads (Auto Jaap, a manual count) stays a gentle shower.
/// Whether it runs is the app's own Falling mantra setting alone.
class FallingMantra extends StatefulWidget {
  const FallingMantra({required this.mantra, required this.count, super.key});

  final Mantra mantra;

  /// Today's count for [mantra]. Each rise releases that many (up to a
  /// handful); a fall (undo) or a change of mantra releases nothing.
  final int count;

  static const int maxParticles = 28;
  static const int maxPerBurst = 6;

  @override
  State<FallingMantra> createState() => _FallingMantraState();
}

class _Particle {
  _Particle({
    required this.x,
    required this.size,
    required this.duration,
    required this.sway,
    required this.phase,
    required this.spin,
    required this.born,
  });

  /// 0–1 across the width.
  final double x;
  final double size;
  final Duration duration;

  /// Side-to-side drift, in logical pixels.
  final double sway;
  final double phase;
  final double spin;
  final Duration born;
}

class _FallingMantraState extends State<FallingMantra>
    with SingleTickerProviderStateMixin {
  final _random = math.Random();
  final _particles = <_Particle>[];
  // Made on the first bead, not up front: most screens never need one.
  Ticker? _ticker;
  Duration _now = Duration.zero;

  @override
  void didUpdateWidget(FallingMantra old) {
    super.didUpdateWidget(old);
    final sameMantra = old.mantra.id == widget.mantra.id;
    final added = widget.count - old.count;
    if (!sameMantra || added <= 0) return;
    for (var i = 0; i < math.min(added, FallingMantra.maxPerBurst); i++) {
      _spawn(delay: Duration(milliseconds: i * 90));
    }
    final ticker = _ticker ??= createTicker(_onTick);
    if (!ticker.isActive) ticker.start();
  }

  void _spawn({Duration delay = Duration.zero}) {
    if (_particles.length >= FallingMantra.maxParticles) {
      _particles.removeAt(0);
    }
    _particles.add(
      _Particle(
        x: 0.08 + _random.nextDouble() * 0.84,
        size: 18 + _random.nextDouble() * 12,
        duration: Duration(milliseconds: 3600 + _random.nextInt(1800)),
        sway: 10 + _random.nextDouble() * 22,
        phase: _random.nextDouble() * math.pi * 2,
        spin: (_random.nextDouble() - 0.5) * 0.5,
        born: _now + delay,
      ),
    );
  }

  void _onTick(Duration elapsed) {
    _now = elapsed;
    _particles.removeWhere((p) => elapsed - p.born > p.duration);
    if (_particles.isEmpty) {
      _ticker?.stop();
      // Restart from zero next time, so spawn times stay comparable.
      _now = Duration.zero;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) return const SizedBox.expand();
    final palette = context.palette;
    final text = widget.mantra.displayName(context).replaceAll('\n', ' ');
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _FallingPainter(
            particles: List.of(_particles),
            now: _now,
            text: text,
            devanagari: Mantra.isDevanagariText(text),
            color: palette.saffron,
          ),
        ),
      ),
    );
  }
}

class _FallingPainter extends CustomPainter {
  _FallingPainter({
    required this.particles,
    required this.now,
    required this.text,
    required this.devanagari,
    required this.color,
  });

  final List<_Particle> particles;
  final Duration now;
  final String text;
  final bool devanagari;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final age = now - p.born;
      if (age.isNegative) continue;
      final t = (age.inMicroseconds / p.duration.inMicroseconds).clamp(
        0.0,
        1.0,
      );
      // Fade in quickly, hold, then fade out before the bottom.
      final opacity = (t < 0.12 ? t / 0.12 : (t > 0.75 ? (1 - t) / 0.25 : 1.0))
          .clamp(0.0, 1.0);

      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style:
              (devanagari
                      ? AppTypography.mantra(
                          size: p.size,
                          weight: FontWeight.w600,
                        )
                      : TextStyle(
                          fontFamily: AppTypography.ui,
                          fontFamilyFallback: AppTypography.fallback,
                          fontSize: p.size,
                          fontWeight: FontWeight.w600,
                        ))
                  .copyWith(color: color.withValues(alpha: 0.55 * opacity)),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: size.width * 0.7);

      final eased = Curves.easeIn.transform(t) * 0.35 + t * 0.65;
      final y = -painter.height + eased * (size.height + painter.height * 2);
      final x =
          p.x * size.width +
          math.sin(p.phase + t * math.pi * 2) * p.sway -
          painter.width / 2;

      canvas
        ..save()
        ..translate(x + painter.width / 2, y + painter.height / 2)
        ..rotate(p.spin * math.sin(p.phase + t * math.pi))
        ..translate(-painter.width / 2, -painter.height / 2);
      painter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FallingPainter old) => true;
}
