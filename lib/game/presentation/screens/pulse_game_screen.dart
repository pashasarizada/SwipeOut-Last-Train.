import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/control_action.dart';
import '../../domain/level_definition.dart';
import '../../domain/level_result.dart';
import '../board/board_view.dart';
import '../game/game_event.dart';
import '../game/game_scope.dart';
import '../game/progress_store.dart';
import '../game/pulse_controller.dart';
import '../kit/game_scaffold.dart';
import '../kit/platform_announcement.dart';
import '../passport/passport_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/game_texts.dart';
import '../widgets/outcome_board.dart';
import '../widgets/pulse_controls.dart';
import '../widgets/pulse_hud.dart';

part 'pulse_game/outcome_boards.dart';

/// The platform for one level: owns its controller, saves the run after
/// every committed pulse, and shows the result board.
final class PulseGameScreen extends StatefulWidget {
  const PulseGameScreen({
    super.key,
    required this.level,
    this.restore = const [],
    this.onNext,
  });

  final LevelDefinition level;

  /// Controls of a half-played run to replay on open.
  final List<ControlAction?> restore;
  final VoidCallback? onNext;

  @override
  State<PulseGameScreen> createState() => _PulseGameScreenState();
}

class _PulseGameScreenState extends State<PulseGameScreen> {
  static const Duration _messageDuration = Duration(milliseconds: 1600);

  late final PulseController _controller = widget.restore.isEmpty
      ? PulseController(level: widget.level)
      : PulseController.restore(level: widget.level, actions: widget.restore);
  late final StreamSubscription<GameEvent> _events;
  ProgressStore? _store;
  List<ControlAction?> _saved = const [];
  String? _message;
  int _messageSerial = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _saved = _controller.history;
    _events = _controller.events.listen(_onEvent);
    _controller.addListener(_saveRun);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GameScope.of(context);
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

  void _showMessage(String? message) {
    if (message == null) return;
    _messageTimer?.cancel();
    setState(() {
      _message = message;
      _messageSerial++;
    });
    _messageTimer = Timer(_messageDuration, () {
      if (mounted) setState(() => _message = null);
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _events.cancel();
    _controller.removeListener(_saveRun);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return GameScaffold(
      city: widget.level.city,
      backdropOpacity: 0.35,
      header: PulseHud(controller: _controller),
      body: Column(
        children: [
          for (final step in widget.level.tutorialSteps.take(
            isCompactScreen(context) ? 1 : 2,
          ))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                step.of(language),
                maxLines: isCompactScreen(context) ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: BoardView(controller: _controller)),
                // The announcement floats over the board's top edge so the
                // board keeps that space; it never blocks a tap.
                if (_message case final message?)
                  Positioned(
                    top: 4,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: PlatformAnnouncement(
                          message: message,
                          serial: _messageSerial,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          PulseControls(controller: _controller),
        ],
      ),
    );
  }
}
