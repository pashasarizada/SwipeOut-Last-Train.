import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/control_action.dart';
import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import '../../domain/level_result.dart';
import '../../domain/node.dart';
import '../../domain/pulse_result.dart';
import '../../domain/star_rating.dart';
import '../../engine/game_session.dart';
import 'game_event.dart';

/// Screen state for one level: the pending control, the animation lock and
/// one-shot [GameEvent]s. Game rules stay in the engine.
final class PulseController extends ChangeNotifier {
  PulseController({required LevelDefinition level})
    : _session = GameSession(level);

  /// Rebuilds a half-played level by replaying its committed controls. A
  /// run that no longer replays (the level changed) starts fresh.
  factory PulseController.restore({
    required LevelDefinition level,
    required List<ControlAction?> actions,
  }) {
    final controller = PulseController(level: level);
    for (final action in actions) {
      if (controller._session.pulse(action) is PulseFailed) {
        controller._session.restart();
        controller._history.clear();
        return controller;
      }
      controller._history.add(action);
    }
    return controller;
  }

  final GameSession _session;
  final StreamController<GameEvent> _events = StreamController.broadcast();

  final List<ControlAction?> _history = [];
  ControlAction? _pending;
  GameState? _animatingFrom;
  bool _disposed = false;

  LevelDefinition get level => _session.level;
  GameState get state => _session.state;
  ControlAction? get pending => _pending;
  int get pulses => _session.pulses;
  int get maxPulses => level.maxPulses;
  bool get isSolved => _session.isSolved;
  bool get isLost => _session.isLost;
  bool get canUndo => _session.canUndo;
  Stream<GameEvent> get events => _events.stream;

  /// The control used by each committed pulse, oldest first (for saving).
  List<ControlAction?> get history => List.unmodifiable(_history);

  /// True between a committed pulse and [finishAnimation].
  bool get isAnimating => _animatingFrom != null;

  /// Where trains are drawn from: the previous state while animating.
  GameState get animationStart => _animatingFrom ?? state;

  bool get _acceptsInput => !_disposed && !isAnimating;

  bool get _canPlan => _acceptsInput && !isSolved && !isLost;

  /// Switch and signal nodes become the pending control; tapping the same
  /// one again cancels it. Other nodes do nothing.
  void tapNode(String nodeId) {
    if (!_canPlan) return;
    final ControlAction? action = switch (level.nodes[nodeId]?.kind) {
      NodeKind.junction => ToggleSwitch(nodeId),
      NodeKind.signal => ToggleSignal(nodeId),
      _ => null,
    };
    if (action == null) return;
    _pending = _pending == action ? null : action;
    _notify();
  }

  void cancelPending() {
    if (!_canPlan || _pending == null) return;
    _pending = null;
    _notify();
  }

  void advance() {
    if (!_canPlan) return;
    final before = state;
    final action = _pending;
    switch (_session.pulse(action)) {
      case PulseApplied(:final state, :final delivered):
        _history.add(action);
        _pending = null;
        _animatingFrom = before;
        _emit(PulseCommitted(before, state, delivered));
      case PulseFailed(:final reason, :final trainIds, :final nodeId):
        _emit(PulseRejected(reason, trainIds, nodeId));
    }
    _notify();
  }

  /// Called by the board when the tween ends; reveals the outcome.
  void finishAnimation() {
    if (_disposed || !isAnimating) return;
    _animatingFrom = null;
    if (isSolved) _emit(LevelWon(_result()));
    if (isLost) _emit(LevelLost(jammed: !_session.isOutOfPulses));
    _notify();
  }

  void undo() {
    if (!_acceptsInput || !_session.undo()) return;
    _history.removeLast();
    _pending = null;
    _notify();
  }

  void restart() {
    if (!_acceptsInput) return;
    _session.restart();
    _history.clear();
    _pending = null;
    _notify();
  }

  LevelResult _result() => LevelResult(
    levelId: level.id,
    pulses: pulses,
    rating: level.tutorial
        ? null
        : StarRating.forPulses(pulses: pulses, par: level.parPulses),
  );

  void _emit(GameEvent event) {
    if (!_disposed) _events.add(event);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _events.close();
    super.dispose();
  }
}
