import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../features/jaap/data/jaap_repository.dart';
import '../features/mantras/data/mantra_repository.dart';
import '../features/reminders/data/reminder_repository.dart';
import '../features/sadhana/data/sadhana_repository.dart';
import '../features/stories/data/story_repository.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/speech_service.dart';
import 'services/widget_service.dart';
import 'utils/day_key.dart';

/// Both of these are overridden in `main` once the platform is ready, so no
/// screen has to unwrap an `AsyncValue` just to read a repository.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('sharedPreferencesProvider was not overridden'),
);

final databaseProvider = Provider<Database>(
  (ref) => throw StateError('databaseProvider was not overridden'),
);

/// Injected so date-sensitive behaviour can be tested.
final clockProvider = Provider<Clock>((ref) => systemClock);

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(ref.watch(sharedPreferencesProvider)),
);

final mantraRepositoryProvider = Provider<MantraRepository>(
  (ref) => MantraRepository(ref.watch(databaseProvider)),
);

final jaapRepositoryProvider = Provider<JaapRepository>(
  (ref) => JaapRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

final sadhanaRepositoryProvider = Provider<SadhanaRepository>(
  (ref) => SadhanaRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(databaseProvider)),
);

final storyRepositoryProvider = Provider<StoryRepository>(
  (ref) => StoryRepository(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Story read-aloud; one instance, so only one story speaks at a time.
final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(service.stop);
  return service;
});

final widgetServiceProvider = Provider<WidgetService>((ref) => WidgetService());

/// Bumped whenever the ledger changes, so every derived screen (progress,
/// sadhana, widgets) recomputes from the database instead of guessing.
final ledgerRevisionProvider = NotifierProvider<LedgerRevision, int>(
  LedgerRevision.new,
);

class LedgerRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}
