import 'package:flutter/painting.dart';

import '../../domain/level_definition.dart';
import '../../domain/node.dart';
import '../kit/game_fonts.dart';
import '../theme/app_colors.dart';
import 'forecast_painter.dart';
import 'network_painter.dart';
import 'rail_geometry.dart';

/// Where each goal's station name goes: the first of twelve spots around
/// the goal (then twelve a little further out) that stays on the board
/// and clear of nodes, rails, signal
/// heads, waiting badges, goal glows and other names. A name with no free
/// spot is left out — the game never depends on it (D-036).
final class StationLabels {
  StationLabels(this.level, this.geometry) {
    final keepClear = _keepClear();
    final board = Offset.zero & geometry.layout.size;
    for (final train in level.trains) {
      final node = level.nodes[train.goalNode]!;
      final name = node.label;
      if (name == null) continue;
      wanted++;
      final size = measure(name);
      final c = geometry.layout.toScreen(node.position);
      for (final spot in [..._spots(c, size), ..._spots(c, size, reach: 18)]) {
        final padded = spot.inflate(2);
        if (!_inside(board, spot)) continue;
        if (keepClear.any((k) => k.hits(padded))) continue;
        if (_rails.any(padded.overlaps)) continue;
        placed[node.id] = spot;
        keepClear.add(_Zone.rect(spot));
        break;
      }
    }
  }

  final LevelDefinition level;
  final RailGeometry geometry;

  /// Goal node id → the box its name is drawn in.
  final Map<String, Rect> placed = {};

  /// Goals that have a name, placed or not.
  int wanted = 0;

  /// How far a name keeps from a goal (its glow) and from any other node.
  static const double goalClearance = 30;
  static const double nodeClearance = 22;

  static const TextStyle style = TextStyle(
    fontFamily: GameFonts.board,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  final Map<(String, bool), TextPainter> _painters = {};

  /// [id]'s name laid out once per board (and per High Contrast), so the
  /// repainting board never lays text out again.
  TextPainter painterFor(String id, {required bool high}) =>
      _painters.putIfAbsent(
        (id, high),
        () => TextPainter(
          text: TextSpan(
            text: level.nodes[id]!.label,
            style: style.copyWith(
              color: AppColors.textPrimary.withValues(alpha: high ? 1 : 0.85),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
      );

  void dispose() {
    for (final p in _painters.values) {
      p.dispose();
    }
    _painters.clear();
  }

  static Size measure(String name) {
    final p = TextPainter(
      text: TextSpan(text: name, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final size = p.size;
    p.dispose();
    return Size(size.width + 6, size.height + 2);
  }

  /// Right, left, above, below, the four corners, then above and below
  /// slid sideways so a goal at the board's edge still finds room.
  static List<Rect> _spots(Offset c, Size s, {double reach = 0}) {
    final g = goalClearance + 2 + reach;
    final k = g * 0.7;
    final w = s.width;
    final h = s.height;
    return [
      Rect.fromLTWH(c.dx + g, c.dy - h / 2, w, h),
      Rect.fromLTWH(c.dx - g - w, c.dy - h / 2, w, h),
      Rect.fromLTWH(c.dx - w / 2, c.dy - g - h, w, h),
      Rect.fromLTWH(c.dx - w / 2, c.dy + g, w, h),
      Rect.fromLTWH(c.dx + k, c.dy + k, w, h),
      Rect.fromLTWH(c.dx - k - w, c.dy + k, w, h),
      Rect.fromLTWH(c.dx + k, c.dy - k - h, w, h),
      Rect.fromLTWH(c.dx - k - w, c.dy - k - h, w, h),
      Rect.fromLTWH(c.dx + 12 - w, c.dy - g - h, w, h),
      Rect.fromLTWH(c.dx + 12 - w, c.dy + g, w, h),
      Rect.fromLTWH(c.dx - 12, c.dy - g - h, w, h),
      Rect.fromLTWH(c.dx - 12, c.dy + g, w, h),
    ];
  }

  static bool _inside(Rect board, Rect r) =>
      board.contains(r.topLeft) && board.contains(r.bottomRight);

  List<_Zone> _keepClear() {
    final layout = geometry.layout;
    return [
      for (final node in level.nodes.values) ...[
        _Zone.circle(
          layout.toScreen(node.position),
          node.kind == NodeKind.goal ? goalClearance : nodeClearance,
        ),
        // A delivered train leaves the board, so no badge ever waits at a goal.
        if (node.kind != NodeKind.goal)
          _Zone.circle(
            layout.toScreen(node.position) + ForecastPainter.badgeOffset,
            12,
          ),
        // The conflict cross, moved in front of a standing train.
        for (final e in level.edgesOf(node.id))
          _Zone.circle(_crossSpot(node.id, e.id), 19),
        if (node.kind == NodeKind.signal)
          _Zone.rect(
            Rect.fromCenter(
              center:
                  layout.toScreen(node.position) +
                  NetworkPainter.signalLampOffset,
              width: 26,
              height: 34,
            ),
          ),
      ],
    ];
  }

  Offset _crossSpot(String nodeId, String edgeId) {
    final rail = geometry.from(nodeId, edgeId);
    return rail.pointAt(
      rail.length / 2 < ForecastPainter.crossShift
          ? rail.length / 2
          : ForecastPainter.crossShift,
    );
  }

  /// Points along every rail, 4 pt apart, grown by the rail's half width.
  late final List<Rect> _rails = [
    for (final edge in level.edges.values)
      for (final p in _samples(geometry.pathOf(edge.id)))
        Rect.fromCircle(center: p, radius: 6),
  ];

  static Iterable<Offset> _samples(RailPath path) sync* {
    for (var d = 0.0; d < path.length; d += 4) {
      yield path.pointAt(d);
    }
    yield path.pointAt(path.length);
  }
}

/// A region a name must not touch.
final class _Zone {
  _Zone.circle(this.center, this.radius) : rect = null;
  _Zone.rect(this.rect) : center = null, radius = 0;

  final Offset? center;
  final double radius;
  final Rect? rect;

  bool hits(Rect r) {
    if (rect case final own?) return own.overlaps(r);
    final c = center!;
    final nearest = Offset(
      c.dx.clamp(r.left, r.right),
      c.dy.clamp(r.top, r.bottom),
    );
    return (nearest - c).distance < radius;
  }
}
