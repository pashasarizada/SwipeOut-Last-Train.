import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/level_definition.dart';
import '../../domain/level_result.dart';
import '../board/board_view.dart';
import '../game/game_event.dart';
import '../game/pulse_controller.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';
import '../widgets/game_texts.dart';
import '../widgets/level_outcome_sheet.dart';
import '../widgets/pulse_controls.dart';
import '../widgets/pulse_hud.dart';

/// Hosts one level: owns its controller and turns events into feedback.
final class PulseGameScreen extends StatefulWidget {
  const PulseGameScreen({super.key, required this.level, this.onNext});

  final LevelDefinition level;
  final VoidCallback? onNext;

  @override
  State<PulseGameScreen> createState() => _PulseGameScreenState();
}

class _PulseGameScreenState extends State<PulseGameScreen> {
  static const Duration _messageDuration = Duration(milliseconds: 1600);

  late final PulseController _controller = PulseController(level: widget.level);
  late final StreamSubscription<GameEvent> _events;
  String? _message;
  int _messageSerial = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _events = _controller.events.listen(_onEvent);
  }

  void _onEvent(GameEvent event) {
    switch (event) {
      case PulseRejected(:final reason):
        _showMessage(AppLocalizations.of(context).failureMessage(reason));
      case LevelWon(:final result):
        _showOutcome(result);
      case LevelLost():
        _showOutcome(null);
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

  void _showOutcome(LevelResult? result) {
    final onNext = widget.onNext;
    void close(BuildContext sheet) => Navigator.of(sheet).pop();
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      builder: (sheet) {
        void playAgain() {
          close(sheet);
          _controller.restart();
        }

        void backToCity() {
          close(sheet);
          Navigator.of(context).maybePop();
        }

        return result == null
            ? LevelOutcomeSheet.lost(
                onUndo: () {
                  close(sheet);
                  _controller.undo();
                },
                onPlayAgain: playAgain,
                onBackToCity: backToCity,
              )
            : LevelOutcomeSheet.won(
                result: result,
                onPlayAgain: playAgain,
                onBackToCity: backToCity,
                onNext: onNext == null
                    ? null
                    : () {
                        close(sheet);
                        onNext();
                      },
              );
      },
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
    final language = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PulseHud(controller: _controller),
            for (final step in widget.level.tutorialSteps)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  step.of(language),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium,
                ),
              ),
            SizedBox(
              height: 28,
              child: _message == null
                  ? null
                  : Text(
                      _message!,
                      key: ValueKey(_messageSerial),
                      style: text.bodyMedium?.copyWith(color: AppColors.danger),
                    ).animate().shakeX(duration: kCollisionFlash, hz: 5),
            ),
            Expanded(child: BoardView(controller: _controller)),
            PulseControls(controller: _controller),
          ],
        ),
      ),
    );
  }
}
