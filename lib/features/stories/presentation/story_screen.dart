import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/story.dart';
import 'story_controllers.dart';

/// Reading a story: wide margins, adjustable text, and the option to be read
/// to. No related-content rail, no next-up — the story ends and that is it.
class StoryScreen extends ConsumerWidget {
  const StoryScreen({required this.storyId, super.key});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final library = ref.watch(storyLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            tooltip: l10n.textSize,
            onPressed: () => _cycleTextSize(ref),
            icon: const Icon(Icons.text_fields_rounded),
          ),
        ],
      ),
      body: AsyncView<StoryLibrary>(
        value: library,
        onRetry: () => ref.invalidate(storyLibraryProvider),
        builder: (context, data) {
          final story = data.byId(storyId);
          if (story == null) {
            return EmptyState(glyph: '📖', title: l10n.noStoriesFound);
          }
          return _StoryBody(story: story);
        },
      ),
    );
  }

  /// One button steps through three sizes: fewer choices, less to explain.
  void _cycleTextSize(WidgetRef ref) {
    const steps = [1.0, 1.2, 1.45];
    final current = ref.read(settingsProvider).storyTextScale;
    final index = steps.indexWhere((s) => (s - current).abs() < 0.01);
    final next = steps[(index + 1) % steps.length];
    ref.read(settingsProvider.notifier).setStoryTextScale(next);
  }
}

class _StoryBody extends ConsumerWidget {
  const _StoryBody({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final scale = ref.watch(settingsProvider).storyTextScale;
    final isFavourite = ref.watch(favouriteStoriesProvider).contains(story.id);
    final speakingId = ref.watch(speakingStoryProvider);
    final isSpeaking = speakingId == story.id;
    final isHindi = ref.watch(contentLocaleProvider) == 'hi';

    final bodyStyle = isHindi
        ? AppTypography.mantra(
            size: 17 * scale,
            weight: FontWeight.w400,
            color: palette.primaryText,
          )
        : theme.textTheme.bodyLarge!.copyWith(
            fontSize: 17 * scale,
            height: 1.72,
            color: palette.primaryText,
          );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Insets.xxl,
        Insets.sm,
        Insets.xxl,
        Insets.xxxl,
      ),
      children: [
        Text(story.emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: Insets.lg),
        Text(
          story.title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 30 * (scale > 1.2 ? 1.1 : 1),
            height: 1.2,
          ),
        ),
        const SizedBox(height: Insets.md),
        Text(
          l10n.minRead(story.readingMinutes),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: Insets.xl),
        Divider(color: palette.divider),
        const SizedBox(height: Insets.xl),
        for (final paragraph in story.paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.xl),
            child: Text(paragraph, style: bodyStyle),
          ),
        const SizedBox(height: Insets.sm),
        Divider(color: palette.divider),
        const SizedBox(height: Insets.lg),
        Row(
          children: [
            _StoryAction(
              icon: isSpeaking
                  ? Icons.stop_circle_outlined
                  : Icons.volume_up_rounded,
              label: isSpeaking ? l10n.stopListening : l10n.listen,
              active: isSpeaking,
              onTap: () =>
                  ref.read(speakingStoryProvider.notifier).toggle(story),
            ),
            _StoryAction(
              icon: isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: l10n.favorite,
              active: isFavourite,
              onTap: () =>
                  ref.read(favouriteStoriesProvider.notifier).toggle(story.id),
            ),
            _StoryAction(
              icon: Icons.ios_share_rounded,
              label: l10n.share,
              active: false,
              onTap: () => _share(story),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _share(Story story) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: story.title,
          text: '${story.title}\n\n${story.plainText}',
        ),
      );
    } on Object catch (error, stack) {
      AppLogger.e('Sharing a story failed', error, stack);
    }
  }
}

class _StoryAction extends StatelessWidget {
  const _StoryAction({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final color = active ? palette.saffron : palette.secondaryText;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.md),
          child: Column(
            children: [
              Icon(icon, size: 21, color: color),
              const SizedBox(height: Insets.xs),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
