import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/mantra_text.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../mantras/presentation/mantra_editor_sheet.dart';
import '../../mantras/presentation/mantra_tile.dart';
import '../../sadhana/presentation/daily_goal_picker.dart';
import '../../settings/presentation/settings_controller.dart';

/// Three screens of welcome, then two that make the app the user's own:
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
      precacheImage(
        const AssetImage('assets/branding/app_icon.png'),
        context,
      );
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
      const _MantraPage(),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: Column(
        children: [
          const SizedBox(height: Insets.lg),
          _StepHeader(title: l10n.onbMantraTitle, body: l10n.onbMantraBody),
          const SizedBox(height: Insets.xl),
          Expanded(
            child: ListView(
              children: [
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
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: palette.saffron,
                              )
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
                const SizedBox(height: Insets.lg),
              ],
            ),
          ),
        ],
      ),
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
