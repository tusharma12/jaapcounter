import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/settings_controller.dart';

/// Counts a bead from a physical button, for chanting with eyes closed, while
/// walking, or with the phone in a pocket.
///
/// Android delivers the volume buttons and a wired or Bluetooth headset's
/// button as key events; when this widget handles one, the system volume does
/// not change. iOS never delivers the volume buttons to apps (and App Review
/// rejects apps that repurpose them), so there it is Bluetooth clickers and
/// keyboards only - which send arrows, space, enter or page down.
///
/// Only the screen that is actually in front listens: a counter on a hidden
/// tab, or beneath a pushed route or dialog, leaves the keys alone.
class HardwareCountKeys extends ConsumerStatefulWidget {
  const HardwareCountKeys({
    required this.onCount,
    required this.child,
    super.key,
  });

  final VoidCallback onCount;
  final Widget child;

  /// The keys that count one bead.
  static final Set<LogicalKeyboardKey> countKeys = {
    LogicalKeyboardKey.audioVolumeUp,
    LogicalKeyboardKey.audioVolumeDown,
    LogicalKeyboardKey.headsetHook,
    LogicalKeyboardKey.mediaPlayPause,
    LogicalKeyboardKey.mediaPlay,
    LogicalKeyboardKey.mediaTrackNext,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.pageDown,
  };

  /// Whether this platform lets the volume buttons count.
  static bool get volumeButtonsSupported =>
      defaultTargetPlatform == TargetPlatform.android;

  @override
  ConsumerState<HardwareCountKeys> createState() => _HardwareCountKeysState();
}

class _HardwareCountKeysState extends ConsumerState<HardwareCountKeys> {
  ValueListenable<TickerModeData>? _tickerMode;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handle);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hidden tabs of the shell are wrapped in a disabled TickerMode.
    _tickerMode = TickerMode.getValuesNotifier(context);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handle);
    super.dispose();
  }

  bool get _inFront {
    if (!mounted) return false;
    if (!(_tickerMode?.value.enabled ?? true)) return false;
    return ModalRoute.of(context)?.isCurrent ?? true;
  }

  bool _handle(KeyEvent event) {
    if (!HardwareCountKeys.countKeys.contains(event.logicalKey)) return false;
    if (!ref.read(settingsProvider).hardwareKeyCounting || !_inFront) {
      return false;
    }
    // A held button counts once; its repeats and release are still consumed
    // so the volume does not move underneath the count.
    if (event is KeyDownEvent) widget.onCount();
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
