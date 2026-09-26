import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimens.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../auto_jaap_controller.dart';
import '../jaap_controller.dart';

/// Lists the voices on the device, each with a play button that chants the
/// current mantra, so the choice is made by ear.
Future<void> showVoicePicker(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _VoicePicker());
}

class _VoicePicker extends ConsumerStatefulWidget {
  const _VoicePicker();

  @override
  ConsumerState<_VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends ConsumerState<_VoicePicker> {
  bool _showAll = false;
  String? _previewing;
  late final SpeechService _speech;

  @override
  void initState() {
    super.initState();
    _speech = ref.read(speechServiceProvider);
  }

  /// Voices likely to read Devanagari well, shown before anything else.
  static bool _isIndian(TtsVoice voice) {
    final locale = voice.locale.replaceAll('_', '-').toLowerCase();
    return voice.language == 'hi' ||
        voice.language == 'pa' ||
        locale == 'en-in';
  }

  Future<void> _preview(TtsVoice? voice) async {
    final mantra = ref.read(jaapControllerProvider).value?.mantra;
    if (mantra == null) return;
    final key = voice?.id ?? '';
    setState(() => _previewing = key);
    final config = ref.read(autoJaapProvider).config.copyWith(voice: voice);
    await ref.read(autoJaapProvider.notifier).chant(mantra, config);
    if (mounted && _previewing == key) setState(() => _previewing = null);
  }

  void _select(TtsVoice? voice) {
    final notifier = ref.read(autoJaapProvider.notifier);
    notifier.updateConfig(
      ref.read(autoJaapProvider).config.copyWith(voice: voice),
    );
  }

  @override
  void dispose() {
    // Leaving the picker mid-preview should not leave the voice talking.
    if (_previewing != null) _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final selected = ref.watch(autoJaapProvider.select((s) => s.config.voice));
    final voicesAsync = ref.watch(ttsVoicesProvider);
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;

    final all = voicesAsync.value ?? const <TtsVoice>[];
    final indian = all.where(_isIndian).toList();
    final shown = _showAll || indian.isEmpty ? all : indian;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              Insets.lg,
              Insets.page,
              Insets.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.autoJaapChooseVoice,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: Insets.sm),
                Text(
                  isIos
                      ? l10n.autoJaapVoiceHintIos
                      : l10n.autoJaapVoiceHintAndroid,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: Insets.page),
            title: Text(l10n.autoJaapShowAllVoices),
            value: _showAll,
            onChanged: (value) => setState(() => _showAll = value),
          ),
          const Divider(height: 1),
          Expanded(
            child: voicesAsync.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : ListView(
                    padding: const EdgeInsets.only(bottom: Insets.xxl),
                    children: [
                      _VoiceTile(
                        title: l10n.autoJaapVoiceDefault,
                        subtitle: null,
                        selected: selected == null,
                        previewing: _previewing == '',
                        onSelect: () => _select(null),
                        onPreview: () => _preview(null),
                      ),
                      if (all.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(Insets.page),
                          child: Text(
                            l10n.autoJaapNoVoices,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.tertiaryText,
                            ),
                          ),
                        ),
                      for (final voice in shown)
                        _VoiceTile(
                          title: voice.name,
                          subtitle: _describe(l10n, voice),
                          selected: selected == voice,
                          previewing: _previewing == voice.id,
                          onSelect: () => _select(voice),
                          onPreview: () => _preview(voice),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static String _describe(AppL10n l10n, TtsVoice voice) {
    final locale = voice.locale.replaceAll('_', '-');
    final language = switch (voice.language) {
      'hi' => l10n.languageHindi,
      'pa' => l10n.languagePunjabi,
      _ when locale.toLowerCase() == 'en-in' => l10n.languageEnglishIndia,
      _ => locale,
    };
    final quality = switch (voice.quality) {
      'premium' => l10n.voiceQualityPremium,
      'enhanced' => l10n.voiceQualityEnhanced,
      _ => null,
    };
    return quality == null ? language : '$language · $quality';
  }
}

class _VoiceTile extends StatelessWidget {
  const _VoiceTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.previewing,
    required this.onSelect,
    required this.onPreview,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final bool previewing;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: Insets.page,
        right: Insets.sm,
      ),
      leading: Icon(
        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: selected ? palette.saffron : palette.tertiaryText,
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      onTap: onSelect,
      trailing: IconButton(
        tooltip: l10n.autoJaapPreview,
        onPressed: onPreview,
        icon: Icon(
          previewing ? Icons.graphic_eq_rounded : Icons.play_circle_outline,
          color: palette.saffron,
        ),
      ),
    );
  }
}
