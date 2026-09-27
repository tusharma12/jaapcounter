import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';

/// Empty states carry their weight here: a screen with nothing in it should
/// still feel considered, and should say what to do next.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.body,
    this.glyph = '🪷',
    this.action,
    super.key,
  });

  final String title;
  final String? body;
  final String glyph;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.xxl,
          vertical: Insets.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.softSaffron,
                shape: BoxShape.circle,
              ),
              child: Text(glyph, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(height: Insets.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (body != null) ...[
              const SizedBox(height: Insets.sm),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (action != null) ...[const SizedBox(height: Insets.xl), action!],
          ],
        ),
      ),
    );
  }
}
