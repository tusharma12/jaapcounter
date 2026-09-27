import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

/// True once the first bead has been counted: the "tap anywhere" hint is
/// shown until then and never again.
final counterHintSeenProvider = NotifierProvider<CounterHintSeen, bool>(
  CounterHintSeen.new,
);

class CounterHintSeen extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsServiceProvider).counterHintSeen();

  void markSeen() {
    if (state) return;
    state = true;
    ref.read(settingsServiceProvider).setCounterHintSeen();
  }
}

/// Hides the mantra on the counter, for those who chant from memory.
final hideMantraProvider = NotifierProvider<HideMantra, bool>(HideMantra.new);

class HideMantra extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsServiceProvider).hideMantra();

  void toggle() => set(!state);

  void set(bool hidden) {
    state = hidden;
    ref.read(settingsServiceProvider).setHideMantra(hidden);
  }
}
