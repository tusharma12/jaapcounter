import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers.dart';
import '../../../core/services/voice_note_store.dart';
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
  bool _saved = false;

  bool _listening = false;
  String _dictationBase = '';

  String? _audioPath;
  String? _recordingName;
  bool _recording = false;
  bool _playing = false;
  Duration _recordElapsed = Duration.zero;
  Timer? _recordTicker;
  StreamSubscription<void>? _playbackSub;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    _malaSize = existing?.malaSize ?? AppConstants.defaultMalaSize;
    _audioPath = existing?.audioPath;
    if (existing?.hasAudio ?? false) unawaited(_dropMissingRecording());
  }

  /// A row can point at a recording that is not on this phone (a restore from
  /// an older backup, say). Showing a play button for it would only fail.
  Future<void> _dropMissingRecording() async {
    final present = await ref.read(voiceNoteStoreProvider).exists(_audioPath);
    if (!present && mounted) setState(() => _audioPath = null);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _recordTicker?.cancel();
    _playbackSub?.cancel();
    if (_listening) unawaited(ref.read(dictationServiceProvider).cancel());
    if (_recording) {
      unawaited(ref.read(mantraAudioServiceProvider).cancelRecording());
    }
    // A recording made in this sheet is orphaned the moment the sheet closes
    // without saving, so it never lingers on disk unreferenced.
    if (!_saved && _audioPath != widget.existing?.audioPath) {
      unawaited(ref.read(voiceNoteStoreProvider).delete(_audioPath));
    }
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
          audioPath: _audioPath,
        );
      } else {
        saved = existing.copyWith(
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          malaSize: _malaSize,
          audioPath: _audioPath,
        );
        await controller.save(saved);
      }
      _saved = true;
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

  Future<void> _startRecording() async {
    final l10n = AppL10n.of(context);
    final audio = ref.read(mantraAudioServiceProvider);
    final granted = await audio.hasPermission();
    if (!mounted) return;
    if (!granted) {
      showAppSnack(context, l10n.micPermissionDenied);
      return;
    }
    final store = ref.read(voiceNoteStoreProvider);
    final previous = _audioPath;
    final name = VoiceNoteStore.newFileName();
    await audio.startRecording(await store.pathFor(name));
    if (previous != null && previous != widget.existing?.audioPath) {
      await store.delete(previous);
    }
    if (!mounted) return;
    setState(() {
      _recordingName = name;
      _recording = true;
      _recordElapsed = Duration.zero;
    });
    _recordTicker?.cancel();
    _recordTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordElapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    _recordTicker?.cancel();
    final written = await ref.read(mantraAudioServiceProvider).stopRecording();
    if (!mounted) return;
    setState(() {
      _recording = false;
      // Only the file name is kept; the full path is rebuilt on each use.
      _audioPath = written == null ? null : _recordingName;
    });
  }

  Future<void> _togglePlayback() async {
    final stored = _audioPath;
    if (stored == null) return;
    final audio = ref.read(mantraAudioServiceProvider);
    if (_playing) {
      await audio.pausePlayback();
      if (mounted) setState(() => _playing = false);
      return;
    }
    final store = ref.read(voiceNoteStoreProvider);
    if (!await store.exists(stored)) {
      if (!mounted) return;
      setState(() => _audioPath = null);
      showAppSnack(context, AppL10n.of(context).voiceNoteMissing);
      return;
    }
    await audio.play(await store.pathFor(stored));
    if (!mounted) return;
    setState(() => _playing = true);
    _playbackSub?.cancel();
    _playbackSub = audio.onPlaybackComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  Future<void> _deleteVoiceNote() async {
    final audio = ref.read(mantraAudioServiceProvider);
    if (_playing) await audio.stopPlayback();
    final path = _audioPath;
    setState(() {
      _audioPath = null;
      _playing = false;
    });
    if (path != null && path == widget.existing?.audioPath) {
      // Deleting an already-saved recording takes effect only if the sheet
      // is then saved; the repository removes the file once nothing in the
      // database points at it any more.
      return;
    }
    await ref.read(voiceNoteStoreProvider).delete(path);
  }

  static String _formatElapsed(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
              const SizedBox(height: Insets.xl),
              _Label('${l10n.voiceNote} · ${l10n.optional}'),
              _VoiceNoteRow(
                hasRecording: _audioPath != null,
                recording: _recording,
                playing: _playing,
                elapsed: _recordElapsed,
                onRecord: _startRecording,
                onStop: _stopRecording,
                onTogglePlayback: _togglePlayback,
                onDelete: _deleteVoiceNote,
                formatElapsed: _formatElapsed,
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

/// Record, play back or discard a mantra's voice note. Its parent owns every
/// piece of state; this widget only ever renders it.
class _VoiceNoteRow extends StatelessWidget {
  const _VoiceNoteRow({
    required this.hasRecording,
    required this.recording,
    required this.playing,
    required this.elapsed,
    required this.onRecord,
    required this.onStop,
    required this.onTogglePlayback,
    required this.onDelete,
    required this.formatElapsed,
  });

  final bool hasRecording;
  final bool recording;
  final bool playing;
  final Duration elapsed;
  final VoidCallback onRecord;
  final VoidCallback onStop;
  final VoidCallback onTogglePlayback;
  final VoidCallback onDelete;
  final String Function(Duration) formatElapsed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;

    if (recording) {
      return _Pill(
        color: palette.danger,
        leading: const Icon(Icons.fiber_manual_record_rounded),
        label: Text('${l10n.voiceNoteRecording} · ${formatElapsed(elapsed)}'),
        trailing: IconButton(
          onPressed: onStop,
          tooltip: l10n.voiceNoteRecord,
          icon: const Icon(Icons.stop_circle_rounded),
        ),
      );
    }

    if (hasRecording) {
      return _Pill(
        color: theme.colorScheme.primary,
        leading: IconButton(
          onPressed: onTogglePlayback,
          tooltip: playing ? l10n.voiceNotePause : l10n.voiceNotePlay,
          icon: Icon(
            playing ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
          ),
        ),
        label: Text(l10n.voiceNote),
        trailing: IconButton(
          onPressed: onDelete,
          tooltip: l10n.voiceNoteDelete,
          icon: Icon(Icons.delete_outline_rounded, color: palette.danger),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onRecord,
      icon: const Icon(Icons.mic_none_rounded),
      label: Text(l10n.voiceNoteRecord),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.color,
    required this.leading,
    required this.label,
    required this.trailing,
  });

  final Color color;
  final Widget leading;
  final Widget label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        children: [
          IconTheme(
            data: IconThemeData(color: color),
            child: leading,
          ),
          const SizedBox(width: Insets.xs),
          Expanded(
            child: DefaultTextStyle(
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ) ??
                  const TextStyle(),
              child: label,
            ),
          ),
          trailing,
        ],
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
