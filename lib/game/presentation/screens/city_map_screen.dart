import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../domain/city.dart';
import '../../domain/level_definition.dart';
import '../../domain/passport.dart';
import '../city/city_theme.dart';
import '../game/game_scope.dart';
import '../game/progress_store.dart';
import '../kit/departure_board.dart';
import '../kit/game_button.dart';
import '../kit/game_fonts.dart';
import '../kit/game_scaffold.dart';
import '../kit/signal_back_button.dart';
import '../theme/app_colors.dart';
import '../widgets/game_texts.dart';
import 'level_navigation.dart';

/// The city's line: six stations, solved stretches lit. Tap a station to
/// preview it, then board.
final class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key, required this.city});

  final CityId city;

  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen> {
  LevelDefinition? _selected;

  /// Station positions on a gentle S-curve, top to bottom (0–1 space).
  static Offset _station(int i) =>
      Offset(0.5 + 0.28 * math.sin(i * 1.1), 0.08 + i * 0.165);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = GameScope.of(context);
    final theme = CityTheme.of(widget.city);
    final levels = store.levelsOf(widget.city);
    final selected = _selected;
    return GameScaffold(
      city: widget.city,
      backdropOpacity: 0.55,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
        child: Row(
          children: [
            const SignalBackButton(),
            const SizedBox(width: 4),
            Expanded(
              child: DepartureBoard(
                color: theme.accentAlt,
                lines: [l.cityName(widget.city), l.greeting(widget.city)],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                Offset at(int i) => Offset(
                  _station(i).dx * box.maxWidth,
                  _station(i).dy * box.maxHeight,
                );
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LinePainter(
                          points: [
                            for (var i = 0; i < kLevelsPerCity; i++) at(i),
                          ],
                          lit: [
                            for (var i = 0; i < kLevelsPerCity; i++)
                              i < levels.length &&
                                  store.progress.isSolved(levels[i].id),
                          ],
                          theme: theme,
                        ),
                      ),
                    ),
                    for (var i = 0; i < kLevelsPerCity; i++)
                      _StationDot(
                        center: at(i),
                        number: i + 1,
                        level: i < levels.length ? levels[i] : null,
                        store: store,
                        theme: theme,
                        selected:
                            selected != null &&
                            i < levels.length &&
                            levels[i].id == selected.id,
                        onTap: (level) => setState(() => _selected = level),
                      ),
                  ],
                );
              },
            ),
          ),
          if (selected != null) _Preview(level: selected, store: store),
        ],
      ),
    );
  }
}

final class _StationDot extends StatelessWidget {
  const _StationDot({
    required this.center,
    required this.number,
    required this.level,
    required this.store,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  static const double size = 52;

  final Offset center;
  final int number;
  final LevelDefinition? level;
  final ProgressStore store;
  final CityTheme theme;
  final bool selected;
  final ValueChanged<LevelDefinition> onTap;

  @override
  Widget build(BuildContext context) {
    final level = this.level;
    final open = level != null && store.isUnlocked(level);
    final solved = level != null && store.progress.isSolved(level.id);
    final color = solved
        ? theme.accent
        : (open ? theme.accentAlt : AppColors.trackInactive);
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: GestureDetector(
        key: ValueKey('station-${level?.id ?? '${theme.city.name}-$number'}'),
        behavior: HitTestBehavior.opaque,
        onTap: open ? () => onTap(level) : null,
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: Container(
              width: selected ? 46 : 38,
              height: selected ? 46 : 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: solved ? color : AppColors.background,
                border: Border.all(color: color, width: 3),
                boxShadow: open
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: selected ? 18 : 10,
                        ),
                      ]
                    : null,
              ),
              child: open
                  ? Text(
                      '$number',
                      style: TextStyle(
                        fontFamily: GameFonts.board,
                        fontWeight: FontWeight.w600,
                        color: solved
                            ? AppColors.background
                            : AppColors.textPrimary,
                      ),
                    )
                  : const Icon(
                      Icons.lock,
                      size: 16,
                      color: AppColors.trackInactive,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

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
