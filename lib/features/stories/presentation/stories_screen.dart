import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pill_tabs.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/story.dart';
import 'story_controllers.dart';

/// A reading room rather than a feed: a few short stories, gently sorted.
class StoriesScreen extends ConsumerWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final library = ref.watch(storyLibraryProvider);
    final filter = ref.watch(storyCategoryFilterProvider);
    final favourites = ref.watch(favouriteStoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stories),
        actions: [
          IconButton(
            tooltip: l10n.favorites,
            onPressed: () => context.push('/stories/favourites'),
            icon: Icon(
              favourites.isEmpty
                  ? Icons.favorite_border_rounded
                  : Icons.favorite_rounded,
              color: favourites.isEmpty ? null : context.palette.saffron,
            ),
          ),
        ],
      ),
      body: AsyncView<StoryLibrary>(
        value: library,
        onRetry: () => ref.invalidate(storyLibraryProvider),
        builder: (context, data) {
          final stories = data.inCategory(filter);
          return ListView(
            padding: const EdgeInsets.only(bottom: Insets.xxxl),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Insets.page,
                  0,
                  Insets.page,
                  Insets.lg,
                ),
                child: Text(
                  l10n.storiesSubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              PillTabs<String?>(
                scrollable: true,
                items: [null, ...data.categories.map((c) => c.id)],
                selected: filter,
                onSelected: ref.read(storyCategoryFilterProvider.notifier).select,
                labelOf: (id) => id == null
                    ? l10n.all
                    : data.categories
                          .firstWhere((c) => c.id == id)
                          .label,
              ),
              const SizedBox(height: Insets.xl),
              if (stories.isEmpty)
                EmptyState(glyph: '📖', title: l10n.noStoriesFound)
              else ...[
                for (final story in stories)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Insets.page,
                      0,
                      Insets.page,
                      Insets.md,
                    ),
                    child: StoryCard(story: story),
                  ),
              ],
              if (filter == null && data.popular.isNotEmpty) ...[
                const SizedBox(height: Insets.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Insets.page),
                  child: ScreenSectionTitle(l10n.popular),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Insets.page),
                  child: Row(
                    children: [
                      for (final story in data.popular)
                        Padding(
                          padding: const EdgeInsets.only(right: Insets.md),
                          child: SizedBox(
                            width: 208,
                            child: StoryCard(story: story, compact: true),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class StoryCard extends ConsumerWidget {
  const StoryCard({required this.story, this.compact = false, super.key});

  final Story story;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final isFavourite = ref.watch(favouriteStoriesProvider).contains(story.id);

    return AppCard(
      onTap: () => context.push('/stories/${story.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(story.emoji, style: const TextStyle(fontSize: 24)),
              const Spacer(),
              if (isFavourite)
                Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: palette.saffron,
                ),
            ],
          ),
          const SizedBox(height: Insets.lg),
          Text(
            story.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: Insets.sm),
          Text(
            story.summary,
            maxLines: compact ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Insets.lg),
          Row(
            children: [
              Text(
                l10n.minRead(story.readingMinutes),
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${l10n.read} →',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: palette.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Favourites, kept on a screen of their own so the main list stays calm.
class FavouriteStoriesScreen extends ConsumerWidget {
  const FavouriteStoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final favourites = ref.watch(favouriteStoriesProvider);
    final library = ref.watch(storyLibraryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites)),
      body: AsyncView<StoryLibrary>(
        value: library,
        builder: (context, data) {
          final stories = data.stories
              .where((s) => favourites.contains(s.id))
              .toList();
          if (stories.isEmpty) {
            return EmptyState(
              glyph: '♡',
              title: l10n.noFavoritesTitle,
              body: l10n.noFavoritesBody,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              Insets.sm,
              Insets.page,
              Insets.xxxl,
            ),
            itemCount: stories.length,
            separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
            itemBuilder: (context, index) => StoryCard(story: stories[index]),
          );
        },
      ),
    );
  }
}
