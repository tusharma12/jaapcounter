import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/widgets/async_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../jaap/presentation/jaap_controller.dart';
import '../../jaap/presentation/jaap_state.dart';
import '../../settings/presentation/settings_controller.dart';

/// A pure black screen for chanting with the eyes closed or the phone face
/// up in a dark room.
///
/// Tapping anywhere counts. Nothing is lit except two faint buttons: one
/// shows the mantra and the count, the other leaves. Haptics still mark each
/// bead and each completed mala, so the screen never has to be looked at.
class BlackoutScreen extends ConsumerStatefulWidget {
  const BlackoutScreen({super.key});

  /// Dim, but a clear step up from the black behind them so the two buttons
  /// read as buttons rather than disappearing into the screen.
  static const Color controlColor = Color(0xFFCFCFCF);
  static const Color controlBackground = Color(0xFF232323);
  static const Color textColor = Color(0xFF8A8A8A);

  @override
  ConsumerState<BlackoutScreen> createState() => _BlackoutScreenState();
}

class _BlackoutScreenState extends ConsumerState<BlackoutScreen> {
  bool _showMantra = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _applyWakelock(ref.read(settingsProvider).keepScreenOnInMeditation);
  }

  @override
  void dispose() {
    // Whoever opened this screen restores its own wakelock on return.
    _applyWakelock(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _applyWakelock(bool enable) async {
    try {
      await WakelockPlus.toggle(enable: enable);
    } on Object catch (error, stack) {
      AppLogger.e('Could not change the screen wakelock', error, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final async = ref.watch(jaapControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AsyncView<JaapState>(
          value: async,
          builder: (context, state) => Stack(
            children: [
              // The buttons sit above this, not inside it, so pressing one
              // never counts a bead as well.
              Positioned.fill(
                child: Semantics(
                  button: true,
                  label: l10n.semanticCounter(
                    state.position.beadsInCurrentMala,
                    state.position.malaSize,
                  ),
                  child: GestureDetector(
                    key: const ValueKey('blackout-tap-area'),
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) =>
                        ref.read(jaapControllerProvider.notifier).count(),
                    onVerticalDragEnd: (details) {
                      if ((details.primaryVelocity ?? 0) > 220) {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: _showMantra
                        ? _MantraAndCount(state: state)
                        : const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: Insets.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _BlackoutButton(
                          key: const ValueKey('blackout-show-mantra'),
                          tooltip: _showMantra
                              ? l10n.hideMantra
                              : l10n.showMantra,
                          onTap: () =>
                              setState(() => _showMantra = !_showMantra),
                          icon: _showMantra
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        const SizedBox(width: Insets.xl),
                        _BlackoutButton(
                          key: const ValueKey('blackout-exit'),
                          tooltip: l10n.exitBlackout,
                          onTap: () => Navigator.of(context).maybePop(),
                          icon: Icons.close_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A round button just bright enough to find in the dark, distinct from the
/// black behind it rather than another almost-invisible glyph on it.
class _BlackoutButton extends StatelessWidget {
  const _BlackoutButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: BlackoutScreen.controlBackground,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(Insets.md),
            child: Icon(icon, size: 24, color: BlackoutScreen.controlColor),
          ),
        ),
      ),
    );
  }
}

class _MantraAndCount extends StatelessWidget {
  const _MantraAndCount({required this.state});

  final JaapState state;

  @override
  Widget build(BuildContext context) {
    final position = state.position;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Insets.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.mantra.name,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.mantra(
                size: 26,
                color: BlackoutScreen.textColor,
              ),
            ),
            const SizedBox(height: Insets.xxl),
            Text(
              '${position.beadsInCurrentMala} / ${position.malaSize}',
              style: const TextStyle(
                fontFamily: AppTypography.ui,
                fontSize: 20,
                color: Color(0xFF5E5E5E),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
