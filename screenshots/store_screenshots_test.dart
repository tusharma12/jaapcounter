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
    this.lightCanvas = false,
    this.headlineHi,
    this.subHi,
  });

  final String file;
  final List<_Span> headline;
  final String sub;

  /// Hindi headline/sub; null on the hero (reused as-is across locales).
  final List<_Span>? headlineHi;
  final String? subHi;

  /// Drives the app to the screen to capture.
  final Future<void> Function(WidgetTester, ProviderContainer, GoRouter)
  capture;

  /// The warm cream/peach cover background (matching the hero screenshot)
  /// instead of the maroon gradient, with dark headline text.
  final bool lightCanvas;

  /// White status-bar glyphs, for screens that are dark themselves.
  final bool darkStatusBar;
  final String? badge;
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
    lightCanvas: true,
    headline: [
      ('Build a Daily\nNaam Jap ', false),
      ('Sadhana', true),
      (' Habit', false),
    ],
    sub: 'A simple and modern way to track your daily chants',
    headlineHi: [('रोज़ नाम जप की\n', false), ('साधना', true), (' बनाएं', false)],
    subHi: 'अपने दैनिक जप को सरल और आधुनिक तरीके से ट्रैक करें',
    // The counter screen, mid-session: this morning's jaap already underway.
    capture: (tester, c, router) async {},
  ),
  _Shot(
    file: '03_streak',
    lightCanvas: true,
    headline: [
      ('Track Your Progress.\n', false),
      ('Stay Motivated.', true),
    ],
    sub: 'View your daily, weekly and total chant progress',
    headlineHi: [
      ('अपनी प्रगति देखें।\n', false),
      ('प्रेरित रहें।', true),
    ],
    subHi: 'अपना दैनिक, साप्ताहिक और कुल जप देखें',
    capture: (tester, c, router) async {
      router.go('/progress');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '04_mantras',
    lightCanvas: true,
    headline: [('21 Sacred', true), (' Mantras\n— or Your Own', false)],
    sub: 'Ram, Radha, Shiva, Gayatri & more',
    headlineHi: [
      ('21 पवित्र मंत्र', true),
      ('\n— या अपना खुद का', false),
    ],
    subHi: 'राम, राधा, शिव, गायत्री और भी बहुत कुछ',
    capture: (tester, c, router) async {
      router.push('/mantras');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '05_sankalp',
    lightCanvas: true,
    headline: [('Take a ', false), ('Sankalp', true), ('.\nKeep It.', false)],
    sub: 'A 40-day vow with a daily mala goal',
    headlineHi: [
      ('एक ', false),
      ('संकल्प', true),
      (' लें।\nउसे निभाएं।', false),
    ],
    subHi: '40 दिनों की प्रतिज्ञा, रोज़ माला के लक्ष्य के साथ',
    capture: (tester, c, router) async {
      router.push('/sadhana');
      await _settle(tester);
    },
  ),
  _Shot(
    file: '06_blackout',
    lightCanvas: true,
    darkStatusBar: true,
    headline: [('Chant with Your\n', false), ('Eyes Closed', true)],
    sub: 'Pure black screen. One tap per bead.',
    headlineHi: [('आंखें बंद करके\n', false), ('जप करें', true)],
    subHi: 'पूरी तरह काली स्क्रीन। हर मनके पर एक टैप।',
    capture: (tester, c, router) async {
      router.push('/blackout');
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('blackout-show-mantra')));
      await _settle(tester);
    },
  ),
  _Shot(
    file: '07_themes',
    darkStatusBar: true,
    headline: [('Choose Your\n', false), ('Sacred Space', true)],
    sub: '13 themes, bead mala, falling mantra',
    headlineHi: [('अपना ', false), ('पवित्र स्थान', true), ('\nचुनें', false)],
    subHi: '13 थीम, माला के मनके, गिरते मंत्र',
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

Future<void> _settle(WidgetTester tester) async {
  // Never pumpAndSettle: the counter's animations would keep it spinning.
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

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
  for (final f in Directory('assets/fonts').listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    final loader = FontLoader(
      name.startsWith('Noto') ? 'NotoSansDevanagari' : 'Inter',
    )..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
    await loader.load();
  }
}

/// 23 days in a row of steady Jaap, a gap, and some earlier practice.
Future<ProviderContainer> _seededApp() async {
  final clock = TestClock(_now);
  final container = await createTestContainer(clock: clock);
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
  required bool hindi,
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
          hindi: hindi,
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
    this.hindi = false,
  });

  final _Shot shot;
  final ui.Image screen;
  final Size size;
  final bool hindi;

  static const _cream = Color(0xFFFFF4E2);
  static const _saffron = Color(0xFFFFB23F);

  // The warm cream/peach cover, matching the hero screenshot's background.
  static const _peachTop = Color(0xFFFFE9D6);
  static const _peachMid = Color(0xFFFDD3C0);
  static const _peachBottom = Color(0xFFEFC0AC);
  static const _ink = Color(0xFF241608);
  static const _inkMuted = Color(0xFF6E5B52);
  static const _rust = Color(0xFFD9600F);

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final h = size.height;
    final tall = h / w > 2;
    final headlineSize = w * (tall ? 0.092 : 0.082);
    final phoneTop = h * (tall ? 0.268 : 0.305);
    // The phone runs a little off the bottom edge, as if held up to you.
    final phoneHeight = h - phoneTop + h * 0.035;
    final phoneWidth = phoneHeight * (_device.width / _device.height);

    final background = shot.lightCanvas
        ? const [_peachTop, _peachMid, _peachBottom]
        : const [Color(0xFF2A0A04), Color(0xFF5A1A07), Color(0xFF8A3A0C)];

    final highlightColor = shot.lightCanvas ? _rust : _saffron;
    final headlineColor = shot.lightCanvas ? _ink : _cream;
    final subColor = shot.lightCanvas
        ? _inkMuted
        : _cream.withValues(alpha: 0.78);
    final badgeColor = shot.lightCanvas ? _rust : _saffron;
    final textFont = hindi ? 'NotoSansDevanagari' : 'Inter';
    final headline = hindi ? (shot.headlineHi ?? shot.headline) : shot.headline;
    final sub = hindi ? (shot.subHi ?? shot.sub) : shot.sub;

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
          if (!shot.lightCanvas)
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
        ],
      ),
    );
  }
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
                      'Naam Jap Counter',
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
                      'Smaran',
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
];

void main() {
  testWidgets('store screenshots', (tester) async {
    await tester.runAsync(_loadFonts);
    addTearDown(tester.view.reset);

    final root = Directory.current.path;

    await _featureGraphic(
      tester,
      '$root/android/fastlane/metadata/android/en-US/images/featureGraphic.png',
    );

    for (final loc in _locales) {
      final hindi = loc.code == 'hi';
      final iosDir = '$root/ios/fastlane/screenshots/${loc.iosDir}';
      final playDir =
          '$root/android/fastlane/metadata/android/${loc.playDir}/images/phoneScreenshots';
      Directory(iosDir).createSync(recursive: true);
      Directory(playDir).createSync(recursive: true);

      for (final shot in _shots) {
        // The hero cover image (icon, name, hand with mala) is a hand-made
        // graphic, localized by hand per locale; never overwrite it here.
        if (shot.file == '01_counter') continue;
        final bytes = await _captureApp(
          tester,
          shot,
          Locale(loc.code),
        );
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
          hindi: hindi,
        );
        await _compose(
          tester,
          shot,
          screen,
          canvas: const Size(360, 640),
          path: '$playDir/${shot.file}.png',
          hindi: hindi,
        );
      }
    }
  });
}
