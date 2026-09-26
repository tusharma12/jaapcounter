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
    String? devanagari,
    String? transliteration,
    int malaSize = AppConstants.defaultMalaSize,
  }) async {
    final mantra = await ref.read(mantraRepositoryProvider).create(
      name: name,
      devanagari: devanagari,
      transliteration: transliteration,
      malaSize: malaSize,
    );
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
      final next = remaining.isEmpty ? BuiltInMantras.fallback : remaining.first;
      await ref.read(settingsProvider.notifier).setActiveMantra(next.id);
    }
    ref.invalidateSelf();
  }

  Future<void> setActive(String id) =>
      ref.read(settingsProvider.notifier).setActiveMantra(id);
}

/// The mantra the counter is on. Falls back to the first in the library, so
/// the app always has something to chant even on a fresh install.
final activeMantraProvider = Provider<Mantra?>((ref) {
  final mantras = ref.watch(mantraListProvider).value;
  if (mantras == null || mantras.isEmpty) return null;
  final id = ref.watch(settingsProvider).activeMantraId;
  if (id == null) return mantras.first;
  for (final mantra in mantras) {
    if (mantra.id == id) return mantra;
  }
  return mantras.first;
});
