import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/user_music_store.dart';
import 'package:japmala/features/meditation/presentation/music_controllers.dart';

import '../../support/test_harness.dart';

void main() {
  late Directory base;
  late UserMusicStore store;

  setUp(() async {
    base = await Directory.systemTemp.createTemp('music');
    addTearDown(() => base.delete(recursive: true));
    store = UserMusicStore(baseDirectory: () async => base);
  });

  Future<File> sampleFile(String name, [List<int> bytes = const [1, 2, 3]]) {
    return File('${base.path}/$name').writeAsBytes(bytes);
  }

  group('the store', () {
    test('a picked file is copied in under a name of our own', () async {
      final source = await sampleFile('My Sound.MP3', [9, 9, 9]);

      final stored = await store.importFile(source.path);

      expect(stored, endsWith('.mp3'));
      expect(stored, isNot(contains('My Sound')));
      expect(await File(await store.pathFor(stored)).readAsBytes(), [9, 9, 9]);
    });

    test('an odd extension falls back to m4a', () {
      expect(UserMusicStore.newFileName('.exe'), endsWith('.m4a'));
      expect(UserMusicStore.newFileName('.WAV'), endsWith('.wav'));
    });

    test('paths always resolve into our own folder', () async {
      final path = await store.pathFor('/somewhere/else/../x.m4a');

      expect(path, '${base.path}/user_music/x.m4a');
    });

    test('deleting a missing file is harmless', () async {
      await store.delete('never.m4a');
    });

    test('old voice notes are cleared out', () async {
      final legacy = Directory('${base.path}/mantra_audio')..createSync();
      File('${legacy.path}/old.m4a').writeAsBytesSync([1]);

      await store.purgeLegacyVoiceNotes();

      expect(legacy.existsSync(), isFalse);
    });
  });

  group('the library', () {
    Future<ProviderContainer> setUpContainer() => createTestContainer(
      overrides: [userMusicStoreProvider.overrideWithValue(store)],
    );

    test('adds, lists, resolves and removes a track', () async {
      final c = await setUpContainer();
      final source = await sampleFile('a.m4a');
      final library = c.read(userMusicProvider.notifier);
      await c.read(userMusicProvider.future);

      final track = await library.addPicked(
        PickedMusic(path: source.path, name: 'Evening bowl'),
      );

      expect(track, isNotNull);
      expect(c.read(userMusicProvider).value!.single.name, 'Evening bowl');
      final chant = await library.resolve('$userTrackPrefix${track!.id}');
      expect(chant!.label, 'Evening bowl');
      expect(await File(chant.filePath!).exists(), isTrue);

      await library.remove(track.id);

      expect(c.read(userMusicProvider).value, isEmpty);
      expect(await File(chant.filePath!).exists(), isFalse);
      expect(await library.resolve('$userTrackPrefix${track.id}'), isNull);
    });

    test('bundled sounds resolve by id, unknown ones do not', () async {
      final c = await setUpContainer();
      final library = c.read(userMusicProvider.notifier);

      expect((await library.resolve('white_noise'))!.isUserFile, isFalse);
      expect(await library.resolve('nope'), isNull);
      expect(await library.resolve(null), isNull);
    });

    test('a file that cannot be copied is not added', () async {
      final c = await setUpContainer();
      await c.read(userMusicProvider.future);

      final track = await c
          .read(userMusicProvider.notifier)
          .addPicked(const PickedMusic(path: '/no/such/file.mp3', name: 'x'));

      expect(track, isNull);
      expect(c.read(userMusicProvider).value, isEmpty);
    });

    test('a track whose file has gone is dropped on the next load', () async {
      final c = await setUpContainer();
      final source = await sampleFile('b.m4a');
      await c.read(userMusicProvider.future);
      final track = await c
          .read(userMusicProvider.notifier)
          .addPicked(PickedMusic(path: source.path, name: 'Gone soon'));
      await File(await store.pathFor(track!.file)).delete();

      c.invalidate(userMusicProvider);

      expect(await c.read(userMusicProvider.future), isEmpty);
    });
  });
}
