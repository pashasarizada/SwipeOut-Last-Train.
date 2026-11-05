import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/passport.dart';
import '../city/city_theme.dart';
import '../kit/game_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/game_texts.dart';
import 'passport_stamp.dart';

/// A passport page for one city: its pattern, name, welcome and stamp.
final class PassportPage extends StatelessWidget {
  const PassportPage({super.key, required this.stamp, this.highlight = false});

  final CityStamp stamp;
  final bool highlight;

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = CityTheme.of(stamp.city);
    final earnedOn = stamp.earnedOn;
    return _PaperSheet(
      theme: theme,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l.cityName(stamp.city),
            style: TextStyle(
              fontFamily: GameFonts.display,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              color: theme.accentAlt,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.greeting(stamp.city),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 28),
          PassportStamp(
            stamp: stamp,
            animateIn: highlight,
            progressLabel: l.cityProgress(stamp.solved, stamp.total),
          ),
          const SizedBox(height: 24),
          if (stamp.earned) ...[
            if (highlight)
              Text(
                l.stampEarned,
                style: TextStyle(
                  fontFamily: GameFonts.display,
                  fontSize: 18,
                  color: theme.accent,
                ),
              ),
            if (earnedOn != null)
              Text(
                l.stampedOn(_date(earnedOn.toLocal())),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            Text(
              l.cityProgress(stamp.solved, stamp.total),
              style: const TextStyle(
                fontFamily: GameFonts.board,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dark passport paper with the city's faint pattern and a stitched edge.
final class _PaperSheet extends StatelessWidget {
  const _PaperSheet({required this.theme, required this.child});

  final CityTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: CustomPaint(
        painter: _PaperPainter(theme),
        child: Center(child: child),
      ),
    ),
  );
}

final class _PaperPainter extends CustomPainter {
  const _PaperPainter(this.theme);

  final CityTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Color.lerp(theme.background, AppColors.surface, 0.5)!,
    );
    theme.art.paintPattern(canvas, size, theme);
    final stitch = Paint()
      ..color = theme.accentAlt.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    final inset = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    for (var x = inset.left; x < inset.right; x += 10) {
      canvas.drawLine(Offset(x, inset.top), Offset(x + 5, inset.top), stitch);
      canvas.drawLine(
        Offset(x, inset.bottom),
        Offset(x + 5, inset.bottom),
        stitch,
      );
    }
    for (var y = inset.top; y < inset.bottom; y += 10) {
      canvas.drawLine(Offset(inset.left, y), Offset(inset.left, y + 5), stitch);
      canvas.drawLine(
        Offset(inset.right, y),
        Offset(inset.right, y + 5),
        stitch,
      );
    }
  }

  @override
  bool shouldRepaint(_PaperPainter old) => old.theme != theme;
}
