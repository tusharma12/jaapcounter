import 'package:meta/meta.dart';

/// A story, already resolved into one language.
@immutable
class Story {
  const Story({
    required this.id,
    required this.title,
    required this.summary,
    required this.paragraphs,
    required this.categoryIds,
    this.emoji = '🪷',
    this.popular = false,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> paragraphs;
  final List<String> categoryIds;
  final String emoji;
  final bool popular;

  String get plainText => paragraphs.join('\n\n');

  int get wordCount =>
      paragraphs.fold(0, (sum, p) => sum + p.split(RegExp(r'\s+')).length);

  /// Rounded up, and never zero - every story is at least a minute of quiet.
  int get readingMinutes {
    final minutes = (wordCount / 180).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  bool operator ==(Object other) => other is Story && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class StoryCategory {
  const StoryCategory({required this.id, required this.label});

  final String id;
  final String label;
}

@immutable
class StoryLibrary {
  const StoryLibrary({required this.stories, required this.categories});

  final List<Story> stories;
  final List<StoryCategory> categories;

  static const empty = StoryLibrary(stories: [], categories: []);

  List<Story> get popular => stories.where((s) => s.popular).toList();

  List<Story> inCategory(String? categoryId) => categoryId == null
      ? stories
      : stories.where((s) => s.categoryIds.contains(categoryId)).toList();

  Story? byId(String id) =>
      stories.where((s) => s.id == id).cast<Story?>().firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T?> {
  T? get firstOrNull => isEmpty ? null : first;
}
