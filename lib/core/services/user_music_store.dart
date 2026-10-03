import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/ids.dart';
import 'app_logger.dart';

/// A sound the user brought: recorded in the app, or picked from the phone.
@immutable
class UserTrack {
  const UserTrack({required this.id, required this.name, required this.file});

  final String id;
  final String name;

  /// File name only. iOS moves the app's container on updates and device
  /// restores, so a saved absolute path would point nowhere later; the
  /// folder is resolved afresh on every use.
  final String file;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'file': file};

  static UserTrack? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final name = json['name'];
    final file = json['file'];
    if (id is! String || name is! String || file is! String) return null;
    return UserTrack(id: id, name: name, file: p.basename(file));
  }
}

/// Where the user's own meditation sounds live on disk.
class UserMusicStore {
  UserMusicStore({Future<Directory> Function()? baseDirectory})
    : _baseDirectory = baseDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _baseDirectory;

  static const String _folder = 'user_music';

  /// The folder earlier versions kept per-mantra voice notes in. Those were
  /// removed in favour of this one place, so the folder is cleared.
  static const String _legacyFolder = 'mantra_audio';

  static const Set<String> allowedExtensions = {'mp3', 'm4a', 'aac', 'wav'};

  /// A fresh name for a new file, keeping [extension] so the player can tell
  /// the format.
  static String newFileName([String extension = 'm4a']) {
    final clean = extension.toLowerCase().replaceAll('.', '');
    return '${newId()}.${allowedExtensions.contains(clean) ? clean : 'm4a'}';
  }

  Future<Directory> directory() async {
    final base = await _baseDirectory();
    final dir = Directory(p.join(base.path, _folder));
    await dir.create(recursive: true);
    return dir;
  }

  Future<String> pathFor(String file) async {
    final dir = await directory();
    return p.join(dir.path, p.basename(file));
  }

  Future<bool> exists(String file) async => File(await pathFor(file)).exists();

  /// Copies a file the user picked into the app's own folder, so it survives
  /// the original being moved or deleted. Returns the stored file name.
  Future<String> importFile(String sourcePath) async {
    final name = newFileName(p.extension(sourcePath));
    await File(sourcePath).copy(await pathFor(name));
    return name;
  }

  Future<void> delete(String file) async {
    try {
      final target = File(await pathFor(file));
      if (await target.exists()) await target.delete();
    } on Object catch (error, stack) {
      AppLogger.e('Could not delete $file', error, stack);
    }
  }

  /// Removes the voice notes earlier versions recorded for single mantras.
  Future<void> purgeLegacyVoiceNotes() async {
    try {
      final base = await _baseDirectory();
      final dir = Directory(p.join(base.path, _legacyFolder));
      if (await dir.exists()) await dir.delete(recursive: true);
    } on Object catch (error, stack) {
      AppLogger.e('Could not remove old voice notes', error, stack);
    }
  }
}
