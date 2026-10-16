import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/app/theme/app_colors.dart';
import 'package:japmala/core/services/widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  late Map<String, Object?> saved;

  setUp(() {
    saved = {};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'saveWidgetData') {
            final args = call.arguments as Map;
            saved[args['id'] as String] = args['data'];
          }
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> publish(AppPalette? palette) => WidgetService().publish(
    mantraDisplay: 'Ram',
    beadsInCurrentMala: 5,
    malaSize: 108,
    todayTotal: 113,
    todayMalas: 1,
    streak: 3,
    palette: palette,
  );

  // On iOS a null reaches UserDefaults as NSNull and crashes the app.
  test('never saves null for the Auto theme', () async {
    await publish(null);

    expect(saved, isNotEmpty);
    expect(saved.values, isNot(contains(null)));
    expect(saved['themed'], isFalse);
    expect(saved.keys.where((k) => k.startsWith('color')), isEmpty);
  });

  test('saves the colours of a chosen theme', () async {
    final palette = AppPalette.light();
    await publish(palette);

    expect(saved.values, isNot(contains(null)));
    expect(saved['themed'], isTrue);
    expect(saved['colorBackground'], palette.background.toARGB32());
    expect(saved['colorAccent'], palette.saffron.toARGB32());
  });
}
