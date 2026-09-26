import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';

/// Live session time. Owns its own ticker so the rest of the counter does not
/// rebuild once a second.
class SessionPill extends StatefulWidget {
  const SessionPill({
    required this.startedAt,
    required this.count,
    required this.onEnd,
    super.key,
  });

  final DateTime startedAt;
  final int count;
  final VoidCallback onEnd;

  @override
  State<SessionPill> createState() => _SessionPillState();
}

class _SessionPillState extends State<SessionPill> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final elapsed = DateTime.now().difference(widget.startedAt);

    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(Radii.pill),
      child: InkWell(
        onTap: widget.onEnd,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: palette.saffron,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Insets.sm),
              Text(
                Fmt.stopwatch(elapsed),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: Insets.sm),
              Text('· ${widget.count}', style: theme.textTheme.bodySmall),
              const SizedBox(width: Insets.sm),
              Icon(Icons.stop_rounded, size: 16, color: palette.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
