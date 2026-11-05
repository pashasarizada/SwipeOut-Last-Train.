part of '../city_map_screen.dart';

final class _Preview extends StatelessWidget {
  const _Preview({required this.level, required this.store});

  final LevelDefinition level;
  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final record = store.progress.records[level.id];
    return Container(
      key: ValueKey(level.id),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEE07090F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${l.levelCode(level)} · ${level.title.of(language)}',
            style: const TextStyle(
              fontFamily: GameFonts.display,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            [
              l.parLabel(level.parPulses),
              if (record != null) l.bestLabel(record.bestPulses),
            ].join(' · '),
            style: const TextStyle(
              fontFamily: GameFonts.board,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          GameButton(
            label: l.board,
            onPressed: () => openLevel(context, level),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2);
  }
}

final class _LinePainter extends CustomPainter {
  const _LinePainter({
    required this.points,
    required this.lit,
    required this.theme,
  });

  final List<Offset> points;
  final List<bool> lit;
  final CityTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i + 1 < points.length; i++) {
      final on = lit[i];
      final paint = Paint()
        ..color = on ? theme.accent : AppColors.trackInactive
        ..strokeWidth = on ? 8 : 6
        ..strokeCap = StrokeCap.round;
      if (on) {
        canvas.drawLine(
          points[i],
          points[i + 1],
          Paint()
            ..color = theme.accent.withValues(alpha: 0.35)
            ..strokeWidth = 18
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}
