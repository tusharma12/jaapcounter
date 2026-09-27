import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_dimens.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../auto_jaap_controller.dart';
import '../jaap_controller.dart';

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
              const SizedBox(height: Insets.xl),
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
