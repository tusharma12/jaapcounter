import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/built_in_mantras.dart';
import '../../../core/providers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/mantra.dart';

final mantraListProvider =
    AsyncNotifierProvider<MantraListController, List<Mantra>>(
      MantraListController.new,
    );

class MantraListController extends AsyncNotifier<List<Mantra>> {
  @override
  Future<List<Mantra>> build() => ref.watch(mantraRepositoryProvider).all();

  Future<Mantra> add({
    required String name,
    String? description,
    int malaSize = AppConstants.defaultMalaSize,
  }) async {
    final mantra = await ref
        .read(mantraRepositoryProvider)
        .create(name: name, description: description, malaSize: malaSize);
    unawaited(ref.read(analyticsProvider).mantraAdded());
    ref.invalidateSelf();
    return mantra;
  }

  Future<void> save(Mantra mantra) async {
    await ref.read(mantraRepositoryProvider).update(mantra);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await ref.read(mantraRepositoryProvider).delete(id);
    // If the deleted mantra was the active one, fall back to the first in the
    // library so the counter is never left pointing at nothing.
    final settings = ref.read(settingsProvider);
    if (settings.activeMantraId == id) {
      final remaining = await ref.read(mantraRepositoryProvider).all();
      final next = remaining.isEmpty
          ? BuiltInMantras.fallback
          : remaining.first;
      await ref.read(settingsProvider.notifier).setActiveMantra(next.id);
    }
    ref.invalidateSelf();
  }

  Future<void> setActive(String id) =>
      ref.read(settingsProvider.notifier).setActiveMantra(id);
}

/// The mantra a language starts on, before the user picks one, following
/// what its readers most often chant: Waheguru for Punjabi (mostly Sikh),
/// Om Namah Shivaya for Tamil, Nepali and Indonesian (Bali's Shaiva Hindus),
/// Shri Krishna for Gujarati, Hare Rama for Russian (mostly ISKCON), Om
/// Namah Shivaya for Malay (Malaysia's Hindus are mostly Tamil Shaivites)
/// and Ganesha for Thai, the Hindu deity most worshipped in Thailand.
/// Anything else starts on the first in the library, Ram Ram.
const Map<String, String> defaultMantraByLanguage = {
  'pa': 'builtin.waheguru',
  'ta': 'builtin.om-namah-shivaya',
  'ne': 'builtin.om-namah-shivaya',
  'id': 'builtin.om-namah-shivaya',
  'gu': 'builtin.shri-krishna',
  'ru': 'builtin.hare-rama',
  'ms': 'builtin.om-namah-shivaya',
  'th': 'builtin.om-gam-ganapataye-namah',
};

/// The mantra the counter is on. Until the user picks one, the default for
/// the app's language, else the first in the library, so the app always has
/// something to chant even on a fresh install.
final activeMantraProvider = Provider<Mantra?>((ref) {
  final mantras = ref.watch(mantraListProvider).value;
  if (mantras == null || mantras.isEmpty) return null;
  final settings = ref.watch(settingsProvider);
  final id = settings.activeMantraId;
  if (id == null) {
    final language =
        settings.localeCode ?? PlatformDispatcher.instance.locale.languageCode;
    final preferred = defaultMantraByLanguage[language];
    for (final mantra in mantras) {
      if (mantra.id == preferred) return mantra;
    }
    return mantras.first;
  }
  for (final mantra in mantras) {
    if (mantra.id == id) return mantra;
  }
  return mantras.first;
});
