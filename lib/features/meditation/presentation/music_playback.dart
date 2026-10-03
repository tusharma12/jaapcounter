import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/services/ambient_chant_service.dart';
import 'music_controllers.dart';

@immutable
class MusicPlaybackState {
  const MusicPlaybackState({this.selectedId, this.playing = false});

  /// The sound last chosen, bundled or the user's own, or null for none yet.
  final String? selectedId;
  final bool playing;

  MusicPlaybackState copyWith({String? selectedId, bool? playing}) =>
      MusicPlaybackState(
        selectedId: selectedId ?? this.selectedId,
        playing: playing ?? this.playing,
      );
}

final musicPlaybackProvider =
    NotifierProvider<MusicPlaybackController, MusicPlaybackState>(
      MusicPlaybackController.new,
    );

/// The background music, shared by Meditation and Auto Jaap so there is one
/// choice and one player however the user got to it.
class MusicPlaybackController extends Notifier<MusicPlaybackState> {
  // True when Auto Jaap, not the user, started the music, so that Auto Jaap
  // stopping stops it again but never cuts off music the user started.
  bool _startedByAuto = false;

  @override
  MusicPlaybackState build() {
    return MusicPlaybackState(
      selectedId: ref.read(settingsServiceProvider).meditationChant(),
    );
  }

  /// Whether Auto Jaap, not the user, is what started the music.
  bool get startedByAuto => _startedByAuto;

  AmbientChantService get _ambient => ref.read(ambientChantProvider);

  /// Whether the user left a sound switched on, ready to start by itself.
  bool get wantedOn =>
      state.selectedId != null &&
      ref.read(settingsServiceProvider).meditationChantOn();

  /// Chooses [id] and starts or stops it. A stopped sound stays chosen, so
  /// Play brings back the same one. An unknown or vanished sound stays
  /// silent rather than failing.
  Future<void> choose(String? id, {required bool play}) async {
    _startedByAuto = false;
    final chant = play
        ? await ref.read(userMusicProvider.notifier).resolve(id)
        : null;
    final playNow = chant != null;
    state = MusicPlaybackState(selectedId: id, playing: playNow);
    final settings = ref.read(settingsServiceProvider);
    unawaited(settings.setMeditationChant(id));
    unawaited(settings.setMeditationChantOn(playNow));
    if (chant != null) {
      unawaited(_ambient.play(chant));
    } else {
      unawaited(_ambient.stop());
    }
  }

  /// Starts what was playing last time, if the user left it on.
  Future<void> resume() async {
    final id = state.selectedId;
    if (id == null || state.playing || !wantedOn) return;
    final chant = await ref.read(userMusicProvider.notifier).resolve(id);
    if (chant == null) return;
    state = state.copyWith(playing: true);
    unawaited(_ambient.play(chant));
  }

  /// Stops the sound without forgetting the choice or the user's setting.
  Future<void> stop() async {
    // A screen can close just as the app is being torn down.
    if (!ref.mounted) return;
    _startedByAuto = false;
    if (state.playing) state = state.copyWith(playing: false);
    await _ambient.stop();
  }

  /// Lets the sound fade away, for the end of a timed sitting.
  Future<void> fadeOutAndStop() async {
    _startedByAuto = false;
    if (state.playing) state = state.copyWith(playing: false);
    await _ambient.fadeOutAndStop();
  }

  /// Auto Jaap began with its sound switched on: play the last chosen sound,
  /// or the first one if none was ever chosen. Nothing is saved, so this
  /// does not change whether Meditation starts music by itself.
  Future<void> startForAuto() async {
    if (state.playing) return;
    final id = state.selectedId ?? AmbientChantService.chants.first.id;
    final chant = await ref.read(userMusicProvider.notifier).resolve(id);
    if (chant == null) return;
    _startedByAuto = true;
    state = MusicPlaybackState(selectedId: id, playing: true);
    unawaited(ref.read(settingsServiceProvider).setMeditationChant(id));
    unawaited(_ambient.play(chant));
  }

  /// Auto Jaap ended: stop the sound only if Auto Jaap started it.
  Future<void> stopForAuto() async {
    if (!_startedByAuto) return;
    await stop();
  }
}
