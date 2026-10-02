import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/story.dart';
import '../../../core/constants/app_languages.dart';

/// The language the stories are read in: the app's setting when there is one,
/// otherwise whatever the device is set to.
final contentLocaleProvider = Provider<String>((ref) {
  final chosen = ref.watch(settingsProvider).localeCode;
  return AppLanguages.storyLanguage(
    chosen ?? PlatformDispatcher.instance.locale.languageCode,
  );
});

final storyLibraryProvider = FutureProvider<StoryLibrary>((ref) {
  return ref
      .watch(storyRepositoryProvider)
      .load(ref.watch(contentLocaleProvider));
});

final storyCategoryFilterProvider =
    NotifierProvider<StoryCategoryFilter, String?>(StoryCategoryFilter.new);

class StoryCategoryFilter extends Notifier<String?> {
  @override
  String? build() => null;

  /// Tapping the selected category clears the filter.
  void select(String? categoryId) =>
      state = state == categoryId ? null : categoryId;
}

final favouriteStoriesProvider =
    NotifierProvider<FavouriteStories, Set<String>>(FavouriteStories.new);

class FavouriteStories extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      ref.watch(settingsServiceProvider).favouriteStoryIds().toSet();

  Future<void> toggle(String storyId) async {
    final next = {...state};
    if (!next.remove(storyId)) next.add(storyId);
    state = next;
    await ref.read(settingsServiceProvider).setFavouriteStoryIds(next.toList());
  }

  bool contains(String storyId) => state.contains(storyId);
}

/// Which story is being read aloud, if any.
final speakingStoryProvider = NotifierProvider<SpeakingStory, String?>(
  SpeakingStory.new,
);

class SpeakingStory extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> toggle(Story story) async {
    final speech = ref.read(speechServiceProvider);
    if (state == story.id) {
      state = null;
      await speech.stop();
      return;
    }
    state = story.id;
    await speech.speak(
      '${story.title}. ${story.plainText}',
      localeCode: ref.read(contentLocaleProvider),
    );
    // The engine awaits completion, so reaching here means it finished or
    // failed; either way the button should go back to "Listen".
    if (state == story.id) state = null;
  }

  Future<void> stop() async {
    state = null;
    await ref.read(speechServiceProvider).stop();
  }
}
