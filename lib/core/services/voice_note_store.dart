import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/ids.dart';
import 'app_logger.dart';

/// Where a mantra's voice notes live on disk.
///
/// The database stores only a recording's file name, never its absolute path:
/// iOS moves the app's container on updates and device restores, so a path
/// saved today points nowhere tomorrow. The directory is resolved afresh on
/// every use, and [pathFor] also accepts an absolute path from an older build
/// by keeping just its file name.
class VoiceNoteStore {
  VoiceNoteStore({Future<Directory> Function()? baseDirectory})
    : _baseDirectory = baseDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _baseDirectory;

  static const String _folder = 'mantra_audio';

  /// A fresh file name for a new recording. Store this, not the path.
  static String newFileName() => '${newId()}.m4a';

  Future<Directory> directory() async {
    final base = await _baseDirectory();
    final dir = Directory(p.join(base.path, _folder));
    await dir.create(recursive: true);
    return dir;
  }

  /// The absolute path of a stored recording on this device, today.
  Future<String> pathFor(String stored) async {
    final dir = await directory();
    return p.join(dir.path, p.basename(stored));
  }

  /// Whether a recording is actually on disk, which a row pointing at it does
  /// not guarantee after a restore or a device move.
  Future<bool> exists(String? stored) async {
    if (stored == null || stored.isEmpty) return false;
    return File(await pathFor(stored)).exists();
  }

  Future<Uint8List?> read(String stored) async {
    final file = File(await pathFor(stored));
    return await file.exists() ? file.readAsBytes() : null;
  }

  Future<void> write(String stored, List<int> bytes) async {
    await File(await pathFor(stored)).writeAsBytes(bytes, flush: true);
  }

  Future<void> delete(String? stored) async {
    if (stored == null || stored.isEmpty) return;
    try {
      final file = File(await pathFor(stored));
      if (await file.exists()) await file.delete();
    } on Object catch (error, stack) {
      AppLogger.e('Could not delete voice note $stored', error, stack);
    }
  }

  /// Removes every recording not named in [keep], so a restore that replaces
  /// the library does not leave the old library's audio behind.
  Future<void> deleteAllExcept(Set<String> keep) async {
    final names = keep.map(p.basename).toSet();
    final dir = await directory();
    await for (final entity in dir.list()) {
      if (entity is File && !names.contains(p.basename(entity.path))) {
        try {
          await entity.delete();
        } on Object catch (error, stack) {
          AppLogger.e('Could not prune ${entity.path}', error, stack);
        }
      }
    }
  }
}
