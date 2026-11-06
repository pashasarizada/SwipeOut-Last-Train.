import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/presentation/board/board_layout.dart';
import 'package:swipeout_last_train/game/presentation/board/rail_geometry.dart';

import '../../support/all_levels.dart';

/// 0°, 45°, 90°… within the snapping tolerance.
bool _octilinear(Offset a, Offset b) {
  final deg = math.atan2(b.dy - a.dy, b.dx - a.dx) * 180 / math.pi;
  final off = (deg % 45 + 45) % 45;
  return off <= RailGeometry.snapDegrees + 0.01 ||
      off >= 45 - RailGeometry.snapDegrees - 0.01;
}

double _toSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

void main() {
  final levels = allLevels();

  for (final side in boardSides) {
    final layout = BoardLayout(size: Size.square(side + 48));

    test('every segment is octilinear unless a straight fallback ($side)', () {
      for (final level in levels) {
        final g = RailGeometry(level, layout);
        for (final id in level.edges.keys) {
          final p = g.pathOf(id);
          if (p.straightFallback) continue;
          for (var i = 0; i + 1 < p.corners.length; i++) {
            expect(
              _octilinear(p.corners[i], p.corners[i + 1]),
              isTrue,
              reason: '${level.id} $id',
            );
          }
        }
      }
    });

    test('paths start and end on their nodes ($side)', () {
      for (final level in levels) {
        final g = RailGeometry(level, layout);
        for (final edge in level.edges.values) {
          final p = g.pathOf(edge.id);
          final a = layout.toScreen(level.nodes[edge.a]!.position);
          final b = layout.toScreen(level.nodes[edge.b]!.position);
          expect((p.corners.first - a).distance, lessThan(0.01));
          expect((p.corners.last - b).distance, lessThan(0.01));
          expect((p.pointAt(0) - a).distance, lessThan(0.5));
          expect((p.pointAt(p.length) - b).distance, lessThan(0.5));
        }
      }
    });

    test('no two rails leave a node in the same direction ($side)', () {
      for (final level in levels) {
        final g = RailGeometry(level, layout);
        for (final node in level.nodes.keys) {
          final headings = [
            for (final e in level.edgesOf(node))
              g.from(node, e.id).headingAt(0),
          ];
          for (var i = 0; i < headings.length; i++) {
            for (var j = i + 1; j < headings.length; j++) {
              var d = (headings[i] - headings[j]).abs() % (2 * math.pi);
              d = math.min(d, 2 * math.pi - d);
              expect(d, greaterThan(0.2), reason: '${level.id} at $node');
            }
          }
        }
      }
    });

    test('rails leaving one node are apart where a closed arm stops '
        '($side)', () {
      for (final level in levels) {
        final g = RailGeometry(level, layout);
        for (final node in level.nodes.keys) {
          final ends = [
            for (final e in level.edgesOf(node))
              g.from(node, e.id).pointAt(RailGeometry.armCheck),
          ];
          for (var i = 0; i < ends.length; i++) {
            for (var j = i + 1; j < ends.length; j++) {
              expect(
                (ends[i] - ends[j]).distance,
                greaterThanOrEqualTo(12),
                reason: '${level.id} at $node',
              );
            }
          }
        }
      }
    });

    test('paths keep clear of other nodes ($side)', () {
      for (final level in levels) {
        final g = RailGeometry(level, layout);
        for (final edge in level.edges.values) {
          final p = g.pathOf(edge.id);
          if (p.straightFallback) continue;
          for (final node in level.nodes.values) {
            if (edge.touches(node.id)) continue;
            final c = layout.toScreen(node.position);
            for (var i = 0; i + 1 < p.corners.length; i++) {
              expect(
                _toSegment(c, p.corners[i], p.corners[i + 1]),
                greaterThanOrEqualTo(RailGeometry.nodeClearance),
                reason: '${level.id} ${edge.id} near ${node.id}',
              );
            }
          }
        }
      }
    });

    test('straight fallbacks stay rare ($side)', () {
      for (final level in levels) {
        final g = RailGeometry(level, layout);
        expect(
          g.fallbackCount / level.edges.length,
          lessThanOrEqualTo(0.25),
          reason: '${level.id}: ${g.fallbackCount}/${level.edges.length}',
        );
      }
    });
  }

  test('pointAt and headingAt follow a bent path', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-02');
    final g = RailGeometry(level, BoardLayout(size: const Size.square(400)));
    final bent = level.edges.keys
        .map(g.pathOf)
        .firstWhere((p) => p.corners.length > 2);
    // Every point along the path lies on one of its straight runs or on a
    // rounded corner close to its knee.
    for (var d = 0.0; d <= bent.length; d += bent.length / 20) {
      final p = bent.pointAt(d);
      var nearest = double.infinity;
      for (var i = 0; i + 1 < bent.corners.length; i++) {
        nearest = math.min(
          nearest,
          _toSegment(p, bent.corners[i], bent.corners[i + 1]),
        );
      }
      expect(nearest, lessThan(RailGeometry.cornerRadius * 0.5));
    }
    final first = bent.corners[1] - bent.corners[0];
    expect(bent.headingAt(0), closeTo(math.atan2(first.dy, first.dx), 0.01));
  });

  test('a drawn piece of a rail is cut once and reused', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-02');
    final g = RailGeometry(level, BoardLayout(size: const Size.square(400)));
    final p = g.pathOf(level.edges.keys.first);
    expect(p.segment(0, p.length), same(p.segment(0, p.length)));
  });

  test('from() runs the same rail from the other end', () {
    final level = levels.firstWhere((l) => l.id == 'BAK-02');
    final g = RailGeometry(level, BoardLayout(size: const Size.square(400)));
    final edge = level.edges.values.first;
    final forward = g.from(edge.a, edge.id);
    final back = g.from(edge.b, edge.id);
    expect(back.corners, forward.corners.reversed.toList());
    expect(back.length, closeTo(forward.length, 0.01));
  });
}
