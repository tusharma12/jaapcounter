import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/observance.dart';
import '../domain/observance_calendar.dart';

final observanceCalendarProvider = Provider<ObservanceCalendar>(
  (ref) => const ObservanceCalendar(),
);

/// Ekadashi and festivals in the coming weeks, soonest first.
final upcomingObservancesProvider = Provider<List<Observance>>((ref) {
  return ref
      .watch(observanceCalendarProvider)
      .upcoming(ref.watch(clockProvider)());
});
