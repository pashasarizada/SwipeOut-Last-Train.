import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../domain/level_definition.dart';
import '../theme/app_colors.dart';
import 'board_layout.dart';

/// A short burst at each goal a train just reached, in that train's
/// colour; several trains home in one minute make a bigger burst with a
/// white ring. With Reduced Motion only a soft ring shows.
final class CelebrationPainter extends CustomPainter {
  CelebrationPainter({
    required this.level,
    required this.trainIds,
    required this.layout,
    required this.reduced,
    required Animation<double> progress,
  }) : _progress = progress,
       super(repaint: progress);

  final LevelDefinition level;

  /// Trains delivered by the last pulse.
  final List<String> trainIds;
  final BoardLayout layout;
  final bool reduced;
  final Animation<double> _progress;

  static const int sparks = 10;

  bool get big => trainIds.length > 1;

  /// Sparks per goal: none with Reduced Motion, double for a multi-delivery.
  int get particleCount => reduced ? 0 : (big ? sparks * 2 : sparks);

  @override
  void paint(Canvas canvas, Size size) {
    final t = _progress.value;
    if (t <= 0 || t >= 1) return;
    final fade = 1 - t;
    final spread = Curves.easeOutCubic.transform(t);
    for (final id in trainIds) {
      final train = level.trainDef(id);
      if (train == null) continue;
      final c = layout.toScreen(level.nodes[train.goalNode]!.position);
      final color = colorForStyle(train.style);
      canvas.drawCircle(
        c,
        22 + 26 * spread,
        Paint()
          ..color = color.withValues(alpha: 0.5 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final count = particleCount;
      for (var i = 0; i < count; i++) {
        final angle = 2 * math.pi * i / count + id.hashCode % 7 * 0.1;
        final reach = (18 + (big ? 58 : 40) * spread) * (i.isEven ? 1 : 0.8);
        canvas.drawCircle(
          c + Offset(math.cos(angle), math.sin(angle)) * reach,
          1.2 + 2.6 * fade,
          Paint()..color = color.withValues(alpha: fade),
        );
      }
      if (big && !reduced) {
        canvas.drawCircle(
          c,
          30 + 60 * spread,
          Paint()
            ..color = AppColors.textPrimary.withValues(alpha: 0.4 * fade)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CelebrationPainter old) =>
      old.trainIds != trainIds ||
      old.reduced != reduced ||
      old.layout != layout;
}
