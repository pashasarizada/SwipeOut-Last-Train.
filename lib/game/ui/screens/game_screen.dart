import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/level_definition.dart';
import '../../domain/level_result.dart';
import '../board/board_view.dart';
import '../game/game_controller.dart';
import '../game/game_event.dart';
import '../game/hint_runner.dart';
import '../theme/app_colors.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_texts.dart';
import '../widgets/level_complete_sheet.dart';

/// Hosts one level: owns its controller and reacts to its one-shot events.
final class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.level,
    this.onNext,
    this.hintRunner = computeHint,
  });

  final LevelDefinition level;
  final VoidCallback? onNext;
  final HintRunner hintRunner;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const Duration _messageDuration = Duration(milliseconds: 1200);

  late final GameController _controller = GameController(
    level: widget.level,
    hintRunner: widget.hintRunner,
  );
  late final StreamSubscription<GameEvent> _events;
  String? _message;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _events = _controller.events.listen(_onEvent);
  }

  void _onEvent(GameEvent event) {
    final l = AppLocalizations.of(context);
    switch (event) {
      case MoveBlocked(:final reason):
        _showMessage(l.blockedMessage(reason));
      case SelectTrainFirst():
        _showMessage(l.selectTrainFirst);
      case HintUnavailable():
        _showMessage(l.hintUnavailable);
      case TrainDelivered():
        HapticFeedback.selectionClick();
      case LevelCompleted(:final result):
        _showResult(result);
    }
  }

  void _showMessage(String? message) {
    if (message == null) return;
    _messageTimer?.cancel();
    setState(() => _message = message);
    _messageTimer = Timer(_messageDuration, () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _showResult(LevelResult result) {
    final onNext = widget.onNext;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => LevelCompleteSheet(
        result: result,
        onReplay: () {
          Navigator.of(sheetContext).pop();
          _controller.restart();
        },
        onNext: onNext == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onNext();
              },
      ),
    );
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _events.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = AppLocalizations.of(
      context,
    ).tutorialText(widget.level.tutorialKey);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => GameHud(
                levelNumber: widget.level.number,
                moves: _controller.moveCount,
              ),
            ),
            SizedBox(
              height: 24,
              child: Text(
                _message ?? '',
                style: text.bodyMedium?.copyWith(color: AppColors.accentAmber),
              ),
            ),
            if (tutorial != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  tutorial,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BoardView(controller: _controller),
              ),
            ),
            GameControls(controller: _controller),
          ],
        ),
      ),
    );
  }
}
