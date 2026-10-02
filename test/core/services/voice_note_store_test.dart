import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/services/voice_note_store.dart';
import 'package:japmala/features/mantras/data/mantra_repository.dart';

import '../../support/test_harness.dart';

void main() {
  late Directory base;
  late VoiceNoteStore store;

  setUp(() async {
    base = await Directory.systemTemp.createTemp('voice');
    addTearDown(() => base.delete(recursive: true));
    store = VoiceNoteStore(baseDirectory: () async => base);
  });

  test('a new recording is named, not placed', () {
    final name = VoiceNoteStore.newFileName();

    expect(name, endsWith('.m4a'));
    expect(name, isNot(contains('/')));
  });

  test('a path from an older container resolves into today\'s', () async {
    // iOS moves the container on updates; only the file name survives.
    const stale =
        '/var/mobile/Containers/Data/Application/OLD/'
        'Documents/mantra_audio/abc.m4a';
    await store.write('abc.m4a', [1, 2, 3]);

    expect(await store.pathFor(stale), '${base.path}/mantra_audio/abc.m4a');
    expect(await store.exists(stale), isTrue);
  });

  test('a missing or absent recording does not exist', () async {
    expect(await store.exists(null), isFalse);
    expect(await store.exists(''), isFalse);
    expect(await store.exists('never.m4a'), isFalse);
  });

  test('deleting a recording that is not there is harmless', () async {
    await store.delete('never.m4a');
    await store.delete(null);
  });

  group('the repository keeps no recording unreferenced', () {
    late MantraRepository repository;

    setUp(() async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      repository = MantraRepository(db, voiceNotes: store);
    });

    test('replacing a voice note deletes the old file', () async {
      await store.write('first.m4a', [1]);
      await store.write('second.m4a', [2]);
      final mantra = await repository.create(
        name: 'सीता राम',
        audioPath: 'first.m4a',
      );

      await repository.update(mantra.copyWith(audioPath: 'second.m4a'));

      expect(await store.exists('first.m4a'), isFalse);
      expect(await store.exists('second.m4a'), isTrue);
    });

    test('removing a voice note deletes its file', () async {
      await store.write('first.m4a', [1]);
      final mantra = await repository.create(
        name: 'सीता राम',
        audioPath: 'first.m4a',
      );

      await repository.update(mantra.copyWith(audioPath: null));

      expect(await store.exists('first.m4a'), isFalse);
      expect((await repository.byId(mantra.id))!.hasAudio, isFalse);
    });

    test('saving other changes keeps the voice note', () async {
      await store.write('first.m4a', [1]);
      final mantra = await repository.create(
        name: 'सीता राम',
        audioPath: 'first.m4a',
      );

      await repository.update(mantra.copyWith(malaSize: 27));

      expect(await store.exists('first.m4a'), isTrue);
    });

    test('deleting a mantra deletes its voice note', () async {
      await store.write('first.m4a', [1]);
      final mantra = await repository.create(
        name: 'सीता राम',
        audioPath: 'first.m4a',
      );

      await repository.delete(mantra.id);

      expect(await store.exists('first.m4a'), isFalse);
    });
  });
}
