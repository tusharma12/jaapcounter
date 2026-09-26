import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../../jaap/presentation/jaap_controller.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../reminders/presentation/reminder_controllers.dart';
import '../../sadhana/presentation/sadhana_controllers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../stories/presentation/story_controllers.dart';
import '../data/backup_service.dart';
import 'backup_controllers.dart';

/// Export and restore. Restoring replaces everything, so it asks first and
/// says so plainly.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  Future<void> _export() async {
    final l10n = AppL10n.of(context);
    setState(() => _busy = true);
    try {
      final service = await ref.read(backupServiceProvider.future);
      final file = await service.writeBackupFile();
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          text: l10n.exportShareText,
        ),
      );
      if (mounted) showAppSnack(context, l10n.backupCreated);
    } on Object catch (error, stack) {
      AppLogger.e('Export failed', error, stack);
      if (mounted) showAppSnack(context, l10n.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l10n = AppL10n.of(context);
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null || !mounted) return;

    final confirmed = await confirm(
      context,
      title: l10n.restoreWarningTitle,
      message: l10n.restoreWarningBody,
      confirmLabel: l10n.restore,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      final raw = utf8.decode(await file.readAsBytes());
      final service = await ref.read(backupServiceProvider.future);
      final result = await service.restore(raw);
      _refreshEverything();
      if (mounted) {
        showAppSnack(context, l10n.restoreSuccess(result.entries));
      }
    } on InvalidBackupException catch (error) {
      AppLogger.w('Rejected backup file: $error');
      if (mounted) showAppSnack(context, l10n.importInvalid);
    } on Object catch (error, stack) {
      AppLogger.e('Restore failed', error, stack);
      if (mounted) showAppSnack(context, l10n.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// A restore changes everything at once, so every derived provider is
  /// rebuilt rather than patched.
  void _refreshEverything() {
    ref.invalidate(settingsProvider);
    ref.invalidate(mantraListProvider);
    ref.invalidate(activeSadhanaProvider);
    ref.invalidate(remindersProvider);
    ref.invalidate(favouriteStoriesProvider);
    ref.invalidate(jaapControllerProvider);
    ref.read(ledgerRevisionProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupRestore)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          Insets.sm,
          Insets.page,
          Insets.xxxl,
        ),
        children: [
          _ActionCard(
            icon: Icons.ios_share_rounded,
            title: l10n.createBackup,
            body: l10n.createBackupBody,
            actionLabel: l10n.exportMyData,
            onPressed: _busy ? null : _export,
          ),
          const SizedBox(height: Insets.md),
          _ActionCard(
            icon: Icons.restore_rounded,
            title: l10n.restoreBackup,
            body: l10n.restoreBackupBody,
            actionLabel: l10n.restore,
            onPressed: _busy ? null : _restore,
          ),
          const SizedBox(height: Insets.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.xs),
            child: Text(l10n.aboutBody, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: palette.secondaryText),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Text(title, style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: Insets.xl),
          OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
