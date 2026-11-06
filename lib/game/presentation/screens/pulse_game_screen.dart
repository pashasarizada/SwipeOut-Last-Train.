import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/control_action.dart';
import '../../domain/level_definition.dart';
import '../../domain/level_result.dart';
import '../../engine/hint_finder.dart';
import '../board/board_view.dart';
import '../game/game_event.dart';
import '../game/game_scope.dart';
import '../game/hint_controller.dart';
import '../game/progress_store.dart';
import '../game/pulse_controller.dart';
import '../game/tutorial_guide.dart';
import '../kit/game_scaffold.dart';
import '../kit/platform_announcement.dart';
import '../passport/passport_screen.dart';
import '../widgets/game_texts.dart';
import '../widgets/outcome_board.dart';
import '../widgets/pulse_controls.dart';
import '../widgets/pulse_hud.dart';
import '../widgets/tutorial_hand.dart';

part 'pulse_game/notices.dart';
part 'pulse_game/outcome_boards.dart';

/// The platform for one level: owns its controller, saves the run after
/// every committed pulse, and shows the result board.
final class PulseGameScreen extends StatefulWidget {
  const PulseGameScreen({
    super.key,
    required this.level,
    this.restore = const [],
    this.onNext,
    this.hintRunner,
  });

  final LevelDefinition level;

  /// Controls of a half-played run to replay on open.
  final List<ControlAction?> restore;
  final VoidCallback? onNext;

  /// Where hints are worked out; tests run them inline.
  @visibleForTesting
  final HintRunner? hintRunner;

  @override
  State<PulseGameScreen> createState() => _PulseGameScreenState();
}

class _PulseGameScreenState extends State<PulseGameScreen> {
  late final PulseController _controller = widget.restore.isEmpty
      ? PulseController(level: widget.level)
      : PulseController.restore(level: widget.level, actions: widget.restore);
  late final HintController? _hints = widget.level.tutorial
      ? null
      : HintController(_controller, runner: widget.hintRunner);
  late final StreamSubscription<GameEvent> _events;
  ProgressStore? _store;
  List<ControlAction?> _saved = const [];
  String? _message;
  AnnouncementTone _messageTone = AnnouncementTone.alarm;
  int _messageSerial = 0;
  Timer? _messageTimer;
  bool _rulesShown = false;
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey _leverKey = GlobalKey();
  final GlobalKey _undoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _saved = _controller.history;
    _events = _controller.events.listen(_onEvent);
    _controller.addListener(_saveRun);
    _controller.addListener(_hideRulesOnPlay);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GameScope.of(context);
    if (!_rulesShown) {
      _rulesShown = true;
      _showRules();
    }
  }

  /// Persist the half-played run whenever its history changes. A lost run
  /// is not worth continuing, so it clears the slot (undo saves it again).
  void _saveRun() {
    final history = _controller.history;
    if (_controller.isSolved || listEquals(history, _saved)) return;
    _saved = history;
    _store?.saveRun(widget.level.id, _controller.isLost ? const [] : history);
  }

  /// Result boards open only while this platform is the screen in front:
  /// a player who left during the last pulse is not followed by one.
  bool get _inFront => mounted && (ModalRoute.of(context)?.isCurrent ?? false);

  Future<void> _onEvent(GameEvent event) async {
    switch (event) {
      case PulseRejected(:final reason):
        if (!mounted) return;
        _showMessage(AppLocalizations.of(context).failureMessage(reason));
      case LevelWon(:final result):
        final fresh = await _store?.recordWin(result) ?? const [];
        if (_inFront) {
          _showWin(result, newStamp: fresh.contains(widget.level.city));
        }
      case LevelLost(:final jammed):
        if (_inFront) _showLoss(jammed: jammed);
      case PulseCommitted():
        break;
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _events.cancel();
    _controller.removeListener(_saveRun);
    _controller.removeListener(_hideRulesOnPlay);
    _hints?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      city: widget.level.city,
      backdropOpacity: 0.35,
      header: PulseHud(controller: _controller, onBoardTap: _showRules),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BoardView(key: _boardKey, controller: _controller),
                    ),
                    // The notice floats over the board's top edge so the
                    // board keeps that space; it never blocks a tap.
                    if (_message case final message?)
                      Positioned(
                        top: 4,
                        left: 12,
                        right: 12,
                        child: IgnorePointer(
                          child: Center(
                            child: PlatformAnnouncement(
                              message: message,
                              serial: _messageSerial,
                              tone: _messageTone,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PulseControls(
                controller: _controller,
                leverKey: _leverKey,
                undoKey: _undoKey,
                hints: _hints,
              ),
            ],
          ),
          Positioned.fill(child: _tutorialHand()),
        ],
      ),
    );
  }
}
