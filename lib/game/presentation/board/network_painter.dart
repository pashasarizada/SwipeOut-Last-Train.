import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/control_action.dart';
import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import '../../domain/node.dart';
import '../../domain/signal_aspect.dart';
import '../../domain/train_def.dart';
import '../city/city_theme.dart';
import '../kit/game_fonts.dart';
import '../kit/game_icon.dart';
import '../theme/app_colors.dart';
import 'board_layout.dart';
import 'metro_lines.dart';

part 'rail_marks.dart';
part 'station_marks.dart';

/// Draws the static network: rails, switches, signals, goals, the pending
/// control preview, the pulse light wave and the collision flash.
final class NetworkPainter extends CustomPainter {
  NetworkPainter({
    required this.level,
    required this.state,
    required this.layout,
    GameState? arrivals,
    this.pending,
    this.wave = 0,
    this.flashNode,
    this.flash = 0,
    this.highContrast = false,
    MetroMap? map,
  }) : arrivals = arrivals ?? state,
       _map = map;

  final LevelDefinition level;
  final GameState state;

  /// Deliveries to mark with a check — the pre-pulse state while trains still move.
  final GameState arrivals;
  final BoardLayout layout;
  final ControlAction? pending;

  /// 0–1 brightness boost of the rails right after a pulse.
  final double wave;
  final String? flashNode;

  /// Brighter, thicker rails (High Contrast).
  final bool highContrast;

  final MetroMap? _map;

  /// Metro-map paths and line colours (D-036); built here when not given.
  late final MetroMap map = _map ?? MetroMap(level, layout);
  late final CityTheme theme = CityTheme.of(level.city);

  /// Colour and width of a rail: open or a closed switch arm.
  static (Color, double) railStyle({required bool open, required bool high}) =>
      switch ((open, high)) {
        (true, false) => (AppColors.track, 6),
        (true, true) => (AppColors.textPrimary, 8),
        (false, false) => (AppColors.trackInactive, 4),
        (false, true) => (AppColors.textSecondary, 3),
      };

  /// 0–1 opacity of the red collision flash at [flashNode].
  final double flash;

  Offset _at(String nodeId) => layout.toScreen(level.nodes[nodeId]!.position);

  @override
  void paint(Canvas canvas, Size size) {
    _paintRails(canvas);
    for (final node in level.nodes.values) {
      _paintNode(canvas, node);
    }
    _paintNames(canvas);
    if (flashNode case final id? when flash > 0) {
      canvas.drawCircle(
        _at(id),
        24,
        Paint()..color = AppColors.danger.withValues(alpha: 0.7 * flash),
      );
    }
  }

  /// Closed switch arms with the pending control applied, so the board
  /// shows the track as it will be when the lever is pulled.
  late final Set<String> _closedArms = {
    for (final sw in level.switches.values)
      sw.edgeFor(
        pending == ToggleSwitch(sw.nodeId)
            ? state.switches[sw.nodeId]!
            : state.switches[sw.nodeId]!.toggled,
      ),
  };

  /// Whether a train can use [edgeId] next pulse: everything except the
  /// closed arm of each switch.
  bool isOpen(String edgeId) => !_closedArms.contains(edgeId);

  /// How far a closed arm stops short of its switch, so the gap reads as
  /// "this way is shut" (D-030).
  static const double closedGap = 30;

  void _paintNode(Canvas canvas, Node node) {
    final c = _at(node.id);
    switch (node.kind) {
      case NodeKind.depot:
        _paintDepot(canvas, node, c);
      case NodeKind.track:
        _paintTick(canvas, node, c, half: 6, width: 4);
      case NodeKind.junction:
        final selected = pending == ToggleSwitch(node.id);
        canvas.drawCircle(c, 11, Paint()..color = AppColors.accentAmber);
        // Outer ring stays visible when a train stands on the switch.
        canvas.drawCircle(
          c,
          21,
          _stroke(AppColors.accentAmber.withValues(alpha: 0.7), 2),
        );
        if (selected) {
          canvas.drawCircle(c, 19, _stroke(AppColors.accentTurquoise, 3));
        }
      case NodeKind.signal:
        _paintSignal(canvas, node, c);
      case NodeKind.goal:
        _paintGoal(canvas, node, c);
      case NodeKind.terminal:
        _paintTick(canvas, node, c, half: 8, width: 5);
    }
  }

  /// Where a signal's lamp head sits relative to its node: on a short
  /// post, clear of a train standing on the node, so its aspect stays
  /// readable while it holds that train.
  static const Offset signalLampOffset = Offset(22, -26);

  /// The train that must reach goal [nodeId], if any.
  TrainDef? _ownerOf(String nodeId) {
    for (final t in level.trains) {
      if (t.goalNode == nodeId) return t;
    }
    return null;
  }

  /// Whether goal [nodeId] shows its check mark — only once the train has arrived.
  bool goalChecked(String nodeId) {
    final owner = _ownerOf(nodeId);
    return owner != null && (arrivals.trainById(owner.id)?.delivered ?? false);
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  @override
  bool shouldRepaint(NetworkPainter old) =>
      old.state != state ||
      old.arrivals != arrivals ||
      old.pending != pending ||
      old.wave != wave ||
      old.flash != flash ||
      old.flashNode != flashNode ||
      old.layout != layout ||
      old.level != level ||
      old.highContrast != highContrast;
}
