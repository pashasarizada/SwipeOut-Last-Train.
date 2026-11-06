import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/data/settings_repository.dart';
import 'package:swipeout_last_train/game/domain/game_settings.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/game/pulse_controller.dart';
import 'package:swipeout_last_train/game/presentation/game/settings_store.dart';
import 'package:swipeout_last_train/game/presentation/sound/game_sounds.dart';

import '../../support/graph_builders.dart';

final class _MemorySettings implements SettingsRepository {
  @override
  Future<GameSettings> load() async => const GameSettings();

  @override
  Future<void> save(GameSettings settings) async {}
}

final class _Recorder implements GameSounds {
  final List<SoundCue> played = [];

  @override
  void play(SoundCue cue) => played.add(cue);

  @override
  void dispose() {}
}

Future<(PulseController, _Recorder)> _pump(
  WidgetTester tester,
  LevelDefinition level, {
  bool sound = true,
}) async {
  final controller = PulseController(level: level);
  addTearDown(controller.dispose);
  final recorder = _Recorder();
  await tester.pumpWidget(
    SwipeOutApp(
      sounds: recorder,
      settings: SettingsStore(
        repository: _MemorySettings(),
        settings: GameSettings(sound: sound, reducedMotion: true),
      ),
      home: Scaffold(body: BoardView(controller: controller)),
    ),
  );
  return (controller, recorder);
}

Future<void> _tapNode(WidgetTester tester, LevelDefinition level, String id) {
  final board = find.byType(BoardView);
  final layout = BoardLayout(size: tester.getSize(board));
  return tester.tapAt(
    tester.getTopLeft(board) + layout.toScreen(level.nodes[id]!.position),
  );
}

Future<void> _advance(WidgetTester tester, PulseController c) async {
  c.advance();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('switch, pulse and delivery each have their sound', (
    tester,
  ) async {
    final level = ank01();
    final (c, sounds) = await _pump(tester, level);

    await _advance(tester, c);
    expect(sounds.played, [SoundCue.pulseTick]);

    await _tapNode(tester, level, 'B');
    await tester.pump();
    expect(sounds.played.last, SoundCue.switchClack);

    await _advance(tester, c);
    expect(
      sounds.played,
      containsAllInOrder([SoundCue.pulseTick, SoundCue.delivery]),
    );
  });

  testWidgets('a rejected pulse buzzes', (tester) async {
    final (c, sounds) = await _pump(tester, wrongWayLevel());
    await _advance(tester, c);
    await _advance(tester, c);
    expect(sounds.played, contains(SoundCue.crash));
  });

  testWidgets('with sound off, nothing plays', (tester) async {
    final level = ank01();
    final (c, sounds) = await _pump(tester, level, sound: false);
    await _advance(tester, c);
    await _tapNode(tester, level, 'B');
    await _advance(tester, c);
    expect(sounds.played, isEmpty);
  });

  test('every cue has its file', () {
    for (final cue in SoundCue.values) {
      expect(
        File('assets/sounds/${cue.file}.wav').existsSync(),
        isTrue,
        reason: cue.name,
      );
    }
  });
}
