import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'motion_settings.dart';

/// Loading indicator: a headlight running along a short stretch of track.
final class TrackLoader extends StatefulWidget {
  const TrackLoader({super.key});

  @override
  State<TrackLoader> createState() => _TrackLoaderState();
}

class _TrackLoaderState extends State<TrackLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MotionSettings.reducedOf(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 120,
    height: 24,
    child: CustomPaint(painter: _TrackPainter(_controller)),
  );
}

final class _TrackPainter extends CustomPainter {
  _TrackPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final rail = Paint()
      ..color = AppColors.trackInactive
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), rail);
    final x = 4 + (size.width - 8) * progress.value;
    canvas.drawCircle(
      Offset(x, y),
      9,
      Paint()
        ..color = AppColors.accentAmber.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.accentAmber);
  }

  @override
  bool shouldRepaint(_TrackPainter old) => false;
}
