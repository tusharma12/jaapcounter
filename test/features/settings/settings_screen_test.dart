import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/providers.dart';
import 'package:japmala/core/services/widget_service.dart';
import 'package:japmala/features/settings/presentation/settings_screen.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../support/test_harness.dart';

/// Captures what would have been launched, instead of reaching the OS.
class _FakeUrlLauncher extends UrlLauncherPlatform {
  String? lastLaunched;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunched = url;
    return true;
  }

  @override
  LinkDelegate? get linkDelegate => null;
}

/// Lets a test fix whether the launcher can be asked to place the widget
/// directly, without a real platform channel.
class _FakeWidgetService extends WidgetService {
  _FakeWidgetService({required this.canPin});

  final bool canPin;
  bool pinRequested = false;

  @override
  Future<bool> canRequestPin() async => canPin;

  @override
  Future<void> requestPin() async => pinRequested = true;
}

void main() {
  late _FakeUrlLauncher urlLauncher;

  setUp(() {
    urlLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = urlLauncher;
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    required ProviderContainer container,
  }) async {
    await usePhoneSurface(tester);
    await pumpScreen(tester, container, const SettingsScreen());
    await tester.pumpAndSettle();
  }

  testWidgets('feedback opens a mail composer addressed to Codivo Labs', (
    tester,
  ) async {
    final container = await createTestContainer();
    await pumpSettings(tester, container: container);

    await tester.scrollUntilVisible(find.text('Feedback'), 300);
    await tester.ensureVisible(find.text('Feedback'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Feedback'));
    await tester.pumpAndSettle();

    expect(urlLauncher.lastLaunched, isNotNull);
    final uri = Uri.parse(urlLauncher.lastLaunched!);
    expect(uri.scheme, 'mailto');
    expect(uri.path, 'codivolabs@gmail.com');
    expect(uri.queryParameters['subject'], 'Smaran feedback');
  });

  testWidgets('a launcher that can place the widget gets an Add button', (
    tester,
  ) async {
    final container = await createTestContainer(
      overrides: [
        widgetServiceProvider.overrideWithValue(
          _FakeWidgetService(canPin: true),
        ),
      ],
    );
    await pumpSettings(tester, container: container);

    await tester.scrollUntilVisible(find.text('Home screen widget'), 100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home screen widget'));
    await tester.pumpAndSettle();

    expect(find.text('Add to Home Screen'), findsOneWidget);
    expect(
      find.textContaining('Long-press an empty spot'),
      findsNothing,
      reason: 'the button replaces the manual steps',
    );

    await tester.tap(find.text('Add to Home Screen'));
    await tester.pumpAndSettle();

    final fake = container.read(widgetServiceProvider) as _FakeWidgetService;
    expect(fake.pinRequested, isTrue);
    expect(find.text('Add to Home Screen'), findsNothing, reason: 'closed');
  });

  testWidgets('a launcher that cannot place it shows the manual steps', (
    tester,
  ) async {
    final container = await createTestContainer(
      overrides: [
        widgetServiceProvider.overrideWithValue(
          _FakeWidgetService(canPin: false),
        ),
      ],
    );
    await pumpSettings(tester, container: container);

    await tester.scrollUntilVisible(find.text('Home screen widget'), 100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home screen widget'));
    await tester.pumpAndSettle();

    expect(find.text('Add to Home Screen'), findsNothing);
    expect(find.textContaining('Long-press an empty spot'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Home screen widget'), findsOneWidget, reason: 'closed');
  });
}
