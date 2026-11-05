import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import 'board_layout.dart';
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
    this.bump = kAlwaysDismissedAnimation,
    this.bumped = const {},
    this.bumpNode,
  });

  final LevelDefinition level;
  final GameState before;
  final GameState after;
  final Animation<double> progress;
  final BoardLayout layout;
  final Animation<double> bump;
  final Set<String> bumped;

  /// Where the conflict happens; without one, the bumped trains meet in
  /// the middle (a head-on swap on one edge).
  final String? bumpNode;

  /// How far towards the conflict a bumped train lurches.
  static const double bumpReach = 0.35;

  @override
  State<TrainLayer> createState() => _TrainLayerState();
}

class _TrainLayerState extends State<TrainLayer> {
  static const double _length = 34;
  static const double _idleLights = 0.4;
  static const Interval _shrink = Interval(0.75, 1);

  /// Last known facing per train, kept while a train stands still.
  final Map<String, double> _headings = {};

  Offset _pos(String nodeId) =>
      widget.layout.toScreen(widget.level.nodes[nodeId]!.position);

  /// Facing at the depot: towards the depot's only edge.
  double _initialHeading(String nodeId) {
    final edges = widget.level.edgesOf(nodeId);
    if (edges.isEmpty) return 0;
    return headingOf(_pos(nodeId), _pos(edges.first.other(nodeId)));
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
          id: _pos(t.nodeId),
    };
    if (at.isEmpty) return const {};
    final contact = widget.bumpNode != null
        ? _pos(widget.bumpNode!)
        : at.values.reduce((a, b) => a + b) / at.length.toDouble();
    final k = TrainLayer.bumpReach * math.sin(v * math.pi);
    return {
      for (final MapEntry(:key, :value) in at.entries)
        key: (contact - value) * k,
    };
  }

  Widget _car({
    required String id,
    required String from,
    required String to,
    required double t,
    required double scale,
    required double lights,
    Offset lurch = Offset.zero,
  }) {
    final start = _pos(from);
    final end = _pos(to);
    if (from != to) {
      _headings[id] = headingOf(start, end);
    }
    final heading = _headings.putIfAbsent(id, () => _initialHeading(from));
    final center = Offset.lerp(start, end, t)! + lurch;
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
