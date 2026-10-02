import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/lock_screen_counter_service.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';

import '../../support/test_harness.dart';

/// Stands in for the native side: records calls, holds the pending count.
class _FakeLockScreen extends LockScreenCounterService {
  _FakeLockScreen() : super(platformSupported: true);

  final shown = <Map<String, Object?>>[];
  var ended = 0;
  int pending = 0;
  DateTime? pendingAt;
  int drains = 0;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<void> show({
    required String mantra,
    required int beads,
    required int malaSize,
    required int todayTotal,
  }) async => shown.add({
    'mantra': mantra,
    'beads': beads,
    'malaSize': malaSize,
    'todayTotal': todayTotal,
  });

  @override
  Future<void> end() async => ended++;

  @override
  Future<PendingLockScreenBeads> drainPending() async {
    drains++;
    final taken = PendingLockScreenBeads(pending, pendingAt);
    pending = 0;
    pendingAt = null;
    return taken.count == 0 ? PendingLockScreenBeads.none : taken;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the channel contract', () {
    final calls = <MethodCall>[];
    Object? reply;

    LockScreenCounterService service({bool supported = true}) {
      final channel = const MethodChannel(LockScreenCounterService.channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return reply;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      return LockScreenCounterService(
        channel: channel,
        platformSupported: supported,
      );
    }

    setUp(() {
      calls.clear();
      reply = null;
    });

    test('show sends the four numbers the Live Activity needs', () async {
      await service().show(
        mantra: 'राम',
        beads: 12,
        malaSize: 108,
        todayTotal: 300,
      );

      expect(calls.single.method, 'start');
      expect(calls.single.arguments, {
        'mantra': 'राम',
        'beads': 12,
        'malaSize': 108,
        'todayTotal': 300,
      });
    });

    test('draining returns the count and when it was tapped', () async {
      reply = {
        'count': 7,
        'at': DateTime(2026, 10, 2, 8).millisecondsSinceEpoch,
      };

      final pending = await service().drainPending();

      expect(pending.count, 7);
      expect(pending.at, DateTime(2026, 10, 2, 8));
    });

    test('draining with nothing pending is none', () async {
      reply = {'count': 0};

      expect((await service().drainPending()).count, 0);
    });

    test('a platform without it never touches the channel', () async {
      final unsupported = service(supported: false);

      expect(await unsupported.isSupported(), isFalse);
      await unsupported.show(
        mantra: 'x',
        beads: 1,
        malaSize: 108,
        todayTotal: 1,
      );
      await unsupported.end();
      expect((await unsupported.drainPending()).count, 0);
      expect(calls, isEmpty);
    });

    test('a missing native side is unsupported, not an error', () async {
      final channel = const MethodChannel(LockScreenCounterService.channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      final bare = LockScreenCounterService(
        channel: channel,
        platformSupported: true,
      );

      expect(await bare.isSupported(), isFalse);
      expect((await bare.drainPending()).count, 0);
    });
  });

  group('in the counter', () {
    late ProviderContainer container;
    late _FakeLockScreen lockScreen;
    late TestClock clock;

    setUp(() async {
      lockScreen = _FakeLockScreen();
      clock = TestClock(DateTime(2026, 10, 2, 9));
      container = await createTestContainer(
        clock: clock,
        overrides: [lockScreenCounterProvider.overrideWithValue(lockScreen)],
      );
      await container.read(settingsProvider.notifier).setHaptics(false);
      await container.read(jaapControllerProvider.future);
    });

    int today() => container.read(jaapControllerProvider).value!.todayTotal;

    test('beads tapped on the lock screen join the ledger on resume', () async {
      lockScreen.pending = 5;
      lockScreen.pendingAt = DateTime(2026, 10, 2, 8, 30);

      await container.read(jaapControllerProvider.notifier).refreshForResume();

      expect(today(), 5);
      expect(await container.read(jaapRepositoryProvider).lifetimeTotal(), 5);
    });

    test('a second resume adds nothing', () async {
      lockScreen.pending = 3;
      final controller = container.read(jaapControllerProvider.notifier);

      await controller.refreshForResume();
      await controller.refreshForResume();

      expect(today(), 3);
      expect(lockScreen.drains, 2);
    });

    test('nothing pending leaves the ledger alone', () async {
      await container.read(jaapControllerProvider.notifier).refreshForResume();

      expect(today(), 0);
    });

    test('taps made in the app are written before the drained ones', () async {
      final controller = container.read(jaapControllerProvider.notifier);
      for (var i = 0; i < 4; i++) {
        controller.count();
      }
      lockScreen.pending = 2;

      await controller.refreshForResume();

      expect(today(), 6);
      expect(
        await container.read(jaapRepositoryProvider).lifetimeTotal(),
        6,
        reason: 'six rows of history, none lost to the drain',
      );
    });

    test('nothing is shown while the setting is off', () async {
      container.read(jaapControllerProvider.notifier).count();
      await container
          .read(jaapControllerProvider.notifier)
          .flushPendingWrites();
      await Future<void>.delayed(const Duration(milliseconds: 800));

      expect(lockScreen.shown, isEmpty);
    });

    test('switching it on shows the current numbers; off ends it', () async {
      final controller = container.read(jaapControllerProvider.notifier);
      for (var i = 0; i < 12; i++) {
        controller.count();
      }
      await controller.flushPendingWrites();

      await container
          .read(settingsProvider.notifier)
          .setLockScreenCounter(true);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(lockScreen.shown.last, {
        'mantra': 'Ram',
        'beads': 12,
        'malaSize': 108,
        'todayTotal': 12,
      });

      await container
          .read(settingsProvider.notifier)
          .setLockScreenCounter(false);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(lockScreen.ended, 1);
    });

    test(
      'after a drain it shows the true numbers, not the lock screen\'s',
      () async {
        await container
            .read(settingsProvider.notifier)
            .setLockScreenCounter(true);
        lockScreen.pending = 9;

        await container
            .read(jaapControllerProvider.notifier)
            .refreshForResume();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(lockScreen.shown.last['beads'], 9);
        expect(lockScreen.shown.last['todayTotal'], 9);
      },
    );
  });
}
