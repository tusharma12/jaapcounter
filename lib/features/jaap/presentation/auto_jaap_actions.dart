import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import 'auto_jaap_controller.dart';
import 'jaap_controller.dart';
import 'widgets/auto_jaap_sheet.dart';

/// What Auto Jaap's button does on any counting screen: stop it if it is
/// running, otherwise open its settings so it can be started.
void toggleAutoJaap(BuildContext context, WidgetRef ref) {
  if (ref.read(autoJaapProvider).running) {
    ref.read(autoJaapProvider.notifier).stop();
  } else {
    showAutoJaapSheet(context);
  }
}

/// What a tap, or a button press, does on a counting screen: while Auto Jaap
/// runs it stops it, otherwise it counts a bead. The same rule as the main
/// counter, so a tap in the dark never fights the automatic beads.
void countOrStopAuto(WidgetRef ref) {
  if (ref.read(autoJaapProvider).running) {
    ref.read(autoJaapProvider.notifier).stop();
    return;
  }
  ref.read(jaapControllerProvider.notifier).count();
}

/// Stopping Auto Jaap lets the screen sleep again, which a screen that is
/// keeping itself awake (meditation, blackout) must undo. Runs [reapply]
/// just after the stop, once Auto Jaap has finished releasing the wakelock.
void reapplyWakelockWhenAutoStops(
  WidgetRef ref, {
  required bool Function() mounted,
  required void Function() reapply,
}) {
  ref.listen(autoJaapProvider.select((s) => s.running), (was, now) {
    if (was == true && now == false) {
      Timer(const Duration(milliseconds: 250), () {
        if (mounted()) reapply();
      });
    }
  });
}

/// The daily goal was reached during Auto Jaap. Counting waits here, so the
/// user decides whether to carry on. Resolves with true to continue.
Future<bool> showGoalReachedDialog(BuildContext context) async {
  final l10n = AppL10n.of(context);
  final keepGoing = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.goalReached),
      content: Text(l10n.goalReachedAutoBody),
      actions: [
        TextButton(
          key: const ValueKey('goal-stop'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.autoJaapStopAction),
        ),
        FilledButton(
          key: const ValueKey('goal-continue'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.keepGoing),
        ),
      ],
    ),
  );
  return keepGoing ?? false;
}
