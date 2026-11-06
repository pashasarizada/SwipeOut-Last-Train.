part of 'board_view.dart';

/// How the board answers the game: a pulse plays as one tween and ticks,
/// a crash flashes, shakes and buzzes, a delivery chimes and bursts.
extension _BoardFeedback on _BoardViewState {
  /// A tap picks the control nearest to it; a changed choice clacks.
  void _onTap(BoardLayout layout, Offset at) {
    final nodes = _controller.level.nodes;
    final id = layout.controlAt(at, nodes) ?? layout.nodeAt(at, nodes);
    if (id == null) return;
    final before = _controller.pending;
    _controller.tapNode(id);
    if (_controller.pending != before) {
      GameSound.play(context, SoundCue.switchClack);
    }
  }

  void _onEvent(GameEvent event) {
    switch (event) {
      case PulseCommitted(:final delivered):
        _pulse.forward(from: 0);
        GameSound.play(context, SoundCue.pulseTick);
        _arriving = delivered;
        if (delivered.isNotEmpty) _deliveryTaps(delivered.length);
      case PulseRejected(:final trainIds, :final nodeId):
        // ignore: invalid_use_of_protected_member
        setState(() {
          _flashNode = nodeId;
          _bumped = trainIds.toSet();
          _bumpNode = nodeId;
        });
        _flash.forward(from: 0).then((_) => _flash.reverse());
        if (!_reduced) _bump.forward(from: 0);
        GameHaptics.play(context, HapticKind.heavy);
        GameSound.play(context, SoundCue.crash);
      case LevelWon() || LevelLost():
        break;
    }
  }

  /// Delivery speaks in two light taps (docs/UI_UX_GUIDELINES.md §9).
  /// Several trains home in one minute chime twice.
  void _deliveryTaps(int count) {
    GameHaptics.play(context, HapticKind.light);
    GameSound.play(context, SoundCue.delivery);
    _secondTap?.cancel();
    _secondTap = Timer(kDeliveryTapGap, () {
      if (!mounted) return;
      GameHaptics.play(context, HapticKind.light);
      if (count > 1) GameSound.play(context, SoundCue.delivery);
    });
  }

  /// A damped side-to-side shake that starts and ends at rest.
  double get _shakeOffset {
    if (_reduced || !_bump.isAnimating) return 0;
    final v = _bump.value;
    return BoardView.shakeAmplitude * math.sin(v * math.pi * 6) * (1 - v);
  }

  void _onPulseStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_arriving.isNotEmpty) {
      // ignore: invalid_use_of_protected_member
      setState(() => _celebrated = _arriving);
      _arriving = const [];
      _celebrate.forward(from: 0);
    }
    _controller.finishAnimation();
  }

  /// Leaving the app mid-pulse settles on the committed state.

  /// Plays the idle loop when there is a forecast to animate.
  void _wakeIdle() {
    if (_reduced || _controller.forecast == null) {
      _idle.value = 0;
      _idle.stop();
      return;
    }
    _idle.repeat(count: kForecastLoops);
  }

  /// The burst over the goals the last pulse delivered to.
  Widget _celebration(BoardLayout layout) => Positioned.fill(
    child: CustomPaint(
      painter: CelebrationPainter(
        level: _controller.level,
        trainIds: _celebrated,
        layout: layout,
        reduced: _reduced,
        progress: _celebrate,
      ),
    ),
  );
}
