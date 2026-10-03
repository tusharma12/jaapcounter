// Generates the App Store and Google Play screenshots from the real app.
//
// Run with tool/screenshots.sh (it sets the font path and output folders).
// Each shot drives the actual router, screens and database, seeded with a
// believable 23-day practice, then frames the capture under a headline.
//
// Output:
//   ios/fastlane/screenshots/en-US/          1320×2868 (6.9" iPhone)
//   android/fastlane/metadata/android/en-US/images/phoneScreenshots/
//                                            1080×1920
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:japmala/app/router.dart';
import 'package:japmala/app/theme/app_theme.dart';
import 'package:japmala/app/theme/app_themes.dart';
import 'package:japmala/core/database/app_database.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/features/jaap/presentation/counter_prefs.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/meditation/presentation/music_playback.dart';
import 'package:japmala/core/services/ambient_chant_service.dart';
import 'package:japmala/core/services/user_music_store.dart';
import 'package:japmala/features/settings/domain/counter_background.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';
import 'package:japmala/l10n/app_localizations.dart';

import '../test/support/test_harness.dart';

/// The phone the app is captured on: iPhone 16 Pro sized, at 3×.
const Size _device = Size(393, 852);
const double _statusBar = 59;
const double _homeIndicator = 34;

/// "Today" in every shot: early on a Sunday morning.
final DateTime _now = DateTime(2026, 9, 27, 6, 40);

/// A headline line is a run of plain and highlighted words.
typedef _Span = (String text, bool highlight);

class _Shot {
  const _Shot({
    required this.file,
    required this.headline,
    required this.sub,
    required this.capture,
    this.darkStatusBar = false,
    this.badge,
    this.card,
    this.cardAt = _CardAt.top,
  });

  final String file;
  final List<_Span> headline;
  final String sub;

  /// Drives the app to the screen to capture.
  final Future<void> Function(WidgetTester, ProviderContainer, GoRouter)
  capture;

  /// White status-bar glyphs, for screens that are dark themselves.
  final bool darkStatusBar;
  final String? badge;

  /// A floating card that spells out the feature, over the phone.
  final Widget Function(double scale)? card;
  final _CardAt cardAt;
}

final _shots = <_Shot>[
  _Shot(
    file: '01_counter',
    badge: 'No ads  •  Private  •  Works offline',
    headline: [('Never lose count\nof your ', false), ('Naam Jap', true)],
    sub: 'Tap anywhere. Every bead, counted.',
    capture: (tester, c, router) async {},
  ),
  _Shot(
    file: '02_habit',
    headline: [('Tap Anywhere.\n', false), ('Every Bead Counts.', true)],
    sub: 'A real 108-bead mala fills as you chant',
    card: _todayCard,
    cardAt: _CardAt.bottom,
    // The counter screen, mid-session: this morning's jaap already underway.
    capture: (tester, c, router) async {},
  ),
  _Shot(
    file: '03_streak',
    headline: [('Build a\n', false), ('Daily Habit', true)],
    sub: 'Streaks, charts and every day you chanted',
    card: _streakCard,
    cardAt: _CardAt.bottom,
    capture: (tester, c, router) async {
      router.go('/progress');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '04_music',
    darkStatusBar: true,
    headline: [('Chant with\n', false), ('Calming Music', true)],
    sub: 'Soothing sounds, or record your own',
    card: _musicCard,
    // Meditation with a sound playing.
    capture: (tester, c, router) async {
      // The deep night theme, so the music card sits on a calm scene.
      await c.read(settingsProvider.notifier).setTheme(AppThemeId.meditative);
      router.push('/meditation');
      await _settle(tester);
      await c
          .read(musicPlaybackProvider.notifier)
          .choose(AmbientChantService.chants[1].id, play: true);
      await _settle(tester);
    },
  ),
  _Shot(
    file: '05_mantras',
    headline: [('21 Sacred Mantras\n', true), ('or Your Own', false)],
    sub: 'Add any mantra, in any script',
    card: _mantraCard,
    cardAt: _CardAt.bottom,
    capture: (tester, c, router) async {
      router.push('/mantras');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '06_sankalp',
    headline: [('Take a ', false), ('Sankalp', true), ('.\nKeep It.', false)],
    sub: 'An 11, 21 or 40-day vow with a daily goal',
    card: _sankalpCard,
    cardAt: _CardAt.bottom,
    capture: (tester, c, router) async {
      router.push('/sadhana');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '07_blackout',
    darkStatusBar: true,
    headline: [('Chant with Your\n', false), ('Eyes Closed', true)],
    sub: 'Pure black. Nothing lights the room.',
    card: _blackoutCard,
    cardAt: _CardAt.bottom,
    capture: (tester, c, router) async {
      router.push('/blackout');
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('blackout-show-mantra')));
      await _settle(tester);
    },
  ),
  _Shot(
    file: '08_themes',
    darkStatusBar: true,
    headline: [('Choose Your\n', false), ('Sacred Space', true)],
    sub: '13 themes, bead mala, falling mantra',
    card: _themesCard,
    cardAt: _CardAt.bottom,
    capture: (tester, c, router) async {
      await c.read(settingsProvider.notifier).setTheme(AppThemeId.meditative);
      await c
          .read(settingsProvider.notifier)
          .setBackground(CounterBackground.cosmos);
      // Off by default; this shot exists to show it off.
      await c.read(settingsProvider.notifier).setFallingMantra(true);
      await _settle(tester);
      // Release a shower of mantras and catch it mid-fall.
      final jaap = c.read(jaapControllerProvider.notifier);
      for (var i = 0; i < 7; i++) {
        jaap.count();
        await tester.pump(const Duration(milliseconds: 260));
      }
      await tester.pump(const Duration(milliseconds: 900));
    },
  ),
];

class _SilentChants implements AmbientChantService {
  String? _playing;

  @override
  String? get playing => _playing;

  @override
  Future<void> play(AmbientChant chant) async => _playing = chant.id;

  @override
  Future<void> stop() async => _playing = null;

  @override
  Future<void> fadeOutAndStop({Duration fade = const Duration(seconds: 4)}) =>
      stop();

  @override
  Future<void> dispose() async {}
}

Future<void> _settle(WidgetTester tester) async {
  // Never pumpAndSettle: the counter's animations would keep it spinning.
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The language this run draws, from SHOT_LOCALE (tool/screenshots.sh runs the
/// test once per language); all of them when unset.
final String? _runLocale = Platform.environment['SHOT_LOCALE'];

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) throw StateError('Run via tool/screenshots.sh');
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File(
            '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
          ).readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
  // One language per run, because the script font stands in as
  // 'NotoSansDevanagari' (the app's fallback family) and a family can only be
  // registered once. Devanagari itself is the app's bundled font.
  final script = _scriptFonts[_runLocale];
  for (final f in Directory('assets/fonts').listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    final isNoto = name.startsWith('Noto');
    if (isNoto && script != null) continue;
    final loader = FontLoader(isNoto ? 'NotoSansDevanagari' : 'Inter')
      ..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
    await loader.load();
  }
  // Each script also under its own name, for cards that mix scripts.
  for (final (family, file) in [
    ('NotoSansDevanagariReal', 'assets/fonts/NotoSansDevanagari-Regular.ttf'),
    ('NotoSansGujarati', 'screenshots/fonts/NotoSansGujarati-Regular.ttf'),
    ('NotoSansGurmukhi', 'screenshots/fonts/NotoSansGurmukhi-Regular.ttf'),
    ('NotoSansTamil', 'screenshots/fonts/NotoSansTamil-Regular.ttf'),
    ('NotoSansTelugu', 'screenshots/fonts/NotoSansTelugu-Regular.ttf'),
  ]) {
    final loader = FontLoader(family)
      ..addFont(
        Future.value(ByteData.sublistView(File(file).readAsBytesSync())),
      );
    await loader.load();
  }
  if (script != null) {
    final loader = FontLoader('NotoSansDevanagari');
    for (final weight in ['Regular', 'Bold']) {
      final file = File('screenshots/fonts/$script-$weight.ttf');
      loader.addFont(
        Future.value(ByteData.sublistView(file.readAsBytesSync())),
      );
    }
    await loader.load();
  }
}

/// 23 days in a row of steady Jaap, a gap, and some earlier practice.
Future<ProviderContainer> _seededApp() async {
  final clock = TestClock(_now);
  final music = Directory.systemTemp.createTempSync('shotmusic');
  final container = await createTestContainer(
    clock: clock,
    overrides: [
      // Silent: the shots show the music controls, nothing needs to play.
      ambientChantProvider.overrideWithValue(_SilentChants()),
      userMusicStoreProvider.overrideWithValue(
        UserMusicStore(baseDirectory: () async => music),
      ),
    ],
  );
  // In-memory databases are shared within the test isolate, so each shot
  // starts from an empty one rather than piling onto the last.
  await AppDatabase.clearAll(container.read(databaseProvider));
  final settings = container.read(settingsProvider.notifier);
  await settings.completeOnboarding();
  await settings.setHaptics(false);
  container.read(counterHintSeenProvider.notifier).markSeen();

  final repo = container.read(jaapRepositoryProvider);
  const streakDays = 23;
  // Mostly the 10-mala goal or more; a few lighter days keep it believable.
  const daily = [
    1188,
    1080,
    1296,
    1080,
    1404,
    1080,
    1188,
    1620,
    1080,
    1296,
    1188,
    1080,
    1512,
    1080,
    1188,
    1296,
    1080,
    1404,
    1188,
    1080,
    1296,
    1188,
  ];
  for (var d = streakDays - 1; d >= 1; d--) {
    clock.set(_now.subtract(Duration(days: d)).copyWith(hour: 6));
    await repo.addBeads(
      mantraId: 'builtin.ram',
      delta: daily[(streakDays - 1 - d) % daily.length],
    );
    if (d % 4 == 0) {
      await repo.addBeads(mantraId: 'builtin.radha', delta: 216);
    }
  }
  for (final d in [26, 27, 29, 30, 33, 34, 35]) {
    clock.set(_now.subtract(Duration(days: d)).copyWith(hour: 7));
    await repo.addBeads(mantraId: 'builtin.ram', delta: 540);
  }

  // A 40-day Sankalp begun on the first day of the streak.
  await container
      .read(sadhanaRepositoryProvider)
      .create(
        mantraId: 'builtin.ram',
        dailyGoal: 1080,
        durationDays: 40,
        startAt: _now.subtract(const Duration(days: streakDays - 1)),
      );

  // This morning: five malas and part of the sixth.
  clock.set(_now);
  await repo.addBeads(mantraId: 'builtin.ram', delta: 612);
  container.read(ledgerRevisionProvider.notifier).bump();
  return container;
}

/// Captures the app itself at device size, 3×.
Future<Uint8List> _captureApp(
  WidgetTester tester,
  _Shot shot,
  Locale locale,
) async {
  tester.view.physicalSize = _device * 3;
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(
    top: _statusBar * 3,
    bottom: _homeIndicator * 3,
  );
  tester.view.viewPadding = const FakeViewPadding(
    top: _statusBar * 3,
    bottom: _homeIndicator * 3,
  );

  final container = await _seededApp();
  await container.read(jaapControllerProvider.future);
  final router = container.read(routerProvider);
  const key = ValueKey('app');

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final settings = ref.watch(settingsProvider);
            final fixed = settings.themeId != AppThemeId.system;
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              locale: locale,
              theme: fixed
                  ? AppTheme.forId(settings.themeId)
                  : AppTheme.light(),
              darkTheme: fixed
                  ? AppTheme.forId(settings.themeId)
                  : AppTheme.dark(),
              themeMode: settings.themeMode,
              localizationsDelegates: const [
                AppL10n.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppL10n.supportedLocales,
            );
          },
        ),
      ),
    ),
  );
  await _settle(tester);
  await shot.capture(tester, container, router);

  late Uint8List bytes;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = data!.buffer.asUint8List();
  });
  await container.read(jaapControllerProvider.notifier).flushPendingWrites();
  // Unmount so the next shot starts from a clean tree.
  await tester.pumpWidget(const SizedBox());
  return bytes;
}

/// Frames a capture under its headline and writes the PNG.
Future<void> _compose(
  WidgetTester tester,
  _Shot shot,
  ui.Image screen, {
  required Size canvas,
  required String path,
  required String code,
}) async {
  tester.view.physicalSize = canvas * 3;
  tester.view.devicePixelRatio = 3;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
  const key = ValueKey('canvas');

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: _StoreCanvas(
          shot: shot,
          screen: screen,
          size: canvas,
          code: code,
        ),
      ),
    ),
  );
  await tester.pump();

  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

class _StoreCanvas extends StatelessWidget {
  const _StoreCanvas({
    required this.shot,
    required this.screen,
    required this.size,
    this.code = 'en',
  });

  final _Shot shot;
  final ui.Image screen;
  final Size size;
  final String code;

  static const _cream = Color(0xFFFFF4E2);
  static const _saffron = Color(0xFFFFB23F);

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final h = size.height;
    final tall = h / w > 2;
    // Tamil and Telugu letters are wider and taller, so they are set smaller.
    final headlineScale = const {'ta': 0.76, 'te': 0.86}[code] ?? 1.0;
    final headlineSize = w * (tall ? 0.092 : 0.082) * headlineScale;
    final phoneTop = h * (tall ? 0.268 : 0.305);
    // The phone runs a little off the bottom edge, as if held up to you.
    final phoneHeight = h - phoneTop + h * 0.035;
    final phoneWidth = phoneHeight * (_device.width / _device.height);

    // Every shot shares the maroon night canvas, lit from behind the phone.
    const background = [
      Color(0xFF2A0A04),
      Color(0xFF5A1A07),
      Color(0xFF8A3A0C),
    ];
    const highlightColor = _saffron;
    const headlineColor = _cream;
    final subColor = _cream.withValues(alpha: 0.78);
    const badgeColor = _saffron;
    // Every non-English run loads its script's font as 'NotoSansDevanagari',
    // the family the app already falls back to (see _loadFonts).
    final textFont = code == 'en' ? 'Inter' : 'NotoSansDevanagari';
    final copy = _headlines[shot.file]?[code];
    final headline = copy == null ? shot.headline : _spans(copy.$1);
    final sub = copy?.$2 ?? shot.sub;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: background,
                ),
              ),
            ),
          ),
          // A soft glow behind the phone, the way a diya lights a room.
          Positioned(
            left: -w * 0.3,
            right: -w * 0.3,
            top: phoneTop - w * 0.25,
            height: w * 1.3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    _saffron.withValues(alpha: 0.28),
                    _saffron.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: w * 0.07,
            right: w * 0.07,
            top: h * (tall ? 0.045 : 0.035),
            child: Column(
              children: [
                if (shot.badge != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: w * 0.013,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: badgeColor.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Text(
                      shot.badge!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: w * 0.031,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  SizedBox(height: w * 0.035),
                ] else
                  SizedBox(height: w * 0.02),
                Text.rich(
                  TextSpan(
                    children: [
                      for (final (text, highlight) in headline)
                        TextSpan(
                          text: text,
                          style: TextStyle(
                            color: highlight ? highlightColor : headlineColor,
                          ),
                        ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: textFont,
                    fontFamilyFallback: const ["Inter"],
                    fontSize: headlineSize,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                    letterSpacing: -headlineSize * 0.025,
                  ),
                ),
                SizedBox(height: w * 0.03),
                Text(
                  sub,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: textFont,
                    fontFamilyFallback: const ["Inter"],
                    fontSize: w * 0.041,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: phoneTop,
            left: (w - phoneWidth) / 2,
            width: phoneWidth,
            height: phoneHeight,
            child: _Phone(screen: screen, darkStatusBar: shot.darkStatusBar),
          ),
          if (shot.card case final card?)
            Positioned(
              top: shot.cardAt == _CardAt.top ? phoneTop - h * 0.045 : null,
              bottom: shot.cardAt == _CardAt.bottom ? h * 0.035 : null,
              left: w * 0.06,
              right: w * 0.06,
              child: (() {
                _cardCode = code;
                return card(w / 440);
              })(),
            ),
        ],
      ),
    );
  }
}

/// Where a shot's feature card floats: over the top of the phone, or over
/// its bottom edge.
enum _CardAt { top, bottom }

const _cInk = Color(0xFF241608);
const _cMuted = Color(0xFF7A6552);
const _cRust = Color(0xFFD9600F);
const _cSaffron = Color(0xFFF5A623);
const _cFaint = Color(0xFFF0DCC4);
const _cChip = Color(0xFFFFF1DF);
const _cChipLine = Color(0xFFF3D2A8);

TextStyle _cardText(
  double s,
  double size, {
  FontWeight weight = FontWeight.w600,
  Color color = _cInk,
  double spacing = 0,
  String? family,
}) => TextStyle(
  fontFamily: family ?? (_cardCode == 'en' ? 'Inter' : 'NotoSansDevanagari'),
  fontFamilyFallback: const ['Inter', 'NotoSansDevanagariReal'],
  fontSize: size * s,
  fontWeight: weight,
  color: color,
  letterSpacing: spacing,
  decoration: TextDecoration.none,
);

/// The white card every feature sits on.
Widget _cardShell(double s, List<Widget> children) => Container(
  padding: EdgeInsets.fromLTRB(18 * s, 18 * s, 18 * s, 16 * s),
  decoration: BoxDecoration(
    color: const Color(0xFFFFFBF5),
    borderRadius: BorderRadius.circular(26 * s),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 36 * s,
        offset: Offset(0, 16 * s),
      ),
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  ),
);

/// Icon disc, small caps eyebrow, bold title, and an optional trailing bit.
Widget _cardHeader(
  double s, {
  required IconData icon,
  required String eyebrow,
  required String title,
  Widget? trailing,
}) => Row(
  children: [
    Container(
      width: 46 * s,
      height: 46 * s,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFB23F), Color(0xFFD9600F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 25 * s),
    ),
    SizedBox(width: 12 * s),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: _cardText(
              s,
              10.5,
              weight: FontWeight.w700,
              color: _cRust,
              spacing: _cardCode == 'en' ? 1.2 : 0,
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _cardText(s, 16, weight: FontWeight.w700),
          ),
        ],
      ),
    ),
    ?trailing,
  ],
);

Widget _cardChip(double s, String label, {IconData? icon, String? family}) =>
    Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        color: _cChip,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _cChipLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13 * s, color: _cRust),
            SizedBox(width: 4 * s),
          ],
          Text(label, style: _cardText(s, 11.5, family: family)),
        ],
      ),
    );

Widget _cardChips(double s, List<Widget> chips) =>
    Wrap(spacing: 6 * s, runSpacing: 6 * s, children: chips);

Widget _cardBar(double s, double value) => ClipRRect(
  borderRadius: BorderRadius.circular(100),
  child: SizedBox(
    height: 8 * s,
    child: Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: _cFaint),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB23F), Color(0xFFD9600F)],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

Widget _roundButton(double s, IconData icon) => Container(
  width: 38 * s,
  height: 38 * s,
  decoration: const BoxDecoration(shape: BoxShape.circle, color: _cSaffron),
  child: Icon(icon, color: _cInk, size: 22 * s),
);

Widget _gap(double s, [double h = 14]) => SizedBox(height: h * s);

// The numbers below match the seeded practice in _seededApp: 612 of a 1,080
// goal this morning, a 22-day streak, day 23 of a 40-day Sankalp.

Widget _todayCard(double s) => _cardShell(s, [
  _cardHeader(
    s,
    icon: Icons.touch_app_rounded,
    eyebrow: _ct('todayEyebrow'),
    title: _ct('todayTitle'),
    trailing: _cardChip(s, _ct('days'), icon: Icons.local_fire_department),
  ),
  _gap(s),
  _cardBar(s, 612 / 1080),
  _gap(s, 6),
  Text(_ct('todaySub'), style: _cardText(s, 11.5, color: _cMuted)),
  _gap(s, 12),
  _cardChips(s, [
    _cardChip(s, _ct('haptic'), icon: Icons.vibration_rounded),
    _cardChip(s, _ct('undo'), icon: Icons.undo_rounded),
  ]),
]);

Widget _streakCard(double s) {
  final days = _ct('wk').split(' ');
  return _cardShell(s, [
    _cardHeader(
      s,
      icon: Icons.local_fire_department_rounded,
      eyebrow: _ct('streakEyebrow'),
      title: _ct('streakTitle'),
    ),
    _gap(s),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final d in days)
          Column(
            children: [
              Container(
                width: 32 * s,
                height: 32 * s,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFB23F), Color(0xFFD9600F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18 * s,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(d, style: _cardText(s, 10.5, color: _cMuted)),
            ],
          ),
      ],
    ),
    _gap(s, 12),
    _cardChips(s, [
      _cardChip(s, _ct('charts'), icon: Icons.bar_chart_rounded),
      _cardChip(s, _ct('reminders'), icon: Icons.notifications_rounded),
    ]),
  ]);
}

Widget _musicCard(double s) {
  // A fixed, hand-shaped waveform: louder in the middle, never flat.
  const bars = [
    .30, .55, .80, .45, .95, .60, .75, 1.0, .50, .85, .65, .40, .90, .55, //
    .70, .35, .80, .60, .95, .45, .65, .30, .55, .75, .40, .60, .35, .50,
  ];
  return _cardShell(s, [
    _cardHeader(
      s,
      icon: Icons.music_note_rounded,
      eyebrow: _ct('nowPlaying'),
      title: _ct('track1'),
      trailing: _roundButton(s, Icons.pause_rounded),
    ),
    _gap(s),
    SizedBox(
      height: 30 * s,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < bars.length; i++)
            Container(
              width: 4.5 * s,
              height: 30 * s * bars[i],
              decoration: BoxDecoration(
                // Played part in saffron, the rest faint.
                color: i < 17 ? _cSaffron : _cFaint,
                borderRadius: BorderRadius.circular(4 * s),
              ),
            ),
        ],
      ),
    ),
    _gap(s),
    _cardChips(s, [
      _cardChip(s, _ct('track2')),
      _cardChip(s, _ct('track3')),
      _cardChip(s, _ct('yourRec'), icon: Icons.mic_rounded),
    ]),
  ]);
}

Widget _mantraCard(double s) => _cardShell(s, [
  _cardHeader(
    s,
    icon: Icons.add_rounded,
    eyebrow: _ct('addOwn'),
    title: _ct('mantra'),
    trailing: _roundButton(s, Icons.check_rounded),
  ),
  _gap(s),
  _cardChips(s, [
    _cardChip(s, 'ॐ नमः शिवाय', family: 'NotoSansDevanagariReal'),
    _cardChip(s, 'ਵਾਹਿਗੁਰੂ', family: 'NotoSansGurmukhi'),
    _cardChip(s, 'ராம ராம', family: 'NotoSansTamil'),
    _cardChip(s, 'శ్రీ రామ', family: 'NotoSansTelugu'),
    _cardChip(s, 'જય શ્રી કૃષ્ણ', family: 'NotoSansGujarati'),
  ]),
]);

Widget _sankalpCard(double s) => _cardShell(s, [
  _cardHeader(
    s,
    icon: Icons.flag_rounded,
    eyebrow: _ct('sankalpEyebrow'),
    title: _ct('dayOf'),
    trailing: _cardChip(s, _ct('malasADay')),
  ),
  _gap(s),
  // One dot a day: kept days filled, today ringed, the rest to come.
  Wrap(
    spacing: 5.2 * s,
    runSpacing: 6 * s,
    children: [
      for (var d = 1; d <= 40; d++)
        Container(
          width: 12 * s,
          height: 12 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: d < 23 ? _cSaffron : _cFaint,
            border: d == 23 ? Border.all(color: _cRust, width: 2.5 * s) : null,
          ),
        ),
    ],
  ),
  _gap(s, 12),
  Text(_ct('kept'), style: _cardText(s, 11.5, color: _cMuted)),
]);

Widget _blackoutCard(double s) => _cardShell(s, [
  _cardHeader(
    s,
    icon: Icons.dark_mode_rounded,
    eyebrow: _ct('blackoutEyebrow'),
    title: _ct('blackoutTitle'),
  ),
  _gap(s),
  _cardChips(s, [
    _cardChip(s, _ct('tap'), icon: Icons.touch_app_rounded),
    _cardChip(s, _ct('vol'), icon: Icons.volume_up_rounded),
    _cardChip(s, _ct('buzz'), icon: Icons.vibration_rounded),
    _cardChip(s, _ct('longPress'), icon: Icons.bolt_rounded),
  ]),
]);

Widget _themesCard(double s) {
  final themes = [for (final id in AppThemeId.values) ?AppThemeSpec.of(id)];
  return _cardShell(s, [
    _cardHeader(
      s,
      icon: Icons.palette_rounded,
      eyebrow: _ct('themesEyebrow'),
      title: _ct('themesTitle'),
    ),
    _gap(s),
    Wrap(
      spacing: 4.6 * s,
      runSpacing: 6 * s,
      children: [
        for (final t in themes)
          Container(
            width: 22.5 * s,
            height: 22.5 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.swatch,
              border: Border.all(color: _cChipLine, width: 1.2),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 9 * s,
              height: 9 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.palette.saffron,
              ),
            ),
          ),
      ],
    ),
    _gap(s, 12),
    _cardChips(s, [
      _cardChip(s, _ct('beads'), icon: Icons.circle_outlined),
      _cardChip(s, _ct('falling'), icon: Icons.south_rounded),
      _cardChip(s, _ct('photo'), icon: Icons.image_rounded),
    ]),
  ]);
}

/// A plain modern iPhone: black bezel, rounded screen, dynamic island.
class _Phone extends StatelessWidget {
  const _Phone({required this.screen, required this.darkStatusBar});

  final ui.Image screen;
  final bool darkStatusBar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / _device.width;
        final bezel = 11 * scale;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(60 * scale),
            border: Border.all(color: const Color(0xFF3A3A3C), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 40 * scale,
                offset: Offset(0, 18 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(bezel),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50 * scale),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RawImage(image: screen, fit: BoxFit.cover),
                  // The status bar and island, drawn at device scale.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: _statusBar * scale,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _device.width,
                        height: _statusBar,
                        child: _StatusBar(dark: darkStatusBar),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : Colors.black;
    return Stack(
      children: [
        Positioned(
          left: 0,
          width: 150,
          top: 18,
          child: Center(
            child: Text(
              '9:41',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
        Positioned(
          top: 11,
          left: (_device.width - 126) / 2,
          width: 126,
          height: 37,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          right: 0,
          width: 150,
          top: 19,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_cellular_alt_rounded, size: 18, color: color),
              const SizedBox(width: 5),
              Icon(Icons.wifi_rounded, size: 18, color: color),
              const SizedBox(width: 5),
              RotatedBox(
                quarterTurns: 1,
                child: Icon(Icons.battery_full_rounded, size: 22, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Google Play's 1024×500 banner: icon, name and promise on the maroon.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.icon});

  final ui.Image icon;

  @override
  Widget build(BuildContext context) {
    const cream = _StoreCanvas._cream;
    const saffron = _StoreCanvas._saffron;
    return SizedBox(
      width: 1024,
      height: 500,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A0A04), Color(0xFF5A1A07), Color(0xFF8A3A0C)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 72),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(64),
                child: RawImage(image: icon, width: 280, height: 280),
              ),
              const SizedBox(width: 56),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JaapMitra',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 58,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        letterSpacing: -1.2,
                        color: cream,
                      ),
                    ),
                    Text(
                      'Bhakti Ka Sathi,\nHar Din',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 58,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1.2,
                        color: saffron,
                      ),
                    ),
                    SizedBox(height: 22),
                    Text(
                      'Your digital jap mala, always with you',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: Color(0xC7FFF4E2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _featureGraphic(WidgetTester tester, String path) async {
  late ui.Image icon;
  await tester.runAsync(() async {
    icon = await decodeImageFromList(
      File('appstore_assets/appicon-fullbleed.png').readAsBytesSync(),
    );
  });
  tester.view.physicalSize = const Size(1024, 500);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
  const key = ValueKey('feature');
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: _FeatureGraphic(icon: icon),
      ),
    ),
  );
  await tester.pump();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

/// One localized run: which screens, which text, where it lands on disk.
class _StoreLocale {
  const _StoreLocale(this.code, this.iosDir, this.playDir);
  final String code;
  final String iosDir;
  final String playDir;
}

const _locales = [
  _StoreLocale('en', 'en-US', 'en-US'),
  _StoreLocale('hi', 'hi', 'hi-IN'),
  _StoreLocale('mr', 'mr-IN', 'mr-IN'),
  _StoreLocale('gu', 'gu-IN', 'gu'),
  _StoreLocale('pa', 'pa-IN', 'pa'),
  _StoreLocale('ta', 'ta-IN', 'ta-IN'),
  _StoreLocale('te', 'te-IN', 'te-IN'),
];

/// The script font each language is drawn in; Devanagari is bundled with the
/// app, the rest live beside this test.
const _scriptFonts = {
  'gu': 'NotoSansGujarati',
  'pa': 'NotoSansGurmukhi',
  'ta': 'NotoSansTamil',
  'te': 'NotoSansTelugu',
};

/// Headline (`*` marks the highlighted run) and sub-line per shot and language.
const _headlines = <String, Map<String, (String, String)>>{
  '02_habit': {
    'hi': (
      'कहीं भी टैप करें।\n*हर मनका गिना जाए।*',
      'जप के साथ 108 मनकों की असली माला भरती है',
    ),
    'mr': (
      'कुठेही टॅप करा.\n*प्रत्येक मणी मोजा.*',
      'जप करताना 108 मण्यांची खरी माळ भरते',
    ),
    'gu': (
      'ગમે ત્યાં ટૅપ કરો.\n*દરેક મણકો ગણાય.*',
      'જપ સાથે 108 મણકાની સાચી માળા ભરાય છે',
    ),
    'pa': (
      'ਕਿਤੇ ਵੀ ਟੈਪ ਕਰੋ।\n*ਹਰ ਮਣਕਾ ਗਿਣੋ।*',
      'ਜਪ ਨਾਲ 108 ਮਣਕਿਆਂ ਦੀ ਅਸਲੀ ਮਾਲਾ ਭਰਦੀ ਹੈ',
    ),
    'ta': (
      'ஒவ்வொரு மணியும்\n*எண்ணப்படும்*',
      'ஜபிக்கும்போது 108 மணி மாலை நிரம்பும்',
    ),
    'te': (
      'ట్యాప్ చేయండి.\n*ప్రతి పూసా లెక్కే*',
      'జపంతో 108 పూసల మాల నిండుతుంది',
    ),
  },
  '03_streak': {
    'hi': ('रोज़ की\n*आदत बनाएं*', 'लगातार दिन, चार्ट और हर जप का हिसाब'),
    'mr': ('रोजची\n*सवय घडवा*', 'सातत्य, आलेख आणि जपाचा प्रत्येक दिवस'),
    'gu': ('રોજની\n*ટેવ બનાવો*', 'સાતત્ય, ચાર્ટ અને જપનો દરેક દિવસ'),
    'pa': ('ਰੋਜ਼ ਦੀ\n*ਆਦਤ ਬਣਾਓ*', 'ਲਗਾਤਾਰ ਦਿਨ, ਚਾਰਟ ਅਤੇ ਜਪ ਦਾ ਹਰ ਦਿਨ'),
    'ta': (
      'தினசரிப்\n*பழக்கம்*',
      'தொடர்ச்சி, வரைபடங்கள், ஜபித்த ஒவ்வொரு நாளும்',
    ),
    'te': ('రోజువారీ\n*అలవాటు*', 'క్రమం, చార్టులు, జపించిన ప్రతి రోజు'),
  },
  '04_music': {
    'hi': (
      'जप करें\n*शांत संगीत* के साथ',
      'सुकून भरी ध्वनियाँ, या अपनी रिकॉर्डिंग',
    ),
    'mr': ('जप करा\n*शांत संगीतासह*', 'सुखद ध्वनी, किंवा स्वतःचे रेकॉर्डिंग'),
    'gu': (
      'જપ કરો\n*શાંત સંગીત સાથે*',
      'સુખદ અવાજો, અથવા તમારું પોતાનું રેકોર્ડિંગ',
    ),
    'pa': ('ਜਪ ਕਰੋ\n*ਸ਼ਾਂਤ ਸੰਗੀਤ ਨਾਲ*', 'ਸੁਖਦ ਧੁਨਾਂ, ਜਾਂ ਆਪਣੀ ਰਿਕਾਰਡਿੰਗ'),
    'ta': (
      '*அமைதியான இசை*\nஉடன் ஜபம்',
      'இதமான ஒலிகள், அல்லது உங்கள் சொந்தப் பதிவு',
    ),
    'te': (
      '*ప్రశాంత సంగీతంతో*\nజపం చేయండి',
      'హాయైన శబ్దాలు, లేదా మీ సొంత రికార్డింగ్',
    ),
  },
  '05_mantras': {
    'hi': (
      '*21 पवित्र मंत्र*\nया अपना खुद का',
      'कोई भी मंत्र, किसी भी लिपि में जोड़ें',
    ),
    'mr': (
      '*21 पवित्र मंत्र*\nकिंवा स्वतःचा',
      'कोणताही मंत्र, कोणत्याही लिपीत जोडा',
    ),
    'gu': (
      '*21 પવિત્ર મંત્રો*\nઅથવા તમારો પોતાનો',
      'કોઈપણ મંત્ર, કોઈપણ લિપિમાં ઉમેરો',
    ),
    'pa': ('*21 ਪਵਿੱਤਰ ਮੰਤਰ*\nਜਾਂ ਆਪਣਾ', 'ਕੋਈ ਵੀ ਮੰਤਰ, ਕਿਸੇ ਵੀ ਲਿਪੀ ਵਿੱਚ ਜੋੜੋ'),
    'ta': (
      '*21 புனித மந்திரங்கள்*\nஅல்லது சொந்தம்',
      'எந்த மந்திரமும், எந்த எழுத்திலும் சேர்க்கலாம்',
    ),
    'te': (
      '*21 పవిత్ర మంత్రాలు*\nలేదా మీ సొంతం',
      'ఏ మంత్రాన్నైనా, ఏ లిపిలోనైనా చేర్చండి',
    ),
  },
  '06_sankalp': {
    'hi': (
      'एक *संकल्प* लें।\nउसे निभाएं।',
      '11, 21 या 40 दिन का संकल्प, रोज़ के लक्ष्य के साथ',
    ),
    'mr': (
      'एक *संकल्प* घ्या.\nतो निभवा.',
      '11, 21 किंवा 40 दिवसांचा संकल्प, रोजच्या ध्येयासह',
    ),
    'gu': (
      'એક *સંકલ્પ* લો.\nતેને નિભાવો.',
      '11, 21 કે 40 દિવસનો સંકલ્પ, રોજના લક્ષ્ય સાથે',
    ),
    'pa': (
      'ਇੱਕ *ਸੰਕਲਪ* ਲਓ।\nਇਸ ਨੂੰ ਨਿਭਾਓ।',
      '11, 21 ਜਾਂ 40 ਦਿਨਾਂ ਦਾ ਸੰਕਲਪ, ਰੋਜ਼ ਦੇ ਟੀਚੇ ਨਾਲ',
    ),
    'ta': (
      'ஒரு *சங்கல்பம்*\nஎடுங்கள்',
      '11, 21 அல்லது 40 நாள் உறுதி, தினசரி இலக்குடன்',
    ),
    'te': (
      'ఒక *సంకల్పం* చేయండి.\nనిలబెట్టుకోండి.',
      '11, 21 లేదా 40 రోజుల దీక్ష, రోజువారీ లక్ష్యంతో',
    ),
  },
  '07_blackout': {
    'hi': (
      'आंखें बंद करके\n*जप करें*',
      'पूरी काली स्क्रीन। कमरे में रोशनी नहीं।',
    ),
    'mr': ('डोळे मिटून\n*जप करा*', 'पूर्ण काळी स्क्रीन. खोलीत प्रकाश नाही.'),
    'gu': (
      'આંખો બંધ કરીને\n*જપ કરો*',
      'સંપૂર્ણ કાળી સ્ક્રીન. રૂમમાં પ્રકાશ નહીં.',
    ),
    'pa': (
      'ਅੱਖਾਂ ਬੰਦ ਕਰ ਕੇ\n*ਜਪ ਕਰੋ*',
      'ਪੂਰੀ ਕਾਲੀ ਸਕ੍ਰੀਨ। ਕਮਰੇ ਵਿੱਚ ਰੌਸ਼ਨੀ ਨਹੀਂ।',
    ),
    'ta': (
      'கண்களை மூடி\n*ஜபம் செய்யுங்கள்*',
      'முழுக் கருப்பு. அறையில் ஒளி இல்லை.',
    ),
    'te': (
      'కళ్ళు మూసుకుని\n*జపం చేయండి*',
      'పూర్తిగా నలుపు. గదిలో వెలుతురు లేదు.',
    ),
  },
  '08_themes': {
    'hi': ('अपना *पवित्र स्थान*\nचुनें', '13 थीम, माला के मनके, गिरता मंत्र'),
    'mr': ('तुमचे *पवित्र स्थान*\nनिवडा', '13 थीम, माळेचे मणी, पडणारा मंत्र'),
    'gu': (
      'તમારું *પવિત્ર સ્થાન*\nપસંદ કરો',
      '13 થીમ, માળાના મણકા, પડતો મંત્ર',
    ),
    'pa': ('ਆਪਣੀ *ਪਵਿੱਤਰ ਥਾਂ*\nਚੁਣੋ', '13 ਥੀਮ, ਮਾਲਾ ਦੇ ਮਣਕੇ, ਡਿੱਗਦਾ ਮੰਤਰ'),
    'ta': ('உங்கள்\n*புனித இடம்*', '13 தீம்கள், மணி மாலை, விழும் மந்திரம்'),
    'te': (
      'మీ *పవిత్ర స్థలాన్ని*\nఎంచుకోండి',
      '13 థీమ్‌లు, పూసల మాల, పడే మంత్రం',
    ),
  },
};

/// Words on the feature cards, per language.
const _cardCopy = <String, Map<String, String>>{
  'en': {
    'track1': 'Morning on the High Plateau',
    'track2': 'Still Waters',
    'track3': 'Inner Peace',
    'todayEyebrow': 'TODAY\'S JAAP',
    'todayTitle': '612 of 1,080',
    'days': '22 days',
    'todaySub': '5 malas done · 468 to go',
    'haptic': 'Haptic on every bead',
    'undo': 'Undo chant',
    'streakEyebrow': 'STREAK',
    'streakTitle': '22 days in a row',
    'wk': 'M T W T F S S',
    'charts': 'Daily · Weekly · Yearly',
    'reminders': 'Reminders',
    'nowPlaying': 'NOW PLAYING',
    'yourRec': 'Your recording',
    'addOwn': 'ADD YOUR OWN',
    'mantra': 'Radhe Radhe',
    'sankalpEyebrow': '40-DAY SANKALP',
    'dayOf': 'Day 23 of 40',
    'malasADay': '10 malas a day',
    'kept': '22 days kept · 18 to go',
    'blackoutEyebrow': 'BLACKOUT MODE',
    'blackoutTitle': 'No light. Full count.',
    'tap': 'Tap anywhere',
    'vol': 'Volume buttons count',
    'buzz': 'A buzz every bead',
    'longPress': 'Long-press the icon',
    'themesEyebrow': '13 THEMES',
    'themesTitle': 'Saffron, Ocean, Night & more',
    'beads': 'Bead mala',
    'falling': 'Falling mantra',
    'photo': 'Your photo',
  },
  'hi': {
    'track1': 'ऊँचे पठार की सुबह',
    'track2': 'शांत जल',
    'track3': 'आंतरिक शांति',
    'todayEyebrow': 'आज का जाप',
    'todayTitle': '1,080 में से 612',
    'days': '22 दिन',
    'todaySub': '5 माला पूरी · 468 बाकी',
    'haptic': 'हर मनके पर कंपन',
    'undo': 'जप वापस लें',
    'streakEyebrow': 'लगातार साधना',
    'streakTitle': 'लगातार 22 दिन',
    'wk': 'सो मं बु गु शु श र',
    'charts': 'दैनिक · साप्ताहिक · वार्षिक',
    'reminders': 'रिमाइंडर',
    'nowPlaying': 'अभी बज रहा है',
    'yourRec': 'आपकी रिकॉर्डिंग',
    'addOwn': 'अपना जोड़ें',
    'mantra': 'राधे राधे',
    'sankalpEyebrow': '40 दिन का संकल्प',
    'dayOf': '40 में से दिन 23',
    'malasADay': 'रोज़ 10 माला',
    'kept': '22 दिन पूरे · 18 बाकी',
    'blackoutEyebrow': 'अंधकार मोड',
    'blackoutTitle': 'रोशनी नहीं। पूरी गिनती।',
    'tap': 'कहीं भी टैप करें',
    'vol': 'वॉल्यूम बटन से गिनती',
    'buzz': 'हर मनके पर कंपन',
    'longPress': 'आइकन दबाकर रखें',
    'themesEyebrow': '13 थीम',
    'themesTitle': 'केसरिया, सागर, रात और भी',
    'beads': 'मनकों की माला',
    'falling': 'गिरता मंत्र',
    'photo': 'आपकी फ़ोटो',
  },
  'mr': {
    'track1': 'उंच पठारावरील सकाळ',
    'track2': 'शांत जल',
    'track3': 'अंतरीची शांती',
    'todayEyebrow': 'आजचा जप',
    'todayTitle': '1,080 पैकी 612',
    'days': '22 दिवस',
    'todaySub': '5 माळा पूर्ण · 468 बाकी',
    'haptic': 'प्रत्येक मण्यावर कंपन',
    'undo': 'जप मागे घ्या',
    'streakEyebrow': 'सातत्य',
    'streakTitle': 'सलग 22 दिवस',
    'wk': 'सो मं बु गु शु श र',
    'charts': 'दैनिक · साप्ताहिक · वार्षिक',
    'reminders': 'स्मरणपत्रे',
    'nowPlaying': 'आता वाजत आहे',
    'yourRec': 'तुमचे रेकॉर्डिंग',
    'addOwn': 'स्वतःचा जोडा',
    'mantra': 'राधे राधे',
    'sankalpEyebrow': '40 दिवसांचा संकल्प',
    'dayOf': '40 पैकी दिवस 23',
    'malasADay': 'रोज 10 माळा',
    'kept': '22 दिवस पूर्ण · 18 बाकी',
    'blackoutEyebrow': 'ब्लॅकआउट मोड',
    'blackoutTitle': 'प्रकाश नाही. पूर्ण मोजणी.',
    'tap': 'कुठेही टॅप करा',
    'vol': 'व्हॉल्यूम बटणाने मोजणी',
    'buzz': 'प्रत्येक मण्यावर कंपन',
    'longPress': 'आयकॉन दाबून ठेवा',
    'themesEyebrow': '13 थीम',
    'themesTitle': 'केशरी, सागर, रात्र आणि बरेच',
    'beads': 'मण्यांची माळ',
    'falling': 'पडणारा मंत्र',
    'photo': 'तुमचा फोटो',
  },
  'gu': {
    'track1': 'ઊંચા ઉચ્ચપ્રદેશની સવાર',
    'track2': 'શાંત જળ',
    'track3': 'આંતરિક શાંતિ',
    'todayEyebrow': 'આજનો જપ',
    'todayTitle': '1,080 માંથી 612',
    'days': '22 દિવસ',
    'todaySub': '5 માળા પૂર્ણ · 468 બાકી',
    'haptic': 'દરેક મણકે કંપન',
    'undo': 'જપ પાછો લો',
    'streakEyebrow': 'સાતત્ય',
    'streakTitle': 'સતત 22 દિવસ',
    'wk': 'સો મં બુ ગુ શુ શ ર',
    'charts': 'દૈનિક · સાપ્તાહિક · વાર્ષિક',
    'reminders': 'રિમાઇન્ડર',
    'nowPlaying': 'હમણાં વાગે છે',
    'yourRec': 'તમારું રેકોર્ડિંગ',
    'addOwn': 'તમારો પોતાનો ઉમેરો',
    'mantra': 'રાધે રાધે',
    'sankalpEyebrow': '40 દિવસનો સંકલ્પ',
    'dayOf': '40 માંથી દિવસ 23',
    'malasADay': 'રોજ 10 માળા',
    'kept': '22 દિવસ પૂર્ણ · 18 બાકી',
    'blackoutEyebrow': 'બ્લૅકઆઉટ મોડ',
    'blackoutTitle': 'પ્રકાશ નહીં. પૂરી ગણતરી.',
    'tap': 'ગમે ત્યાં ટૅપ કરો',
    'vol': 'વૉલ્યુમ બટનથી ગણતરી',
    'buzz': 'દરેક મણકે કંપન',
    'longPress': 'આઇકન દબાવી રાખો',
    'themesEyebrow': '13 થીમ',
    'themesTitle': 'કેસરી, સાગર, રાત્રિ અને વધુ',
    'beads': 'મણકાની માળા',
    'falling': 'પડતો મંત્ર',
    'photo': 'તમારો ફોટો',
  },
  'pa': {
    'track1': 'ਉੱਚੇ ਪਠਾਰ ਦੀ ਸਵੇਰ',
    'track2': 'ਸ਼ਾਂਤ ਜਲ',
    'track3': 'ਅੰਦਰੂਨੀ ਸ਼ਾਂਤੀ',
    'todayEyebrow': 'ਅੱਜ ਦਾ ਜਪ',
    'todayTitle': '1,080 ਵਿੱਚੋਂ 612',
    'days': '22 ਦਿਨ',
    'todaySub': '5 ਮਾਲਾ ਪੂਰੀਆਂ · 468 ਬਾਕੀ',
    'haptic': 'ਹਰ ਮਣਕੇ ਉੱਤੇ ਥਰਥਰਾਹਟ',
    'undo': 'ਜਪ ਵਾਪਸ ਲਓ',
    'streakEyebrow': 'ਨਿਰੰਤਰਤਾ',
    'streakTitle': 'ਲਗਾਤਾਰ 22 ਦਿਨ',
    'wk': 'ਸੋ ਮੰ ਬੁ ਵੀ ਸ਼ੁ ਸ਼ ਐ',
    'charts': 'ਰੋਜ਼ਾਨਾ · ਹਫ਼ਤਾਵਾਰੀ · ਸਾਲਾਨਾ',
    'reminders': 'ਰੀਮਾਈਂਡਰ',
    'nowPlaying': 'ਹੁਣ ਵੱਜ ਰਿਹਾ ਹੈ',
    'yourRec': 'ਤੁਹਾਡੀ ਰਿਕਾਰਡਿੰਗ',
    'addOwn': 'ਆਪਣਾ ਜੋੜੋ',
    'mantra': 'ਰਾਧੇ ਰਾਧੇ',
    'sankalpEyebrow': '40 ਦਿਨਾਂ ਦਾ ਸੰਕਲਪ',
    'dayOf': '40 ਵਿੱਚੋਂ ਦਿਨ 23',
    'malasADay': 'ਰੋਜ਼ 10 ਮਾਲਾ',
    'kept': '22 ਦਿਨ ਪੂਰੇ · 18 ਬਾਕੀ',
    'blackoutEyebrow': 'ਬਲੈਕਆਊਟ ਮੋਡ',
    'blackoutTitle': 'ਰੌਸ਼ਨੀ ਨਹੀਂ। ਪੂਰੀ ਗਿਣਤੀ।',
    'tap': 'ਕਿਤੇ ਵੀ ਟੈਪ ਕਰੋ',
    'vol': 'ਵਾਲੀਅਮ ਬਟਨ ਨਾਲ ਗਿਣਤੀ',
    'buzz': 'ਹਰ ਮਣਕੇ ਉੱਤੇ ਥਰਥਰਾਹਟ',
    'longPress': 'ਆਈਕਨ ਦਬਾ ਕੇ ਰੱਖੋ',
    'themesEyebrow': '13 ਥੀਮ',
    'themesTitle': 'ਕੇਸਰੀ, ਸਾਗਰ, ਰਾਤ ਅਤੇ ਹੋਰ',
    'beads': 'ਮਣਕਿਆਂ ਦੀ ਮਾਲਾ',
    'falling': 'ਡਿੱਗਦਾ ਮੰਤਰ',
    'photo': 'ਤੁਹਾਡੀ ਫੋਟੋ',
  },
  'ta': {
    'track1': 'உயர் சமவெளியின் காலை',
    'track2': 'நீரோடை',
    'track3': 'உள் அமைதி',
    'todayEyebrow': 'இன்றைய ஜபம்',
    'todayTitle': '1,080-இல் 612',
    'days': '22 நாட்கள்',
    'todaySub': '5 மாலை முடிந்தது · 468 மீதம்',
    'haptic': 'ஒவ்வொரு மணிக்கும் அதிர்வு',
    'undo': 'ஜபத்தைத் திரும்பப் பெறு',
    'streakEyebrow': 'தொடர்ச்சி',
    'streakTitle': 'தொடர்ந்து 22 நாட்கள்',
    'wk': 'தி செ பு வி வெ ச ஞா',
    'charts': 'தினசரி · வாராந்திர · ஆண்டு',
    'reminders': 'நினைவூட்டல்கள்',
    'nowPlaying': 'இப்போது ஒலிக்கிறது',
    'yourRec': 'உங்கள் பதிவு',
    'addOwn': 'உங்களுடையதைச் சேர்க்கவும்',
    'mantra': 'ராதே ராதே',
    'sankalpEyebrow': '40 நாள் சங்கல்பம்',
    'dayOf': '40-இல் நாள் 23',
    'malasADay': 'தினமும் 10 மாலை',
    'kept': '22 நாட்கள் முடிந்தது · 18 மீதம்',
    'blackoutEyebrow': 'பிளாக்அவுட் முறை',
    'blackoutTitle': 'ஒளியின்றி எண்ணுங்கள்',
    'tap': 'எங்கும் தட்டுங்கள்',
    'vol': 'ஒலி பொத்தானால் எண்ணுங்கள்',
    'buzz': 'ஒவ்வொரு மணிக்கும் அதிர்வு',
    'longPress': 'ஐகானை அழுத்திப் பிடிக்கவும்',
    'themesEyebrow': '13 தீம்கள்',
    'themesTitle': 'காவி, கடல், இரவு மேலும்',
    'beads': 'மணி மாலை',
    'falling': 'விழும் மந்திரம்',
    'photo': 'உங்கள் படம்',
  },
  'te': {
    'track1': 'ఎత్తైన పీఠభూమి ఉదయం',
    'track2': 'ప్రశాంత జలాలు',
    'track3': 'అంతర్గత శాంతి',
    'todayEyebrow': 'నేటి జపం',
    'todayTitle': '1,080లో 612',
    'days': '22 రోజులు',
    'todaySub': '5 మాలలు పూర్తి · 468 మిగిలాయి',
    'haptic': 'ప్రతి పూసకు కంపనం',
    'undo': 'జపం వెనక్కి తీసుకోండి',
    'streakEyebrow': 'క్రమం',
    'streakTitle': 'వరుసగా 22 రోజులు',
    'wk': 'సో మం బు గు శు శ ఆ',
    'charts': 'రోజువారీ · వారపు · వార్షిక',
    'reminders': 'రిమైండర్లు',
    'nowPlaying': 'ఇప్పుడు ప్లే అవుతోంది',
    'yourRec': 'మీ రికార్డింగ్',
    'addOwn': 'మీ సొంతం చేర్చండి',
    'mantra': 'రాధే రాధే',
    'sankalpEyebrow': '40 రోజుల సంకల్పం',
    'dayOf': '40లో రోజు 23',
    'malasADay': 'రోజుకు 10 మాలలు',
    'kept': '22 రోజులు పూర్తి · 18 మిగిలాయి',
    'blackoutEyebrow': 'బ్లాక్‌అవుట్ మోడ్',
    'blackoutTitle': 'వెలుతురు లేదు. పూర్తి లెక్క.',
    'tap': 'ఎక్కడైనా ట్యాప్ చేయండి',
    'vol': 'వాల్యూమ్ బటన్లతో లెక్క',
    'buzz': 'ప్రతి పూసకు కంపనం',
    'longPress': 'ఐకాన్ నొక్కి ఉంచండి',
    'themesEyebrow': '13 థీమ్‌లు',
    'themesTitle': 'కాషాయం, సముద్రం, రాత్రి ఇంకా',
    'beads': 'పూసల మాల',
    'falling': 'పడే మంత్రం',
    'photo': 'మీ ఫోటో',
  },
};

/// The language the cards are being drawn in; set before each shot.
String _cardCode = 'en';

String _ct(String key) => _cardCopy[_cardCode]?[key] ?? _cardCopy['en']![key]!;

/// `*highlighted*` text as styled spans.
List<_Span> _spans(String text) => [
  for (final (i, part) in text.split('*').indexed)
    if (part.isNotEmpty) (part, i.isOdd),
];

void main() {
  testWidgets('store screenshots', (tester) async {
    await tester.runAsync(_loadFonts);
    addTearDown(tester.view.reset);

    final root = Directory.current.path;

    if (_runLocale == null || _runLocale == 'en') {
      await _featureGraphic(
        tester,
        '$root/android/fastlane/metadata/android/en-US/images/featureGraphic.png',
      );
    }

    for (final loc in _locales) {
      if (_runLocale != null && loc.code != _runLocale) continue;
      final iosDir = '$root/ios/fastlane/screenshots/${loc.iosDir}';
      final playDir =
          '$root/android/fastlane/metadata/android/${loc.playDir}/images/phoneScreenshots';
      Directory(iosDir).createSync(recursive: true);
      Directory(playDir).createSync(recursive: true);

      for (final shot in _shots) {
        // The hero cover image (icon, name, hand with mala) is a hand-made
        // graphic, localized by hand per locale; never overwrite it here.
        if (shot.file == '01_counter') continue;
        final bytes = await _captureApp(tester, shot, Locale(loc.code));
        late ui.Image screen;
        await tester.runAsync(() async {
          screen = await decodeImageFromList(bytes);
        });
        await _compose(
          tester,
          shot,
          screen,
          canvas: const Size(440, 956),
          path: '$iosDir/${shot.file}.png',
          code: loc.code,
        );
        await _compose(
          tester,
          shot,
          screen,
          canvas: const Size(360, 640),
          path: '$playDir/${shot.file}.png',
          code: loc.code,
        );
      }
    }
  });
}
