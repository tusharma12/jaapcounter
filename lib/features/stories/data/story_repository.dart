import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/story.dart';

/// Loads the bundled story collection.
///
/// Content is read from an asset rather than compiled into Dart, so the same
/// loader can later be pointed at a downloaded file without touching the UI.
class StoryRepository {
  StoryRepository({this.assetPath = 'assets/stories/stories.json'});

  final String assetPath;

  static const String _fallbackLocale = 'en';

  Map<String, Object?>? _raw;

  Future<StoryLibrary> load(String localeCode) async {
    final data = _raw ??= jsonDecode(await rootBundle.loadString(assetPath))
        as Map<String, Object?>;

    final categories = (data['categories'] as List<Object?>? ?? const [])
        .cast<Map<String, Object?>>()
        .map(
          (c) => StoryCategory(
            id: c['id'] as String,
            label: _localised(c['label'], localeCode) ?? c['id'] as String,
          ),
        )
        .toList();

    final stories = (data['stories'] as List<Object?>? ?? const [])
        .cast<Map<String, Object?>>()
        .map((s) => _story(s, localeCode))
        .whereType<Story>()
        .toList();

    return StoryLibrary(stories: stories, categories: categories);
  }

  Story? _story(Map<String, Object?> raw, String localeCode) {
    final content = raw['content'] as Map<String, Object?>?;
    if (content == null) return null;
    final localised =
        (content[localeCode] ?? content[_fallbackLocale])
            as Map<String, Object?>?;
    if (localised == null) return null;

    return Story(
      id: raw['id'] as String,
      title: localised['title'] as String? ?? '',
      summary: localised['summary'] as String? ?? '',
      paragraphs: (localised['body'] as List<Object?>? ?? const [])
          .map((p) => p.toString())
          .toList(),
      categoryIds: (raw['categoryIds'] as List<Object?>? ?? const [])
          .map((c) => c.toString())
          .toList(),
      emoji: raw['emoji'] as String? ?? '🪷',
      popular: raw['popular'] as bool? ?? false,
    );
  }

  static String? _localised(Object? field, String localeCode) {
    if (field is String) return field;
    if (field is Map<String, Object?>) {
      return (field[localeCode] ?? field[_fallbackLocale]) as String?;
    }
    return null;
  }
}
