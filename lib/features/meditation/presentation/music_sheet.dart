import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/providers.dart';
import '../../../core/services/ambient_chant_service.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/user_music_store.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/app_localizations.dart';
import 'music_controllers.dart';

/// The one place for sound in meditation: the tick sound, the background
/// music, and the user's own music, recorded in the app or uploaded.
class MusicSheet extends ConsumerStatefulWidget {
  const MusicSheet({
    required this.selected,
    required this.playing,
    required this.onChoose,
    super.key,
  });

  /// What the meditation screen currently has chosen and playing. Read afresh
  /// after every choice, since the screen owns that state.
  final String? Function() selected;
  final bool Function() playing;

  /// Chooses [id], and plays it or stops it.
  final Future<void> Function(String? id, {required bool play}) onChoose;

  @override
  ConsumerState<MusicSheet> createState() => _MusicSheetState();
}

class _MusicSheetState extends ConsumerState<MusicSheet> {
  bool _recording = false;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  String? _recordingFile;

  @override
  void dispose() {
    _ticker?.cancel();
    if (_recording) {
      unawaited(ref.read(musicRecorderProvider).cancel());
      final file = _recordingFile;
      if (file != null) {
        unawaited(ref.read(userMusicStoreProvider).delete(file));
      }
    }
    super.dispose();
  }

  Future<void> _choose(String? id, {required bool play}) async {
    await widget.onChoose(id, play: play);
    if (mounted) setState(() {});
  }

  Future<void> _startRecording() async {
    final l10n = AppL10n.of(context);
    final recorder = ref.read(musicRecorderProvider);
    final store = ref.read(userMusicStoreProvider);
    try {
      if (!await recorder.hasPermission()) {
        if (mounted) showAppSnack(context, l10n.micPermissionDenied);
        return;
      }
      // Recording and the chosen music cannot share the speaker and the
      // microphone, so the music stops first.
      if (widget.playing()) {
        await widget.onChoose(widget.selected(), play: false);
      }
      final file = UserMusicStore.newFileName();
      await recorder.start(await store.pathFor(file));
      if (!mounted) return;
      setState(() {
        _recordingFile = file;
        _recording = true;
        _elapsed = Duration.zero;
      });
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
    } on Object catch (error, stack) {
      AppLogger.e('Could not start recording', error, stack);
      if (mounted) showAppSnack(context, l10n.somethingWentWrong);
    }
  }

  Future<void> _stopRecording() async {
    final l10n = AppL10n.of(context);
    _ticker?.cancel();
    final file = _recordingFile;
    try {
      final written = await ref.read(musicRecorderProvider).stop();
      if (!mounted) return;
      setState(() => _recording = false);
      if (written == null || file == null) return;
      final controller = ref.read(userMusicProvider.notifier);
      final count = (ref.read(userMusicProvider).value ?? const []).length;
      final suggested = l10n.musicRecordingName(count + 1);
      // Asked after the recording is safely on disk, so a closed dialog
      // costs only the name, never the recording.
      final chosen = await showDialog<String>(
        context: context,
        builder: (_) => _NameDialog(initial: suggested),
      );
      if (!mounted) return;
      final name = (chosen ?? '').trim();
      final track = await controller.addStored(
        file: file,
        name: name.isEmpty ? suggested : name,
      );
      // Play it straight away, so a recording is heard as soon as it is made.
      await _choose('$userTrackPrefix${track.id}', play: true);
    } on Object catch (error, stack) {
      AppLogger.e('Could not finish recording', error, stack);
      if (mounted) {
        setState(() => _recording = false);
        showAppSnack(context, l10n.somethingWentWrong);
      }
    }
  }

  Future<void> _upload() async {
    final l10n = AppL10n.of(context);
    try {
      final picked = await ref.read(musicPickerProvider)();
      if (picked == null || !mounted) return;
      final track = await ref
          .read(userMusicProvider.notifier)
          .addPicked(picked);
      if (!mounted) return;
      if (track == null) {
        showAppSnack(context, l10n.musicAddFailed);
        return;
      }
      await _choose('$userTrackPrefix${track.id}', play: true);
    } on Object catch (error, stack) {
      AppLogger.e('Could not pick a sound', error, stack);
      if (mounted) showAppSnack(context, l10n.musicAddFailed);
    }
  }

  Future<void> _remove(UserTrack track) async {
    final id = '$userTrackPrefix${track.id}';
    if (widget.selected() == id) await widget.onChoose(null, play: false);
    await ref.read(userMusicProvider.notifier).remove(track.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final mine = ref.watch(userMusicProvider).value ?? const <UserTrack>[];
    final selected = widget.selected();
    final playing = widget.playing();

    Widget tile({required String id, required String label, Widget? trailing}) {
      return ListTile(
        title: Text(label),
        leading: selected == id && playing
            ? const Icon(Icons.graphic_eq_rounded)
            : const Icon(Icons.music_note_outlined),
        trailing:
            trailing ??
            (selected == id ? const Icon(Icons.check_rounded) : null),
        onTap: () => _choose(id, play: true),
      );
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                Insets.lg,
                Insets.page,
                Insets.sm,
              ),
              child: FilledButton.icon(
                key: const ValueKey('chant-play-stop'),
                onPressed: _recording
                    ? null
                    : () => _choose(
                        selected ?? AmbientChantService.chants.first.id,
                        play: !playing,
                      ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: Icon(
                  playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(playing ? l10n.chantStop : l10n.chantPlay),
              ),
            ),
            for (final chant in AmbientChantService.chants)
              tile(id: chant.id, label: chant.label),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                Insets.lg,
                Insets.page,
                Insets.xs,
              ),
              child: Text(
                l10n.musicYours,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.secondaryText,
                ),
              ),
            ),
            for (final track in mine)
              tile(
                id: '$userTrackPrefix${track.id}',
                label: track.name,
                trailing: IconButton(
                  tooltip: l10n.musicRemove,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: palette.danger,
                  ),
                  onPressed: () => _remove(track),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                Insets.sm,
                Insets.page,
                Insets.lg,
              ),
              child: _recording
                  ? FilledButton.icon(
                      key: const ValueKey('music-stop-recording'),
                      onPressed: _stopRecording,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.danger,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.stop_circle_rounded),
                      label: Text(
                        '${l10n.chantStop} · ${Fmt.stopwatch(_elapsed)}',
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('music-record'),
                            onPressed: _startRecording,
                            icon: const Icon(Icons.mic_none_rounded),
                            label: Text(l10n.musicRecord),
                          ),
                        ),
                        const SizedBox(width: Insets.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('music-upload'),
                            onPressed: _upload,
                            icon: const Icon(Icons.upload_file_rounded),
                            label: Text(l10n.musicUpload),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks what to call a new recording. Owns its text controller, so the
/// controller outlives the dialog's closing animation.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initial.length,
    );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return AlertDialog(
      // Scrolls when the keyboard leaves little room.
      scrollable: true,
      title: Text(l10n.musicNameTitle),
      content: TextField(
        key: const ValueKey('music-name-field'),
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [TextButton(onPressed: _submit, child: Text(l10n.save))],
    );
  }
}
