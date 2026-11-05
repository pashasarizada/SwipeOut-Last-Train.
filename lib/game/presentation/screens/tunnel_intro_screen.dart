import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../kit/motion_settings.dart';
import '../theme/app_colors.dart';

/// ≤2 s intro: headlights rush down a tunnel, the logo appears. A tap (or
/// Reduced Motion) skips straight to [next].
final class TunnelIntroScreen extends StatefulWidget {
  const TunnelIntroScreen({super.key, required this.next});

  final Widget next;

  static const Duration length = Duration(milliseconds: 1800);

  @override
  State<TunnelIntroScreen> createState() => _TunnelIntroScreenState();
}

class _TunnelIntroScreenState extends State<TunnelIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: TunnelIntroScreen.length)
          ..addStatusListener((s) {
            if (s == AnimationStatus.completed) _leave();
          });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MotionSettings.reducedOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _leave());
    } else if (!_controller.isAnimating && !_left) {
      _controller.forward();
    }
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => widget.next,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _leave,
      child: ColoredBox(
        color: AppColors.background,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _TunnelPainter(_controller.value)),
              Center(
                child: Opacity(
                  opacity: const Interval(0.55, 1).transform(_controller.value),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      'assets/branding/logo_512.png',
                      width: 180,
                      height: 180,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _TunnelPainter extends CustomPainter {
  const _TunnelPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // Tunnel rings flow towards the viewer.
    for (var i = 0; i < 9; i++) {
      final depth = ((i / 9) + t * 0.9) % 1;
      final scale = math.pow(depth, 2.2).toDouble();
      final rect = Rect.fromCenter(
        center: c,
        width: size.width * 1.3 * scale,
        height: size.height * 0.9 * scale,
      );
      ring.color = AppColors.trackInactive.withValues(
        alpha: 0.15 + 0.5 * depth,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.4)),
        ring,
      );
    }
    // Headlights growing as the train approaches.
    final glow = Curves.easeIn.transform(t);
    for (final side in [-1.0, 1.0]) {
      final light = c + Offset(side * 24 * (0.3 + glow * 2.5), 40 + glow * 60);
      canvas.drawCircle(
        light,
        10 + glow * 60,
        Paint()
          ..color = AppColors.accentAmber.withValues(alpha: 0.25 + glow * 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 + glow * 30),
      );
      canvas.drawCircle(
        light,
        4 + glow * 14,
        Paint()..color = AppColors.accentAmber,
      );
    }
  }

  @override
  bool shouldRepaint(_TunnelPainter old) => old.t != t;
}
