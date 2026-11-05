import 'package:flutter/material.dart';

import '../../domain/control_action.dart';
import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import '../../domain/node.dart';
import '../../domain/signal_aspect.dart';
import '../../domain/train_def.dart';
import '../kit/game_fonts.dart';
import '../kit/game_icon.dart';
import '../theme/app_colors.dart';
import 'board_layout.dart';

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
  }) : arrivals = arrivals ?? state;

  final LevelDefinition level;
  final GameState state;

  /// Deliveries to mark with a check — the pre-pulse state while trains still move.
  final GameState arrivals;
  final BoardLayout layout;
  final ControlAction? pending;

  /// 0–1 brightness boost of the rails right after a pulse.
  final double wave;
  final String? flashNode;

  /// 0–1 opacity of the red collision flash at [flashNode].
  final double flash;

  Offset _at(String nodeId) => layout.toScreen(level.nodes[nodeId]!.position);

  @override
  void paint(Canvas canvas, Size size) {
    _paintRails(canvas);
    for (final node in level.nodes.values) {
      _paintNode(canvas, node);
    }
    if (flashNode case final id? when flash > 0) {
      canvas.drawCircle(
        _at(id),
        24,
        Paint()..color = AppColors.danger.withValues(alpha: 0.7 * flash),
      );
    }
  }

  void _paintRails(Canvas canvas) {
    final passive = {
      for (final sw in level.switches.values)
        sw.edgeFor(state.switches[sw.nodeId]!.toggled),
    };
    final preview = switch (pending) {
      ToggleSwitch(:final nodeId) => level.switches[nodeId]!.edgeFor(
        state.switches[nodeId]!.toggled,
      ),
      _ => null,
    };
    for (final edge in level.edges.values) {
      final from = _at(edge.a);
      final to = _at(edge.b);
      if (edge.id == preview) {
        canvas.drawLine(
          from,
          to,
          _stroke(AppColors.accentTurquoise.withValues(alpha: 0.45), 14),
        );
      }
      final base = passive.contains(edge.id)
          ? AppColors.trackInactive
          : AppColors.track;
      final lit = Color.lerp(base, AppColors.textPrimary, wave * 0.6)!;
      canvas.drawLine(from, to, _stroke(lit, 6));
    }
  }

  void _paintNode(Canvas canvas, Node node) {
    final c = _at(node.id);
    switch (node.kind) {
      case NodeKind.depot:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCircle(center: c, radius: 16),
            const Radius.circular(6),
          ),
          _stroke(AppColors.trackInactive, 3),
        );
      case NodeKind.track:
        canvas.drawCircle(c, 5, Paint()..color = AppColors.track);
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
        final green = state.signals[node.id] == SignalAspect.green;
        final selected = pending == ToggleSignal(node.id);
        canvas.drawCircle(
          c,
          10,
          Paint()..color = green ? AppColors.signalGreen : AppColors.danger,
        );
        if (selected) {
          canvas.drawCircle(c, 18, _stroke(AppColors.accentTurquoise, 3));
        }
      case NodeKind.goal:
        _paintGoal(canvas, node, c);
      case NodeKind.terminal:
        canvas.drawRect(
          Rect.fromCircle(center: c, radius: 7),
          Paint()..color = AppColors.trackInactive,
        );
    }
  }

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

  void _paintGoal(Canvas canvas, Node node, Offset c) {
    final owner = _ownerOf(node.id);
    final color = owner == null ? AppColors.track : colorForStyle(owner.style);
    canvas.drawCircle(c, 18, Paint()..color = AppColors.background);
    canvas.drawCircle(c, 18, _stroke(color, 4));
    _label(canvas, c, owner?.symbol.glyph ?? '', color, 16);
    if (goalChecked(node.id)) {
      GameIcon.paint(
        canvas,
        GameIconKind.check,
        Rect.fromCircle(center: c + const Offset(16, -16), radius: 8),
        AppColors.signalGreen,
      );
    }
  }

  void _label(
    Canvas canvas,
    Offset center,
    String text,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: GameFonts.body,
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
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
      old.level != level;
}
