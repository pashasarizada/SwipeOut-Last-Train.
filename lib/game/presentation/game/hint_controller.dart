import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../../domain/control_action.dart';
import '../../domain/game_state.dart';
import '../../domain/level_definition.dart';
import '../../engine/hint_finder.dart';
import 'pulse_controller.dart';

/// Works out a hint; the default runs [HintFinder] on another isolate so a
/// big board's search never stalls the platform.
typedef HintRunner =
    Future<Hint> Function(
      LevelDefinition level,
      GameState state,
      List<ControlAction?> history,
    );

/// The hint button's state: asks for the next right move, shows it until
/// the board moves on, and charges the run its third star.
final class HintController extends ChangeNotifier {
  HintController(this._game, {HintRunner? runner})
    : _runner = runner ?? _offThread {
    _game.addListener(_dropStale);
  }

  final PulseController _game;
  final HintRunner _runner;
  (GameState, Hint)? _hint;
  bool _thinking = false;
  bool _disposed = false;

  /// The hint for the board as it is now, or null.
  Hint? get hint => switch (_hint) {
    (final state, final hint) when state == _game.state => hint,
    _ => null,
  };

  bool get thinking => _thinking;

  /// Hints are offered while the run can still be played.
  bool get canAsk => !_thinking && _game.forecast != null;

  Future<void> request() async {
    if (!canAsk) return;
    final state = _game.state;
    final history = _game.history;
    _thinking = true;
    _notify();
    Hint found;
    try {
      found = await _runner(_game.level, state, history);
    } on Object {
      found = HintFinder(_game.level).next(state, history);
    }
    if (_disposed) return;
    _thinking = false;
    // The player may have moved on while the search ran.
    if (_game.state == state && _game.forecast != null) {
      _hint = (state, found);
      _game.markHintUsed();
    }
    _notify();
  }

  void _dropStale() {
    if (_hint != null && hint == null) {
      _hint = null;
      _notify();
    }
  }

  static Future<Hint> _offThread(
    LevelDefinition level,
    GameState state,
    List<ControlAction?> history,
  ) => Isolate.run(() => HintFinder(level).next(state, history));

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _game.removeListener(_dropStale);
    super.dispose();
  }
}
