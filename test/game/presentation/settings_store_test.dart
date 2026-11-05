import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/data/settings_repository.dart';
import 'package:swipeout_last_train/game/domain/game_settings.dart';
import 'package:swipeout_last_train/game/presentation/game/settings_store.dart';
import 'package:swipeout_last_train/game/presentation/kit/motion_settings.dart';

final class _MemorySettings implements SettingsRepository {
  GameSettings stored = const GameSettings();

  @override
  Future<GameSettings> load() async => stored;

  @override
  Future<void> save(GameSettings settings) async => stored = settings;
}

void main() {
  test('an update is live at once and saved', () async {
    final repo = _MemorySettings();
    final store = SettingsStore(
      repository: repo,
      settings: const GameSettings(),
    );
    var notified = 0;
    store.addListener(() => notified++);

    await store.update(store.settings.copyWith(vibration: false));

    expect(store.settings.vibration, isFalse);
    expect(repo.stored.vibration, isFalse);
    expect(notified, 1);
  });

  testWidgets('the chosen language and motion apply to the whole app', (
    tester,
  ) async {
    final store = SettingsStore(
      repository: _MemorySettings(),
      settings: const GameSettings(
        language: GameLanguage.tr,
        reducedMotion: true,
      ),
    );
    late BuildContext inside;
    await tester.pumpWidget(
      SwipeOutApp(
        settings: store,
        home: Builder(
          builder: (context) {
            inside = context;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(Localizations.localeOf(inside).languageCode, 'tr');
    expect(MotionSettings.reducedOf(inside), isTrue);

    await store.update(store.settings.copyWith(language: GameLanguage.en));
    await tester.pump();
    expect(Localizations.localeOf(inside).languageCode, 'en');
  });
}
