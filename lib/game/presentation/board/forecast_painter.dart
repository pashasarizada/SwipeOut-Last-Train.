import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../domain/level_definition.dart';
import '../../domain/pulse_forecast.dart';
import '../../domain/train_def.dart';
import '../kit/game_icon.dart';
import '../theme/app_colors.dart';
import 'board_layout.dart';

part 'forecast_marks.dart';

/// What a train shows for the next pulse.
enum ForecastMark { arrow, waiting }

/// The forecast is painted twice: under the trains (arrows, badges, goal
/// glow) and above them (the conflict cross, which often sits on a train).
enum ForecastLayer { underTrains, overTrains }

/// The next pulse, drawn without words (docs/GAME_DESIGN_V2.md §3.2/5 —
/// one pulse ahead, never the solution): an arrow in the train's colour
/// towards the node each moving train will enter, and a "waiting" badge
/// beside each train that stays. [flow] (0–1, looping) runs dots along the
/// arrows.
final class ForecastPainter extends CustomPainter {
  ForecastPainter({
    required this.level,
    required this.forecast,
    required this.layout,
    this.layer = ForecastLayer.underTrains,
    Animation<double> flow = kAlwaysDismissedAnimation,
  }) : _flow = flow,
       super(repaint: flow);

  final LevelDefinition level;

  /// Null while a pulse plays or once the run is over: nothing is drawn.
  final PulseForecast? forecast;
  final BoardLayout layout;
  final ForecastLayer layer;
  final Animation<double> _flow;

  /// Where along its edge an arrow starts and ends.
  static const double arrowFrom = 0.30;
  static const double arrowTo = 0.85;

  /// Offset of the waiting badge from the train's node.
  static const Offset badgeOffset = Offset(20, -20);

  static ForecastMark markOf(TrainMove move) =>
      move.moves ? ForecastMark.arrow : ForecastMark.waiting;

  Offset _at(String nodeId) => layout.toScreen(level.nodes[nodeId]!.position);

  /// The arrow's screen ends for a moving train.
  (Offset, Offset) arrowFor(TrainMove move) {
    final from = _at(move.from);
    final delta = _at(move.to!) - from;
    return (from + delta * arrowFrom, from + delta * arrowTo);
  }

  /// The colour [move] is drawn in: red when its train is in the conflict.
  Color colorFor(TrainMove move) =>
      (forecast?.conflict?.trainIds.contains(move.trainId) ?? false)
      ? AppColors.danger
      : colorForStyle(level.trainDef(move.trainId)!.style);

  /// The node where the next pulse would fail, marked with a cross.
  String? get crossAt => forecast?.conflict?.nodeId;

  /// Where the cross is drawn: on the conflict node, or — when a train
  /// stands there — just in front of it, towards the train running in, so
  /// the standing train stays visible.
  Offset? get crossPoint {
    final node = crossAt;
    if (node == null) return null;
    final at = _at(node);
    final moves = forecast!.moves;
    final occupied = moves.any((m) => m.from == node);
    if (!occupied) return at;
    for (final m in moves) {
      if (m.to == node) {
        final back = _at(m.from) - at;
        return at + back / back.distance * crossShift;
      }
    }
    return at;
  }

  /// How far the cross moves off an occupied conflict node.
  static const double crossShift = 26;

  /// Goals that the next pulse would deliver a train to.
  Set<String> get glowingGoals => {
    for (final id in forecast?.delivers ?? const <String>{})
      level.trainDef(id)!.goalNode,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final f = forecast;
    if (f == null) return;
    if (layer == ForecastLayer.overTrains) {
      if (crossPoint case final point?) _paintCross(canvas, point);
      return;
    }
    for (final move in f.moves) {
      switch (markOf(move)) {
        case ForecastMark.arrow:
          _paintArrow(canvas, move);
        case ForecastMark.waiting:
          _paintWaiting(canvas, _at(move.from) + badgeOffset);
      }
    }
    for (final id in f.delivers) {
      _paintGlow(canvas, level.trainDef(id)!);
    }
  }

  @override
  bool shouldRepaint(ForecastPainter old) =>
      old.forecast != forecast ||
      old.layout != layout ||
      old.level != level ||
      old.layer != layer;
}
