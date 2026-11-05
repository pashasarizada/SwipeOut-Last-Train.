import 'package:flutter/widgets.dart';

import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import '../theme/app_colors.dart';
import 'board_layout.dart';

/// The next pulse as faint "ghost" rings: where each train that would move
/// stops after one more minute with the pending control
/// (docs/GAME_DESIGN_V2.md §3.2/5 — next pulse only, never the solution).
final class GhostPainter extends CustomPainter {
  const GhostPainter({
    required this.level,
    required this.state,
    required this.ghost,
    required this.layout,
  });

  final LevelDefinition level;
  final GameState state;

  /// The state one pulse ahead, or null when there is nothing to preview.
  final GameState? ghost;
  final BoardLayout layout;

  static const double radius = 13;

  @override
  void paint(Canvas canvas, Size size) {
    final next = ghost;
    if (next == null) return;
    for (final train in next.trains) {
      final now = state.trainById(train.id);
      if (now == null || now.delivered || now.nodeId == train.nodeId) {
        continue;
      }
      final color = colorForStyle(level.trainDef(train.id)!.style);
      final c = layout.toScreen(level.nodes[train.nodeId]!.position);
      canvas
        ..drawCircle(c, radius, Paint()..color = color.withValues(alpha: 0.18))
        ..drawCircle(
          c,
          radius,
          Paint()
            ..color = color.withValues(alpha: 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
  }

  @override
  bool shouldRepaint(GhostPainter old) =>
      old.ghost != ghost || old.state != state || old.layout != layout;
}
