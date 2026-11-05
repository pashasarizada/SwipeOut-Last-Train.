import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/app.dart';
import 'package:swipeout_last_train/game/data/level_index.dart';
import 'package:swipeout_last_train/game/data/level_json_codec.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/board_view.dart';
import 'package:swipeout_last_train/game/presentation/game/progress_store.dart';
import 'package:swipeout_last_train/game/presentation/screens/pulse_game_screen.dart';

import '../support/memory_progress_repository.dart';

Object? _read(String file) =>
    jsonDecode(File('${LevelIndex.assetDir}/$file').readAsStringSync());

/// docs/UI_UX_GUIDELINES.md: every node stays a 44 pt target on the
/// smallest phone on sale (375×667, iPhone SE) with large text (D-029).
void main() {
  final index = LevelIndex.fromJson(_read(LevelIndex.fileName));
  final levels = <LevelDefinition>[
    for (final city in CityId.values)
      for (final file in index.filesFor(city))
        const LevelJsonCodec().decode(_read(file)! as Map<String, Object?>),
  ];

  for (final level in levels) {
    testWidgets('${level.id} keeps its nodes 44 pt apart at 375×667', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final store = ProgressStore(
        catalog: {
          level.city: [level],
        },
        repository: MemoryProgressRepository(const Progress()),
        progress: const Progress(),
      );
      await tester.pumpWidget(
        SwipeOutApp(
          store: store,
          home: PulseGameScreen(level: level),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final layout = BoardLayout(size: tester.getSize(find.byType(BoardView)));
      final points = [
        for (final n in level.nodes.values) layout.toScreen(n.position),
      ];
      var nearest = double.infinity;
      for (var i = 0; i < points.length; i++) {
        for (var j = i + 1; j < points.length; j++) {
          nearest = math.min(nearest, (points[i] - points[j]).distance);
        }
      }
      expect(nearest, greaterThanOrEqualTo(44));
    });
  }
}
