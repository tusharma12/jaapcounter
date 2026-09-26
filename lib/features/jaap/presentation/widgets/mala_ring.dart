import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';

/// The mala, drawn as a ring.
///
/// The arc is the beads counted so far, the moving bead is where the fingers
/// are, and the quarter marks give a sense of distance at a glance without
/// putting 108 dots on the screen.
class MalaRing extends StatelessWidget {
  const MalaRing({
    required this.beads,
    required this.malaSize,
    required this.diameter,
    this.child,
    this.strokeWidth = 12,
    this.showBead = true,
    this.trackColor,
    this.progressColor,
    super.key,
  });

  final int beads;
  final int malaSize;
  final double diameter;
  final Widget? child;
  final double strokeWidth;
  final bool showBead;
  final Color? trackColor;
  final Color? progressColor;

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
        builder: (context, animated, _) {
          return CustomPaint(
            painter: _MalaRingPainter(
              fraction: animated,
              strokeWidth: strokeWidth,
              track: trackColor ?? palette.track,
              progress: progressColor ?? palette.saffron,
              bead: palette.card,
              guide: palette.divider,
              showBead: showBead,
            ),
            child: Center(child: child),
          );
        },
      ),
    );
  }
}

class _MalaRingPainter extends CustomPainter {
  _MalaRingPainter({
    required this.fraction,
    required this.strokeWidth,
    required this.track,
    required this.progress,
    required this.bead,
    required this.guide,
    required this.showBead,
  });

  final double fraction;
  final double strokeWidth;
  final Color track;
  final Color progress;
  final Color bead;
  final Color guide;
  final bool showBead;

  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Quarter marks: a quiet sense of how far around the mala one is.
    final guidePaint = Paint()..color = guide;
    for (var i = 0; i < 4; i++) {
      final angle = _start + i * math.pi / 2;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(point, strokeWidth * 0.13, guidePaint);
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
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    if (showBead) {
      final angle = _start + 2 * math.pi * fraction;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final beadRadius = strokeWidth * 0.78;
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
  }

  @override
  bool shouldRepaint(_MalaRingPainter old) =>
      old.fraction != fraction ||
      old.progress != progress ||
      old.track != track ||
      old.showBead != showBead ||
      old.strokeWidth != strokeWidth;
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

    return Column(
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
    );
  }
}
