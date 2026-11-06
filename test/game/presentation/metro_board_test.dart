import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/edge.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/pulse_forecast.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/forecast_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/network_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/rail_geometry.dart';
import 'package:swipeout_last_train/game/presentation/board/train_layer.dart';
import 'package:swipeout_last_train/game/presentation/city/city_theme.dart';

import '../../support/all_levels.dart';

/// Rails, arrows and trains all follow the metro-map path (D-036).
void main() {
  final levels = allLevels();
  final layout = BoardLayout(size: const Size.square(400));

  /// A level with a bent rail, and that rail.
  (LevelDefinition, Edge, RailGeometry) bent() {
    for (final level in levels) {
      final g = RailGeometry(level, layout);
      for (final e in level.edges.values) {
        if (g.pathOf(e.id).corners.length > 2) return (level, e, g);
      }
    }
    throw StateError('no bent rail');
  }

  test('forecast arrow ends lie on the rail path', () {
    final (level, edge, g) = bent();
    final painter = ForecastPainter(
      level: level,
      forecast: null,
      layout: layout,
    );
    final (start, end) = painter.arrowFor(
      TrainMove(trainId: level.trains.first.id, from: edge.a, to: edge.b),
    );
    final path = g.from(edge.a, edge.id);
    expect(
      (start - path.pointAt(path.length * ForecastPainter.arrowFrom)).distance,
      lessThan(0.5),
    );
    expect(
      (end - path.pointAt(path.length * ForecastPainter.arrowTo)).distance,
      lessThan(0.5),
    );
  });

  test('a moving train sits on the rail path, facing along it', () {
    final (level, edge, g) = bent();
    final path = g.from(edge.a, edge.id);
    for (final t in [0.0, 0.3, 0.5, 0.8, 1.0]) {
      final (center, heading) = TrainLayer.placeOnRail(
        level,
        g,
        from: edge.a,
        to: edge.b,
        t: t,
      );
      expect((center - path.pointAt(path.length * t)).distance, lessThan(0.5));
      expect(heading, closeTo(path.headingAt(path.length * t), 0.01));
    }
  });

  test('a closed switch arm stops short of the switch along its path', () {
    for (final level in levels) {
      final painter = NetworkPainter(
        level: level,
        state: level.initialState,
        layout: layout,
      );
      final g = RailGeometry(level, layout);
      for (final sw in level.switches.values) {
        final closed = [
          sw.branchAEdge,
          sw.branchBEdge,
        ].firstWhere((e) => !painter.isOpen(e));
        final (from, to) = painter.visibleSpan(closed);
        final length = g.pathOf(closed).length;
        final gap = NetworkPainter.closedGap.clamp(0, length * 0.45);
        final atA = level.edges[closed]!.a == sw.nodeId;
        expect(atA ? from : length - to, closeTo(gap, 0.01));
      }
    }
  });

  test('rails take the city line colours, white in High Contrast', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-02');
    final theme = CityTheme.of(level.city);
    NetworkPainter painter({required bool high}) => NetworkPainter(
      level: level,
      state: level.initialState,
      layout: layout,
      highContrast: high,
    );
    final open = level.edges.keys.firstWhere(painter(high: false).isOpen);
    expect(theme.lines, contains(painter(high: false).railColor(open)));
    expect(
      painter(high: true).railColor(open),
      NetworkPainter.railStyle(open: true, high: true).$1,
    );
  });
}
