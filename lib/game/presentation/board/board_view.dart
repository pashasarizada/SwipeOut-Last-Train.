import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/game_event.dart';
import '../game/pulse_controller.dart';
import '../kit/game_haptics.dart';
import '../kit/motion_settings.dart';
import '../sound/game_sounds.dart';
import '../theme/motion.dart';
import 'board_layout.dart';
import 'forecast_painter.dart';
import 'network_painter.dart';
import 'train_layer.dart';

/// The interactive network: tap controls, play each pulse as one tween.
final class BoardView extends StatefulWidget {
  const BoardView({super.key, required this.controller});

  final PulseController controller;

  /// The board's shake on a crash (6 pt, gone with Reduced Motion).
  static const Key shakeKey = Key('board-shake');
  static const double shakeAmplitude = 6;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: kPulseMove,
    value: 1,
  )..addStatusListener(_onPulseStatus);
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: kCollisionFlash,
  );
  late final Animation<double> _wave = CurvedAnimation(
    parent: _pulse,
    curve: Interval(0, kPulseWave.inMilliseconds / kPulseMove.inMilliseconds),
  );
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: kCollisionBump,
  );

  /// Loops the forecast arrows' running dots a few times after the board
  /// changes, then rests, so an idle phone is not kept busy.
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: kForecastLoop,
  );
  late final StreamSubscription<GameEvent> _events;
  String? _flashNode;
  Set<String> _bumped = const {};
  String? _bumpNode;
  Timer? _secondTap;
  bool _reduced = false;

  PulseController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _events = _controller.events.listen(_onEvent);
    _controller.addListener(_wakeIdle);
  }

  /// Plays the idle loop when there is a forecast to animate.
  void _wakeIdle() {
    if (_reduced || _controller.forecast == null) {
      _idle.value = 0;
      _idle.stop();
      return;
    }
    _idle.repeat(count: kForecastLoops);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MotionSettings.reducedOf(context);
    _wakeIdle();
  }

  void _onEvent(GameEvent event) {
    switch (event) {
      case PulseCommitted(:final delivered):
        _pulse.forward(from: 0);
        GameSound.play(context, SoundCue.pulseTick);
        if (delivered.isNotEmpty) _deliveryTaps(delivered.length);
      case PulseRejected(:final trainIds, :final nodeId):
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
    if (status == AnimationStatus.completed) _controller.finishAnimation();
  }

  /// Leaving the app mid-pulse settles on the committed state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _pulse.isAnimating) {
      _pulse.value = 1;
    }
    if (state != AppLifecycleState.resumed) _idle.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _events.cancel();
    _controller.removeListener(_wakeIdle);
    _idle.dispose();
    _pulse.dispose();
    _flash.dispose();
    _bump.dispose();
    _secondTap?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = BoardLayout(size: constraints.biggest);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final id = layout.nodeAt(d.localPosition, _controller.level.nodes);
            if (id == null) return;
            final before = _controller.pending;
            _controller.tapNode(id);
            if (_controller.pending != before) {
              GameSound.play(context, SoundCue.switchClack);
            }
          },
          child: ListenableBuilder(
            listenable: Listenable.merge([_controller, _wave, _flash, _bump]),
            builder: (context, _) => Transform.translate(
              key: BoardView.shakeKey,
              offset: Offset(_shakeOffset, 0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: NetworkPainter(
                        level: _controller.level,
                        state: _controller.state,
                        arrivals: _pulse.isAnimating
                            ? _controller.animationStart
                            : _controller.state,
                        layout: layout,
                        pending: _controller.pending,
                        wave: _pulse.isAnimating ? 1 - _wave.value : 0,
                        flashNode: _flashNode,
                        flash: _flash.value,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ForecastPainter(
                        level: _controller.level,
                        forecast: _controller.forecast,
                        layout: layout,
                        flow: _idle,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: TrainLayer(
                      level: _controller.level,
                      before: _controller.animationStart,
                      after: _controller.state,
                      progress: _pulse,
                      layout: layout,
                      bump: _bump,
                      bumped: _bumped,
                      bumpNode: _bumpNode,
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ForecastPainter(
                        level: _controller.level,
                        forecast: _controller.forecast,
                        layout: layout,
                        layer: ForecastLayer.overTrains,
                        flow: _idle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
