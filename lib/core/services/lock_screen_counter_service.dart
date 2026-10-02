import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_logger.dart';

/// Beads tapped on the lock screen that are waiting to be written to the
/// ledger.
@immutable
class PendingLockScreenBeads {
  const PendingLockScreenBeads(this.count, [this.at]);

  static const none = PendingLockScreenBeads(0);

  final int count;

  /// When the last of them was tapped.
  final DateTime? at;
}

/// The lock-screen counter: on iOS a Live Activity with a +1 button, on
/// Android (later) an ongoing notification with the same.
///
/// The ledger has exactly one writer, the Flutter app. The +1 button only
/// bumps a pending count on the native side; [drainPending] hands it over and
/// the app writes it. Nothing native ever opens the database.
class LockScreenCounterService {
  LockScreenCounterService({MethodChannel? channel, bool? platformSupported})
    : _channel = channel ?? const MethodChannel(channelName),
      _platformSupported = platformSupported ?? Platform.isIOS;

  static const String channelName = 'japmala/lockscreen';

  final MethodChannel _channel;
  final bool _platformSupported;

  /// Whether this phone can show it: a supported platform and OS, with the
  /// user's Live Activities not switched off in system Settings.
  Future<bool> isSupported() async {
    if (!_platformSupported) return false;
    return await _guard(() => _channel.invokeMethod<bool>('isSupported')) ??
        false;
  }

  /// Starts it, or updates it in place. Safe to call on every change.
  Future<void> show({
    required String mantra,
    required int beads,
    required int malaSize,
    required int todayTotal,
  }) async {
    if (!_platformSupported) return;
    await _guard(
      () => _channel.invokeMethod<void>('start', {
        'mantra': mantra,
        'beads': beads,
        'malaSize': malaSize,
        'todayTotal': todayTotal,
      }),
    );
  }

  Future<void> end() async {
    if (!_platformSupported) return;
    await _guard(() => _channel.invokeMethod<void>('end'));
  }

  /// Takes the beads tapped on the lock screen since the last call. They are
  /// removed natively as they are returned, so a second call gets none.
  Future<PendingLockScreenBeads> drainPending() async {
    if (!_platformSupported) return PendingLockScreenBeads.none;
    final reply = await _guard(
      () => _channel.invokeMapMethod<String, Object?>('drainPending'),
    );
    final count = (reply?['count'] as num?)?.toInt() ?? 0;
    if (count <= 0) return PendingLockScreenBeads.none;
    final ms = (reply?['at'] as num?)?.toInt();
    return PendingLockScreenBeads(
      count,
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms),
    );
  }

  /// A missing or failing native side must never break counting.
  Future<T?> _guard<T>(Future<T?> Function() call) async {
    try {
      return await call();
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error, stack) {
      AppLogger.e('Lock screen counter failed', error, stack);
      return null;
    }
  }
}
