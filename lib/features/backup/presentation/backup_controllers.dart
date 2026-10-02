import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/providers.dart';
import '../data/backup_service.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

final appBuildNumberProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.buildNumber;
});

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  return BackupService(
    database: ref.watch(databaseProvider),
    settingsService: ref.watch(settingsServiceProvider),
    version: await ref.watch(appVersionProvider.future),
    clock: ref.watch(clockProvider),
    voiceNotes: ref.watch(voiceNoteStoreProvider),
  );
});
