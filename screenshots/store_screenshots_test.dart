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
//   appstore_assets/iphone-duo/en-US/{outer,inner}/
//                                            1398×2034, 2007×2853
//
// 08_brand (icon, name, the companion with the app's mala counter) is drawn
// here too, from appstore_assets/appicon-fullbleed.png and
// assets/branding/companion.png.
import 'dart:io';
import 'dart:math' as math;
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
import 'package:japmala/core/constants/app_languages.dart';
import 'package:japmala/core/constants/built_in_mantras.dart';
import 'package:japmala/core/database/app_database.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/features/jaap/presentation/counter_prefs.dart';
import 'package:japmala/features/jaap/presentation/auto_jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/jaap_controller.dart';
import 'package:japmala/features/jaap/presentation/widgets/mala_ring.dart';
import 'package:japmala/features/meditation/presentation/music_playback.dart';
import 'package:japmala/core/services/ambient_chant_service.dart';
import 'package:japmala/core/services/user_music_store.dart';
import 'package:japmala/features/settings/domain/counter_background.dart';
import 'package:japmala/features/settings/presentation/settings_controller.dart';
import 'package:japmala/features/mantras/domain/mantra_names.dart';
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
    headline: [('Naam Jaap for\n', false), ('Radha, Ram & Shiv', true)],
    sub: 'Tap anywhere. Your mala fills up.',
    card: _todayCard,
    cardAt: _CardAt.bottom,
    // The counter screen, mid-session: this morning's jaap already underway.
    capture: (tester, c, router) async {},
  ),
  _Shot(
    file: '02_mantras',
    headline: [('21 Mantras Ready\n', true), ('or Add Your Own', false)],
    sub: 'Ram, Radhe, Om Namah Shivaya, Waheguru and more',
    card: _mantraCard,
    cardAt: _CardAt.bottom,
    capture: (tester, c, router) async {
      router.push('/mantras');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '03_music',
    darkStatusBar: true,
    headline: [('Chant with\n', false), ('Calming Music', true)],
    sub: 'Soft sounds, or record your own',
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
    file: '04_habit',
    headline: [('Build a\n', false), ('Daily Habit', true)],
    sub: 'See every day you chanted',
    card: _streakCard,
    cardAt: _CardAt.bottom,
    capture: (tester, c, router) async {
      router.go('/progress');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '05_blackout',
    darkStatusBar: true,
    headline: [('Chant with Your\n', false), ('Eyes Closed', true)],
    sub: 'Black screen. Tap anywhere.',
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
    file: '06_sankalp',
    headline: [('Take a ', false), ('Sankalp', true), ('.\nKeep It.', false)],
    sub: 'Chant daily for 11, 21 or 40 days',
    card: _sankalpCard,
    cardAt: _CardAt.bottom,
    capture: (tester, c, router) async {
      router.push('/sadhana');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '07_themes',
    darkStatusBar: true,
    headline: [('Make It\n', false), ('Your Own', true)],
    sub: '13 colour themes, or your own photo',
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
  // Every script in one family (fontTools merge of the Noto Regulars), the
  // last fallback, so a screen that lists the languages shows each in its
  // own script whatever language this run is drawing.
  final indic = FontLoader('NotoSansIndicAll')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File(
            'screenshots/fonts/NotoSansIndic-Merged-Regular.ttf',
          ).readAsBytesSync(),
        ),
      ),
    );
  await indic.load();
  // Thai under its own name too, last of all, for the ไทย chip on the
  // languages shot whatever language is being drawn.
  final thai = FontLoader('NotoSansThaiAll')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('screenshots/fonts/NotoSansThai-Regular.ttf').readAsBytesSync(),
        ),
      ),
    );
  await thai.load();
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

/// 23 days in a row of steady Jaap, a gap, and some earlier practice:
/// [main] every day and on the counter, [side] now and then.
Future<ProviderContainer> _seededApp({
  String main = 'builtin.ram',
  String side = 'builtin.radha',
}) async {
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
  if (main != 'builtin.ram') await settings.setActiveMantra(main);

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
      mantraId: main,
      delta: daily[(streakDays - 1 - d) % daily.length],
    );
    if (d % 4 == 0) {
      await repo.addBeads(mantraId: side, delta: 216);
    }
  }
  for (final d in [26, 27, 29, 30, 33, 34, 35]) {
    clock.set(_now.subtract(Duration(days: d)).copyWith(hour: 7));
    await repo.addBeads(mantraId: main, delta: 540);
  }

  // A 40-day Sankalp begun on the first day of the streak.
  await container
      .read(sadhanaRepositoryProvider)
      .create(
        mantraId: main,
        dailyGoal: 1080,
        durationDays: 40,
        startAt: _now.subtract(const Duration(days: streakDays - 1)),
      );

  // This morning: five malas and part of the sixth.
  clock.set(_now);
  await repo.addBeads(mantraId: main, delta: 612);
  container.read(ledgerRevisionProvider.notifier).bump();
  return container;
}

/// Captures the app itself at device size, 3×. With [sequenceDir], it then
/// taps the counter [_sequenceTaps] times and saves every frame (30 fps, 2×)
/// there, for the App Store search-results video.
Future<Uint8List> _captureApp(
  WidgetTester tester,
  _Shot shot,
  Locale locale, {
  String? sequenceDir,
  Future<ProviderContainer> Function() seed = _seededApp,
}) async {
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

  final container = await seed();
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
  if (sequenceDir != null) {
    final dir = Directory(sequenceDir);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    final jaap = container.read(jaapControllerProvider.notifier);
    var frame = 0;
    for (var t = 0; t < _sequenceTaps; t++) {
      jaap.count();
      for (var f = 0; f < _framesPerTap; f++) {
        await tester.pump(const Duration(microseconds: 33333));
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(key),
          );
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            '$sequenceDir/${(frame++).toString().padLeft(3, '0')}.png',
          ).writeAsBytesSync(data!.buffer.asUint8List());
        });
      }
    }
  }
  await container.read(jaapControllerProvider.notifier).flushPendingWrites();
  // Unmount so the next shot starts from a clean tree.
  await tester.pumpWidget(const SizedBox());
  return bytes;
}

/// The search-results video's counting: taps, and frames per tap at 30 fps.
const _sequenceTaps = 12;
const _framesPerTap = 15;

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
    // Text and cards are sized to this width. On a wide canvas (iPhone Duo)
    // it is capped by the height, so they stay in proportion to the phone
    // instead of growing with the page.
    final u = math.min(w, h * 0.62);
    // Tamil and Telugu letters are wider and taller, so they are set smaller.
    final headlineScale = const {'ta': 0.76, 'te': 0.86}[code] ?? 1.0;
    final headlineSize = u * (tall ? 0.092 : 0.082) * headlineScale;
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
    final textFont = const {'en', 'ru', 'id', 'ms'}.contains(code)
        ? 'Inter'
        : 'NotoSansDevanagari';
    final copy = _headlines[shot.file]?[code];
    final headline = copy == null ? shot.headline : _spans(copy.$1);
    final sub = copy?.$2 ?? shot.sub;
    final badge = shot.badge == null ? null : _badges[code] ?? shot.badge;

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
            left: (w - u * 0.86) / 2,
            right: (w - u * 0.86) / 2,
            top: h * (tall ? 0.045 : 0.035),
            child: Column(
              children: [
                if (badge != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: u * 0.04,
                      vertical: u * 0.013,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: badgeColor.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Text(
                      badge,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: textFont,
                        fontFamilyFallback: const ['Inter'],
                        fontSize: u * 0.031,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  SizedBox(height: u * 0.035),
                ] else
                  SizedBox(height: u * 0.02),
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
                SizedBox(height: u * 0.03),
                Text(
                  sub,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: textFont,
                    fontFamilyFallback: const ["Inter"],
                    fontSize: u * 0.047,
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
              left: (w - u * 0.88) / 2,
              right: (w - u * 0.88) / 2,
              child: (() {
                _cardCode = code;
                return card(u / 440);
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

/// The name per language for 08_brand: `*` marks the highlighted run.
const _brandCopy = <String, (String, String)>{
  'en': ('Naam Jaap\n*Counter*', 'JaapMitra'),
  'hi': ('नाम जप\n*काउंटर*', 'जापमित्र'),
  'mr': ('नाम जप\n*काउंटर*', 'जापमित्र'),
  'gu': ('નામ જપ\n*કાઉન્ટર*', 'જાપમિત્ર'),
  'pa': ('ਨਾਮ ਜਪ\n*ਕਾਊਂਟਰ*', 'ਜਾਪਮਿੱਤਰ'),
  'ta': ('நாம ஜப\n*கவுண்டர்*', 'ஜாப்மித்ரா'),
  'te': ('నామ జప\n*కౌంటర్*', 'జాపమిత్ర'),
  'ru': ('Счётчик\n*джапы*', 'JaapMitra'),
  'id': ('Penghitung\n*Japa*', 'JaapMitra'),
  'ms': ('Pengira\n*Japa*', 'JaapMitra'),
  'th': ('ตัวนับ\n*การสวดมนต์*', 'JaapMitra'),
};

/// 08_brand: the icon and name, then the companion under the app's own mala
/// counter, so the last shot says what the app is at a glance.
class _BrandCanvas extends StatelessWidget {
  const _BrandCanvas({
    required this.size,
    required this.code,
    required this.icon,
    required this.companion,
  });

  final Size size;
  final String code;
  final ui.Image icon;
  final ui.Image companion;

  static const _cream = Color(0xFFFFF4E2);
  static const _saffron = Color(0xFFFFB23F);

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final h = size.height;
    final tall = h / w > 2;
    final u = math.min(w, h * 0.62);
    final headlineScale = const {'ta': 0.76, 'te': 0.86}[code] ?? 1.0;
    final headlineSize = u * (tall ? 0.105 : 0.09) * headlineScale;
    final textFont = const {'en', 'ru', 'id', 'ms'}.contains(code)
        ? 'Inter'
        : 'NotoSansDevanagari';
    final (title, name) = _brandCopy[code] ?? _brandCopy['en']!;
    final iconSize = u * (tall ? 0.24 : 0.2);

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2A0A04),
                    Color(0xFF5A1A07),
                    Color(0xFF8A3A0C),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: h * (tall ? 0.05 : 0.035)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(iconSize * 0.225),
                  child: RawImage(
                    image: icon,
                    width: iconSize,
                    height: iconSize,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(height: u * 0.045),
                Text.rich(
                  TextSpan(
                    children: [
                      for (final (text, highlight) in _spans(title))
                        TextSpan(
                          text: text,
                          style: TextStyle(
                            color: highlight ? _saffron : _cream,
                          ),
                        ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: textFont,
                    fontFamilyFallback: const ['Inter'],
                    fontSize: headlineSize,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                    letterSpacing: -headlineSize * 0.025,
                  ),
                ),
                SizedBox(height: u * 0.025),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: textFont,
                    fontFamilyFallback: const ['Inter'],
                    fontSize: u * 0.052,
                    fontWeight: FontWeight.w500,
                    color: _cream.withValues(alpha: 0.78),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final ringSize = math.min(w * 0.66, box.maxHeight * 0.5);
                      final figure = math.min(
                        box.maxHeight * 0.56,
                        w * 0.62 * companion.height / companion.width,
                      );
                      final ringTop = box.maxHeight * 0.06;
                      return Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // The diya glow behind the counter.
                          Positioned(
                            top: ringTop - ringSize * 0.35,
                            width: ringSize * 1.7,
                            height: ringSize * 1.7,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    _saffron.withValues(alpha: 0.3),
                                    _saffron.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: ringTop,
                            child: Theme(
                              data: AppTheme.dark(),
                              child: MalaRing(
                                beads: 81,
                                malaSize: 108,
                                diameter: ringSize,
                                child: Padding(
                                  padding: EdgeInsets.all(ringSize * 0.2),
                                  child: MalaRingLabel(
                                    beads: 81,
                                    malaSize: 108,
                                    color: _cream,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -h * 0.012,
                            height: figure,
                            child: RawImage(
                              image: companion,
                              height: figure,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws [child] at [canvas] points, 3×, and writes it to [path].
Future<void> _renderTo(
  WidgetTester tester,
  Widget child,
  Size canvas,
  String path,
) async {
  tester.view.physicalSize = canvas * 3;
  tester.view.devicePixelRatio = 3;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
  const key = ValueKey('render');
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(key: key, child: child),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
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
  await tester.pumpWidget(const SizedBox());
}

// ---------------------------------------------------------------------------
// The phone shots of the store gallery (see _hybrid): gold, black or night
// canvases, a large phone and a benefit-first headline.

enum _V2Look { gold, black, night }

/// What floats beside the phone on a v2 shot.
enum _V2Extra { none, companion, badges, paces, nowPlaying }

class _V2Shot {
  const _V2Shot({
    required this.file,
    required this.headline,
    required this.sub,
    required this.capture,
    this.look = _V2Look.gold,
    this.badge,
    this.darkStatusBar = false,
    this.extra = _V2Extra.none,
    this.chips = const [],
    this.headlineScale = 1,
  });

  final String file;
  final List<_Span> headline;
  final String sub;
  final Future<void> Function(WidgetTester, ProviderContainer, GoRouter)
  capture;
  final _V2Look look;
  final String? badge;
  final bool darkStatusBar;
  final _V2Extra extra;

  /// Short facts pinned over the phone, each with its icon.
  final List<(IconData, String)> chips;

  /// Below 1 for headlines with a long line.
  final double headlineScale;
}

/// Auto Jaap's pace in seconds when 04 was captured.
int _v2Pace = 1;

/// Stops 04's Auto Jaap once the gallery is drawn, so no timer outlives it.
AutoJaapController? _v2Auto;

final _v2Shots = <_V2Shot>[
  _V2Shot(
    file: '01_jaap',
    badge: 'Ad‑free  •  No subscriptions',
    headline: [('Naam Jaap for\n', false), ('Radha, Ram & Shiv', true)],
    sub: '',
    extra: _V2Extra.companion,
    capture: (tester, c, router) async {},
  ),
  _V2Shot(
    file: '02_habit',
    headline: [('Build a\n', false), ('Daily Habit', true)],
    sub: 'Daily goals, streaks and Sankalp.',
    chips: [(Icons.local_fire_department_rounded, '22 days in a row')],
    capture: (tester, c, router) async {
      router.go('/progress');
      await _settle(tester);
      // The daily chart: Jaap for each day, so the streak is a bar per day.
      await tester.tap(find.text('Daily'));
      await _settle(tester);
    },
  ),
  _V2Shot(
    file: '03_blackout',
    look: _V2Look.black,
    darkStatusBar: true,
    headline: [('Chant Without\n', false), ('Distractions', true)],
    chips: [
      (Icons.touch_app_rounded, 'Tap anywhere'),
      (Icons.volume_up_rounded, 'Volume buttons count'),
    ],
    sub: 'A completely dark screen for peaceful Jaap.',
    capture: (tester, c, router) async {
      router.push('/blackout');
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('blackout-show-mantra')));
      await _settle(tester);
    },
  ),
  _V2Shot(
    file: '04_auto_jaap',
    headline: [('Let Your\n', false), ('Jaap Flow', true)],
    sub: 'Chant hands-free at your own pace.',
    extra: _V2Extra.paces,
    capture: (tester, c, router) async {
      c.read(autoJaapProvider.notifier).start();
      await tester.pump(const Duration(seconds: 3));
      await _settle(tester);
      _v2Pace = c.read(autoJaapProvider).config.interval.inSeconds;
      _v2Auto = c.read(autoJaapProvider.notifier);
    },
  ),
  _V2Shot(
    file: '05_music',
    look: _V2Look.night,
    darkStatusBar: true,
    headline: [('Make Every Jaap\n', false), ('Peaceful', true)],
    extra: _V2Extra.nowPlaying,
    sub: 'Chant with calming sounds and music.',
    capture: (tester, c, router) async {
      await c.read(settingsProvider.notifier).setTheme(AppThemeId.meditative);
      router.push('/meditation');
      await _settle(tester);
      await c
          .read(musicPlaybackProvider.notifier)
          .choose(AmbientChantService.chants[1].id, play: true);
      await _settle(tester);
    },
  ),
  _V2Shot(
    file: '06_mantras',
    headline: [('Your Favourite Naam.\n', false), ('All in One Place.', true)],
    headlineScale: 0.8,
    sub: 'Ram, Radha, Krishna, Shiva and more.',
    chips: [(Icons.add_rounded, 'Add your own mantra')],
    capture: (tester, c, router) async {
      router.push('/mantras');
      await _settle(tester);
    },
  ),
  _V2Shot(
    file: '07_mala',
    darkStatusBar: true,
    headline: [('Your ', false), ('108-Bead\n', true), ('Digital Mala', false)],
    sub: 'Feel every bead with gentle haptic feedback.',
    chips: [(Icons.vibration_rounded, 'Haptic on every bead')],
    // One bead from a full mala, on a warm theme of its own, so it does
    // not repeat 01.
    capture: (tester, c, router) async {
      await c.read(settingsProvider.notifier).setTheme(AppThemeId.spiritual);
      final jaap = c.read(jaapControllerProvider.notifier);
      final left =
          107 -
          c.read(jaapControllerProvider).value!.position.beadsInCurrentMala;
      for (var i = 0; i < left; i++) {
        jaap.count();
        await tester.pump(const Duration(milliseconds: 30));
      }
      await _settle(tester);
    },
  ),
  _V2Shot(
    file: '08_language',
    headline: [('Your Practice.\n', false), ('Your Language.', true)],
    sub: 'Eleven languages. Ad‑free, no subscriptions.',
    extra: _V2Extra.badges,
    capture: (tester, c, router) async {
      router.go('/settings');
      await _settle(tester);
      final tile = find.text('Language');
      await tester.scrollUntilVisible(
        tile,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await _settle(tester);
      await tester.tap(tile);
      await _settle(tester);
    },
  ),
];

class _V2Canvas extends StatelessWidget {
  const _V2Canvas({
    required this.shot,
    required this.screen,
    required this.size,
    required this.companion,
  });

  final _V2Shot shot;
  final ui.Image screen;
  final Size size;
  final ui.Image companion;

  static const _ink = Color(0xFF2B1608);
  static const _inkSoft = Color(0xFF6E5442);
  static const _saffron = Color(0xFFE8770E);
  static const _burnt = Color(0xFFB83A06);
  static const _gold = Color(0xFFFFB23F);
  static const _cream = Color(0xFFFFF4E2);

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final h = size.height;
    final dark = shot.look != _V2Look.gold;
    final headlineSize =
        w *
        0.098 *
        shot.headlineScale *
        (const {'ta': 0.76, 'te': 0.86}[_hyCode] ?? 1.0);
    final phoneTop = h * 0.235;
    // The phone runs off the bottom edge: the screen's top two thirds carry
    // the story, at a size that reads in the store.
    final phoneWidth = w * 0.80;
    final phoneHeight = phoneWidth * _device.height / _device.width;
    final phoneLeft = (w - phoneWidth) / 2;
    final ink = dark ? _cream : _ink;
    final highlight = dark ? _gold : _burnt;
    final soft = dark ? _cream.withValues(alpha: 0.7) : _inkSoft;
    final (headline, sub, badge) = _hyText(
      shot.file,
      shot.headline,
      shot.sub,
      shot.badge,
    );

    TextStyle text(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: 'Inter',
      fontFamilyFallback: _hyFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      decoration: TextDecoration.none,
    );

    Widget chip(IconData icon, String label, {double k = 1}) => Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.04 * k,
        vertical: w * 0.025 * k,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A3A10).withValues(alpha: 0.22),
            blurRadius: w * 0.05,
            offset: Offset(0, w * 0.015),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: w * 0.05 * k, color: _saffron),
          SizedBox(width: w * 0.02 * k),
          Text(label, style: text(w * 0.038 * k, FontWeight.w600, _ink)),
        ],
      ),
    );

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
                  colors: switch (shot.look) {
                    _V2Look.black => const [
                      Color(0xFF000000),
                      Color(0xFF120A05),
                    ],
                    _V2Look.night => const [
                      Color(0xFF2A0A04),
                      Color(0xFF5A1A07),
                      Color(0xFF8A3A0C),
                    ],
                    _V2Look.gold => const [
                      Color(0xFFFFE2A0),
                      Color(0xFFFFC25C),
                      Color(0xFFF5962A),
                    ],
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: w * 0.05,
            right: w * 0.05,
            top: h * 0.055,
            child: Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      for (final (t, hi) in headline)
                        TextSpan(
                          text: t,
                          style: TextStyle(color: hi ? highlight : ink),
                        ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: text(
                    headlineSize,
                    FontWeight.w800,
                    ink,
                  ).copyWith(height: 1.08, letterSpacing: -headlineSize * 0.03),
                ),
                if (sub.isNotEmpty) ...[
                  SizedBox(height: w * 0.03),
                  Text(
                    sub,
                    textAlign: TextAlign.center,
                    style: text(w * 0.041, FontWeight.w500, soft),
                  ),
                ],
                if (badge case final badge?) ...[
                  SizedBox(height: w * 0.035),
                  Container(
                    constraints: BoxConstraints(maxWidth: w * 0.9),
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: w * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        badge,
                        maxLines: 1,
                        style: text(w * 0.036, FontWeight.w700, _burnt),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: phoneTop,
            left: phoneLeft,
            width: phoneWidth,
            height: phoneHeight,
            child: _Phone(screen: screen, darkStatusBar: shot.darkStatusBar),
          ),
          if (shot.extra == _V2Extra.companion)
            Positioned(
              left: -w * 0.03,
              bottom: -h * 0.005,
              height: h * 0.25,
              child: RawImage(
                image: companion,
                height: h * 0.25,
                filterQuality: FilterQuality.high,
              ),
            ),
          if (shot.extra == _V2Extra.paces)
            Positioned(
              left: w * 0.06,
              right: w * 0.06,
              bottom: h * 0.05,
              child: Container(
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(w * 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A3A10).withValues(alpha: 0.25),
                      blurRadius: w * 0.06,
                      offset: Offset(0, w * 0.02),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill_rounded,
                          color: _saffron,
                          size: w * 0.06,
                        ),
                        SizedBox(width: w * 0.02),
                        Text(
                          '${_hyL10n.autoJaap}  ·  ${_hyL10n.autoJaapPace}',
                          style: text(w * 0.04, FontWeight.w700, _ink),
                        ),
                      ],
                    ),
                    SizedBox(height: w * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final sec in AutoJaapConfig.paces)
                          Container(
                            width: w * 0.145,
                            padding: EdgeInsets.symmetric(vertical: w * 0.022),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: sec == _v2Pace
                                  ? _saffron
                                  : const Color(0xFFFFF1DF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _hyL10n.autoJaapSeconds(sec),
                              style: text(
                                w * 0.038,
                                FontWeight.w700,
                                sec == _v2Pace ? Colors.white : _ink,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (shot.chips.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: h * 0.028,
              child: SizedBox(
                width: w,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final (i, (icon, label)) in shot.chips.indexed) ...[
                        if (i > 0) SizedBox(width: w * 0.025),
                        chip(
                          icon,
                          _tr(label),
                          k: shot.chips.length > 1 ? 0.9 : 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          if (shot.extra == _V2Extra.nowPlaying)
            Positioned(
              left: w * 0.06,
              right: w * 0.06,
              bottom: h * 0.05,
              child: Container(
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(w * 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: w * 0.06,
                      offset: Offset(0, w * 0.02),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: w * 0.1,
                          height: w * 0.1,
                          decoration: const BoxDecoration(
                            color: _saffron,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                            size: w * 0.055,
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tr('NOW PLAYING'),
                                style: text(
                                  w * 0.027,
                                  FontWeight.w700,
                                  _saffron,
                                ).copyWith(letterSpacing: 1),
                              ),
                              Text(
                                AmbientChantService.chants[1].label,
                                style: text(w * 0.041, FontWeight.w700, _ink),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.pause_circle_filled_rounded,
                          color: _saffron,
                          size: w * 0.09,
                        ),
                      ],
                    ),
                    SizedBox(height: w * 0.03),
                    Wrap(
                      spacing: w * 0.02,
                      runSpacing: w * 0.02,
                      children: [
                        for (final i in const [3, 5, 0])
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.03,
                              vertical: w * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1DF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              AmbientChantService.chants[i].label,
                              style: text(w * 0.032, FontWeight.w600, _ink),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (shot.extra == _V2Extra.badges)
            Positioned(
              left: 0,
              right: 0,
              bottom: h * 0.022,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  chip(Icons.block_rounded, _tr('Ad‑free'), k: 0.9),
                  SizedBox(width: w * 0.025),
                  chip(
                    Icons.credit_card_off_rounded,
                    _tr('No subscriptions'),
                    k: 0.9,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The graphic shots of the store gallery (see _hybrid): drawn from the
// app's own parts (its mala ring, its mantras, sounds and paces, the seeded
// practice) instead of phone captures.

class _GfxShot {
  const _GfxShot({
    required this.file,
    required this.headline,
    required this.sub,
    required this.art,
    this.look = _V2Look.gold,
    this.badge,
    this.headlineScale = 1,
  });

  final String file;
  final List<_Span> headline;
  final String sub;
  final _V2Look look;
  final String? badge;
  final double headlineScale;

  /// The graphic under the headline, in a box [w] wide and [h] tall.
  final Widget Function(double w, double h, ui.Image companion) art;
}

/// The app icon, shown on 08 in place of a second companion. Loaded by the
/// test.
late ui.Image _gIcon;

/// One grid for every graphic, as fractions of the area under the headline
/// (and of the width, for the ring): where the mantra's name sits, where the
/// ring starts and how big it is, and how far bottom chips and cards sit
/// from the edge.
const _gTitleTop = 0.03;
const _gRingTop = 0.11;
const _gRingSize = 0.8;
const _gBottom = 0.06;

const _gInk = Color(0xFF2B1608);
const _gSaffron = Color(0xFFE8770E);
const _gBurnt = Color(0xFFB83A06);
const _gGold = Color(0xFFFFB23F);
const _gCream = Color(0xFFFFF4E2);
const _gChip = Color(0xFFFFF1DF);

TextStyle _gt(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: 'Inter',
  fontFamilyFallback: _hyFallback,
  fontSize: size,
  fontWeight: weight,
  color: color,
  decoration: TextDecoration.none,
);

BoxDecoration _gCardDeco(double w, {Color color = Colors.white}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(w * 0.06),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF5A2A08).withValues(alpha: 0.28),
          blurRadius: w * 0.07,
          offset: Offset(0, w * 0.025),
        ),
      ],
    );

Widget _gChipW(double w, IconData icon, String label, {double k = 1}) =>
    Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.04 * k,
        vertical: w * 0.025 * k,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A2A08).withValues(alpha: 0.22),
            blurRadius: w * 0.05,
            offset: Offset(0, w * 0.015),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: w * 0.05 * k, color: _gSaffron),
          SizedBox(width: w * 0.02 * k),
          Text(label, style: _gt(w * 0.038 * k, FontWeight.w600, _gInk)),
        ],
      ),
    );

/// The app's own mala ring with its count, on a disc.
Widget _gRing(
  double size, {
  required int beads,
  required bool dark,
  Color? disc,
}) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: disc ?? (dark ? const Color(0xFF1C1B2E) : Colors.white),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF5A2A08).withValues(alpha: 0.3),
        blurRadius: size * 0.12,
        offset: Offset(0, size * 0.04),
      ),
    ],
  ),
  alignment: Alignment.center,
  child: Theme(
    data: dark ? AppTheme.dark() : AppTheme.light(),
    child: MalaRing(
      beads: beads,
      malaSize: 108,
      diameter: size * 0.84,
      child: Padding(
        padding: EdgeInsets.all(size * 0.2),
        child: MalaRingLabel(
          beads: beads,
          malaSize: 108,
          color: dark ? _gCream : _gInk,
        ),
      ),
    ),
  ),
);

Widget _gCompanion(ui.Image companion, double height) => RawImage(
  image: companion,
  height: height,
  filterQuality: FilterQuality.high,
);

/// Daily Jaap, Sep 21 to 27, as seeded for v2 (all mantras; goal 1,080).
const _gDays = [
  ('21', 1080),
  ('22', 1404),
  ('23', 1404),
  ('24', 1080),
  ('25', 1296),
  ('26', 1188),
  ('27', 612),
];

final _gfxShots = <_GfxShot>[
  _GfxShot(
    file: '01_jaap',
    badge: 'Ad‑free  •  No subscriptions',
    headline: [('Naam Jaap for\n', false), ('Radha, Ram & Shiv', true)],
    sub: '',
    art: (w, h, companion) => Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: h * _gTitleTop,
          child: Text(
            _mName(_hyMain),
            style: _gt(w * 0.1, FontWeight.w800, _gInk),
          ),
        ),
        Positioned(
          top: h * _gRingTop,
          child: _gRing(w * _gRingSize, beads: 72, dark: false),
        ),
        Positioned(
          left: -w * 0.02,
          bottom: -h * 0.01,
          child: _gCompanion(companion, h * 0.4),
        ),
      ],
    ),
  ),
  _GfxShot(
    file: '02_habit',
    headline: [('Build a\n', false), ('Daily Habit', true)],
    sub: 'Daily goals, streaks and Sankalp.',
    art: (w, h, companion) {
      final barMax = h * 0.34;
      return Column(
        children: [
          SizedBox(height: h * 0.03),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.06,
              vertical: w * 0.03,
            ),
            decoration: BoxDecoration(
              color: _gInk,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: _gGold,
                  size: w * 0.08,
                ),
                SizedBox(width: w * 0.02),
                Text(
                  _tr('22 days in a row'),
                  style: _gt(w * 0.06, FontWeight.w800, _gCream),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.04),
          Container(
            margin: EdgeInsets.symmetric(horizontal: w * 0.06),
            padding: EdgeInsets.fromLTRB(
              w * 0.06,
              w * 0.06,
              w * 0.06,
              w * 0.04,
            ),
            decoration: _gCardDeco(w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _tr('Daily Jaap'),
                      style: _gt(w * 0.05, FontWeight.w700, _gInk),
                    ),
                    const Spacer(),
                    Text(
                      _tr('Goal 1,080'),
                      style: _gt(w * 0.036, FontWeight.w600, _gBurnt),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.05),
                SizedBox(
                  height: barMax + w * 0.08,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final (i, (day, jaap)) in _gDays.indexed)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: w * 0.085,
                              height: barMax * jaap / 1404,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: i == _gDays.length - 1
                                      ? const [_gSaffron, _gBurnt]
                                      : const [
                                          Color(0xFFFFD48A),
                                          Color(0xFFF5A623),
                                        ],
                                ),
                              ),
                            ),
                            SizedBox(height: w * 0.02),
                            Text(
                              day,
                              style: _gt(
                                w * 0.035,
                                i == _gDays.length - 1
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                _gInk,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.03),
          Container(
            margin: EdgeInsets.symmetric(horizontal: w * 0.06),
            padding: EdgeInsets.all(w * 0.05),
            decoration: _gCardDeco(w),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr("TODAY'S JAAP"),
                      style: _gt(
                        w * 0.03,
                        FontWeight.w700,
                        _gSaffron,
                      ).copyWith(letterSpacing: 1),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '612',
                            style: _gt(w * 0.075, FontWeight.w800, _gInk),
                          ),
                          TextSpan(
                            text: ' / 1,080',
                            style: _gt(w * 0.04, FontWeight.w500, _gInk),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.035,
                    vertical: w * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: _gChip,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _tr('5 malas done'),
                    style: _gt(w * 0.036, FontWeight.w700, _gBurnt),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  ),
  _GfxShot(
    file: '03_blackout',
    look: _V2Look.black,
    headline: [('Chant Without\n', false), ('Distractions', true)],
    sub: 'A completely dark screen for peaceful Jaap.',
    art: (w, h, companion) => Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // What Blackout looks like: the mala barely lit, the count in grey.
        Positioned(
          top: h * _gTitleTop,
          left: w * 0.06,
          right: w * 0.06,
          // A long mantra (Hare Rama) shrinks to fit rather than run off.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _mName(_hyMain),
              maxLines: 1,
              style: _gt(
                w * 0.1,
                FontWeight.w600,
                Colors.white.withValues(alpha: 0.42),
              ),
            ),
          ),
        ),
        Positioned(
          top: h * _gRingTop - w * 0.16,
          width: w * 1.1,
          height: w * 1.1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  _gGold.withValues(alpha: 0.10),
                  _gGold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: h * _gRingTop + w * _gRingSize * 0.08,
          child: Opacity(
            opacity: 0.38,
            child: Theme(
              data: AppTheme.dark(),
              child: MalaRing(
                beads: 72,
                malaSize: 108,
                diameter: w * _gRingSize * 0.84,
                child: Text(
                  '72 / 108',
                  style: _gt(w * 0.075, FontWeight.w500, Colors.white),
                ),
              ),
            ),
          ),
        ),
        // A tap landing anywhere on the dark screen; only where there is
        // room under the mala (not on the shorter Play and Duo canvases).
        if (h / w > 1.5)
          Positioned(
            bottom: h * 0.16,
            child: SizedBox(
              width: w * 0.34,
              height: w * 0.34,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final (size, alpha) in const [
                    (1.0, 0.05),
                    (0.72, 0.09),
                    (0.46, 0.14),
                  ])
                    Container(
                      width: w * 0.34 * size,
                      height: w * 0.34 * size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: alpha * 2.5),
                          width: 1.5,
                        ),
                        color: Colors.white.withValues(alpha: alpha),
                      ),
                    ),
                  Icon(
                    Icons.touch_app_rounded,
                    size: w * 0.1,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: h * _gBottom,
          child: SizedBox(
            width: w * 0.94,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _gChipW(
                    w,
                    Icons.touch_app_rounded,
                    _tr('Tap anywhere'),
                    k: 0.9,
                  ),
                  SizedBox(width: w * 0.025),
                  _gChipW(
                    w,
                    Icons.volume_up_rounded,
                    _tr('Volume buttons count'),
                    k: 0.9,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
  _GfxShot(
    file: '04_auto_jaap',
    headline: [('Let Your\n', false), ('Jaap Flow', true)],
    sub: 'Chant hands-free at your own pace.',
    art: (w, h, companion) => Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: h * _gTitleTop,
          child: Text(
            _mName(_hyMain),
            style: _gt(w * 0.1, FontWeight.w800, _gInk),
          ),
        ),
        Positioned(
          top: h * _gRingTop,
          child: _gRing(w * _gRingSize, beads: 77, dark: false),
        ),
        Positioned(
          top: h * _gRingTop,
          right: w * 0.08,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: w * 0.022,
            ),
            decoration: BoxDecoration(
              color: _gSaffron,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: w * 0.06,
                ),
                Text(
                  _tr('Auto Jaap'),
                  style: _gt(w * 0.04, FontWeight.w800, Colors.white),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: w * 0.06,
          right: w * 0.06,
          bottom: h * 0.06,
          child: Container(
            padding: EdgeInsets.all(w * 0.05),
            decoration: _gCardDeco(w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr('One bead every'),
                  style: _gt(w * 0.045, FontWeight.w700, _gInk),
                ),
                SizedBox(height: w * 0.035),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final sec in AutoJaapConfig.paces)
                      Container(
                        width: w * 0.145,
                        padding: EdgeInsets.symmetric(vertical: w * 0.025),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sec == 1 ? _gSaffron : _gChip,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _hyL10n.autoJaapSeconds(sec),
                          style: _gt(
                            w * 0.042,
                            FontWeight.w700,
                            sec == 1 ? Colors.white : _gInk,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
  _GfxShot(
    file: '05_music',
    look: _V2Look.night,
    headline: [('Make Every Jaap\n', false), ('Peaceful', true)],
    sub: 'Chant with calming sounds and music.',
    art: (w, h, companion) {
      // A still of a sound wave: a soft rise and fall.
      final bars = [
        for (var i = 0; i < 23; i++)
          0.25 +
              0.75 *
                  (0.5 + 0.5 * math.sin(i * 0.7)) *
                  (1 - (i - 11).abs() / 16),
      ];
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: h * 0.05,
            child: Container(
              width: w * 0.5,
              height: w * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(colors: [_gGold, _gSaffron]),
                boxShadow: [
                  BoxShadow(
                    color: _gGold.withValues(alpha: 0.5),
                    blurRadius: w * 0.2,
                  ),
                ],
              ),
              child: Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: w * 0.24,
              ),
            ),
          ),
          Positioned(
            top: h * 0.37,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final b in bars)
                  Container(
                    width: w * 0.018,
                    height: w * 0.2 * b,
                    margin: EdgeInsets.symmetric(horizontal: w * 0.007),
                    decoration: BoxDecoration(
                      color: _gGold.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: w * 0.06,
            right: w * 0.06,
            bottom: h * 0.06,
            child: Container(
              padding: EdgeInsets.all(w * 0.05),
              decoration: _gCardDeco(w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr('NOW PLAYING'),
                    style: _gt(
                      w * 0.03,
                      FontWeight.w700,
                      _gSaffron,
                    ).copyWith(letterSpacing: 1),
                  ),
                  SizedBox(height: w * 0.01),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AmbientChantService.chants[1].label,
                          style: _gt(w * 0.05, FontWeight.w800, _gInk),
                        ),
                      ),
                      Icon(
                        Icons.pause_circle_filled_rounded,
                        color: _gSaffron,
                        size: w * 0.11,
                      ),
                    ],
                  ),
                  SizedBox(height: w * 0.03),
                  Wrap(
                    spacing: w * 0.02,
                    runSpacing: w * 0.02,
                    children: [
                      for (final i in const [3, 5, 0, 4])
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.03,
                            vertical: w * 0.016,
                          ),
                          decoration: BoxDecoration(
                            color: _gChip,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            AmbientChantService.chants[i].label,
                            style: _gt(w * 0.034, FontWeight.w600, _gInk),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  ),
  _GfxShot(
    file: '06_mantras',
    headline: [('Your Favourite Naam.\n', false), ('All in One Place.', true)],
    headlineScale: 0.8,
    sub: 'Ram, Radha, Krishna, Shiva and more.',
    art: (w, h, companion) {
      Widget row(String name, {bool active = false}) => Container(
        margin: EdgeInsets.only(bottom: w * 0.03),
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: w * 0.042,
        ),
        decoration:
            _gCardDeco(
              w,
              color: active ? const Color(0xFFFFF4DF) : Colors.white,
            ).copyWith(
              border: active ? Border.all(color: _gSaffron, width: 2) : null,
            ),
        child: Row(
          children: [
            Expanded(
              child: Text(name, style: _gt(w * 0.05, FontWeight.w700, _gInk)),
            ),
            Text('108', style: _gt(w * 0.034, FontWeight.w600, _gBurnt)),
            if (active) ...[
              SizedBox(width: w * 0.02),
              Icon(
                Icons.check_circle_rounded,
                color: _gSaffron,
                size: w * 0.06,
              ),
            ],
          ],
        ),
      );
      // On the shorter Play canvas the list shrinks to fit, never spills.
      return Padding(
        padding: EdgeInsets.fromLTRB(w * 0.07, h * 0.03, w * 0.07, 0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: w * 0.86,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: w * 0.04),
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.05,
                    vertical: w * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: _gInk,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _tr('22 mantras ready'),
                    style: _gt(w * 0.045, FontWeight.w800, _gCream),
                  ),
                ),
                for (final (i, id) in _hyMantraList().indexed)
                  row(_mName(id), active: i == 0),
                Container(
                  padding: EdgeInsets.symmetric(vertical: w * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(w * 0.06),
                    border: Border.all(color: _gBurnt.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: _gBurnt, size: w * 0.06),
                      SizedBox(width: w * 0.02),
                      Text(
                        _tr('Add your own mantra'),
                        style: _gt(w * 0.045, FontWeight.w700, _gBurnt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
  _GfxShot(
    file: '07_mala',
    headline: [('Your ', false), ('108-Bead\n', true), ('Digital Mala', false)],
    sub: 'Feel every bead with gentle haptic feedback.',
    art: (w, h, companion) => Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: h * _gTitleTop,
          child: Text(
            _mName(_hyMain),
            style: _gt(w * 0.1, FontWeight.w800, _gInk),
          ),
        ),
        Positioned(
          top: h * _gRingTop,
          child: _gRing(w * _gRingSize, beads: 107, dark: true),
        ),
        Positioned(
          bottom: h * _gBottom,
          child: _gChipW(
            w,
            Icons.vibration_rounded,
            _tr('Haptic on every bead'),
          ),
        ),
      ],
    ),
  ),
  _GfxShot(
    file: '08_language',
    headline: [('Your Practice.\n', false), ('Your Language.', true)],
    sub: 'Eleven languages. Ad‑free, no subscriptions.',
    art: (w, h, companion) => Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: h * _gTitleTop,
          left: w * 0.07,
          right: w * 0.07,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: w * 0.03,
            runSpacing: w * 0.03,
            children: [
              for (final (code, name) in AppLanguages.names.entries.map(
                (e) => (e.key, e.value),
              ))
                // Nine languages, three to a row.
                Container(
                  width: w * 0.26,
                  height: w * 0.15,
                  padding: EdgeInsets.symmetric(
                    vertical: w * 0.02,
                    horizontal: w * 0.02,
                  ),
                  alignment: Alignment.center,
                  decoration: _gCardDeco(
                    w,
                    color: code == _hyCode ? _gInk : Colors.white,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      // Bahasa Indonesia takes two lines, like a wrapped name.
                      name.replaceAll(' ', '\n'),
                      textAlign: TextAlign.center,
                      style: _gt(
                        w * 0.05,
                        FontWeight.w700,
                        code == _hyCode ? _gCream : _gInk,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: w * 0.07,
          bottom: h * 0.06,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(w * 0.08),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A2A08).withValues(alpha: 0.35),
                  blurRadius: w * 0.08,
                  offset: Offset(0, w * 0.03),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(w * 0.08),
              child: RawImage(
                image: _gIcon,
                width: w * 0.36,
                height: w * 0.36,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        Positioned(
          left: w * 0.06,
          bottom: h * 0.06,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _gChipW(w, Icons.block_rounded, _tr('Ad‑free')),
              SizedBox(height: w * 0.03),
              _gChipW(
                w,
                Icons.credit_card_off_rounded,
                _tr('No subscriptions'),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
];

class _GfxCanvas extends StatelessWidget {
  const _GfxCanvas({
    required this.shot,
    required this.size,
    required this.companion,
  });

  final _GfxShot shot;
  final Size size;
  final ui.Image companion;

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final h = size.height;
    final dark = shot.look != _V2Look.gold;
    final headlineSize =
        w *
        0.098 *
        shot.headlineScale *
        (const {'ta': 0.76, 'te': 0.86}[_hyCode] ?? 1.0);
    final ink = dark ? _gCream : _gInk;
    final highlight = dark ? _gGold : _gBurnt;
    final (headline, sub, badge) = _hyText(
      shot.file,
      shot.headline,
      shot.sub,
      shot.badge,
    );
    final soft = dark
        ? _gCream.withValues(alpha: 0.7)
        : const Color(0xFF6E5442);
    // The same for every shot, and level with the phones of the v2 set,
    // so a gallery mixing the two lines up.
    final artTop = h * 0.235;
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
                  colors: switch (shot.look) {
                    _V2Look.black => const [
                      Color(0xFF000000),
                      Color(0xFF120A05),
                    ],
                    _V2Look.night => const [
                      Color(0xFF2A0A04),
                      Color(0xFF5A1A07),
                      Color(0xFF8A3A0C),
                    ],
                    _V2Look.gold => const [
                      Color(0xFFFFE2A0),
                      Color(0xFFFFC25C),
                      Color(0xFFF5962A),
                    ],
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: w * 0.05,
            right: w * 0.05,
            top: h * 0.055,
            child: Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      for (final (t, hi) in headline)
                        TextSpan(
                          text: t,
                          style: TextStyle(color: hi ? highlight : ink),
                        ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: _gt(
                    headlineSize,
                    FontWeight.w800,
                    ink,
                  ).copyWith(height: 1.08, letterSpacing: -headlineSize * 0.03),
                ),
                if (sub.isNotEmpty) ...[
                  SizedBox(height: w * 0.03),
                  Text(
                    sub,
                    textAlign: TextAlign.center,
                    style: _gt(w * 0.041, FontWeight.w500, soft),
                  ),
                ],
                if (badge case final badge?) ...[
                  SizedBox(height: w * 0.035),
                  Container(
                    constraints: BoxConstraints(maxWidth: w * 0.9),
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: w * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        badge,
                        maxLines: 1,
                        style: _gt(w * 0.036, FontWeight.w700, _gBurnt),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: artTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: shot.art(w, h - artTop, companion),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The store gallery: 8 shots, phones where the counter is the story and
// graphics for the rest, then 09_brand. Drawn per language (_hyCode).

/// The language being drawn, and the mantra on its counter: Radha, the most
/// searched; otherwise what each language's readers chant most (the app's
/// own defaultMantraByLanguage, plus Krishna for Telugu).
String _hyCode = 'en';
String _hyMain = 'builtin.radha';
const _hyMains = {
  'pa': 'builtin.waheguru',
  'ta': 'builtin.om-namah-shivaya',
  'te': 'builtin.hare-krishna',
  'gu': 'builtin.shri-krishna',
  'ru': 'builtin.hare-rama',
  'id': 'builtin.om-namah-shivaya',
  'ms': 'builtin.om-namah-shivaya',
  'th': 'builtin.om-gam-ganapataye-namah',
};

/// The second mantra on the counter's history: Radhe for Russian devotees,
/// Ram for everyone else.
const _hySides = {'ru': 'builtin.radha'};

/// Inter, then this run's script, then every script.
const _hyFallback = [
  'NotoSansDevanagari',
  'NotoSansIndicAll',
  'NotoSansThaiAll',
];

AppL10n get _hyL10n => lookupAppL10n(Locale(_hyCode));

/// A built-in mantra's name as the app shows it in [_hyCode].
String _mName(String id) =>
    BuiltInMantras.all.firstWhere((m) => m.id == id).nameIn(_hyCode);

/// The mantra list on 06: this language's mantra first, then five more.
List<String> _hyMantraList() => [
  _hyMain,
  ...[
    'builtin.ram',
    'builtin.radha',
    'builtin.om-namah-shivaya',
    'builtin.hare-krishna',
    'builtin.waheguru',
    'builtin.om-namo-narayanaya',
  ].where((id) => id != _hyMain).take(5),
];

/// [english] in [_hyCode], or as it is.
String _tr(String english) => _hyUi[_hyCode]?[english] ?? english;

/// A shot's headline, sub-line and badge in [_hyCode].
(List<_Span>, String, String?) _hyText(
  String file,
  List<_Span> headline,
  String sub,
  String? badge,
) {
  if (_hyCode == 'en') return (headline, sub, badge);
  final copy = switch (file) {
    '01_jaap' => (_headlines['01_counter']![_hyCode]!.$1, ''),
    '02_habit' => (_headlines['04_habit']![_hyCode]!.$1, _hyHabitSub[_hyCode]!),
    _ => _hyHead[file]?[_hyCode],
  };
  return (
    copy == null ? headline : _spans(copy.$1),
    copy?.$2 ?? sub,
    badge == null ? null : _hyBadge[_hyCode] ?? badge,
  );
}

const _hyBadge = {
  'hi': 'विज्ञापन नहीं  •  सब्सक्रिप्शन नहीं',
  'mr': 'जाहिराती नाहीत  •  सबस्क्रिप्शन नाही',
  'gu': 'જાહેરાત નહીં  •  સબ્સ્ક્રિપ્શન નહીં',
  'pa': 'ਕੋਈ ਇਸ਼ਤਿਹਾਰ ਨਹੀਂ  •  ਕੋਈ ਸਬਸਕ੍ਰਿਪਸ਼ਨ ਨਹੀਂ',
  'ta': 'விளம்பரமில்லை  •  சந்தா இல்லை',
  'te': 'ప్రకటనలు లేవు  •  సబ్‌స్క్రిప్షన్ లేదు',
  'ru': 'Без рекламы  •  Без подписок',
  'id': 'Tanpa iklan  •  Tanpa langganan',
  'ms': 'Tanpa iklan  •  Tanpa langganan',
  'th': 'ไม่มีโฆษณา  •  ไม่ต้องสมัครสมาชิก',
};

const _hyHabitSub = {
  'hi': 'रोज़ का लक्ष्य, लगातार दिन और संकल्प।',
  'mr': 'रोजचे ध्येय, सातत्य आणि संकल्प.',
  'gu': 'રોજનું લક્ષ્ય, સાતત્ય અને સંકલ્પ.',
  'pa': 'ਰੋਜ਼ ਦਾ ਟੀਚਾ, ਲਗਾਤਾਰ ਦਿਨ ਅਤੇ ਸੰਕਲਪ।',
  'ta': 'தினசரி இலக்கு, தொடர்ச்சி, சங்கல்பம்.',
  'te': 'రోజువారీ లక్ష్యం, క్రమం, సంకల్పం.',
  'ru': 'Цели на день, серии дней и санкальпа.',
  'id': 'Target harian, hari beruntun, dan Sankalpa.',
  'ms': 'Sasaran harian, rekod berturut dan sankalpa.',
  'th': 'เป้าหมายรายวัน สถิติต่อเนื่อง และสังกัลปะ',
};

/// Headline (`*` marks the highlight) and sub-line per shot and language.
const _hyHead = <String, Map<String, (String, String)>>{
  '03_blackout': {
    'hi': ('बिना रुकावट\n*जप करें*', 'शांत जप के लिए पूरी तरह काली स्क्रीन।'),
    'mr': ('व्यत्ययाशिवाय\n*जप करा*', 'शांत जपासाठी पूर्ण काळी स्क्रीन.'),
    'gu': ('ખલેલ વગર\n*જપ કરો*', 'શાંત જપ માટે સંપૂર્ણ કાળી સ્ક્રીન.'),
    'pa': ('ਬਿਨਾਂ ਰੁਕਾਵਟ\n*ਜਪ ਕਰੋ*', 'ਸ਼ਾਂਤ ਜਪ ਲਈ ਪੂਰੀ ਕਾਲੀ ਸਕ੍ਰੀਨ।'),
    'ta': (
      'இடையூறு இல்லாமல்\n*ஜபம்*',
      'அமைதியான ஜபத்திற்கு முழு கருப்புத் திரை.',
    ),
    'te': (
      'అంతరాయం లేకుండా\n*జపం*',
      'ప్రశాంత జపానికి పూర్తిగా నల్లని స్క్రీన్.',
    ),
    'ru': (
      'Джапа без\n*отвлечений*',
      'Полностью тёмный экран для спокойной джапы.',
    ),
    'id': (
      'Japa Tanpa\n*Gangguan*',
      'Layar gelap total untuk japa yang tenang.',
    ),
    'ms': (
      'Japa Tanpa\n*Gangguan*',
      'Skrin gelap sepenuhnya untuk japa yang tenang.',
    ),
    'th': (
      'สวดมนต์\n*ไร้สิ่งรบกวน*',
      'หน้าจอมืดสนิท เพื่อการสวดอย่างสงบ',
    ),
  },
  '04_auto_jaap': {
    'hi': ('जप को\n*बहने दें*', 'अपनी गति से, बिना हाथ लगाए जप।'),
    'mr': ('जप\n*सहज वाहू द्या*', 'तुमच्या गतीने, हात न लावता जप.'),
    'gu': ('જપને\n*વહેવા દો*', 'તમારી ગતિએ, હાથ લગાવ્યા વગર જપ.'),
    'pa': ('ਜਪ ਨੂੰ\n*ਵਹਿਣ ਦਿਓ*', 'ਆਪਣੀ ਰਫ਼ਤਾਰ ਨਾਲ, ਬਿਨਾਂ ਹੱਥ ਲਾਏ ਜਪ।'),
    'ta': ('ஜபம்\n*தானாக ஓடட்டும்*', 'உங்கள் வேகத்தில், கை படாமல் ஜபம்.'),
    'te': ('జపాన్ని\n*సాగనివ్వండి*', 'మీ వేగంలో, చేయి తాకకుండా జపం.'),
    'ru': (
      'Пусть джапа\n*течёт сама*',
      'Повторяйте без рук, в своём темпе.',
    ),
    'id': (
      'Biarkan Japa\n*Mengalir*',
      'Japa tanpa tangan, sesuai tempo Anda.',
    ),
    'ms': (
      'Biarkan Japa\n*Mengalir*',
      'Japa tanpa tangan, mengikut rentak anda.',
    ),
    'th': (
      'ให้การสวด\n*ไหลลื่น*',
      'สวดโดยไม่ต้องใช้มือ ตามจังหวะของคุณ',
    ),
  },
  '05_music': {
    'hi': ('हर जप को\n*शांत बनाएं*', 'सुकून भरी ध्वनियों और संगीत के साथ जप।'),
    'mr': ('प्रत्येक जप\n*शांत करा*', 'सुखद ध्वनी आणि संगीतासह जप.'),
    'gu': ('દરેક જપ\n*શાંત બનાવો*', 'સુખદ અવાજો અને સંગીત સાથે જપ.'),
    'pa': ('ਹਰ ਜਪ ਨੂੰ\n*ਸ਼ਾਂਤ ਬਣਾਓ*', 'ਸੁਖਦ ਧੁਨਾਂ ਅਤੇ ਸੰਗੀਤ ਨਾਲ ਜਪ।'),
    'ta': ('ஒவ்வொரு ஜபமும்\n*அமைதியாக*', 'இதமான ஒலிகள், இசையுடன் ஜபம்.'),
    'te': ('ప్రతి జపం\n*ప్రశాంతంగా*', 'హాయైన శబ్దాలు, సంగీతంతో జపం.'),
    'ru': (
      'Каждая джапа —\n*в покое*',
      'Джапа под спокойные звуки и музыку.',
    ),
    'id': (
      'Setiap Japa\n*Lebih Damai*',
      'Japa dengan suara dan musik yang menenangkan.',
    ),
    'ms': (
      'Setiap Japa\n*Lebih Tenang*',
      'Japa diiringi bunyi dan muzik yang menenangkan.',
    ),
    'th': (
      'ทุกการสวด\n*สงบใจ*',
      'สวดพร้อมเสียงและดนตรีผ่อนคลาย',
    ),
  },
  '06_mantras': {
    'hi': ('आपका प्रिय नाम।\n*सब एक जगह।*', 'राम, राधा, कृष्ण, शिव और भी।'),
    'mr': (
      'तुमचे आवडते नाम.\n*सर्व एकाच ठिकाणी.*',
      'राम, राधा, कृष्ण, शिव आणि बरेच.',
    ),
    'gu': (
      'તમારું પ્રિય નામ.\n*બધું એક જગ્યાએ.*',
      'રામ, રાધા, કૃષ્ણ, શિવ અને વધુ.',
    ),
    'pa': (
      'ਤੁਹਾਡਾ ਪਿਆਰਾ ਨਾਮ।\n*ਸਭ ਇੱਕ ਥਾਂ।*',
      'ਵਾਹਿਗੁਰੂ, ਰਾਮ, ਰਾਧਾ, ਸ਼ਿਵ ਅਤੇ ਹੋਰ।',
    ),
    'ta': (
      'உங்கள் பிரிய நாமம்.\n*எல்லாம் ஒரே இடத்தில்.*',
      'ராம், ராதா, கிருஷ்ண, சிவ மேலும்.',
    ),
    'te': ('మీ ప్రియ నామం.\n*అన్నీ ఒకే చోట.*', 'రామ, రాధ, కృష్ణ, శివ ఇంకా.'),
    'ru': (
      'Любимые мантры.\n*Всё в одном месте.*',
      'Харе Кришна, Рама, Радха, Шива и другие.',
    ),
    'id': (
      'Mantra Favorit Anda.\n*Semua di Satu Tempat.*',
      'Om Namah Shivaya, Rama, Krishna, dan lainnya.',
    ),
    'ms': (
      'Mantra Kegemaran.\n*Semua di Satu Tempat.*',
      'Om Namah Shivaya, Rama, Krishna dan banyak lagi.',
    ),
    'th': (
      'มนต์ที่คุณรัก\n*รวมไว้ที่เดียว*',
      'พระพิฆเนศ พระศิวะ พระกฤษณะ และอื่นๆ',
    ),
  },
  '07_mala': {
    'hi': (
      'आपकी *108 मनकों*\nकी डिजिटल माला',
      'हर मनके पर हल्का कंपन महसूस करें।',
    ),
    'mr': (
      'तुमची *108 मण्यांची*\nडिजिटल माळ',
      'प्रत्येक मण्यावर हलके कंपन अनुभवा.',
    ),
    'gu': ('તમારી *108 મણકાની*\nડિજિટલ માળા', 'દરેક મણકે હળવું કંપન અનુભવો.'),
    'pa': (
      'ਤੁਹਾਡੀ *108 ਮਣਕਿਆਂ*\nਦੀ ਡਿਜੀਟਲ ਮਾਲਾ',
      'ਹਰ ਮਣਕੇ ਤੇ ਹਲਕੀ ਕੰਪਨ ਮਹਿਸੂਸ ਕਰੋ।',
    ),
    'ta': (
      'உங்கள் *108 மணி*\nடிஜிட்டல் மாலை',
      'ஒவ்வொரு மணிக்கும் மெல்லிய அதிர்வு.',
    ),
    'te': ('మీ *108 పూసల*\nడిజిటల్ మాల', 'ప్రతి పూసకు సున్నితమైన కంపనం.'),
    'ru': (
      'Цифровая мала\nиз *108 бусин*',
      'Лёгкая вибрация на каждой бусине.',
    ),
    'id': (
      'Mala Digital\n*108 Butir*',
      'Rasakan getar lembut di setiap butir.',
    ),
    'ms': (
      'Mala Digital\n*108 Biji*',
      'Rasai getaran lembut pada setiap biji.',
    ),
    'th': (
      'ลูกประคำดิจิทัล\n*108 เม็ด*',
      'สัมผัสการสั่นเบาๆ ทุกเม็ด',
    ),
  },
  '08_language': {
    'hi': (
      'आपकी साधना।\n*आपकी भाषा।*',
      'ग्यारह भाषाएँ। विज्ञापन नहीं, सब्सक्रिप्शन नहीं।',
    ),
    'mr': (
      'तुमची साधना.\n*तुमची भाषा.*',
      'अकरा भाषा. जाहिराती नाहीत, सबस्क्रिप्शन नाही.',
    ),
    'gu': (
      'તમારી સાધના.\n*તમારી ભાષા.*',
      'અગિયાર ભાષાઓ. જાહેરાત નહીં, સબ્સ્ક્રિપ્શન નહીં.',
    ),
    'pa': (
      'ਤੁਹਾਡੀ ਸਾਧਨਾ।\n*ਤੁਹਾਡੀ ਭਾਸ਼ਾ।*',
      'ਗਿਆਰਾਂ ਭਾਸ਼ਾਵਾਂ। ਕੋਈ ਇਸ਼ਤਿਹਾਰ ਨਹੀਂ, ਕੋਈ ਸਬਸਕ੍ਰਿਪਸ਼ਨ ਨਹੀਂ।',
    ),
    'ta': (
      'உங்கள் வழிபாடு.\n*உங்கள் மொழி.*',
      'பதினொரு மொழிகள். விளம்பரமில்லை, சந்தா இல்லை.',
    ),
    'te': (
      'మీ సాధన.\n*మీ భాష.*',
      'పదకొండు భాషలు. ప్రకటనలు లేవు, సబ్‌స్క్రిప్షన్ లేదు.',
    ),
    'ru': (
      'Ваша практика.\n*Ваш язык.*',
      'Одиннадцать языков. Без рекламы и подписок.',
    ),
    'id': (
      'Praktik Anda.\n*Bahasa Anda.*',
      'Sebelas bahasa. Tanpa iklan, tanpa langganan.',
    ),
    'ms': (
      'Amalan Anda.\n*Bahasa Anda.*',
      'Sebelas bahasa. Tanpa iklan, tanpa langganan.',
    ),
    'th': (
      'การปฏิบัติของคุณ\n*ภาษาของคุณ*',
      '11 ภาษา ไม่มีโฆษณา ไม่ต้องสมัครสมาชิก',
    ),
  },
};

/// The small words on chips and cards, keyed by their English.
final _hyUi = <String, Map<String, String>>{
  for (final code in ['hi', 'mr', 'gu', 'pa', 'ta', 'te', 'ru', 'id', 'ms', 'th'])
    code: {
      '22 days in a row': _cardCopy[code]!['streakTitle']!,
      "TODAY'S JAAP": _cardCopy[code]!['todayEyebrow']!,
      'Tap anywhere': _cardCopy[code]!['tap']!,
      'Volume buttons count': _cardCopy[code]!['vol']!,
      'NOW PLAYING': _cardCopy[code]!['nowPlaying']!,
      'Haptic on every bead': _cardCopy[code]!['haptic']!,
      ..._hyWords[code]!,
    },
};

const _hyWords = <String, Map<String, String>>{
  'hi': {
    'Daily Jaap': 'दैनिक जाप',
    'Goal 1,080': 'लक्ष्य 1,080',
    '5 malas done': '5 माला पूरी',
    'One bead every': 'हर मनका',
    '22 mantras ready': '22 मंत्र तैयार',
    'Add your own mantra': 'अपना मंत्र जोड़ें',
    'Ad‑free': 'विज्ञापन नहीं',
    'No subscriptions': 'सब्सक्रिप्शन नहीं',
  },
  'mr': {
    'Daily Jaap': 'दैनिक जप',
    'Goal 1,080': 'ध्येय 1,080',
    '5 malas done': '5 माळा पूर्ण',
    'One bead every': 'प्रत्येक मणी',
    '22 mantras ready': '22 मंत्र तयार',
    'Add your own mantra': 'स्वतःचा मंत्र जोडा',
    'Ad‑free': 'जाहिराती नाहीत',
    'No subscriptions': 'सबस्क्रिप्शन नाही',
  },
  'gu': {
    'Daily Jaap': 'દૈનિક જપ',
    'Goal 1,080': 'લક્ષ્ય 1,080',
    '5 malas done': '5 માળા પૂર્ણ',
    'One bead every': 'દરેક મણકો',
    '22 mantras ready': '22 મંત્રો તૈયાર',
    'Add your own mantra': 'તમારો મંત્ર ઉમેરો',
    'Ad‑free': 'જાહેરાત નહીં',
    'No subscriptions': 'સબ્સ્ક્રિપ્શન નહીં',
  },
  'pa': {
    'Daily Jaap': 'ਰੋਜ਼ਾਨਾ ਜਪ',
    'Goal 1,080': 'ਟੀਚਾ 1,080',
    '5 malas done': '5 ਮਾਲਾ ਪੂਰੀਆਂ',
    'One bead every': 'ਹਰ ਮਣਕਾ',
    '22 mantras ready': '22 ਮੰਤਰ ਤਿਆਰ',
    'Add your own mantra': 'ਆਪਣਾ ਮੰਤਰ ਜੋੜੋ',
    'Ad‑free': 'ਕੋਈ ਇਸ਼ਤਿਹਾਰ ਨਹੀਂ',
    'No subscriptions': 'ਕੋਈ ਸਬਸਕ੍ਰਿਪਸ਼ਨ ਨਹੀਂ',
  },
  'ta': {
    'Daily Jaap': 'தினசரி ஜபம்',
    'Goal 1,080': 'இலக்கு 1,080',
    '5 malas done': '5 மாலை முடிந்தது',
    'One bead every': 'ஒவ்வொரு மணியும்',
    '22 mantras ready': '22 மந்திரங்கள் தயார்',
    'Add your own mantra': 'உங்கள் மந்திரம் சேர்க்கவும்',
    'Ad‑free': 'விளம்பரமில்லை',
    'No subscriptions': 'சந்தா இல்லை',
  },
  'te': {
    'Daily Jaap': 'రోజువారీ జపం',
    'Goal 1,080': 'లక్ష్యం 1,080',
    '5 malas done': '5 మాలలు పూర్తి',
    'One bead every': 'ప్రతి పూస',
    '22 mantras ready': '22 మంత్రాలు సిద్ధం',
    'Add your own mantra': 'మీ మంత్రం చేర్చండి',
    'Ad‑free': 'ప్రకటనలు లేవు',
    'No subscriptions': 'సబ్‌స్క్రిప్షన్ లేదు',
  },
  'ru': {
    'Daily Jaap': 'Джапа за день',
    'Goal 1,080': 'Цель 1 080',
    '5 malas done': '5 кругов пройдено',
    'One bead every': 'Бусина каждые',
    '22 mantras ready': '22 мантры готовы',
    'Add your own mantra': 'Добавьте свою мантру',
    'Ad‑free': 'Без рекламы',
    'No subscriptions': 'Без подписок',
  },
  'id': {
    'Daily Jaap': 'Japa Harian',
    'Goal 1,080': 'Target 1.080',
    '5 malas done': '5 mala selesai',
    'One bead every': 'Satu butir setiap',
    '22 mantras ready': '22 mantra siap',
    'Add your own mantra': 'Tambah mantra sendiri',
    'Ad‑free': 'Tanpa iklan',
    'No subscriptions': 'Tanpa langganan',
  },
  'ms': {
    'Daily Jaap': 'Japa Harian',
    'Goal 1,080': 'Sasaran 1,080',
    '5 malas done': '5 mala selesai',
    'One bead every': 'Satu biji setiap',
    '22 mantras ready': '22 mantra sedia',
    'Add your own mantra': 'Tambah mantra sendiri',
    'Ad‑free': 'Tanpa iklan',
    'No subscriptions': 'Tanpa langganan',
  },
  'th': {
    'Daily Jaap': 'การสวดรายวัน',
    'Goal 1,080': 'เป้าหมาย 1,080',
    '5 malas done': 'ครบ 5 รอบ',
    'One bead every': 'หนึ่งเม็ดทุก',
    '22 mantras ready': 'มนต์พร้อมสวด 22 บท',
    'Add your own mantra': 'เพิ่มมนต์ของคุณ',
    'Ad‑free': 'ไม่มีโฆษณา',
    'No subscriptions': 'ไม่ต้องสมัครสมาชิก',
  },
};

/// The gallery, in order: true for a phone (v2) shot, false for a graphic.
const _hybrid = [
  ('01_jaap', true),
  ('02_habit', false),
  ('03_blackout', false),
  ('04_auto_jaap', true),
  ('05_music', false),
  ('06_mantras', false),
  ('07_mala', true),
  ('08_language', false),
];

List<Color> _lookColors(_V2Look look) => switch (look) {
  _V2Look.black => const [Color(0xFF000000), Color(0xFF120A05)],
  _V2Look.night => const [
    Color(0xFF2A0A04),
    Color(0xFF5A1A07),
    Color(0xFF8A3A0C),
  ],
  _V2Look.gold => const [
    Color(0xFFFFE2A0),
    Color(0xFFFFC25C),
    Color(0xFFF5962A),
  ],
};

/// [build] laid out as a tall phone shot, centred on [canvas]: the iPhone
/// size as is, Play and the iPhone Duo with the background widened.
Widget _fitted(_V2Look look, Size canvas, Widget Function(Size) build) {
  final u = math.min(canvas.width, canvas.height / 1.8);
  return SizedBox(
    width: canvas.width,
    height: canvas.height,
    child: Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _lookColors(look),
              ),
            ),
          ),
        ),
        Center(child: build(Size(u, canvas.height))),
      ],
    ),
  );
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

/// iPhone Duo screenshot sizes in points (written at 3×): 1398×2034 for the
/// outer display, 2007×2853 for the inner one.
const _duoCanvases = [('outer', Size(466, 678)), ('inner', Size(669, 951))];

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
  _StoreLocale('ru', 'ru', 'ru-RU'),
  _StoreLocale('id', 'id', 'id'),
  _StoreLocale('ms', 'ms', 'ms'),
  _StoreLocale('th', 'th', 'th'),
];

/// The script font each language is drawn in; Devanagari is bundled with the
/// app, the rest live beside this test.
const _scriptFonts = {
  'gu': 'NotoSansGujarati',
  'pa': 'NotoSansGurmukhi',
  'ta': 'NotoSansTamil',
  'te': 'NotoSansTelugu',
  'th': 'NotoSansThai',
};

/// Headline (`*` marks the highlighted run) and sub-line per shot and language.
const _headlines = <String, Map<String, (String, String)>>{
  '01_counter': {
    'hi': (
      'नाम जप करें\n*राधा, राम, शिव*',
      'कहीं भी टैप करें, माला भरती जाएगी',
    ),
    'mr': ('नामजप करा\n*राधा, राम, शिव*', 'कुठेही टॅप करा, माळ भरत जाते'),
    'gu': ('નામ જપ કરો\n*કૃષ્ણ, રામ, શિવ*', 'ગમે ત્યાં ટૅપ કરો, માળા ભરાતી જાય'),
    'pa': (
      'ਨਾਮ ਜਪੋ\n*ਵਾਹਿਗੁਰੂ, ਰਾਮ, ਰਾਧਾ*',
      'ਕਿਤੇ ਵੀ ਟੈਪ ਕਰੋ, ਮਾਲਾ ਭਰਦੀ ਜਾਂਦੀ ਹੈ',
    ),
    'ta': (
      'நாம ஜபம்\n*சிவ, ராம, கிருஷ்ண*',
      'எங்கும் தட்டுங்கள், மாலை நிரம்பும்',
    ),
    'te': (
      'నామ జపం\n*రామ, కృష్ణ, శివ*',
      'ఎక్కడైనా ట్యాప్ చేయండి, మాల నిండుతుంది',
    ),
    'ru': ('Харе Кришна,\n*Харе Рама*', ''),
    'id': ('Japa Nama\n*Om Namah Shivaya*', ''),
    'ms': ('Japa Nama\n*Om Namah Shivaya*', ''),
    'th': ('สวดมนต์ทุกวัน\n*พระพิฆเนศ พระศิวะ*', ''),
  },
  '04_habit': {
    'hi': ('रोज़ की\n*आदत बनाएं*', 'लगातार दिन, चार्ट और हर जप का हिसाब'),
    'mr': ('रोजची\n*सवय घडवा*', 'सातत्य, आलेख आणि जपाचा प्रत्येक दिवस'),
    'gu': ('રોજની\n*ટેવ બનાવો*', 'સાતત્ય, ચાર્ટ અને જપનો દરેક દિવસ'),
    'pa': ('ਰੋਜ਼ ਦੀ\n*ਆਦਤ ਬਣਾਓ*', 'ਲਗਾਤਾਰ ਦਿਨ, ਚਾਰਟ ਅਤੇ ਜਪ ਦਾ ਹਰ ਦਿਨ'),
    'ta': (
      'தினசரிப்\n*பழக்கம்*',
      'தொடர்ச்சி, வரைபடங்கள், ஜபித்த ஒவ்வொரு நாளும்',
    ),
    'te': ('రోజువారీ\n*అలవాటు*', 'క్రమం, చార్టులు, జపించిన ప్రతి రోజు'),
    'ru': ('Ежедневная\n*практика*', ''),
    'id': ('Bangun\n*Kebiasaan Harian*', ''),
    'ms': ('Bina\n*Amalan Harian*', ''),
    'th': ('สร้าง\n*นิสัยสวดมนต์*', ''),
  },
  '03_music': {
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
  '02_mantras': {
    'hi': (
      '*21 पवित्र मंत्र*\nया अपना खुद का',
      'राम, राधे, ॐ नमः शिवाय, वाहेगुरु और भी',
    ),
    'mr': (
      '*21 पवित्र मंत्र*\nकिंवा स्वतःचा',
      'राम, राधे, ॐ नमः शिवाय, वाहेगुरु आणि बरेच',
    ),
    'gu': (
      '*21 પવિત્ર મંત્રો*\nઅથવા તમારો પોતાનો',
      'રામ, રાધે, ૐ નમઃ શિવાય, વાહેગુરુ અને વધુ',
    ),
    'pa': (
      '*21 ਪਵਿੱਤਰ ਮੰਤਰ*\nਜਾਂ ਆਪਣਾ',
      'ਰਾਮ, ਰਾਧੇ, ਓਮ ਨਮਃ ਸ਼ਿਵਾਏ, ਵਾਹਿਗੁਰੂ ਅਤੇ ਹੋਰ',
    ),
    'ta': (
      '*21 புனித மந்திரங்கள்*\nஅல்லது சொந்தம்',
      'ராம், ராதே, ஓம் நம சிவாய, வாஹேகுரு மேலும்',
    ),
    'te': (
      '*21 పవిత్ర మంత్రాలు*\nలేదా మీ సొంతం',
      'రామ, రాధే, ఓం నమః శివాయ, వాహెగురు ఇంకా',
    ),
  },
  '06_sankalp': {
    'hi': ('एक *संकल्प* लें।\nउसे निभाएं।', '11, 21 या 40 दिन रोज़ जप करें'),
    'mr': ('एक *संकल्प* घ्या.\nतो निभवा.', '11, 21 किंवा 40 दिवस रोज जप करा'),
    'gu': ('એક *સંકલ્પ* લો.\nતેને નિભાવો.', '11, 21 કે 40 દિવસ રોજ જપ કરો'),
    'pa': ('ਇੱਕ *ਸੰਕਲਪ* ਲਓ।\nਇਸ ਨੂੰ ਨਿਭਾਓ।', '11, 21 ਜਾਂ 40 ਦਿਨ ਰੋਜ਼ ਜਪ ਕਰੋ'),
    'ta': ('ஒரு *சங்கல்பம்*\nஎடுங்கள்', '11, 21 அல்லது 40 நாள் தினமும் ஜபம்'),
    'te': (
      'ఒక *సంకల్పం* చేయండి.\nనిలబెట్టుకోండి.',
      '11, 21 లేదా 40 రోజులు రోజూ జపం',
    ),
  },
  '05_blackout': {
    'hi': (
      'आंखें बंद करके\n*जप करें*',
      'काली स्क्रीन। कहीं भी टैप करके गिनें।',
    ),
    'mr': ('डोळे मिटून\n*जप करा*', 'काळी स्क्रीन. कुठेही टॅप करून मोजा.'),
    'gu': (
      'આંખો બંધ કરીને\n*જપ કરો*',
      'કાળી સ્ક્રીન. ગમે ત્યાં ટૅપ કરીને ગણો.',
    ),
    'pa': ('ਅੱਖਾਂ ਬੰਦ ਕਰ ਕੇ\n*ਜਪ ਕਰੋ*', 'ਕਾਲੀ ਸਕ੍ਰੀਨ। ਕਿਤੇ ਵੀ ਟੈਪ ਕਰ ਕੇ ਗਿਣੋ।'),
    'ta': (
      'கண்களை மூடி\n*ஜபம் செய்யுங்கள்*',
      'கருப்புத் திரை. எங்கும் தட்டி எண்ணுங்கள்.',
    ),
    'te': (
      'కళ్ళు మూసుకుని\n*జపం చేయండి*',
      'నల్లని స్క్రీన్. ఎక్కడైనా ట్యాప్ చేసి లెక్కించండి.',
    ),
  },
  '07_themes': {
    'hi': ('अपनी पसंद का\n*रंग चुनें*', '13 थीम, या अपनी फ़ोटो'),
    'mr': ('तुमच्या आवडीचा\n*रंग निवडा*', '13 थीम, किंवा तुमचा फोटो'),
    'gu': ('તમારી પસંદનો\n*રંગ પસંદ કરો*', '13 થીમ, અથવા તમારો ફોટો'),
    'pa': ('ਆਪਣੀ ਪਸੰਦ ਦਾ\n*ਰੰਗ ਚੁਣੋ*', '13 ਥੀਮ, ਜਾਂ ਆਪਣੀ ਫੋਟੋ'),
    'ta': ('உங்களுக்குப் பிடித்த\n*வண்ணம்*', '13 தீம்கள், அல்லது உங்கள் படம்'),
    'te': ('మీకు నచ్చిన\n*రంగు ఎంచుకోండి*', '13 థీమ్‌లు, లేదా మీ ఫోటో'),
  },
};

/// The trust badge over the first shot, per language.
const _badges = {
  'hi': 'विज्ञापन नहीं  •  निजी  •  बिना इंटरनेट',
  'mr': 'जाहिराती नाहीत  •  खाजगी  •  इंटरनेटशिवाय',
  'gu': 'જાહેરાત નહીં  •  ખાનગી  •  ઇન્ટરનેટ વગર',
  'pa': 'ਕੋਈ ਇਸ਼ਤਿਹਾਰ ਨਹੀਂ  •  ਨਿੱਜੀ  •  ਬਿਨਾਂ ਇੰਟਰਨੈੱਟ',
  'ta': 'விளம்பரமில்லை  •  ஆஃப்லைன்',
  'te': 'ప్రకటనలు లేవు  •  ప్రైవేట్  •  ఆఫ్‌లైన్',
};

/// Words on the feature cards, per language.
const _cardCopy = <String, Map<String, String>>{
  // Russian and Indonesian draw only the gallery, which uses these few;
  // anything else falls back to English (see _ct).
  'ru': {
    'todayEyebrow': 'ДЖАПА СЕГОДНЯ',
    'haptic': 'Вибрация на каждой бусине',
    'streakTitle': '22 дня подряд',
    'nowPlaying': 'СЕЙЧАС ИГРАЕТ',
    'tap': 'Касание в любом месте',
    'vol': 'Счёт кнопками громкости',
  },
  'id': {
    'todayEyebrow': 'JAPA HARI INI',
    'haptic': 'Getar di setiap butir',
    'streakTitle': '22 hari berturut-turut',
    'nowPlaying': 'SEDANG DIPUTAR',
    'tap': 'Ketuk di mana saja',
    'vol': 'Tombol volume menghitung',
  },
  'ms': {
    'todayEyebrow': 'JAPA HARI INI',
    'haptic': 'Getaran pada setiap biji',
    'streakTitle': '22 hari berturut-turut',
    'nowPlaying': 'SEDANG DIMAINKAN',
    'tap': 'Ketik di mana-mana',
    'vol': 'Butang kelantangan mengira',
  },
  'th': {
    'todayEyebrow': 'การสวดวันนี้',
    'haptic': 'สั่นทุกเม็ด',
    'streakTitle': 'ต่อเนื่อง 22 วัน',
    'nowPlaying': 'กำลังเล่น',
    'tap': 'แตะที่ใดก็ได้',
    'vol': 'นับด้วยปุ่มเสียง',
  },
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

      // The earlier shots, captured bare for the creative assets
      // (tool/make_creative_assets.py) and the search-results video.
      for (final shot in _shots) {
        final bytes = await _captureApp(
          tester,
          shot,
          Locale(loc.code),
          sequenceDir: shot.file == '01_counter'
              ? '$root/build/store_raw/${loc.iosDir}/counter_seq'
              : null,
        );
        File('$root/build/store_raw/${loc.iosDir}/${shot.file}.png')
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(bytes);
      }

      // The store gallery.
      _hyCode = loc.code;
      _hyMain = _hyMains[loc.code] ?? 'builtin.radha';
      late ui.Image companion;
      await tester.runAsync(() async {
        companion = await decodeImageFromList(
          File('$root/assets/branding/companion.png').readAsBytesSync(),
        );
        _gIcon = await decodeImageFromList(
          File('$root/appstore_assets/appicon-fullbleed.png').readAsBytesSync(),
        );
      });
      final sizes = [
        (const Size(440, 956), iosDir),
        (const Size(360, 640), playDir),
        for (final (name, canvas) in _duoCanvases)
          (canvas, '$root/appstore_assets/iphone-duo/${loc.iosDir}/$name'),
      ];
      for (final (file, phone) in _hybrid) {
        late _V2Look look;
        late Widget Function(Size) build;
        if (phone) {
          final shot = _v2Shots.firstWhere((s) => s.file == file);
          final bytes = await _captureApp(
            tester,
            _Shot(
              file: file,
              headline: const [],
              sub: '',
              capture: shot.capture,
            ),
            Locale(loc.code),
            seed: () => _seededApp(
              main: _hyMain,
              side: _hySides[loc.code] ?? 'builtin.ram',
            ),
          );
          late ui.Image screen;
          await tester.runAsync(() async {
            screen = await decodeImageFromList(bytes);
          });
          look = shot.look;
          build = (size) => _V2Canvas(
            shot: shot,
            screen: screen,
            size: size,
            companion: companion,
          );
        } else {
          final shot = _gfxShots.firstWhere((s) => s.file == file);
          look = shot.look;
          build = (size) =>
              _GfxCanvas(shot: shot, size: size, companion: companion);
        }
        for (final (canvas, dir) in sizes) {
          await _renderTo(
            tester,
            _fitted(look, canvas, build),
            canvas,
            '$dir/$file.png',
          );
        }
      }
      _v2Auto?.stop();
      await tester.pump(const Duration(seconds: 30));

      // 09_brand: the icon, the name and the companion. Not on Google Play,
      // which takes at most 8 phone screenshots.
      for (final (canvas, path) in [
        (const Size(440, 956), '$iosDir/09_brand.png'),
        for (final (name, canvas) in _duoCanvases)
          (
            canvas,
            '$root/appstore_assets/iphone-duo/${loc.iosDir}/$name/09_brand.png',
          ),
      ]) {
        await _renderTo(
          tester,
          _BrandCanvas(
            size: canvas,
            code: loc.code,
            icon: _gIcon,
            companion: companion,
          ),
          canvas,
          path,
        );
      }
    }
  });
}
