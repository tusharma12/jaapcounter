import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';

/// The one card in the app: a soft rounded surface with generous padding and
/// no border unless it is carrying an accent.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(Insets.xl),
    this.onTap,
    this.accented = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Draws the card in soft saffron - used for the one thing on a screen that
  /// deserves the accent.
  final bool accented;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final background = accented ? palette.softSaffron : palette.card;
    final radius = BorderRadius.circular(Radii.lg);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        boxShadow: [
          if (!accented)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A grouped list of rows, as used throughout Settings.
class AppCardGroup extends StatelessWidget {
  const AppCardGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: Insets.xl),
                child: Divider(height: 1, color: palette.divider),
              ),
          ],
        ],
      ),
    );
  }
}
