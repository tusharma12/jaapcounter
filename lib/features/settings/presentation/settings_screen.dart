import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/utils/day_key.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../../backup/presentation/backup_controllers.dart';
import '../../diagnostics/presentation/diagnostics_sheet.dart';
import '../../jaap/presentation/counter_prefs.dart';
import '../../jaap/presentation/jaap_controller.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../reminders/domain/reminder.dart';
import '../../reminders/presentation/reminder_controllers.dart';
import '../../reminders/presentation/reminders_screen.dart';
import '../../sadhana/presentation/sadhana_controllers.dart';
import '../../jaap/presentation/widgets/hardware_count_keys.dart';
import '../domain/app_settings.dart';
import '../domain/mala_style.dart';
import 'appearance_sheets.dart';
import 'settings_controller.dart';
import '../../../core/constants/app_languages.dart';

/// The groups Settings is divided into. The main page lists them; each
/// opens its own short page, so a person is never faced with every switch
/// at once.
enum SettingsSection {
  jaap,
  reminders,
  counter,
  appearance,
  support,
  about;

  static SettingsSection? fromName(String? name) {
    for (final section in values) {
      if (section.name == name) return section;
    }
    return null;
  }

  String title(AppL10n l10n) {
    // The strings are written for headers, in capitals.
    final raw = switch (this) {
      jaap => l10n.sectionJaap,
      reminders => l10n.sectionReminders,
      counter => l10n.sectionCounter,
      appearance => l10n.sectionAppearance,
      support => l10n.sectionSupport,
      about => l10n.sectionAbout,
    };
    return raw.isEmpty ? raw : raw[0] + raw.substring(1).toLowerCase();
  }

  /// The section title as a header, in capitals.
  String header(AppL10n l10n) => title(l10n).toUpperCase();

  IconData get icon => switch (this) {
    jaap => Icons.self_improvement_rounded,
    reminders => Icons.notifications_none_rounded,
    counter => Icons.touch_app_outlined,
    appearance => Icons.palette_outlined,
    support => Icons.favorite_border_rounded,
    about => Icons.info_outline_rounded,
  };
}

/// Settings. With no [section] it is a short menu; with one, that group.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.section});

  final SettingsSection? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final version = ref.watch(appVersionProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(section?.title(l10n) ?? l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          Insets.md,
          Insets.page,
          Insets.xxxl,
        ),
        children: [
          if (section == null || section == SettingsSection.jaap) ...[
            if (section == null)
              _SectionHeader(SettingsSection.jaap.header(l10n)),
            AppCardGroup(
              children: [
                _NavRow(
                  label: l10n.sadhanaGoals,
                  icon: Icons.auto_awesome_outlined,
                  onTap: () => context.push('/sadhana'),
                ),
                _NavRow(
                  label: l10n.myMantras,
                  icon: Icons.format_list_bulleted_rounded,
                  onTap: () => context.push('/mantras'),
                ),
                _SwitchRow(
                  label: l10n.graceDays,
                  subtitle: l10n.graceDaysHint,
                  icon: Icons.healing_outlined,
                  value: settings.graceDaysEnabled,
                  onChanged: controller.setGraceDays,
                ),
                _NavRow(
                  label: l10n.resetCounts,
                  icon: Icons.restart_alt_rounded,
                  onTap: () => _showResetOptions(context, ref),
                ),
              ],
            ),
            const SizedBox(height: Insets.lg),
          ],
          if (section == null || section == SettingsSection.reminders) ...[
            if (section == null)
              _SectionHeader(SettingsSection.reminders.header(l10n)),
            AppCardGroup(
              children: [
                _NavRow(
                  label: l10n.jaapReminders,
                  icon: Icons.notifications_none_rounded,
                  onTap: () => context.push('/reminders'),
                ),
                _SingletonReminderRow(
                  kind: ReminderKind.streak,
                  label: l10n.streakReminder,
                  defaultMinutes: 20 * 60,
                ),
                _SingletonReminderRow(
                  kind: ReminderKind.goal,
                  label: l10n.goalReminder,
                  defaultMinutes: 19 * 60,
                ),
                _SwitchRow(
                  label: l10n.festivalReminders,
                  subtitle: l10n.festivalRemindersHint,
                  icon: Icons.nightlight_outlined,
                  value: settings.festivalReminders,
                  onChanged: (on) async {
                    final reminders = ref.read(remindersProvider.notifier);
                    if (on) await reminders.requestPermission();
                    await controller.setFestivalReminders(on);
                    if (context.mounted) {
                      await reminders.reschedule(
                        RemindersScreen.copyFrom(AppL10n.of(context)),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: Insets.lg),
          ],
          if (section == null || section == SettingsSection.counter) ...[
            if (section == null)
              _SectionHeader(SettingsSection.counter.header(l10n)),
            AppCardGroup(
              children: [
                _SwitchRow(
                  label: l10n.showMantraOnCounter,
                  icon: Icons.text_fields_rounded,
                  value: !ref.watch(hideMantraProvider),
                  onChanged: (show) =>
                      ref.read(hideMantraProvider.notifier).set(!show),
                ),
                _NavRow(
                  label: l10n.counterBackground,
                  icon: Icons.wallpaper_rounded,
                  value: backgroundName(l10n, settings.background),
                  onTap: () => showBackgroundPicker(context),
                ),
                _NavRow(
                  label: l10n.malaStyle,
                  icon: Icons.blur_circular_rounded,
                  value: switch (settings.malaStyle) {
                    MalaStyle.beads => l10n.malaStyleBeads,
                    MalaStyle.ring => l10n.malaStyleRing,
                  },
                  onTap: () => _pickMalaStyle(context, ref),
                ),
                _SwitchRow(
                  label: l10n.countWithButtons,
                  subtitle: HardwareCountKeys.volumeButtonsSupported
                      ? l10n.countWithButtonsHintAndroid
                      : l10n.countWithButtonsHintIOS,
                  icon: Icons.touch_app_outlined,
                  value: settings.hardwareKeyCounting,
                  onChanged: controller.setHardwareKeyCounting,
                ),
                if (ref.watch(lockScreenSupportedProvider).value ?? false)
                  _SwitchRow(
                    label: l10n.lockScreenCounter,
                    subtitle: l10n.lockScreenCounterHint,
                    icon: Icons.lock_clock_outlined,
                    value: settings.lockScreenCounter,
                    onChanged: controller.setLockScreenCounter,
                  ),
                _NavRow(
                  label: l10n.markerBead,
                  icon: Icons.adjust_rounded,
                  value: settings.beadMarkerInterval == 0
                      ? l10n.markerBeadOff
                      : l10n.markerBeadEvery(settings.beadMarkerInterval),
                  onTap: () => _pickMarkerBead(context, ref),
                ),
                _SwitchRow(
                  label: l10n.fallingMantra,
                  icon: Icons.auto_awesome_motion_outlined,
                  value: settings.fallingMantra,
                  onChanged: controller.setFallingMantra,
                ),
                _NavRow(
                  label: l10n.blackoutMode,
                  icon: Icons.dark_mode_outlined,
                  onTap: () => context.push('/blackout'),
                ),
                _NavRow(
                  label: l10n.homeScreenWidget,
                  icon: Icons.widgets_outlined,
                  onTap: () => _showWidgetInfo(context, ref),
                ),
              ],
            ),
            const SizedBox(height: Insets.lg),
          ],
          if (section == null || section == SettingsSection.appearance) ...[
            if (section == null)
              _SectionHeader(SettingsSection.appearance.header(l10n)),
            AppCardGroup(
              children: [
                _NavRow(
                  label: l10n.theme,
                  icon: Icons.contrast_rounded,
                  value: themeName(l10n, settings.themeId),
                  onTap: () => showThemePicker(context),
                ),
                _SwitchRow(
                  label: l10n.haptics,
                  icon: Icons.vibration_rounded,
                  value: settings.hapticsEnabled,
                  onChanged: controller.setHaptics,
                ),
                _SwitchRow(
                  label: l10n.sound,
                  icon: Icons.volume_up_outlined,
                  value: settings.soundEnabled,
                  onChanged: controller.setSound,
                ),
                _NavRow(
                  label: l10n.language,
                  icon: Icons.translate_rounded,
                  value:
                      AppLanguages.names[settings.localeCode] ??
                      l10n.languageSystem,
                  onTap: () => _pickLanguage(context, ref),
                ),
              ],
            ),
            const SizedBox(height: Insets.lg),
          ],
          if (section == null || section == SettingsSection.support) ...[
            if (section == null)
              _SectionHeader(SettingsSection.support.header(l10n)),
            AppCardGroup(
              children: [
                _NavRow(
                  label: l10n.feedback,
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => _open(
                    'mailto:${AppConstants.supportEmail}'
                    '?subject=${Uri.encodeComponent(l10n.feedbackEmailSubject)}',
                  ),
                ),
                _NavRow(
                  label: l10n.backupRestore,
                  icon: Icons.cloud_download_outlined,
                  onTap: () => context.push('/backup'),
                ),
                _NavRow(
                  label: l10n.rateApp,
                  icon: Icons.star_border_rounded,
                  onTap: () => _open(
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? AppConstants.iosReviewUrl
                        : AppConstants.androidStoreUrl,
                  ),
                ),
                _NavRow(
                  label: l10n.shareApp,
                  icon: Icons.ios_share_rounded,
                  onTap: () => SharePlus.instance.share(
                    ShareParams(
                      text:
                          '${l10n.appName} - ${l10n.tagline}\n'
                          '${Theme.of(context).platform == TargetPlatform.iOS ? AppConstants.iosStoreUrl : AppConstants.androidStoreUrl}',
                    ),
                  ),
                ),
                _NavRow(
                  label: l10n.sendDiagnostics,
                  icon: Icons.bug_report_outlined,
                  onTap: () => showDiagnosticsSheet(context),
                ),
              ],
            ),
            const SizedBox(height: Insets.lg),
          ],
          if (section == null || section == SettingsSection.about) ...[
            if (section == null)
              _SectionHeader(SettingsSection.about.header(l10n)),
            AppCardGroup(
              children: [
                _NavRow(
                  label: l10n.privacyPolicy,
                  icon: Icons.lock_outline_rounded,
                  onTap: () => _open(AppConstants.privacyPolicyUrl),
                ),
                _NavRow(
                  label: l10n.terms,
                  icon: Icons.description_outlined,
                  onTap: () => _open(AppConstants.termsUrl),
                ),
                _NavRow(
                  label: l10n.aboutApp,
                  icon: Icons.info_outline_rounded,
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
            const SizedBox(height: Insets.lg),
          ],
          if (section == null) ...[
            const SizedBox(height: Insets.xl),
            Center(
              child: Text(
                version == null ? '' : l10n.version(version),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } on Object catch (error, stack) {
      AppLogger.e('Could not open $url', error, stack);
    }
  }

  Future<void> _pickMalaStyle(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final current = ref.read(settingsProvider).malaStyle;
    await showAppSheet<void>(
      context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in {
              MalaStyle.beads: (
                l10n.malaStyleBeads,
                Icons.blur_circular_rounded,
              ),
              MalaStyle.ring: (l10n.malaStyleRing, Icons.donut_large_rounded),
            }.entries)
              ListTile(
                leading: Icon(entry.value.$2),
                title: Text(entry.value.$1),
                trailing: entry.key == current
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setMalaStyle(entry.key);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: Insets.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMarkerBead(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final current = ref.read(settingsProvider).beadMarkerInterval;
    await showAppSheet<void>(
      context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                0,
                Insets.page,
                Insets.md,
              ),
              child: Text(
                l10n.markerBeadHint,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: sheetContext.palette.secondaryText,
                ),
              ),
            ),
            for (final interval in AppSettings.beadMarkerIntervals)
              ListTile(
                title: Text(
                  interval == 0
                      ? l10n.markerBeadOff
                      : l10n.markerBeadEvery(interval),
                ),
                trailing: interval == current
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setBeadMarkerInterval(interval);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: Insets.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final current = ref.read(settingsProvider).localeCode;
    await showAppSheet<void>(
      context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in <String?, String>{
              null: l10n.languageSystem,
              ...AppLanguages.names,
            }.entries)
              ListTile(
                title: Text(entry.value),
                trailing: entry.key == current
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(settingsProvider.notifier)
                      .setLocale(entry.key);
                  // Notification copy is baked in at schedule time, so a new
                  // language means rewriting what is already scheduled.
                  if (context.mounted) {
                    await ref
                        .read(remindersProvider.notifier)
                        .reschedule(
                          RemindersScreen.copyFrom(AppL10n.of(context)),
                        );
                  }
                },
              ),
            const SizedBox(height: Insets.lg),
          ],
        ),
      ),
    );
  }

  /// Explains the home screen widget and, where the launcher supports it,
  /// offers to place it directly. iOS has no such API: a phone there is
  /// always shown the manual steps instead.
  Future<void> _showWidgetInfo(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final canPin = await ref.read(widgetServiceProvider).canRequestPin();
    if (!context.mounted) return;

    await showAppSheet<void>(
      context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            0,
            Insets.page,
            Insets.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.homeScreenWidget,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Insets.md),
              Text(
                l10n.homeScreenWidgetBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.palette.secondaryText,
                ),
              ),
              // Only Android can be asked to place it directly; everywhere
              // else, including an unsupported launcher, gets the steps.
              if (!canPin) ...[
                const SizedBox(height: Insets.xl),
                Text(
                  Platform.isIOS
                      ? l10n.homeScreenWidgetStepsIOS
                      : l10n.homeScreenWidgetStepsAndroid,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (canPin)
                FilledButton(
                  onPressed: () {
                    ref.read(widgetServiceProvider).requestPin();
                    Navigator.of(sheetContext).pop();
                  },
                  child: Text(l10n.addToHomeScreen),
                )
              else
                OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.close),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showResetOptions(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    await showAppSheet<void>(
      context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.resetToday),
              leading: const Icon(Icons.today_rounded),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _resetToday(context, ref);
              },
            ),
            ListTile(
              title: Text(
                l10n.resetEverything,
                style: TextStyle(color: context.palette.danger),
              ),
              leading: Icon(
                Icons.delete_outline_rounded,
                color: context.palette.danger,
              ),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _resetEverything(context, ref);
              },
            ),
            const SizedBox(height: Insets.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _resetToday(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final confirmed = await confirm(
      context,
      title: l10n.resetTodayTitle,
      message: l10n.resetTodayBody,
      confirmLabel: l10n.resetToday,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed) return;

    final today = DayKeys.of(ref.read(clockProvider)());
    await ref.read(jaapRepositoryProvider).deleteDay(today);
    _refresh(ref);
    if (context.mounted) showAppSnack(context, l10n.resetDone);
  }

  Future<void> _resetEverything(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final confirmed = await confirm(
      context,
      title: l10n.resetAllTitle,
      message: l10n.resetAllBody,
      confirmLabel: l10n.resetEverything,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed) return;

    await ref.read(jaapRepositoryProvider).deleteAllEntries();
    await ref.read(sadhanaRepositoryProvider).deleteAll();
    _refresh(ref);
    if (context.mounted) showAppSnack(context, l10n.resetDone);
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(mantraListProvider);
    ref.invalidate(jaapControllerProvider);
    ref.invalidate(activeSadhanaProvider);
    ref.read(ledgerRevisionProvider.notifier).bump();
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.icon,
    required this.onTap,
    this.value,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.secondaryText,
              ),
            ),
          const SizedBox(width: Insets.xs),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: palette.tertiaryText,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    // One node for the row and its switch, so a screen reader announces the
    // label with the toggle instead of a bare, unnamed switch.
    return MergeSemantics(
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(label),
        subtitle: subtitle == null ? null : Text(subtitle!),
        onTap: () => onChanged(!value),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

/// The streak and goal reminders: one switch and one time each.
class _SingletonReminderRow extends ConsumerWidget {
  const _SingletonReminderRow({
    required this.kind,
    required this.label,
    required this.defaultMinutes,
  });

  final ReminderKind kind;
  final String label;
  final int defaultMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final reminders = ref.watch(remindersProvider).value ?? const <Reminder>[];
    final existing = reminders.where((r) => r.kind == kind).firstOrNull;
    final enabled = existing?.enabled ?? false;
    final minutes = existing?.minutes ?? defaultMinutes;
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final controller = ref.read(remindersProvider.notifier);

    Future<void> apply({required bool on, int? newMinutes}) async {
      if (on) await controller.requestPermission();
      await controller.setSingleton(
        kind: kind,
        minutes: newMinutes ?? minutes,
        enabled: on,
      );
      await controller.reschedule(RemindersScreen.copyFrom(l10n));
    }

    return MergeSemantics(
      child: ListTile(
        leading: Icon(
          kind == ReminderKind.streak
              ? Icons.local_fire_department_outlined
              : Icons.flag_outlined,
          size: 20,
        ),
        title: Text(label),
        subtitle: enabled ? Text(time.format(context)) : null,
        onTap: !enabled
            ? null
            : () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                  helpText: l10n.reminderTime,
                );
                if (picked == null) return;
                await apply(
                  on: true,
                  newMinutes: picked.hour * 60 + picked.minute,
                );
              },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: enabled,
              onChanged: (on) => apply(on: on),
            ),
            if (enabled)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: palette.tertiaryText,
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.md, Insets.sm, 0, Insets.sm),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: context.palette.secondaryText,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
