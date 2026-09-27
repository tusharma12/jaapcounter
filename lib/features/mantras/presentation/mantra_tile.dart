import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/mantra_text.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/mantra.dart';

/// One mantra in the library: the mantra large, its description if it has
/// one, the mala size and whether it is the one being chanted.
class MantraTile extends StatelessWidget {
  const MantraTile({
    required this.mantra,
    required this.isActive,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Mantra mantra;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;

    return Semantics(
      selected: isActive,
      button: true,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(
          Insets.xl,
          Insets.lg,
          Insets.md,
          Insets.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MantraText(
                    mantra,
                    size: 22,
                    align: TextAlign.start,
                    maxLines: 2,
                    color: palette.primaryText,
                  ),
                  if (mantra.hasDescription) ...[
                    const SizedBox(height: Insets.xs),
                    Text(
                      mantra.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: Insets.md),
                  Row(
                    children: [
                      Text(
                        l10n.beads(mantra.malaSize),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: Insets.md),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: palette.saffron,
                        ),
                        const SizedBox(width: Insets.xs),
                        Text(
                          l10n.active,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<_MantraAction>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: palette.tertiaryText,
                ),
                position: PopupMenuPosition.under,
                onSelected: (action) => switch (action) {
                  _MantraAction.edit => onEdit?.call(),
                  _MantraAction.delete => onDelete?.call(),
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    PopupMenuItem(
                      value: _MantraAction.edit,
                      child: Text(l10n.edit),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: _MantraAction.delete,
                      child: Text(
                        l10n.delete,
                        style: TextStyle(color: palette.danger),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

enum _MantraAction { edit, delete }

/// Closes the mantra list, so a mantra that is not built in is never more
/// than a scroll away.
class AddOwnMantraTile extends StatelessWidget {
  const AddOwnMantraTile({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;

    return Semantics(
      button: true,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(Insets.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.softSaffron,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: palette.saffron),
            ),
            const SizedBox(width: Insets.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.addOwnMantra, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(l10n.addOwnMantraHint, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
