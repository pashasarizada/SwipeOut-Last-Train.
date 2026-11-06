import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/node.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/forecast_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/network_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/rail_geometry.dart';
import 'package:swipeout_last_train/game/presentation/board/station_labels.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_fonts.dart';

import '../../support/all_levels.dart';

bool _hitsCircle(Rect r, Offset c, double radius) {
  final nearest = Offset(
    c.dx.clamp(r.left, r.right),
    c.dy.clamp(r.top, r.bottom),
  );
  return (nearest - c).distance < radius;
}

void main() {
  setUpAll(() async {
    final bytes = File(GameFonts.files[GameFonts.board]!).readAsBytesSync();
    final loader = FontLoader(GameFonts.board)
      ..addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
    await loader.load();
  });

  final levels = allLevels();

  for (final side in boardSides) {
    test('labels stay on the board and clear of the marks ($side)', () {
      for (final level in levels) {
        final layout = BoardLayout(size: Size.square(side + 48));
        final g = RailGeometry(level, layout);
        final labels = StationLabels(level, g);
        final board = Offset.zero & layout.size;
        final rects = labels.placed.values.toList();
        for (final MapEntry(key: id, value: r) in labels.placed.entries) {
          final why = '${level.id} $id at $side';
          expect(board.contains(r.topLeft), isTrue, reason: why);
          expect(board.contains(r.bottomRight), isTrue, reason: why);
          for (final node in level.nodes.values) {
            final c = layout.toScreen(node.position);
            final radius = node.kind == NodeKind.goal
                ? StationLabels.goalClearance
                : StationLabels.nodeClearance;
            expect(_hitsCircle(r, c, radius), isFalse, reason: why);
            expect(
              node.kind != NodeKind.goal &&
                  _hitsCircle(r, c + ForecastPainter.badgeOffset, 12),
              isFalse,
              reason: '$why: waiting badge of ${node.id}',
            );
            if (node.kind == NodeKind.signal) {
              final head = Rect.fromCenter(
                center: c + NetworkPainter.signalLampOffset,
                width: 26,
                height: 34,
              );
              expect(r.overlaps(head), isFalse, reason: '$why: signal head');
            }
          }
          // Where a conflict cross can sit: on a node, or 26 pt along a
          // rail in front of a standing train.
          for (final node in level.nodes.keys) {
            for (final e in level.edgesOf(node)) {
              final rail = g.from(node, e.id);
              final cross = rail.pointAt(
                rail.length / 2 < ForecastPainter.crossShift
                    ? rail.length / 2
                    : ForecastPainter.crossShift,
              );
              expect(
                _hitsCircle(r, cross, 17),
                isFalse,
                reason: '$why: cross by $node on ${e.id}',
              );
            }
          }
          for (final other in rects) {
            if (identical(other, r)) continue;
            expect(r.overlaps(other), isFalse, reason: why);
          }
        }
      }
    });
  }

  test('name text is laid out once per board, not every frame', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-02');
    final labels = StationLabels(
      level,
      RailGeometry(level, BoardLayout(size: const Size.square(408))),
    );
    final id = labels.placed.keys.first;
    expect(
      labels.painterFor(id, high: false),
      same(labels.painterFor(id, high: false)),
    );
    expect(
      labels.painterFor(id, high: true),
      isNot(same(labels.painterFor(id, high: false))),
    );
    labels.dispose();
  });

  test('most names still fit on a small phone board', () {
    var wanted = 0;
    var placed = 0;
    for (final level in levels) {
      final layout = BoardLayout(size: Size.square(boardSides.last + 48));
      final labels = StationLabels(level, RailGeometry(level, layout));
      wanted += labels.wanted;
      placed += labels.placed.length;
    }
    expect(
      placed / wanted,
      greaterThanOrEqualTo(0.75),
      reason: '$placed/$wanted',
    );
  });

  test('at least 90% of station names fit on a large phone', () {
    var wanted = 0;
    var placed = 0;
    for (final level in levels) {
      final layout = BoardLayout(size: Size.square(boardSides.first + 48));
      final labels = StationLabels(level, RailGeometry(level, layout));
      wanted += labels.wanted;
      placed += labels.placed.length;
    }
    expect(
      placed / wanted,
      greaterThanOrEqualTo(0.9),
      reason: '$placed/$wanted',
    );
  });
}
