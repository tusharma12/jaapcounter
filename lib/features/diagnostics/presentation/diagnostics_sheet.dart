import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../backup/presentation/backup_controllers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../data/diagnostics_report.dart';

final diagnosticsReportProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  return DiagnosticsReport(
    database: ref.watch(databaseProvider),
    settings: ref.watch(settingsProvider),
    appVersion: await ref.watch(appVersionProvider.future),
    buildNumber: await ref.watch(appBuildNumberProvider.future),
    clock: ref.watch(clockProvider),
  ).build();
});

/// Shows the report in full, then lets the user email it or share it as a
/// file. Nothing is sent from here: the user's own mail or share sheet does
/// that, after they have seen exactly what is in it.
Future<void> showDiagnosticsSheet(BuildContext context) => showAppSheet<void>(
  context,
  expand: true,
  builder: (_) => const _DiagnosticsSheet(),
);

class _DiagnosticsSheet extends ConsumerWidget {
  const _DiagnosticsSheet();

  /// Mail apps cope with long bodies unevenly; the newest part of the log is
  /// the part that matters, so an email keeps the head and the tail.
  static const int maxEmailChars = 6000;

  static String forEmail(String report) {
    if (report.length <= maxEmailChars) return report;
    const head = 1200;
    return '${report.substring(0, head)}\n…\n'
        '${report.substring(report.length - (maxEmailChars - head))}';
  }

  Future<void> _email(BuildContext context, String report) async {
    final l10n = AppL10n.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      query:
          'subject=${Uri.encodeComponent(l10n.diagnosticsEmailSubject)}'
          '&body=${Uri.encodeComponent(forEmail(report))}',
    );
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        showAppSnack(context, l10n.diagnosticsNoMail);
      }
    } on Object catch (error, stack) {
      AppLogger.e('Could not open a mail app', error, stack);
      if (context.mounted) showAppSnack(context, l10n.diagnosticsNoMail);
    }
  }

  Future<void> _share(BuildContext context, String report) async {
    final l10n = AppL10n.of(context);
    final box = context.findRenderObject() as RenderBox?;
    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'smaran-diagnostics.txt'));
      await file.writeAsString(report, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/plain')],
          subject: l10n.diagnosticsEmailSubject,
          text: AppConstants.supportEmail,
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } on Object catch (error, stack) {
      AppLogger.e('Could not share diagnostics', error, stack);
      if (context.mounted) showAppSnack(context, l10n.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final report = ref.watch(diagnosticsReportProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.sendDiagnostics, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Insets.sm),
            Text(
              l10n.diagnosticsExplain,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.secondaryText,
              ),
            ),
            const SizedBox(height: Insets.lg),
            Expanded(
              child: AsyncView<String>(
                value: report,
                onRetry: () => ref.invalidate(diagnosticsReportProvider),
                builder: (context, text) => Container(
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: palette.divider),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Insets.md),
                    child: SelectableText(
                      text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontFamilyFallback: const ['Menlo', 'Courier'],
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Insets.lg),
            FilledButton.icon(
              onPressed: report.value == null
                  ? null
                  : () => _email(context, report.value!),
              icon: const Icon(Icons.mail_outline_rounded),
              label: Text(l10n.diagnosticsEmail),
            ),
            const SizedBox(height: Insets.sm),
            OutlinedButton.icon(
              onPressed: report.value == null
                  ? null
                  : () => _share(context, report.value!),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(l10n.diagnosticsShare),
            ),
          ],
        ),
      ),
    );
  }
}
