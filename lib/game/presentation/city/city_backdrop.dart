import 'package:flutter/material.dart';

import '../../domain/city.dart';
import '../kit/motion_settings.dart';
import 'city_art.dart';
import 'city_theme.dart';

/// The city's living background: pattern, skyline and ambient effect.
/// The ambience loops unless Reduced Motion is on.
final class CityBackdrop extends StatefulWidget {
  const CityBackdrop({super.key, required this.city, this.parallax = 0});

  final CityId city;
  final double parallax;

  static const Duration loop = Duration(seconds: 8);

  @override
  State<CityBackdrop> createState() => _CityBackdropState();
}

class _CityBackdropState extends State<CityBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: CityBackdrop.loop,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MotionSettings.reducedOf(context)) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.infinite,
      painter: _BackdropPainter(
        CityTheme.of(widget.city),
        _ambient,
        widget.parallax,
      ),
    ),
  );
}

final class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.theme, this.ambient, this.parallax)
    : super(repaint: ambient);

  final CityTheme theme;
  final Animation<double> ambient;
  final double parallax;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.background);
    theme.art.paintPattern(canvas, size, theme);
    CityArtBase.horizonGlow(canvas, size, theme);
    theme.art.paintSkyline(canvas, size, theme, parallax: parallax);
    theme.art.paintAmbient(canvas, size, theme, ambient.value);
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.theme != theme || old.parallax != parallax;
}
