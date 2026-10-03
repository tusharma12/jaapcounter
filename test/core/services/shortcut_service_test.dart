import 'package:flutter_test/flutter_test.dart';
import 'package:japmala/core/services/shortcut_service.dart';
import 'package:quick_actions/quick_actions.dart';

class _FakeActions implements QuickActions {
  List<ShortcutItem> items = const [];
  int initialised = 0;

  @override
  Future<void> initialize(QuickActionHandler handler) async => initialised++;

  @override
  Future<void> setShortcutItems(List<ShortcutItem> newItems) async =>
      items = newItems;

  @override
  Future<void> clearShortcutItems() async => items = const [];
}

void main() {
  test('the home screen offers music first, then Blackout', () async {
    final actions = _FakeActions();
    final service = ShortcutService(actions);

    await service.publish(blackoutLabel: 'Blackout', musicLabel: 'Play music');

    expect(actions.items.map((i) => i.type), [
      ShortcutService.music,
      ShortcutService.blackout,
    ]);
    expect(actions.items.first.localizedTitle, 'Play music');
    expect(actions.items.first.icon, 'shortcut_music');
  });

  test('the music shortcut says what it will do now', () async {
    final actions = _FakeActions();
    final service = ShortcutService(actions);

    await service.publish(blackoutLabel: 'Blackout', musicLabel: 'Play music');
    await service.publish(blackoutLabel: 'Blackout', musicLabel: 'Stop music');

    expect(actions.items.first.localizedTitle, 'Stop music');
  });

  test('listening starts once however often the list changes', () async {
    final actions = _FakeActions();
    final service = ShortcutService(actions);

    await service.initialize((_) {});
    await service.publish(blackoutLabel: 'a', musicLabel: 'b');
    await service.publish(blackoutLabel: 'a', musicLabel: 'c');

    expect(actions.initialised, 1);
  });
}
