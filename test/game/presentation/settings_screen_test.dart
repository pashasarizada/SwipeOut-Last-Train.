import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/data/settings_repository.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/game_settings.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/presentation/game/progress_store.dart';
import 'package:swipeout_last_train/game/presentation/game/settings_store.dart';
import 'package:swipeout_last_train/game/presentation/kit/signal_toggle.dart';
import 'package:swipeout_last_train/game/presentation/screens/home_screen.dart';
import 'package:swipeout_last_train/game/presentation/screens/settings_screen.dart';

import '../../support/graph_builders.dart';
import '../../support/memory_progress_repository.dart';

final class _MemorySettings implements SettingsRepository {
  GameSettings stored = const GameSettings();

  @override
  Future<GameSettings> load() async => stored;

  @override
  Future<void> save(GameSettings settings) async => stored = settings;
}

void main() {
  testWidgets('settings open from home; changes apply and are saved', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final repo = _MemorySettings();
    final settings = SettingsStore(
      repository: repo,
      settings: const GameSettings(language: GameLanguage.en),
    );
    await tester.pumpWidget(
      SwipeOutApp(
        settings: settings,
        store: ProgressStore(
          catalog: {
            CityId.ankara: [ank01()],
          },
          repository: MemoryProgressRepository(),
          progress: const Progress(),
        ),
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.tap(find.byType(SignalToggle).first);
    await tester.pumpAndSettle();
    expect(repo.stored.vibration, isFalse);

    await tester.tap(find.text('TÜRKÇE'));
    await tester.pumpAndSettle();
    expect(repo.stored.language, GameLanguage.tr);
    expect(find.text('AYARLAR'), findsOneWidget);
  });
}
