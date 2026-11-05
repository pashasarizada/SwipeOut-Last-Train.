import 'package:flutter/material.dart';

import '../../domain/grid_pos.dart';
import '../game/game_controller.dart';
import '../game/swipe_direction.dart';
import '../theme/motion.dart';
import 'board_geometry.dart';
import 'board_painter.dart';
import 'train_token.dart';

/// The interactive board: painted tracks, animated trains and gestures.
final class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.controller});

  static const double _tokenScale = 0.7;

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final level = controller.level;
        final geometry = BoardGeometry(
          columns: level.width,
          rows: level.height,
          available: constraints.biggest,
        );
        final tokenSize = geometry.cellSize * _tokenScale;
        return Center(
          child: SizedBox.fromSize(
            size: geometry.boardSize,
            child: _BoardGestures(
              controller: controller,
              geometry: geometry,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => Stack(
                  children: [
                    CustomPaint(
                      size: geometry.boardSize,
                      painter: BoardPainter(
                        level: level,
                        state: controller.state,
                        geometry: geometry,
                        hint: controller.hint,
                      ),
                    ),
                    for (final train in controller.state.trains)
                      if (!train.delivered)
                        AnimatedPositioned(
                          key: ValueKey(train.id),
                          duration: kMoveAnimation,
                          curve: Curves.easeOut,
                          left:
                              geometry.centerOf(train.position).dx -
                              tokenSize / 2,
                          top:
                              geometry.centerOf(train.position).dy -
                              tokenSize / 2,
                          child: TrainToken(
                            train: train,
                            selected: train.id == controller.selectedTrainId,
                            size: tokenSize,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Translates taps and drags on the board into controller calls.
class _BoardGestures extends StatefulWidget {
  const _BoardGestures({
    required this.controller,
    required this.geometry,
    required this.child,
  });

  final GameController controller;
  final BoardGeometry geometry;
  final Widget child;

  @override
  State<_BoardGestures> createState() => _BoardGesturesState();
}

class _BoardGesturesState extends State<_BoardGestures> {
  Offset _drag = Offset.zero;

  GameController get _controller => widget.controller;

  void _onTapUp(TapUpDetails details) {
    final pos = widget.geometry.cellAt(details.localPosition);
    if (pos != null) _controller.tapCell(pos);
  }

  void _onPanStart(DragStartDetails details) {
    _drag = Offset.zero;
    final pos = widget.geometry.cellAt(details.localPosition);
    if (pos != null && _hasTrainAt(pos)) _controller.tapCell(pos);
  }

  bool _hasTrainAt(GridPos pos) => _controller.state.trainAt(pos) != null;

  void _onPanEnd(DragEndDetails _) {
    final direction = directionFromDelta(_drag.dx, _drag.dy);
    if (direction != null) _controller.swipe(direction);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _onTapUp,
      onPanStart: _onPanStart,
      onPanUpdate: (details) => _drag += details.delta,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}
