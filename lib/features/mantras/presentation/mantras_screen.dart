import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/mantra.dart';
import 'mantra_controllers.dart';
import 'mantra_editor_sheet.dart';
import 'mantra_tile.dart';

/// The mantra library: choose what to chant, and how large its mala is.
class MantrasScreen extends ConsumerWidget {
  const MantrasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final mantras = ref.watch(mantraListProvider);
    final active = ref.watch(activeMantraProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myMantras)),
      body: AsyncView<List<Mantra>>(
        value: mantras,
        onRetry: () => ref.invalidate(mantraListProvider),
        builder: (context, list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            Insets.sm,
            Insets.page,
            Insets.xxxl * 2,
          ),
          itemCount: list.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
          itemBuilder: (context, index) {
            if (index == list.length) {
              return AddOwnMantraTile(onTap: () => _addOwn(context, ref));
            }
            final mantra = list[index];
            return MantraTile(
              mantra: mantra,
              isActive: mantra.id == active?.id,
              onTap: () =>
                  ref.read(mantraListProvider.notifier).setActive(mantra.id),
              onEdit: () => showMantraEditor(context, existing: mantra),
              onDelete: mantra.isBuiltIn
                  ? null
                  : () => _confirmDelete(context, ref, mantra),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOwn(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addMantra),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Mantra mantra,
  ) async {
    final l10n = AppL10n.of(context);
    final confirmed = await confirm(
      context,
      title: l10n.deleteMantraTitle,
      message: l10n.deleteMantraBody(mantra.name),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(mantraListProvider.notifier).remove(mantra.id);
  }
}

/// The quick picker on the counter: switch mantra without leaving the screen.
class MantraPickerSheet extends ConsumerWidget {
  const MantraPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final list = ref.watch(mantraListProvider).value ?? const <Mantra>[];
    final active = ref.watch(activeMantraProvider);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              0,
              Insets.page,
              Insets.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.myMantras,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _addOwn(context, ref),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.addMantra),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                0,
                Insets.page,
                Insets.xl,
              ),
              itemCount: list.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
              itemBuilder: (context, index) {
                if (index == list.length) {
                  return AddOwnMantraTile(onTap: () => _addOwn(context, ref));
                }
                final mantra = list[index];
                return MantraTile(
                  mantra: mantra,
                  isActive: mantra.id == active?.id,
                  onTap: () async {
                    await ref
                        .read(mantraListProvider.notifier)
                        .setActive(mantra.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the editor for a new mantra and, once saved, switches the counter
/// to it: someone adding their own mantra wants to chant it.
Future<void> _addOwn(BuildContext context, WidgetRef ref) async {
  final created = await showMantraEditor(context);
  if (created != null) {
    await ref.read(mantraListProvider.notifier).setActive(created.id);
  }
}

Future<void> showMantraPicker(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (context) => const MantraPickerSheet(),
    expand: true,
  );
}
