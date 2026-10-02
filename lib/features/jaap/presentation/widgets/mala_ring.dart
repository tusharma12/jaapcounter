import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../settings/domain/mala_style.dart';

/// The mala in progress, in the user's chosen [MalaStyle].
///
/// As beads: a string of beads around the count, with the Sumeru (guru
/// bead) and its tassel at the bottom, where a mala hangs.
///
/// Counting starts beside the Sumeru and runs clockwise, as the fingers
/// would. A mala of more than [maxVisibleBeads] is drawn with that many, each
/// standing for an equal share, and the bead in progress fills as it is
/// counted: at phone size, 108 true beads would be specks, not beads.
///
/// As a ring: one smooth arc, with a bead riding its leading edge.
class MalaRing extends StatefulWidget {
  const MalaRing({
    required this.beads,
    required this.malaSize,
    required this.diameter,
    this.style = MalaStyle.beads,
    this.child,
    super.key,
  });

  static const int maxVisibleBeads = 54;

  final int beads;
  final int malaSize;
  final double diameter;
  final MalaStyle style;
  final Widget? child;

  @override
  State<MalaRing> createState() => _MalaRingState();
}

class _MalaRingState extends State<MalaRing>
    with SingleTickerProviderStateMixin {
  // The bead just counted swells and settles, so each tap is felt on screen.
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: Motion.medium,
    value: 1,
  );

  @override
  void didUpdateWidget(MalaRing old) {
    super.didUpdateWidget(old);
    if (widget.beads > old.beads) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (widget.style == MalaStyle.ring) {
      return _ProgressRing(
        beads: widget.beads,
        malaSize: widget.malaSize,
        diameter: widget.diameter,
        child: widget.child,
      );
    }
    final size = widget.malaSize <= 0 ? 1 : widget.malaSize;
    final visible = math.min(size, MalaRing.maxVisibleBeads);
    // Beads counted, in drawn beads; the fraction is the one in progress.
    final progress = widget.beads.clamp(0, size) * visible / size;

    return SizedBox(
      width: widget.diameter,
      height: widget.diameter,
      child: AnimatedBuilder(
        animation: _pop,
        builder: (context, child) => CustomPaint(
          painter: _MalaPainter(
            visible: visible,
            progress: progress,
            pop: Curves.easeOutBack.transform(_pop.value),
            bead: palette.saffron,
            beadDeep: palette.saffronDeep,
            empty: Color.lerp(palette.track, palette.tertiaryText, 0.22)!,
            thread: palette.divider,
            highlight: palette.card,
          ),
          child: child,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

class _MalaPainter extends CustomPainter {
  _MalaPainter({
    required this.visible,
    required this.progress,
    required this.pop,
    required this.bead,
    required this.beadDeep,
    required this.empty,
    required this.thread,
    required this.highlight,
  });

  final int visible;
  final double progress;

  /// 0 → 1 as the latest bead settles; overshoots a little on the way.
  final double pop;
  final Color bead;
  final Color beadDeep;
  final Color empty;
  final Color thread;
  final Color highlight;

  static const double _bottom = math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Beads sit on a circle; the Sumeru takes one extra slot at the bottom.
    final slots = visible + 1;
    final step = 2 * math.pi / slots;
    final maxBead = (size.shortestSide / 2) * 0.065;
    final outer = size.shortestSide / 2;
    final beadRadius = math.min(
      maxBead,
      (2 * math.pi * (outer - maxBead) / slots) * 0.42,
    );
    final radius = outer - beadRadius * 1.6;

    Offset at(double angle) =>
        center + Offset(math.cos(angle), math.sin(angle)) * radius;

    // The thread the beads are strung on.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = thread
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, beadRadius * 0.28),
    );

    // The bead the fingers are on: the part-counted one, or the last full.
    final latest = progress <= 0 ? -1 : progress.ceil() - 1;
    for (var i = 0; i < visible; i++) {
      // Slot 0 is the Sumeru; bead 1 is the first clockwise from it.
      final angle = _bottom + step * (i + 1);
      final share = (progress - i).clamp(0.0, 1.0);
      final isLatest = i == latest;
      final r = isLatest ? beadRadius * (1 + 0.3 * pop) : beadRadius;
      final color = share >= 1
          ? bead
          : Color.lerp(empty, bead, 0.25 + 0.5 * share)!;
      _bead(canvas, at(angle), r, share > 0 ? color : empty, share > 0);
      if (isLatest) {
        canvas.drawCircle(
          at(angle),
          r * 1.9,
          Paint()
            ..color = bead.withValues(alpha: 0.22 * (1.2 - pop).clamp(0, 1))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r),
        );
      }
    }

    // The Sumeru: larger, never counted over, with a tassel beneath.
    final sumeru = at(_bottom);
    final sumeruRadius = math.min(beadRadius * 1.5, outer * 0.07);
    final tassel = Path()
      ..moveTo(sumeru.dx - sumeruRadius * 0.45, sumeru.dy + sumeruRadius * 0.6)
      ..lineTo(sumeru.dx + sumeruRadius * 0.45, sumeru.dy + sumeruRadius * 0.6)
      ..lineTo(sumeru.dx + sumeruRadius * 0.95, sumeru.dy + sumeruRadius * 3.1)
      ..lineTo(sumeru.dx - sumeruRadius * 0.95, sumeru.dy + sumeruRadius * 3.1)
      ..close();
    canvas.drawPath(tassel, Paint()..color = beadDeep);
    _bead(canvas, sumeru, sumeruRadius, beadDeep, true);
  }

  /// A bead with a little light on it, so it reads as round.
  void _bead(Canvas canvas, Offset c, double r, Color color, bool lit) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.95,
          colors: [
            Color.lerp(color, highlight, lit ? 0.35 : 0.2)!,
            color,
            Color.lerp(color, Colors.black, lit ? 0.18 : 0.06)!,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_MalaPainter old) =>
      old.visible != visible ||
      old.progress != progress ||
      old.pop != pop ||
      old.bead != bead ||
      old.empty != empty ||
      old.thread != thread;
}

/// The ring style: the arc is the beads counted so far, the moving bead is
/// where the fingers are, and the quarter marks give a sense of distance.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.beads,
    required this.malaSize,
    required this.diameter,
    this.child,
  });

  final int beads;
  final int malaSize;
  final double diameter;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fraction = malaSize <= 0
        ? 0.0
        : (beads / malaSize).clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: diameter,
      height: diameter,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: fraction, end: fraction),
        duration: Motion.fast,
        curve: Curves.easeOutCubic,
        builder: (context, animated, child) => CustomPaint(
          painter: _RingPainter(
            fraction: animated,
            track: palette.track,
            progress: palette.saffron,
            bead: palette.card,
            guide: palette.divider,
          ),
          child: child,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.progress,
    required this.bead,
    required this.guide,
  });

  final double fraction;
  final Color track;
  final Color progress;
  final Color bead;
  final Color guide;

  static const double _strokeWidth = 12;
  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - _strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );

    // Quarter marks: a quiet sense of how far around the mala one is.
    final guidePaint = Paint()..color = guide;
    for (var i = 0; i < 4; i++) {
      final angle = _start + i * math.pi / 2;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(point, _strokeWidth * 0.13, guidePaint);
    }

    if (fraction > 0) {
      canvas.drawArc(
        rect,
        _start,
        2 * math.pi * fraction,
        false,
        Paint()
          ..color = progress
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    final angle = _start + 2 * math.pi * fraction;
    final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    const beadRadius = _strokeWidth * 0.78;
    canvas.drawCircle(
      point,
      beadRadius + 2,
      Paint()
        ..color = progress.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(point, beadRadius, Paint()..color = progress);
    canvas.drawCircle(point, beadRadius * 0.42, Paint()..color = bead);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.progress != progress ||
      old.track != track;
}

/// The numbers inside the ring: beads counted over the mala size.
class MalaRingLabel extends StatelessWidget {
  const MalaRingLabel({
    required this.beads,
    required this.malaSize,
    this.compact = false,
    this.color,
    super.key,
  });

  final int beads;
  final int malaSize;
  final bool compact;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    // The ring is a fixed size; at large text sizes the numbers shrink to fit
    // inside it rather than spilling out over the beads.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$beads',
            style:
                (compact
                        ? theme.textTheme.displaySmall
                        : theme.textTheme.displayLarge)
                    ?.copyWith(
                      color: color ?? palette.primaryText,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
          ),
          const SizedBox(height: Insets.sm),
          Container(
            width: compact ? 28 : 36,
            height: 1.5,
            color: (color ?? palette.primaryText).withValues(alpha: 0.18),
          ),
          const SizedBox(height: Insets.sm),
          Text(
            '$malaSize',
            style: theme.textTheme.titleMedium?.copyWith(
              color: (color ?? palette.secondaryText).withValues(alpha: 0.75),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
