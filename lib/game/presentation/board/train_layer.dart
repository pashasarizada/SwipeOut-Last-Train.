import 'package:flutter/widgets.dart';

import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import 'board_layout.dart';
import 'train_token.dart';

/// Trains tweened from [before] to [after] — all of them at once.
/// A train delivered by this pulse reaches its goal, then shrinks away.
final class TrainLayer extends StatelessWidget {
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

  static const double _tokenSize = 28;
  static const Interval _shrink = Interval(0.75, 1);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(progress.value);
        return Stack(
          children: [
            for (final train in after.trains)
              if (before.trainById(train.id) case final from?
                  when !from.delivered)
                _token(
                  train.id,
                  Offset.lerp(_pos(from.nodeId), _pos(train.nodeId), t)!,
                  train.delivered ? 1 - _shrink.transform(progress.value) : 1,
                ),
          ],
        );
      },
    );
  }

  Offset _pos(String nodeId) => layout.toScreen(level.nodes[nodeId]!.position);

  Widget _token(String id, Offset center, double scale) => Positioned(
    key: ValueKey(id),
    left: center.dx - _tokenSize / 2,
    top: center.dy - _tokenSize / 2,
    child: Transform.scale(
      scale: scale,
      child: TrainToken(train: level.trainDef(id)!, size: _tokenSize),
    ),
  );
}
