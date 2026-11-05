import 'package:flutter/material.dart';

import '../../domain/board_state.dart';
import '../../domain/cell.dart';
import '../../domain/direction.dart';
import '../../domain/grid_pos.dart';
import '../../domain/level_definition.dart';
import '../../domain/move.dart';
import '../theme/app_colors.dart';
import 'board_geometry.dart';

/// Draws the static board (tracks, switches, stations) and the hint marker.
/// Trains are widgets on top so they can animate independently.
final class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.level,
    required this.state,
    required this.geometry,
    this.hint,
  });

  final LevelDefinition level;
  final BoardState state;
  final BoardGeometry geometry;
  final Move? hint;

  double get _cell => geometry.cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas);
    for (final MapEntry(key: pos, value: cell) in level.cells.entries) {
      switch (cell) {
        case TrackCell(:final kind, :final ports):
          _paintRails(canvas, pos, ports, AppColors.track);
          if (kind == TrackKind.depot) _paintDepot(canvas, pos);
        case SwitchCell():
          _paintSwitch(canvas, pos, cell);
        case StationCell():
          _paintStation(canvas, pos, cell);
        case BlockedCell():
          _paintBlocked(canvas, pos);
        case EmptyCell():
          break;
      }
    }
    _paintHint(canvas);
  }

  void _paintGrid(Canvas canvas) {
    final dot = Paint()..color = AppColors.surface;
    for (var x = 0; x < level.width; x++) {
      for (var y = 0; y < level.height; y++) {
        canvas.drawCircle(geometry.centerOf(GridPos(x, y)), _cell * 0.04, dot);
      }
    }
  }

  void _paintRails(
    Canvas canvas,
    GridPos pos,
    Iterable<Direction> ports,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _cell * 0.12
      ..strokeCap = StrokeCap.round;
    final center = geometry.centerOf(pos);
    for (final d in ports) {
      final edge = center + Offset(d.dx * _cell / 2, d.dy * _cell / 2);
      canvas.drawLine(center, edge, paint);
    }
  }

  void _paintDepot(Canvas canvas, GridPos pos) {
    final rect = Rect.fromCenter(
      center: geometry.centerOf(pos),
      width: _cell * 0.8,
      height: _cell * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(_cell * 0.12)),
      Paint()
        ..color = AppColors.trackInactive
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cell * 0.03,
    );
  }

  void _paintSwitch(Canvas canvas, GridPos pos, SwitchCell cell) {
    final active = cell.portsFor(state.branchAt(pos));
    final inactive = {cell.branchA, cell.branchB}.difference(active);
    _paintRails(canvas, pos, inactive, AppColors.trackInactive);
    _paintRails(canvas, pos, active, AppColors.track);
    canvas.drawCircle(
      geometry.centerOf(pos),
      _cell * 0.14,
      Paint()..color = AppColors.accentAmber,
    );
  }

  void _paintStation(Canvas canvas, GridPos pos, StationCell cell) {
    _paintRails(canvas, pos, cell.ports, AppColors.track);
    final color = colorForTrain(cell.color);
    final rect = Rect.fromCenter(
      center: geometry.centerOf(pos),
      width: _cell * 0.78,
      height: _cell * 0.78,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(_cell * 0.2));
    canvas.drawRRect(rrect, Paint()..color = AppColors.background);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cell * 0.06,
    );
    final hasDelivery = state.trains.any(
      (t) => t.delivered && t.position == pos,
    );
    _paintLabel(canvas, pos, hasDelivery ? '✓' : cell.color.symbol, color);
  }

  void _paintLabel(Canvas canvas, GridPos pos, String text, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: _cell * 0.36,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final center = geometry.centerOf(pos);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _paintBlocked(Canvas canvas, GridPos pos) {
    final rect = Rect.fromCenter(
      center: geometry.centerOf(pos),
      width: _cell * 0.9,
      height: _cell * 0.9,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(_cell * 0.1)),
      Paint()..color = AppColors.surface,
    );
  }

  void _paintHint(Canvas canvas) {
    final target = switch (hint) {
      TrainMove(:final trainId, :final direction) =>
        state.trainById(trainId)?.position.step(direction),
      SwitchToggle(:final position) => position,
      null => null,
    };
    if (target == null) return;
    canvas.drawCircle(
      geometry.centerOf(target),
      _cell * 0.42,
      Paint()
        ..color = AppColors.accentTurquoise
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cell * 0.06,
    );
  }

  @override
  bool shouldRepaint(BoardPainter old) =>
      old.state != state ||
      old.hint != hint ||
      old.geometry != geometry ||
      old.level != level;
}
