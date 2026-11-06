part of '../pulse_game_screen.dart';

/// The platform's notices: the level's rules (calm, until the first tap)
/// and rejected pulses (an alarm that fades), plus the tutorial hand.
extension _Notices on _PulseGameScreenState {
  static const Duration _alarmDuration = Duration(milliseconds: 1600);

  /// Shows the level's rules; also when the departure board is tapped.
  void _showRules() {
    final language = Localizations.localeOf(context).languageCode;
    final rules = widget.level.tutorialSteps
        .map((step) => step.of(language))
        .join(' ');
    if (rules.isEmpty) return;
    _messageTimer?.cancel();
    _setNotice(rules, AnnouncementTone.info);
  }

  /// The first play clears the rules notice.
  void _hideRulesOnPlay() {
    if (_message != null && _messageTone == AnnouncementTone.info) {
      _setNotice(null, AnnouncementTone.info);
    }
  }

  /// A rejected pulse replaces any notice and fades on its own.
  void _showMessage(String? message) {
    if (message == null) return;
    _messageTimer?.cancel();
    _setNotice(message, AnnouncementTone.alarm);
    _messageTimer = Timer(_alarmDuration, () {
      if (mounted) _setNotice(null, AnnouncementTone.alarm);
    });
  }

  void _setNotice(String? message, AnnouncementTone tone) {
    // ignore: invalid_use_of_protected_member
    setState(() {
      _message = message;
      _messageTone = tone;
      if (message != null) _messageSerial++;
    });
  }

  /// A drawn hand points at the next right tap: always on tutorial
  /// levels, and after the hint button elsewhere.
  Widget _tutorialHand() => ListenableBuilder(
    listenable: Listenable.merge([_controller, _hints]),
    builder: (context, _) {
      final target = _controller.isAnimating || _controller.isSolved
          ? null
          : TutorialGuide.next(
                  level: widget.level,
                  history: _controller.history,
                  pending: _controller.pending,
                ) ??
                _hintTarget();
      if (target == null) return const SizedBox.shrink();
      return TutorialHand(
        target: target,
        level: widget.level,
        boardKey: _boardKey,
        leverKey: _leverKey,
        undoKey: _undoKey,
      );
    },
  );

  GuideTarget? _hintTarget() => switch (_hints?.hint) {
    HintAction(:final action) => TutorialGuide.towards(
      action,
      _controller.pending,
    ),
    HintUndo() => const GuideUndo(),
    null => null,
  };
}
