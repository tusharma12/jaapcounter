import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/pill_tabs.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/mantra.dart';
import 'mantra_controllers.dart';
import '../../../core/constants/app_languages.dart';

/// Add or edit a mantra. Returns the saved mantra, so the caller can make it
/// active straight away.
Future<Mantra?> showMantraEditor(BuildContext context, {Mantra? existing}) {
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
  late final TextEditingController _description;
  late int _malaSize;
  bool _saving = false;

  bool _listening = false;
  String _dictationBase = '';

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    _malaSize = existing?.malaSize ?? AppConstants.defaultMalaSize;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    if (_listening) unawaited(ref.read(dictationServiceProvider).cancel());
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
          description: _description.text,
          malaSize: _malaSize,
        );
      } else {
        saved = existing.copyWith(
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
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

  /// Fills the mantra field by speaking it, in place of typing. Tapping the
  /// mic again, or a pause in speech, ends it.
  Future<void> _toggleDictation() async {
    final l10n = AppL10n.of(context);
    final dictation = ref.read(dictationServiceProvider);
    if (_listening) {
      await dictation.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ready = await dictation.ensureReady();
    if (!mounted) return;
    if (!ready) {
      showAppSnack(context, l10n.dictationUnavailable);
      return;
    }
    _dictationBase = _name.text.trim();
    final localeId = AppLanguages.dictationLocale(
      Localizations.localeOf(context).languageCode,
    );
    setState(() => _listening = true);
    await dictation.listen(
      localeId: localeId,
      onResult: (text, isFinal) {
        if (!mounted) return;
        final combined = _dictationBase.isEmpty
            ? text
            : '$_dictationBase $text';
        _name.value = TextEditingValue(
          text: combined,
          selection: TextSelection.collapsed(offset: combined.length),
        );
        if (isFinal) setState(() => _listening = false);
      },
      onDone: () {
        if (mounted && _listening) setState(() => _listening = false);
      },
      onError: () {
        if (!mounted) return;
        setState(() => _listening = false);
        showAppSnack(context, l10n.dictationOfflineUnavailable);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    // Scrollable, so with the keyboard up every field can still be reached
    // and a drag moves the form, not the sheet and the screen behind it.
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              _Label(l10n.mantraText),
              // Any script: the keyboard decides, and the counter shows it
              // exactly as typed. A verse may run to several lines.
              TextFormField(
                controller: _name,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                textCapitalization: TextCapitalization.sentences,
                autofocus: widget.existing == null,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.mantraTextHint,
                  suffixIcon: IconButton(
                    onPressed: _toggleDictation,
                    tooltip: _listening
                        ? l10n.dictationListening
                        : l10n.dictationStart,
                    icon: Icon(
                      _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _listening ? theme.colorScheme.primary : null,
                    ),
                  ),
                ),
                style: AppTypography.mantra(size: 18),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.mantraRequired
                    : null,
              ),
              const SizedBox(height: Insets.lg),
              _Label('${l10n.mantraDescription} · ${l10n.optional}'),
              TextFormField(
                controller: _description,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.mantraDescriptionHint,
                ),
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
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _NumberPrompt(
      title: title,
      initialValue: initialValue,
      min: min,
      max: max,
      invalidMessage: invalidMessage,
      helperText: helperText,
    ),
  );
}

/// Owns its text controller, so the controller outlives the dialog's closing
/// animation instead of being disposed while the field is still on screen.
class _NumberPrompt extends StatefulWidget {
  const _NumberPrompt({
    required this.title,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.invalidMessage,
    this.helperText,
  });

  final String title;
  final int initialValue;
  final int min;
  final int max;
  final String invalidMessage;
  final String? helperText;

  @override
  State<_NumberPrompt> createState() => _NumberPromptState();
}

class _NumberPromptState extends State<_NumberPrompt> {
  late final _controller = TextEditingController(
    text: '${widget.initialValue}',
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(int.parse(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AlertDialog(
      // Scrolls when the keyboard and an error message leave little room.
      scrollable: true,
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(helperText: widget.helperText),
          validator: (value) {
            final parsed = int.tryParse(value ?? '');
            if (parsed == null || parsed < widget.min || parsed > widget.max) {
              return widget.invalidMessage;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
