import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import 'board_layout.dart';
import 'rail_geometry.dart';
import 'train_sprite.dart';

/// Trains tweened from [before] to [after] — all of them at once. Each car
/// faces the edge it travels; a train delivered by this pulse reaches its
/// goal, then shrinks away. On a rejected pulse the [bumped] trains lurch
/// towards the conflict and spring back; the state never changes.
final class TrainLayer extends StatefulWidget {
  const TrainLayer({
    super.key,
    required this.level,
    required this.before,
    required this.after,
    required this.progress,
    required this.layout,
    required this.geometry,
    this.bump = kAlwaysDismissedAnimation,
    this.bumped = const {},
    this.bumpNode,
  });

  final LevelDefinition level;
  final GameState before;
  final GameState after;
  final Animation<double> progress;
  final BoardLayout layout;

  /// The metro paths trains run along (D-036).
  final RailGeometry geometry;
  final Animation<double> bump;
  final Set<String> bumped;

  /// Where the conflict happens; without one, the bumped trains meet in
  /// the middle (a head-on swap on one edge).
  final String? bumpNode;

  /// A drawn car's length in pt.
  static const double carLength = 34;

  /// How far towards the conflict a bumped train lurches.
  static const double bumpReach = 0.35;

  /// Where a train running from [from] to [to] is at progress [t] (0–1),
  /// and which way it faces: on the rail's path, along its tangent.
  static (Offset, double) placeOnRail(
    LevelDefinition level,
    RailGeometry geometry, {
    required String from,
    required String to,
    required double t,
  }) {
    final rail = geometry.between(from, to);
    final d = rail.length * t;
    return (rail.pointAt(d), rail.headingAt(d));
  }

  /// How far a bumped train at [node] has lurched towards [toward] when it
  /// is [fraction] of the way there: along the rail between them when they
  /// are neighbours, so it never leaves a bent track; straight otherwise.
  static Offset lurchOffset(
    LevelDefinition level,
    RailGeometry geometry, {
    required String node,
    required String toward,
    required double fraction,
  }) {
    if (node == toward) return Offset.zero;
    final layout = geometry.layout;
    final from = layout.toScreen(level.nodes[node]!.position);
    final neighbour = level.edgesOf(node).any((e) => e.other(node) == toward);
    if (!neighbour) {
      return (layout.toScreen(level.nodes[toward]!.position) - from) * fraction;
    }
    final rail = geometry.between(node, toward);
    return rail.pointAt(rail.length * fraction) - from;
  }

  @override
  State<TrainLayer> createState() => _TrainLayerState();
}

class _TrainLayerState extends State<TrainLayer> {
  static const double _length = TrainLayer.carLength;
  static const double _idleLights = 0.4;
  static const Interval _shrink = Interval(0.75, 1);

  Offset _pos(String nodeId) =>
      widget.layout.toScreen(widget.level.nodes[nodeId]!.position);

  /// Facing of a standing train, read from its state so undo and restart
  /// can never leave it pointing the wrong way: along the edge it came in
  /// on, or at the depot towards the depot's only edge.
  double _standingHeading(String nodeId, String? incomingEdgeId) {
    final g = widget.geometry;
    final incoming = widget.level.edges[incomingEdgeId];
    if (incoming != null) {
      final rail = g.from(incoming.other(nodeId), incoming.id);
      return rail.headingAt(rail.length);
    }
    final edges = widget.level.edgesOf(nodeId);
    if (edges.isEmpty) return 0;
    return g.from(nodeId, edges.first.id).headingAt(0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.progress, widget.bump]),
      builder: (context, _) {
        final lurch = _lurch();
        final t = Curves.easeInOut.transform(widget.progress.value);
        final moving = widget.progress.value < 1;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final train in widget.after.trains)
              if (widget.before.trainById(train.id) case final from?
                  when !from.delivered)
                _car(
                  id: train.id,
                  from: from.nodeId,
                  to: train.nodeId,
                  incomingEdgeId: train.incomingEdgeId,
                  t: t,
                  scale: train.delivered
                      ? 1 - _shrink.transform(widget.progress.value)
                      : 1,
                  lights: moving && from.nodeId != train.nodeId
                      ? 1
                      : _idleLights,
                  lurch: lurch[train.id] ?? Offset.zero,
                ),
          ],
        );
      },
    );
  }

  /// Per bumped train, its offset towards the conflict right now.
  Map<String, Offset> _lurch() {
    final v = widget.bump.value;
    if (widget.bumped.isEmpty || v == 0 || v == 1) return const {};
    final at = {
      for (final id in widget.bumped)
        if (widget.after.trainById(id) case final t? when !t.delivered)
          id: t.nodeId,
    };
    if (at.isEmpty) return const {};
    final k = TrainLayer.bumpReach * math.sin(v * math.pi);
    final target = widget.bumpNode;
    Offset towards(String node) {
      if (target != null) {
        // A train standing on the conflict node holds still.
        return TrainLayer.lurchOffset(
          widget.level,
          widget.geometry,
          node: node,
          toward: target,
          fraction: k,
        );
      }
      // No conflict node: the bumped trains meet half way between them.
      final other = at.values.firstWhere((n) => n != node, orElse: () => node);
      return TrainLayer.lurchOffset(
        widget.level,
        widget.geometry,
        node: node,
        toward: other,
        fraction: k / 2,
      );
    }

    return {
      for (final MapEntry(:key, :value) in at.entries) key: towards(value),
    };
  }

  Widget _car({
    required String id,
    required String from,
    required String to,
    required String? incomingEdgeId,
    required double t,
    required double scale,
    required double lights,
    Offset lurch = Offset.zero,
  }) {
    final (onRail, heading) = from != to
        ? TrainLayer.placeOnRail(
            widget.level,
            widget.geometry,
            from: from,
            to: to,
            t: t,
          )
        : (_pos(to), _standingHeading(to, incomingEdgeId));
    final center = onRail + lurch;
    const box = _length * 1.6;
    return Positioned(
      key: ValueKey(id),
      left: center.dx - box / 2,
      top: center.dy - box / 2,
      child: Transform.scale(
        scale: scale,
        child: TrainSprite(
          train: widget.level.trainDef(id)!,
          heading: heading,
          headlights: lights,
          length: _length,
        ),
      ),
    );
  }
}
