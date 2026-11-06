import 'dart:math' as math;
import 'dart:ui';

import '../../domain/level_definition.dart';
import 'board_layout.dart';

/// One rail drawn the metro-map way: straight runs at 0°, 45° or 90° with
/// rounded knees. Rails, trains, arrows and the closed-arm gap all read
/// this one path, so what is drawn and what moves can never differ.
final class RailPath {
  RailPath(this.corners, {this.straightFallback = false})
    : path = _rounded(corners) {
    _metric = path.computeMetrics().first;
  }

  /// Ends and knees, in order.
  final List<Offset> corners;

  /// No metro shape fitted; drawn as the plain straight line.
  final bool straightFallback;
  final Path path;
  late final PathMetric _metric;

  double get length => _metric.length;

  Offset pointAt(double distance) => _tangent(distance).position;

  /// Facing at [distance], in radians — the same convention as `headingOf`.
  double headingAt(double distance) {
    final v = _tangent(distance).vector;
    return math.atan2(v.dy, v.dx);
  }

  /// The piece of the path between two distances from its start.
  Path segment(double from, double to) => _metric.extractPath(
    from.clamp(0, length).toDouble(),
    to.clamp(0, length).toDouble(),
  );

  RailPath get reversed =>
      RailPath(corners.reversed.toList(), straightFallback: straightFallback);

  Tangent _tangent(double distance) =>
      _metric.getTangentForOffset(distance.clamp(0, length).toDouble())!;

  static Path _rounded(List<Offset> c) {
    final path = Path()..moveTo(c.first.dx, c.first.dy);
    for (var i = 1; i + 1 < c.length; i++) {
      final inLen = (c[i] - c[i - 1]).distance;
      final outLen = (c[i + 1] - c[i]).distance;
      final r = math.min(
        RailGeometry.cornerRadius,
        math.min(inLen, outLen) / 2,
      );
      final a = c[i] - (c[i] - c[i - 1]) / inLen * r;
      final b = c[i] + (c[i + 1] - c[i]) / outLen * r;
      path
        ..lineTo(a.dx, a.dy)
        ..quadraticBezierTo(c[i].dx, c[i].dy, b.dx, b.dy);
    }
    return path..lineTo(c.last.dx, c.last.dy);
  }
}

/// Metro-map shapes for every rail of a level on one board layout.
/// Node positions never move; only the line between two nodes bends.
final class RailGeometry {
  RailGeometry(this.level, this.layout) {
    for (final edge in level.edges.values) {
      final a = _at(edge.a);
      final b = _at(edge.b);
      final shape = _candidates(a, b).firstWhere(
        (c) => _fits(c, edge.a, edge.b, edge.id),
        orElse: () => const [],
      );
      final path = shape.isEmpty
          ? RailPath([a, b], straightFallback: true)
          : RailPath(shape);
      _paths[edge.id] = path;
      _leaving.putIfAbsent(edge.a, () => []).add(path.headingAt(0));
      _leaving.putIfAbsent(edge.b, () => []).add(path.reversed.headingAt(0));
    }
  }

  final LevelDefinition level;
  final BoardLayout layout;

  /// Rounding of each knee, in pt.
  static const double cornerRadius = 14;

  /// How close a rail may pass to a node it does not serve.
  static const double nodeClearance = 20;

  /// A rail within this many degrees of 0°/45°/90° stays one straight run.
  static const double snapDegrees = 3;

  final Map<String, RailPath> _paths = {};
  final Map<String, RailPath> _reversed = {};

  /// Directions rails already leave each node in.
  final Map<String, List<double>> _leaving = {};

  RailPath pathOf(String edgeId) => _paths[edgeId]!;

  /// The rail of [edgeId] as run from [nodeId].
  RailPath from(String nodeId, String edgeId) =>
      level.edges[edgeId]!.a == nodeId
      ? pathOf(edgeId)
      : _reversed.putIfAbsent(edgeId, () => pathOf(edgeId).reversed);

  /// The rail a train runs from [fromNode] to the neighbouring [toNode].
  RailPath between(String fromNode, String toNode) => from(
    fromNode,
    level.edgesOf(fromNode).firstWhere((e) => e.other(fromNode) == toNode).id,
  );

  int get fallbackCount =>
      _paths.values.where((p) => p.straightFallback).length;

  Offset _at(String nodeId) => layout.toScreen(level.nodes[nodeId]!.position);

  /// Straight–diagonal–straight, diagonal–straight, straight–diagonal; an
  /// already octilinear rail is a single run.
  static List<List<Offset>> _candidates(Offset a, Offset b) {
    final d = b - a;
    final deg = math.atan2(d.dy, d.dx) * 180 / math.pi;
    final off = (deg % 45 + 45) % 45;
    if (off <= snapDegrees || off >= 45 - snapDegrees) {
      return [
        [a, b],
      ];
    }
    final dx = d.dx.abs();
    final dy = d.dy.abs();
    final diag = math.min(dx, dy);
    final sx = d.dx.sign;
    final sy = d.dy.sign;
    final diagonal = Offset(sx * diag, sy * diag);
    final straight = dx > dy
        ? Offset(sx * (dx - dy), 0)
        : Offset(0, sy * (dy - dx));
    return [
      [a, a + straight / 2, a + straight / 2 + diagonal, b],
      [a, a + diagonal, b],
      [a, a + straight, b],
    ];
  }

  bool _fits(List<Offset> shape, String from, String to, String edgeId) {
    if (_clashes(from, shape[1] - shape[0])) return false;
    final n = shape.length;
    if (_clashes(to, shape[n - 2] - shape[n - 1])) return false;
    for (final node in level.nodes.values) {
      if (node.id == from || node.id == to) continue;
      final c = _at(node.id);
      for (var i = 0; i + 1 < n; i++) {
        if (_distance(c, shape[i], shape[i + 1]) < nodeClearance) return false;
      }
    }
    return true;
  }

  /// Whether a rail leaving [nodeId] along [direction] would lie on top of
  /// one already leaving it.
  bool _clashes(String nodeId, Offset direction) {
    final heading = math.atan2(direction.dy, direction.dx);
    for (final other in _leaving[nodeId] ?? const <double>[]) {
      var d = (heading - other).abs() % (2 * math.pi);
      d = math.min(d, 2 * math.pi - d);
      if (d < 0.2) return true;
    }
    return false;
  }

  static double _distance(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(
      0.0,
      1.0,
    );
    return (p - (a + ab * t)).distance;
  }

  @override
  bool operator ==(Object other) =>
      other is RailGeometry &&
      identical(other.level, level) &&
      other.layout == layout;

  @override
  int get hashCode => Object.hash(identityHashCode(level), layout);
}
