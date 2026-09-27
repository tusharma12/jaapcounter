import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/providers.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/mantra_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../jaap/domain/mala_math.dart';
import '../../mantras/domain/mantra.dart';
import '../../mantras/presentation/mantra_controllers.dart';
import '../../sadhana/domain/sadhana.dart';
import '../../sadhana/presentation/sadhana_controllers.dart';

/// Everything the card shows, gathered once.
class ShareCardData {
  const ShareCardData({
    required this.streak,
    required this.lifetimeJaap,
    required this.lifetimeMalas,
    required this.today,
    this.mantra,
    this.sadhana,
    this.sankalpCompletedDays = 0,
  });

  final int streak;
  final int lifetimeJaap;
  final int lifetimeMalas;
  final DateTime today;
  final Mantra? mantra;
  final Sadhana? sadhana;
  final int sankalpCompletedDays;
}

final shareCardDataProvider = FutureProvider.autoDispose<ShareCardData>((
  ref,
) async {
  ref.watch(ledgerRevisionProvider);
  final repo = ref.watch(jaapRepositoryProvider);
  final mantras = await ref.watch(mantraListProvider.future);
  final byId = {for (final m in mantras) m.id: m};
  final totals = await repo.totalsByMantra();
  var malas = 0;
  for (final entry in totals.entries) {
    malas += MalaMath.malasIn(entry.value, byId[entry.key]?.malaSize ?? 108);
  }
  final streak = await ref.watch(streakProvider.future);
  final sadhana = await ref.watch(activeSadhanaProvider.future);
  return ShareCardData(
    streak: streak.current,
    lifetimeJaap: totals.values.fold(0, (a, b) => a + b),
    lifetimeMalas: malas,
    today: ref.watch(clockProvider)(),
    mantra: ref.watch(activeMantraProvider),
    sadhana: sadhana,
    sankalpCompletedDays: sadhana == null
        ? 0
        : await ref.watch(sankalpProgressProvider.future),
  );
});

/// A preview of the card, and a button to send it on.
Future<void> showShareCardSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    expand: true,
    builder: (_) => const _ShareSheet(),
  );
}

class _ShareSheet extends ConsumerStatefulWidget {
  const _ShareSheet();

  @override
  ConsumerState<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<_ShareSheet> {
  final _cardKey = GlobalKey();
  final _buttonKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share(ShareCardData data) async {
    final l10n = AppL10n.of(context);
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      // The card is laid out at 360×450, so this is 1080×1350 (4:5), a size
      // every messaging and social app shows whole.
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'japmala-progress.png'));
      await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);

      // iPad anchors its share popover to the button.
      final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: l10n.shareCardText(data.streak),
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } on Object catch (error, stack) {
      AppLogger.e('Could not share progress card', error, stack);
      if (mounted) showAppSnack(context, l10n.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final data = ref.watch(shareCardDataProvider);

    return SafeArea(
      top: false,
      child: AsyncView<ShareCardData>(
        value: data,
        onRetry: () => ref.invalidate(shareCardDataProvider),
        builder: (context, data) => Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            0,
            Insets.page,
            Insets.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.shareProgress,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Insets.lg),
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.xl),
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: ShareCard(data: data),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Insets.lg),
              FilledButton.icon(
                key: _buttonKey,
                onPressed: _sharing ? null : () => _share(data),
                icon: _sharing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share_rounded),
                label: Text(l10n.share),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The card itself: 360×450 logical pixels, in the user's theme.
class ShareCard extends StatelessWidget {
  const ShareCard({required this.data, super.key});

  final ShareCardData data;

  static const Size size = Size(360, 450);

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final sadhana = data.sadhana;
    final total = sadhana?.durationDays;

    Widget stat(String value, String label) => Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: palette.primaryText,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: palette.secondaryText,
          ),
        ),
      ],
    );

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(Insets.xxl),
      // Square: rounded corners would export as transparency, which chat
      // apps show as black. The preview rounds it instead.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(palette.background, palette.saffron, 0.10)!,
            palette.background,
          ],
        ),
      ),
      child: Column(
        children: [
          // The app's own icon beside its name, so a card passed along a
          // chat still says where it came from.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/branding/app_icon.png',
                width: 28,
                height: 28,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: Insets.sm),
              Flexible(
                child: Text(
                  l10n.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: palette.secondaryText,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          // Whatever the mantra's length and whether a Sankalp is running,
          // the middle shrinks to fit rather than pushing the stats off.
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 56,
                      color: palette.secondary,
                    ),
                    Text(
                      Fmt.count(data.streak, locale),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: palette.primaryText,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: Insets.xs),
                    Text(
                      l10n.shareStreakLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                    if (data.mantra != null) ...[
                      const SizedBox(height: Insets.xl),
                      SizedBox(
                        width: size.width - Insets.xxl * 2,
                        // A fixed width, so a long verse wraps instead of making
                        // the whole middle one line wide and tiny.
                        child: MantraText(
                          data.mantra!,
                          size: 22,
                          maxLines: 2,
                          weight: FontWeight.w600,
                          color: palette.saffron,
                        ),
                      ),
                    ],
                    if (sadhana != null && total != null) ...[
                      const SizedBox(height: Insets.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Insets.md,
                          vertical: Insets.xs,
                        ),
                        decoration: BoxDecoration(
                          color: palette.softSecondary,
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: Text(
                          '${l10n.sankalpDays(total)} · '
                          '${l10n.dayXofY(sadhana.dayNumber(data.today), total)}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: palette.secondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              stat(Fmt.count(data.lifetimeJaap, locale), l10n.totalJaap),
              Container(width: 1, height: 36, color: palette.divider),
              stat(Fmt.count(data.lifetimeMalas, locale), l10n.totalMalas),
            ],
          ),
          const SizedBox(height: Insets.xl),
          Text(
            l10n.tagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}
