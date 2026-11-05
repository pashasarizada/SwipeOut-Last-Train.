import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/board_state.dart';
import '../../domain/cell.dart';
import '../../domain/direction.dart';
import '../../domain/grid_pos.dart';
import '../../domain/level_definition.dart';
import '../../domain/level_result.dart';
import '../../domain/move.dart';
import '../../domain/move_result.dart';
import '../../domain/star_rating.dart';
import '../../engine/game_session.dart';
import '../../engine/level_solver.dart';
import '../theme/motion.dart';
import 'game_event.dart';
import 'hint_runner.dart';

/// Turns taps and swipes into session moves. Owns selection, the input lock
/// during animations and hints; publishes one-shot [GameEvent]s.
final class GameController extends ChangeNotifier {
  GameController({
    required LevelDefinition level,
    HintRunner hintRunner = computeHint,
    Duration inputLock = kMoveAnimation,
  }) : _session = GameSession(level),
       _hintRunner = hintRunner,
       _inputLock = inputLock {
    _syncSelection();
  }

  final GameSession _session;
  final HintRunner _hintRunner;
  final Duration _inputLock;
  final StreamController<GameEvent> _events = StreamController.broadcast();

  String? _selectedTrainId;
  Move? _hint;
  Timer? _lockTimer;

  LevelDefinition get level => _session.level;
  BoardState get state => _session.state;
  int get moveCount => _session.moveCount;
  bool get isSolved => _session.isSolved;
  bool get canUndo => _session.canUndo;
  bool get isBusy => _lockTimer?.isActive ?? false;
  String? get selectedTrainId => _selectedTrainId;
  Move? get hint => _hint;
  Stream<GameEvent> get events => _events.stream;

  bool get _acceptsPlay => !isBusy && !isSolved;

  void tapCell(GridPos pos) {
    if (!_acceptsPlay) return;
    final train = state.trainAt(pos);
    if (train != null) {
      _selectedTrainId = train.id;
      notifyListeners();
    } else if (level.cellAt(pos) is SwitchCell) {
      _play(SwitchToggle(pos));
    }
  }

  void swipe(Direction direction) {
    if (!_acceptsPlay) return;
    final trainId = _selectedTrainId;
    if (trainId == null) {
      _events.add(const SelectTrainFirst());
      return;
    }
    _play(TrainMove(trainId, direction));
  }

  void undo() {
    if (isBusy) return;
    final before = state;
    if (_session.undo()) _afterBoardChange(before);
  }

  void restart() {
    if (isBusy || !canUndo) return;
    final before = state;
    _session.restart();
    _selectedTrainId = null;
    _afterBoardChange(before);
  }

  Future<void> requestHint() async {
    if (!_acceptsPlay) return;
    final asked = state;
    final outcome = await _hintRunner(level, asked);
    if (state != asked) return; // board changed while solving
    if (outcome is Solved && outcome.moves.isNotEmpty) {
      final next = outcome.moves.first;
      _hint = next;
      if (next is TrainMove) _selectedTrainId = next.trainId;
      notifyListeners();
    } else {
      _events.add(const HintUnavailable());
    }
  }

  void _play(Move move) {
    final before = state;
    final result = _session.play(move);
    switch (result) {
      case MoveRejected(:final reason):
        _events.add(MoveBlocked(reason));
      case MoveApplied(:final deliveredTrainId):
        if (deliveredTrainId != null) {
          _events.add(TrainDelivered(deliveredTrainId));
        }
        _afterBoardChange(before);
        if (isSolved) _events.add(LevelCompleted(_result()));
    }
  }

  void _afterBoardChange(BoardState before) {
    _hint = null;
    _syncSelection();
    if (_trainsMoved(before, state)) _startInputLock();
    notifyListeners();
  }

  /// Only train movement animates, so only it needs to block input.
  static bool _trainsMoved(BoardState a, BoardState b) =>
      !listEquals(a.trains, b.trains);

  void _startInputLock() {
    if (_inputLock == Duration.zero) return;
    _lockTimer?.cancel();
    _lockTimer = Timer(_inputLock, notifyListeners);
  }

  /// Drops a delivered selection; auto-selects when only one train remains.
  void _syncSelection() {
    final active = state.trains.where((t) => !t.delivered).toList();
    final selectedStillActive = active.any((t) => t.id == _selectedTrainId);
    if (!selectedStillActive) _selectedTrainId = null;
    if (active.length == 1) _selectedTrainId = active.single.id;
  }

  LevelResult _result() => LevelResult(
    levelId: level.id,
    moves: moveCount,
    rating: StarRating.forMoves(moves: moveCount, optimal: level.optimalMoves),
  );

  @override
  void dispose() {
    _lockTimer?.cancel();
    _events.close();
    super.dispose();
  }
}
