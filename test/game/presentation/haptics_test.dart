import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/data/settings_repository.dart';
import 'package:swipeout_last_train/game/domain/game_settings.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';
import 'package:swipeout_last_train/game/presentation/game/settings_store.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_button.dart';
import 'package:swipeout_last_train/game/presentation/kit/signal_back_button.dart';

import '../../support/graph_builders.dart';

final class _MemorySettings implements SettingsRepository {
  @override
  Future<GameSettings> load() async => const GameSettings();

  @override
  Future<void> save(GameSettings settings) async {}
}

List<String> _record(WidgetTester tester) {
  final log = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') log.add('${call.arguments}');
      return null;
    },
  );
  return log;
}

Future<PulseController> _pump(WidgetTester tester, {required bool vibration}) {
  final controller = PulseController(level: wrongWayLevel());
  addTearDown(controller.dispose);
  return tester
      .pumpWidget(
        SwipeOutApp(
          settings: SettingsStore(
            repository: _MemorySettings(),
            settings: GameSettings(vibration: vibration, reducedMotion: true),
          ),
          home: Scaffold(
            body: Column(
              children: [
                const SignalBackButton(),
                GameButton(label: 'GO', onPressed: () {}),
                Expanded(child: BoardView(controller: controller)),
              ],
            ),
          ),
        ),
      )
      .then((_) => controller);
}

Future<void> _play(WidgetTester tester, PulseController c) async {
  await tester.tap(find.byType(GameButton));
  await tester.tap(find.byType(SignalBackButton));
  c.advance();
  await tester.pumpAndSettle();
  c.advance(); // rejected: the wrong goal
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  testWidgets('with vibration on, presses and crashes are felt', (
    tester,
  ) async {
    final log = _record(tester);
    await _play(tester, await _pump(tester, vibration: true));
    expect(log, isNotEmpty);
  });

  testWidgets('with vibration off, nothing vibrates', (tester) async {
    final log = _record(tester);
    await _play(tester, await _pump(tester, vibration: false));
    expect(log, isEmpty);
  });
}
