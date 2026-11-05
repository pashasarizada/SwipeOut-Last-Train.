part of '../city_map_screen.dart';

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
                  : const GameIcon(
                      GameIconKind.lock,
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
