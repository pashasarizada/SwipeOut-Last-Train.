import 'package:flutter/widgets.dart';

import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import 'board_layout.dart';
import 'train_sprite.dart';

/// Trains tweened from [before] to [after] — all of them at once. Each car
/// faces the edge it travels; a train delivered by this pulse reaches its
/// goal, then shrinks away.
final class TrainLayer extends StatefulWidget {
  const TrainLayer({
    super.key,
    required this.level,
    required this.before,
    required this.after,
    required this.progress,
    required this.layout,
  });

  final LevelDefinition level;
  final GameState before;
  final GameState after;
  final Animation<double> progress;
  final BoardLayout layout;

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
      animation: widget.progress,
      builder: (context, _) {
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
                ),
          ],
        );
      },
    );
  }

  Widget _car({
    required String id,
    required String from,
    required String to,
    required double t,
    required double scale,
    required double lights,
  }) {
    final start = _pos(from);
    final end = _pos(to);
    if (from != to) {
      _headings[id] = headingOf(start, end);
    }
    final heading = _headings.putIfAbsent(id, () => _initialHeading(from));
    final center = Offset.lerp(start, end, t)!;
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
