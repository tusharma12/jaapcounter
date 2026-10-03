import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/mantra_text.dart';
import '../../../app/theme/app_themes.dart';
import '../../../core/services/ambient_chant_service.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../jaap/presentation/counter_prefs.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../meditation/presentation/music_controllers.dart';
import '../../meditation/presentation/music_playback.dart';
import '../../meditation/presentation/music_sheet.dart';
import '../../settings/presentation/appearance_sheets.dart';
import '../../mantras/presentation/mantra_editor_sheet.dart';
import '../../mantras/presentation/mantra_tile.dart';
import '../../sadhana/presentation/daily_goal_picker.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../../core/constants/app_languages.dart';

/// Three screens of welcome, one tour of the features, then three that make the app the user's own:
/// which mantra they chant and how much each day. Then out of the way.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  int? _goal;
  bool _iconPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Every page shows this icon, so it is loaded once up front rather than
    // popping in on whichever page happens to be first.
    if (!_iconPrecached) {
      _iconPrecached = true;
      precacheImage(const AssetImage('assets/branding/app_icon.png'), context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    // A goal the user set is kept; skipping keeps the default.
    final goal = _goal;
    if (goal != null) {
      await ref.read(settingsProvider.notifier).setFallbackDailyGoal(goal);
    }
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) context.go('/jaap');
  }

  void _next(int total) {
    if (_page >= total - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: Motion.medium, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;

    final mantra = ref.watch(activeMantraProvider);
    final pages = <Widget>[
      _OnboardingPage(title: l10n.onb1Title, body: l10n.onb1Body),
      _OnboardingPage(title: l10n.onb2Title, body: l10n.onb2Body),
      _OnboardingPage(title: l10n.onb3Title, body: l10n.onb3Body),
      const _FeaturesPage(),
      const _MantraPage(),
      const _LookPage(),
      _GoalPage(
        goal: _goal ?? ref.watch(settingsProvider).fallbackDailyGoal,
        malaSize: mantra?.malaSize ?? AppConstants.defaultMalaSize,
        onChanged: (goal) => setState(() => _goal = goal),
      ),
    ];

    final isLast = _page == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  l10n.skip,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: palette.secondaryText,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: Motion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page ? palette.saffron : palette.track,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(Insets.page),
              child: FilledButton(
                onPressed: () => _next(pages.length),
                child: Text(isLast ? l10n.startJap : l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The app's own icon, used on every onboarding page so the app introduces
/// itself once and consistently rather than switching symbols each screen.
class _AppIconMark extends StatelessWidget {
  const _AppIconMark({this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/branding/app_icon.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _AppIconMark(size: 132),
              const SizedBox(height: Insets.xxxl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: Insets.md),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the app can do beyond counting, so a new user meets the features
/// they would otherwise only find by wandering through Settings.
class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final features = <(IconData, String, String)>[
      (Icons.play_circle_outline_rounded, l10n.autoJaap, l10n.autoJaapBody),
      (Icons.library_music_outlined, l10n.ownMusicTitle, l10n.ownMusicBody),
      (
        Icons.music_note_outlined,
        l10n.soundsFeatureTitle,
        l10n.soundsFeatureBody,
      ),
      (Icons.dark_mode_outlined, l10n.onb3Title, l10n.onb3Body),
      (
        Icons.local_fire_department_outlined,
        l10n.graceDays,
        l10n.graceDaysHint,
      ),
      (
        Icons.nightlight_outlined,
        l10n.festivalReminders,
        l10n.festivalRemindersHint,
      ),
      if (Platform.isIOS)
        (
          Icons.phonelink_lock_outlined,
          l10n.lockScreenCounter,
          l10n.lockScreenCounterHint,
        ),
      (
        Icons.widgets_outlined,
        l10n.homeScreenWidget,
        l10n.homeScreenWidgetBody,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.page,
        vertical: Insets.md,
      ),
      children: [
        _StepHeader(title: l10n.onbFeaturesTitle, body: l10n.onbFeaturesBody),
        const SizedBox(height: Insets.xl),
        for (final (icon, title, body) in features)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.lg),
            child: MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: context.palette.saffron, size: 26),
                  const SizedBox(width: Insets.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.palette.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// How the counter looks and sounds, chosen up front so these are not
/// switches to hunt for later. Each is saved as it is picked.
class _LookPage extends ConsumerWidget {
  const _LookPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(settingsProvider);
    final hideMantra = ref.watch(hideMantraProvider);
    final music = ref.watch(musicPlaybackProvider);
    final mine = ref.watch(userMusicProvider).value ?? const [];

    String musicName() {
      final id = music.selectedId;
      if (id == null) return l10n.off[0] + l10n.off.substring(1).toLowerCase();
      final bundled = AmbientChantService.byId(id);
      if (bundled != null) return bundled.label;
      for (final track in mine) {
        if ('$userTrackPrefix${track.id}' == id) return track.name;
      }
      return l10n.off[0] + l10n.off.substring(1).toLowerCase();
    }

    /// Picking music here is a preview: it plays while the list is open and
    /// stops when it closes, but the choice stays for everywhere else.
    Future<void> chooseMusic() async {
      final notifier = ref.read(musicPlaybackProvider.notifier);
      await showAppSheet<void>(
        context,
        builder: (_) => MusicSheet(
          selected: () => ref.read(musicPlaybackProvider).selectedId,
          playing: () => ref.read(musicPlaybackProvider).playing,
          onChoose: (id, {required play}) => notifier.choose(id, play: play),
        ),
      );
      if (ref.read(musicPlaybackProvider).playing) await notifier.stop();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.page,
        vertical: Insets.md,
      ),
      children: [
        _StepHeader(title: l10n.onbLookTitle, body: l10n.onbLookBody),
        const SizedBox(height: Insets.xl),
        Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: Insets.sm),
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.sm,
          children: [
            for (final id in AppThemeId.values)
              ChoiceChip(
                label: Text(themeName(l10n, id)),
                selected: id == settings.themeId,
                onSelected: (_) =>
                    ref.read(settingsProvider.notifier).setTheme(id),
              ),
          ],
        ),
        const SizedBox(height: Insets.lg),
        SwitchListTile(
          key: const ValueKey('onb-show-mantra'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.showMantraOnCounter),
          value: !hideMantra,
          onChanged: (show) => ref.read(hideMantraProvider.notifier).set(!show),
        ),
        SwitchListTile(
          key: const ValueKey('onb-falling-mantra'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.fallingMantra),
          value: settings.fallingMantra,
          onChanged: ref.read(settingsProvider.notifier).setFallingMantra,
        ),
        ListTile(
          key: const ValueKey('onb-music'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.music),
          subtitle: Text(musicName()),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: chooseMusic,
        ),
      ],
    );
  }
}

/// A title and a line of guidance above the personal steps.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const _AppIconMark(size: 64),
        const SizedBox(height: Insets.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: Insets.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.palette.secondaryText,
          ),
        ),
      ],
    );
  }
}

/// The app's language, and with it how the mantra names read. Shown here
/// rather than buried in Settings, since it decides whether the list below
/// is legible the moment it appears. Each is named in its own script.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.locale, required this.onChanged});

  final String? locale;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Shows the device's own language until the user picks one explicitly.
    final current = locale ?? Localizations.localeOf(context).languageCode;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        for (final MapEntry(key: code, value: name)
            in AppLanguages.names.entries)
          ChoiceChip(
            label: Text(name),
            selected: code == current,
            showCheckmark: false,
            onSelected: (_) => onChanged(code),
          ),
      ],
    );
  }
}

/// Which mantra the counter opens on. A tap chooses it at once, so even a
/// user who skips from here starts on the mantra they picked.
class _MantraPage extends ConsumerWidget {
  const _MantraPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final mantras = ref.watch(mantraListProvider).value ?? const [];
    final active = ref.watch(activeMantraProvider);
    final controller = ref.read(mantraListProvider.notifier);

    final locale = ref.watch(settingsProvider.select((s) => s.localeCode));

    // One scrolling list for the whole page. The header and the seven
    // language chips take real room on a phone; if only the mantras below them
    // scrolled, they would be left a thin strip to move in.
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Insets.page,
        Insets.lg,
        Insets.page,
        Insets.lg,
      ),
      children: [
        _StepHeader(title: l10n.onbMantraTitle, body: l10n.onbMantraBody),
        const SizedBox(height: Insets.md),
        _LanguageToggle(
          locale: locale,
          onChanged: (code) =>
              ref.read(settingsProvider.notifier).setLocale(code),
        ),
        const SizedBox(height: Insets.lg),
        for (final mantra in mantras)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.sm),
            child: Material(
              color: mantra.id == active?.id
                  ? palette.softSaffron
                  : palette.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.md),
                side: BorderSide(
                  color: mantra.id == active?.id
                      ? palette.saffron
                      : palette.divider,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                title: MantraText(
                  mantra,
                  size: 19,
                  maxLines: 2,
                  align: TextAlign.start,
                  color: palette.primaryText,
                ),
                trailing: mantra.id == active?.id
                    ? Icon(Icons.check_circle_rounded, color: palette.saffron)
                    : null,
                onTap: () => controller.setActive(mantra.id),
              ),
            ),
          ),
        const SizedBox(height: Insets.xs),
        AddOwnMantraTile(
          onTap: () async {
            final created = await showMantraEditor(context);
            if (created != null) await controller.setActive(created.id);
          },
        ),
      ],
    );
  }
}

/// How much to chant each day, in malas or in Jaap.
class _GoalPage extends StatelessWidget {
  const _GoalPage({
    required this.goal,
    required this.malaSize,
    required this.onChanged,
  });

  final int goal;
  final int malaSize;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: Column(
        children: [
          const SizedBox(height: Insets.xxxl),
          _StepHeader(title: l10n.onbGoalTitle, body: l10n.onbGoalBody),
          const SizedBox(height: Insets.xxl),
          DailyGoalPicker(
            // The mantra chosen a page back sets what a mala is.
            key: ValueKey(malaSize),
            value: goal,
            malaSize: malaSize,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
