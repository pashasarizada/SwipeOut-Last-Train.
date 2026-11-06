part of '../pulse_game_screen.dart';

/// The result boards a finished run opens over the platform.
extension _OutcomeBoards on _PulseGameScreenState {
  void _openBoard(Widget Function(void Function(VoidCallback) close) builder) {
    final navigator = Navigator.of(context);
    navigator.push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: const Color(0xAA000000),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => builder((then) {
          navigator.pop();
          then();
        }),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _backToCity() => Navigator.of(context).maybePop();

  void _showWin(LevelResult result, {required bool newStamp}) {
    final l = AppLocalizations.of(context);
    final store = _store;
    final onNext = widget.onNext;
    _openBoard(
      (close) => OutcomeBoard(
        title: l.levelComplete,
        result: result,
        goldTarget: widget.level.tutorial ? null : widget.level.parPulses,
        hintUsed: _controller.hintUsed,
        actions: [
          if (newStamp && store != null)
            (
              label: l.openPassport,
              primary: true,
              onPressed: () => close(
                () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => PassportScreen(
                      passport: store.passport,
                      highlight: widget.level.city,
                    ),
                  ),
                ),
              ),
            )
          else if (onNext != null)
            (label: l.next, primary: true, onPressed: () => close(onNext)),
          (
            label: l.playAgain,
            primary: false,
            onPressed: () => close(_controller.restart),
          ),
          (
            label: l.backToCity,
            primary: false,
            onPressed: () => close(_backToCity),
          ),
        ],
      ),
    );
  }

  void _showLoss({required bool jammed}) {
    final l = AppLocalizations.of(context);
    _openBoard(
      (close) => OutcomeBoard(
        title: jammed ? l.levelJammed : l.levelLost,
        failed: true,
        actions: [
          (
            label: l.undo,
            primary: true,
            onPressed: () => close(_controller.undo),
          ),
          (
            label: l.playAgain,
            primary: false,
            onPressed: () => close(_controller.restart),
          ),
          (
            label: l.backToCity,
            primary: false,
            onPressed: () => close(_backToCity),
          ),
        ],
      ),
    );
  }
}
