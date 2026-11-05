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
import '../kit/game_icon.dart';
import '../kit/game_scaffold.dart';
import '../kit/signal_back_button.dart';
import '../theme/app_colors.dart';
import '../widgets/game_texts.dart';
import 'level_navigation.dart';

part 'city_map/station_dot.dart';
part 'city_map/line_preview.dart';

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
