import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/pill_tabs.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/mantra.dart';
import 'mantra_controllers.dart';

/// Add or edit a mantra. Returns the saved mantra, so the caller can make it
/// active straight away.
Future<Mantra?> showMantraEditor(
  BuildContext context, {
  Mantra? existing,
}) {
  return showAppSheet<Mantra>(
    context,
    builder: (context) => MantraEditorSheet(existing: existing),
  );
}

class MantraEditorSheet extends ConsumerStatefulWidget {
  const MantraEditorSheet({this.existing, super.key});

  final Mantra? existing;

  @override
  ConsumerState<MantraEditorSheet> createState() => _MantraEditorSheetState();
}

class _MantraEditorSheetState extends ConsumerState<MantraEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _devanagari;
  late final TextEditingController _transliteration;
  late int _malaSize;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _devanagari = TextEditingController(text: existing?.devanagari ?? '');
    _transliteration = TextEditingController(
      text: existing?.transliteration ?? '',
    );
    _malaSize = existing?.malaSize ?? AppConstants.defaultMalaSize;
  }

  @override
  void dispose() {
    _name.dispose();
    _devanagari.dispose();
    _transliteration.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    try {
      final controller = ref.read(mantraListProvider.notifier);
      final existing = widget.existing;
      final Mantra saved;
      if (existing == null) {
        saved = await controller.add(
          name: _name.text,
          devanagari: _devanagari.text,
          transliteration: _transliteration.text,
          malaSize: _malaSize,
        );
      } else {
        saved = existing.copyWith(
          name: _name.text.trim(),
          devanagari: _devanagari.text.trim().isEmpty
              ? null
              : _devanagari.text.trim(),
          transliteration: _transliteration.text.trim().isEmpty
              ? null
              : _transliteration.text.trim(),
          malaSize: _malaSize,
        );
        await controller.save(saved);
      }
      if (mounted) Navigator.of(context).pop(saved);
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        showAppSnack(context, l10n.somethingWentWrong);
      }
    }
  }

  Future<void> _pickCustomSize() async {
    final l10n = AppL10n.of(context);
    final value = await showNumberPrompt(
      context,
      title: l10n.malaSize,
      initialValue: _malaSize,
      min: AppConstants.minMalaSize,
      max: AppConstants.maxMalaSize,
      invalidMessage: l10n.malaSizeInvalid,
    );
    if (value != null && mounted) setState(() => _malaSize = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? l10n.addMantra : l10n.editMantra,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: Insets.xl),
              _Label(l10n.mantraName),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofocus: widget.existing == null,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.nameRequired
                    : null,
              ),
              const SizedBox(height: Insets.lg),
              _Label('${l10n.mantraDevanagari} · ${l10n.optional}'),
              TextFormField(
                controller: _devanagari,
                textInputAction: TextInputAction.next,
                maxLines: 2,
                minLines: 1,
              ),
              const SizedBox(height: Insets.lg),
              _Label('${l10n.mantraTransliteration} · ${l10n.optional}'),
              TextFormField(
                controller: _transliteration,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: Insets.xl),
              _Label(l10n.malaSize),
              PresetSelector(
                presets: AppConstants.malaSizePresets,
                value: _malaSize,
                customLabel: l10n.custom,
                onSelected: (value) => setState(() => _malaSize = value),
                onCustom: _pickCustomSize,
              ),
              const SizedBox(height: Insets.xxl),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.sm, left: Insets.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

/// A single-field number prompt, shared by mala size, daily goal and manual
/// count entry.
Future<int?> showNumberPrompt(
  BuildContext context, {
  required String title,
  required int initialValue,
  required int min,
  required int max,
  required String invalidMessage,
  String? helperText,
}) async {
  final controller = TextEditingController(text: '$initialValue');
  final formKey = GlobalKey<FormState>();
  final l10n = AppL10n.of(context);

  final result = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(helperText: helperText),
          validator: (value) {
            final parsed = int.tryParse(value ?? '');
            if (parsed == null || parsed < min || parsed > max) {
              return invalidMessage;
            }
            return null;
          },
          onFieldSubmitted: (_) {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(int.parse(controller.text));
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(int.parse(controller.text));
            }
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
