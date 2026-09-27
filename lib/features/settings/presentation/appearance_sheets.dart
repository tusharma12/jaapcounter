import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_themes.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_settings.dart';
import '../domain/counter_background.dart';
import 'settings_controller.dart';

/// The name shown for a theme in the picker and in Settings.
String themeName(AppL10n l10n, AppThemeId id) => switch (id) {
  AppThemeId.system => l10n.themeAuto,
  AppThemeId.white => l10n.themeWhite,
  AppThemeId.black => l10n.themeBlack,
  AppThemeId.pastelPink => l10n.themePastelPink,
  AppThemeId.spiritual => l10n.themeSpiritual,
  AppThemeId.saffron => l10n.themeSaffron,
  AppThemeId.peaceful => l10n.themePeaceful,
  AppThemeId.terracotta => l10n.themeTerracotta,
  AppThemeId.meditative => l10n.themeMeditative,
  AppThemeId.nature => l10n.themeNature,
  AppThemeId.roseGold => l10n.themeRoseGold,
  AppThemeId.ocean => l10n.themeOcean,
  AppThemeId.lavender => l10n.themeLavender,
  AppThemeId.charcoal => l10n.themeCharcoal,
};

String backgroundName(AppL10n l10n, CounterBackground background) =>
    switch (background) {
      CounterBackground.none => l10n.backgroundNone,
      CounterBackground.dawn => l10n.backgroundDawn,
      CounterBackground.dusk => l10n.backgroundDusk,
      CounterBackground.lotus => l10n.backgroundLotus,
      CounterBackground.forest => l10n.backgroundForest,
      CounterBackground.ocean => l10n.backgroundOcean,
      CounterBackground.cosmos => l10n.backgroundCosmos,
      CounterBackground.photo => l10n.backgroundPhoto,
    };

/// A grid of colour swatches. A tap applies the theme at once, so the sheet
/// itself previews it.
Future<void> showThemePicker(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _ThemePickerSheet());
}

class _ThemePickerSheet extends ConsumerWidget {
  const _ThemePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final current = ref.watch(settingsProvider.select((s) => s.themeId));

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.chooseTheme, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Insets.xl),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Insets.lg,
              crossAxisSpacing: Insets.md,
              childAspectRatio: 0.9,
              children: [
                for (final id in AppThemeId.values)
                  _ThemeSwatch(
                    id: id,
                    label: themeName(l10n, id),
                    selected: id == current,
                    onTap: () =>
                        ref.read(settingsProvider.notifier).setTheme(id),
                  ),
              ],
            ),
            const SizedBox(height: Insets.lg),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId id;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final spec = AppThemeSpec.of(id);
    // Auto is drawn half light, half dark.
    final decoration = spec == null
        ? const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.5, 0.5],
              colors: [Colors.white, Colors.black],
            ),
          )
        : BoxDecoration(shape: BoxShape.circle, color: spec.swatch);
    final checkColor = spec == null
        ? AppColors.saffron
        : (spec.brightness == Brightness.dark ? Colors.white : Colors.black);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Motion.fast,
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? palette.primaryText : palette.divider,
                  width: selected ? 3 : 1,
                ),
              ),
              child: DecoratedBox(
                decoration: decoration,
                child: selected
                    ? Icon(Icons.check_rounded, color: checkColor, size: 28)
                    : null,
              ),
            ),
            const SizedBox(height: Insets.sm),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.primaryText,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradients, a photo of the user's own, and how strongly to dim it.
Future<void> showBackgroundPicker(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (_) => const _BackgroundPickerSheet(),
  );
}

class _BackgroundPickerSheet extends ConsumerStatefulWidget {
  const _BackgroundPickerSheet();

  @override
  ConsumerState<_BackgroundPickerSheet> createState() =>
      _BackgroundPickerSheetState();
}

class _BackgroundPickerSheetState
    extends ConsumerState<_BackgroundPickerSheet> {
  bool _picking = false;

  Future<void> _pickPhoto() async {
    final l10n = AppL10n.of(context);
    setState(() => _picking = true);
    try {
      // Compression also converts HEIC to JPEG, which every platform decodes.
      final file = await FilePicker.pickFile(
        type: FileType.image,
        compressionQuality: 85,
      );
      if (file == null) return;
      await ref
          .read(settingsProvider.notifier)
          .setBackgroundPhoto(
            await file.readAsBytes(),
            extension: file.extension,
          );
    } on Object catch (error, stack) {
      AppLogger.e('Could not set background photo', error, stack);
      if (mounted) showAppSnack(context, l10n.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final photoPath = settings.backgroundPhotoPath;
    final hasPhoto = photoPath != null;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          0,
          Insets.page,
          Insets.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.counterBackground, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Insets.xs),
            Text(l10n.counterBackgroundBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Insets.xl),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Insets.md,
              crossAxisSpacing: Insets.md,
              childAspectRatio: 0.62,
              children: [
                _BackgroundTile(
                  label: l10n.backgroundNone,
                  selected: settings.background == CounterBackground.none,
                  onTap: () => controller.setBackground(CounterBackground.none),
                  child: Icon(
                    Icons.block_rounded,
                    color: context.palette.tertiaryText,
                  ),
                ),
                for (final preset in CounterBackground.presets)
                  _BackgroundTile(
                    label: backgroundName(l10n, preset),
                    selected: settings.background == preset,
                    onTap: () => controller.setBackground(preset),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: preset.colors,
                    ),
                  ),
                _BackgroundTile(
                  label: l10n.backgroundPhoto,
                  selected: settings.background == CounterBackground.photo,
                  onTap: _picking
                      ? null
                      : (hasPhoto ? controller.useSavedPhoto : _pickPhoto),
                  image: hasPhoto ? FileImage(File(photoPath)) : null,
                  child: hasPhoto
                      ? null
                      : Icon(
                          Icons.add_photo_alternate_outlined,
                          color: context.palette.secondaryText,
                        ),
                ),
              ],
            ),
            const SizedBox(height: Insets.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _picking ? null : _pickPhoto,
                    icon: _picking
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_library_outlined),
                    label: Text(
                      hasPhoto
                          ? l10n.backgroundChangePhoto
                          : l10n.backgroundChoosePhoto,
                    ),
                  ),
                ),
                if (hasPhoto) ...[
                  const SizedBox(width: Insets.sm),
                  IconButton(
                    tooltip: l10n.backgroundRemovePhoto,
                    onPressed: _picking
                        ? null
                        : controller.removeBackgroundPhoto,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: context.palette.danger,
                    ),
                  ),
                ],
              ],
            ),
            if (settings.background != CounterBackground.none) ...[
              const SizedBox(height: Insets.xl),
              Text(l10n.backgroundDim, style: theme.textTheme.titleSmall),
              Slider.adaptive(
                value: settings.backgroundDim,
                min: AppSettings.minBackgroundDim,
                max: AppSettings.maxBackgroundDim,
                onChanged: controller.setBackgroundDim,
              ),
              Text(l10n.backgroundDimHint, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: Insets.lg),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundTile extends StatelessWidget {
  const _BackgroundTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.gradient,
    this.image,
    this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final ImageProvider? image;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Column(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: Motion.fast,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(
                    color: selected ? palette.saffron : palette.divider,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(Radii.sm),
                    gradient: gradient,
                    image: image == null
                        ? null
                        : DecorationImage(image: image!, fit: BoxFit.cover),
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
            const SizedBox(height: Insets.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? palette.primaryText : palette.secondaryText,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the chosen background behind the counter, dimmed with the theme's
/// own background colour so the text keeps its contrast.
class CounterBackdrop extends ConsumerWidget {
  const CounterBackdrop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final palette = context.palette;
    final path = settings.backgroundPhotoPath;

    final Widget layer;
    switch (settings.background) {
      case CounterBackground.none:
        return const SizedBox.shrink();
      case CounterBackground.photo:
        if (path == null) return const SizedBox.shrink();
        layer = Image.file(
          File(path),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          // A deleted or unreadable file just leaves the plain theme.
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        );
      default:
        layer = DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: settings.background.colors,
            ),
          ),
        );
    }

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          layer,
          ColoredBox(
            color: palette.background.withValues(alpha: settings.backgroundDim),
          ),
        ],
      ),
    );
  }
}
