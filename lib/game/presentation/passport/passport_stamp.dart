import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/passport.dart';
import '../city/city_theme.dart';
import '../kit/game_fonts.dart';
import '../kit/game_haptics.dart';
import '../kit/motion_settings.dart';
import '../sound/game_sounds.dart';
import '../theme/app_colors.dart';

/// One city's stamp. Earned stamps are pressed in at a slight angle with a
/// thud; unearned ones show a dashed outline and the progress count.
final class PassportStamp extends StatefulWidget {
  const PassportStamp({
    super.key,
    required this.stamp,
    required this.progressLabel,
    this.animateIn = false,
    this.size = 200,
  });

  final CityStamp stamp;
  final String progressLabel;
  final bool animateIn;
  final double size;

  static const Duration press = Duration(milliseconds: 220);
  static const Duration ink = Duration(milliseconds: 400);

  @override
  State<PassportStamp> createState() => _PassportStampState();
}

class _PassportStampState extends State<PassportStamp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale = Tween(begin: 1.45, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.35, curve: Curves.easeIn),
    ),
  );
  late final Animation<double> _inkFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.2, 1),
  );
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PassportStamp.press + PassportStamp.ink,
      value: 1,
    );
  }

  /// A fixed per-city tilt between −8° and +8°, so it looks hand-stamped.
  double get _tilt => ((widget.stamp.city.index * 37) % 17 - 8) * math.pi / 180;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !widget.animateIn || !widget.stamp.earned) return;
    _started = true;
    if (MotionSettings.reducedOf(context)) return;
    _controller.forward(from: 0);
    Future<void>.delayed(PassportStamp.press, () {
      if (!mounted) return;
      GameHaptics.play(context, HapticKind.heavy);
      GameSound.play(context, SoundCue.stamp);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stamp = widget.stamp;
    final theme = CityTheme.of(stamp.city);
    if (!stamp.earned) {
      return SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: const _DashedRingPainter(),
          child: Center(
            child: Text(
              widget.progressLabel,
              style: const TextStyle(
                fontFamily: GameFonts.board,
                fontSize: 26,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Opacity(
        opacity: _inkFade.value.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: _tilt,
          child: Transform.scale(
            scale: _scale.value,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _StampPainter(theme, gold: stamp.gold),
            ),
          ),
        ),
      ),
    );
  }
}

final class _StampPainter extends CustomPainter {
  const _StampPainter(this.theme, {required this.gold});

  final CityTheme theme;
  final bool gold;

  @override
  void paint(Canvas canvas, Size size) =>
      theme.art.paintStamp(canvas, size, theme, gold: gold);

  @override
  bool shouldRepaint(_StampPainter old) =>
      old.theme != theme || old.gold != gold;
}

final class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.45;
    final paint = Paint()
      ..color = AppColors.trackInactive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const dashes = 36;
    for (var i = 0; i < dashes; i += 2) {
      final a = i * 2 * math.pi / dashes;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        a,
        2 * math.pi / dashes,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => false;
}
