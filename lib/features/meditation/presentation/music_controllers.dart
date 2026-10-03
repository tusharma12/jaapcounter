import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/providers.dart';
import '../../../core/services/ambient_chant_service.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/user_music_store.dart';
import '../../../core/utils/ids.dart';

/// Prefix that tells the user's own sounds apart from the bundled ones in a
/// saved choice.
const String userTrackPrefix = 'user:';

/// A file the user picked, before it is copied into the app.
class PickedMusic {
  const PickedMusic({required this.path, required this.name});

  final String path;
  final String name;
}

/// Opens the system file picker for a sound. Overridden in tests.
final musicPickerProvider = Provider<Future<PickedMusic?> Function()>(
  (ref) => () async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: UserMusicStore.allowedExtensions.toList(),
    );
    final path = file?.path;
    if (file == null || path == null) return null;
    return PickedMusic(path: path, name: p.basenameWithoutExtension(file.name));
  },
);

/// The user's own sounds: recordings made in the app and files picked from
/// the phone. Kept in one list, in one place.
final userMusicProvider =
    AsyncNotifierProvider<UserMusicController, List<UserTrack>>(
      UserMusicController.new,
    );

class UserMusicController extends AsyncNotifier<List<UserTrack>> {
  @override
  Future<List<UserTrack>> build() async {
    final store = ref.read(userMusicStoreProvider);
    final saved = [
      for (final json in ref.read(settingsServiceProvider).userMusic())
        ?_decode(json),
    ];
    // A row whose file is gone (a device move, say) would only fail to play.
    return [
      for (final track in saved)
        if (await store.exists(track.file)) track,
    ];
  }

  static UserTrack? _decode(String json) {
    try {
      return UserTrack.fromJson(jsonDecode(json));
    } on Object {
      return null;
    }
  }

  Future<void> _save(List<UserTrack> tracks) async {
    state = AsyncData(tracks);
    await ref.read(settingsServiceProvider).setUserMusic([
      for (final track in tracks) jsonEncode(track.toJson()),
    ]);
  }

  /// Adds a file already inside the app's folder, such as a fresh recording.
  Future<UserTrack> addStored({
    required String file,
    required String name,
  }) async {
    final track = UserTrack(id: newId(), name: name, file: file);
    await _save([...(state.value ?? const []), track]);
    return track;
  }

  /// Copies a picked file into the app and adds it. Returns null when the
  /// file could not be copied.
  Future<UserTrack?> addPicked(PickedMusic picked) async {
    try {
      final file = await ref
          .read(userMusicStoreProvider)
          .importFile(picked.path);
      return addStored(
        file: file,
        name: picked.name.isEmpty ? file : picked.name,
      );
    } on Object catch (error, stack) {
      AppLogger.e('Could not add the picked sound', error, stack);
      return null;
    }
  }

  Future<void> remove(String id) async {
    final tracks = [...(state.value ?? const <UserTrack>[])];
    final index = tracks.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final removed = tracks.removeAt(index);
    await _save(tracks);
    await ref.read(userMusicStoreProvider).delete(removed.file);
  }

  /// A saved choice resolved to something playable, or null if it is
  /// unknown or its file is gone.
  Future<AmbientChant?> resolve(String? id) async {
    if (id == null) return null;
    if (!id.startsWith(userTrackPrefix)) return AmbientChantService.byId(id);
    final tracks = await future;
    for (final track in tracks) {
      if ('$userTrackPrefix${track.id}' == id) {
        final path = await ref.read(userMusicStoreProvider).pathFor(track.file);
        return AmbientChant.file(id, track.name, path);
      }
    }
    return null;
  }
}
