import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../backup/presentation/backup_controllers.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final version = ref.watch(appVersionProvider).value;
    final build = ref.watch(appBuildNumberProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
      body: Padding(
        padding: const EdgeInsets.all(Insets.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ॐ',
              style: AppTypography.mantra(size: 44, color: palette.saffron),
            ),
            const SizedBox(height: Insets.lg),
            Text(l10n.appName, style: theme.textTheme.headlineMedium),
            const SizedBox(height: Insets.sm),
            Text(l10n.tagline, style: theme.textTheme.bodyLarge),
            const SizedBox(height: Insets.xxl),
            Text(l10n.aboutBody, style: theme.textTheme.bodyMedium),
            const Spacer(),
            if (version != null)
              Text(
                build == null
                    ? l10n.version(version)
                    : '${l10n.version(version)} · $build',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: Insets.xs),
            Text(l10n.madeWith, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
