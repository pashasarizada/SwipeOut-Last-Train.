import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/metro_lines.dart';
import 'package:swipeout_last_train/game/presentation/board/rail_geometry.dart';
import 'package:swipeout_last_train/game/presentation/city/city_theme.dart';
import 'package:swipeout_last_train/game/presentation/theme/app_colors.dart';

import '../../support/all_levels.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

double _hueGap(Color a, Color b) {
  final d = (HSVColor.fromColor(a).hue - HSVColor.fromColor(b).hue).abs();
  return math.min(d, 360 - d);
}

void main() {
  final levels = allLevels();
  final layout = BoardLayout(size: const Size.square(400));

  MetroLines linesOf(String id) {
    final level = levels.firstWhere((l) => l.id == id);
    return MetroLines(level, RailGeometry(level, layout));
  }

  test('a switch trunk continues into its straightest branch', () {
    for (final level in levels) {
      final g = RailGeometry(level, layout);
      final lines = MetroLines(level, g);
      for (final sw in level.switches.values) {
        double turn(String branch) {
          final inbound = g.from(sw.nodeId, sw.trunkEdge).headingAt(0);
          final out = g.from(sw.nodeId, branch).headingAt(0);
          var d = (inbound - out).abs() % (2 * math.pi);
          d = math.min(d, 2 * math.pi - d);
          return math.pi - d; // 0 = dead straight through
        }

        final straight = turn(sw.branchAEdge) <= turn(sw.branchBEdge)
            ? sw.branchAEdge
            : sw.branchBEdge;
        expect(
          lines.lineOf(straight),
          lines.lineOf(sw.trunkEdge),
          reason: '${level.id} ${sw.nodeId}',
        );
        // The other branch starts its own line — unless a ring brings
        // it back round into the trunk's line further on.
      }
    }
  });

  test('a pass-through node keeps one line', () {
    final lines = linesOf('ANK-05');
    expect(lines.lineOf('AU'), lines.lineOf('UM'));
  });

  test('lines meeting at a node have different colours', () {
    for (final level in levels) {
      final lines = MetroLines(level, RailGeometry(level, layout));
      for (final node in level.nodes.keys) {
        final byLine = <int, int>{
          for (final e in level.edgesOf(node))
            lines.lineOf(e.id): lines.colorOf(e.id),
        };
        expect(
          byLine.values.toSet(),
          hasLength(byLine.length),
          reason: '${level.id} at $node',
        );
      }
    }
  });

  test('every level colours with three colours', () {
    for (final level in levels) {
      final lines = MetroLines(level, RailGeometry(level, layout));
      expect(lines.colorsNeeded, lessThanOrEqualTo(3), reason: level.id);
    }
  });

  for (final city in CityId.values) {
    final theme = CityTheme.of(city);

    test('${city.name} has three line colours that contrast 3:1', () {
      expect(theme.lines, hasLength(3));
      for (final c in theme.lines) {
        expect(_contrast(c, theme.background), greaterThanOrEqualTo(3));
      }
    });

    test('${city.name} two main line colours are told apart by hue', () {
      expect(_hueGap(theme.lines[0], theme.lines[1]), greaterThanOrEqualTo(45));
    });

    test('${city.name} saturated lines keep 30° from train colours', () {
      const reserved = [
        AppColors.accentRed,
        AppColors.trainBlue,
        AppColors.trainGreen,
        AppColors.accentAmber,
        AppColors.signalGreen,
        AppColors.accentTurquoise,
        AppColors.danger,
      ];
      for (final c in theme.lines) {
        if (HSVColor.fromColor(c).saturation < 0.35) continue;
        for (final r in reserved) {
          expect(_hueGap(c, r), greaterThanOrEqualTo(30), reason: '$c vs $r');
        }
      }
    });
  }
}
