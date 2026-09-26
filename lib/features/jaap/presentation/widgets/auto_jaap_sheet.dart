import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../auto_jaap_controller.dart';
import '../jaap_controller.dart';
import 'voice_picker_sheet.dart';

/// Opens the Auto Jaap settings. Starting from the sheet closes it, so the
/// counter is in view while the beads move.
Future<void> showAutoJaapSheet(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _AutoJaapSheet());
}

class _AutoJaapSheet extends ConsumerWidget {
  const _AutoJaapSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final config = ref.watch(autoJaapProvider).config;
    final controller = ref.read(autoJaapProvider.notifier);
    final jaap = ref.watch(jaapControllerProvider).value;
    final hasGoal = jaap != null && jaap.dailyGoal > 0 && !jaap.goalReached;

    void update(AutoJaapConfig next) => controller.updateConfig(next);

    // A goal that is already met (or absent) cannot be what stops the run.
    final stopAfter = !hasGoal && config.stopAfter == AutoJaapStop.goal
        ? AutoJaapStop.mala
        : config.stopAfter;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            Insets.lg,
            Insets.page,
            Insets.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.autoJaap, style: theme.textTheme.titleLarge),
              const SizedBox(height: Insets.xs),
              Text(l10n.autoJaapBody, style: theme.textTheme.bodyMedium),
              const SizedBox(height: Insets.xl),
              Text(l10n.autoJaapPace, style: theme.textTheme.titleSmall),
              const SizedBox(height: Insets.sm),
              Wrap(
                spacing: Insets.sm,
                runSpacing: Insets.sm,
                children: [
                  for (final seconds in AutoJaapConfig.paces)
                    ChoiceChip(
                      label: Text(l10n.autoJaapSeconds(seconds)),
                      selected: config.interval.inSeconds == seconds,
                      onSelected: (_) => update(
                        config.copyWith(interval: Duration(seconds: seconds)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Insets.md),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.autoJaapSpeak),
                subtitle: Text(l10n.autoJaapSpeakHint),
                value: config.speakAloud,
                onChanged: (value) =>
                    update(config.copyWith(speakAloud: value)),
              ),
              if (config.speakAloud) _VoiceSettings(config: config),
              const SizedBox(height: Insets.md),
              Text(l10n.autoJaapStopAfter, style: theme.textTheme.titleSmall),
              const SizedBox(height: Insets.sm),
              SegmentedButton<AutoJaapStop>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: AutoJaapStop.mala,
                    label: Text(l10n.autoJaapStopMala),
                  ),
                  ButtonSegment(
                    value: AutoJaapStop.goal,
                    label: Text(l10n.autoJaapStopGoal),
                    enabled: hasGoal,
                  ),
                  ButtonSegment(
                    value: AutoJaapStop.never,
                    label: Text(l10n.autoJaapStopNever),
                  ),
                ],
                selected: {stopAfter},
                onSelectionChanged: (selection) =>
                    update(config.copyWith(stopAfter: selection.first)),
              ),
              const SizedBox(height: Insets.xl),
              FilledButton.icon(
                onPressed: () {
                  if (stopAfter != config.stopAfter) {
                    update(config.copyWith(stopAfter: stopAfter));
                  }
                  Navigator.of(context).pop();
                  controller.start();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.autoJaapStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Voice, speed and pitch, with a preview so each change can be heard.
class _VoiceSettings extends ConsumerWidget {
  const _VoiceSettings({required this.config});

  final AutoJaapConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final controller = ref.read(autoJaapProvider.notifier);
    final mantra = ref.watch(jaapControllerProvider).value?.mantra;
    final isDefault =
        config.voice == null &&
        config.rate == AutoJaapConfig.defaultRate &&
        config.pitch == AutoJaapConfig.defaultPitch;

    Widget slider({
      required String label,
      required String low,
      required String high,
      required double value,
      required double min,
      required double max,
      required ValueChanged<double> onChanged,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          Slider.adaptive(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(low, style: theme.textTheme.bodySmall),
              Text(high, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: Insets.sm),
      padding: const EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        color: palette.saffron.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.record_voice_over_outlined),
            title: Text(l10n.autoJaapVoice),
            subtitle: Text(config.voice?.name ?? l10n.autoJaapVoiceDefault),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showVoicePicker(context),
          ),
          const SizedBox(height: Insets.sm),
          slider(
            label: l10n.autoJaapSpeed,
            low: l10n.autoJaapSlow,
            high: l10n.autoJaapFast,
            value: config.rate,
            min: AutoJaapConfig.minRate,
            max: AutoJaapConfig.maxRate,
            onChanged: (v) => controller.updateConfig(config.copyWith(rate: v)),
          ),
          const SizedBox(height: Insets.md),
          slider(
            label: l10n.autoJaapPitch,
            low: l10n.autoJaapDeep,
            high: l10n.autoJaapHigh,
            value: config.pitch,
            min: AutoJaapConfig.minPitch,
            max: AutoJaapConfig.maxPitch,
            onChanged: (v) =>
                controller.updateConfig(config.copyWith(pitch: v)),
          ),
          const SizedBox(height: Insets.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: mantra == null
                      ? null
                      : () => controller.chant(mantra, config),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.autoJaapPreview),
                ),
              ),
              if (!isDefault) ...[
                const SizedBox(width: Insets.sm),
                IconButton(
                  tooltip: l10n.autoJaapResetVoice,
                  onPressed: () => controller.updateConfig(
                    config.copyWith(
                      voice: null,
                      rate: AutoJaapConfig.defaultRate,
                      pitch: AutoJaapConfig.defaultPitch,
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
