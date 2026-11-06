import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/presentation/board/forecast_painter.dart';
import 'package:swipeout_last_train/game/presentation/board/network_painter.dart';
import 'package:swipeout_last_train/game/presentation/city/city_backdrop.dart';
import 'package:swipeout_last_train/game/presentation/kit/contrast_settings.dart';
import 'package:swipeout_last_train/game/presentation/kit/game_scaffold.dart';
import 'package:swipeout_last_train/game/presentation/kit/motion_settings.dart';
import 'package:swipeout_last_train/game/presentation/theme/app_colors.dart';

void main() {
  testWidgets('the phone setting turns high contrast on by default', (
    tester,
  ) async {
    late bool high;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(highContrast: true),
        child: Builder(
          builder: (context) {
            high = ContrastSettings.highOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(high, isTrue);
  });

  test('open rails turn white and thicker; closed arms stay visible', () {
    final (openColor, openWidth) = NetworkPainter.railStyle(
      open: true,
      high: true,
    );
    final (closedColor, _) = NetworkPainter.railStyle(open: false, high: true);
    expect(openColor, AppColors.textPrimary);
    expect(
      openWidth,
      greaterThan(NetworkPainter.railStyle(open: true, high: false).$2),
    );
    expect(closedColor, isNot(AppColors.trackInactive));
  });

  test('forecast arrows get thicker with high contrast', () {
    expect(
      ForecastPainter.shaftWidth(high: true),
      greaterThan(ForecastPainter.shaftWidth(high: false)),
    );
  });

  testWidgets('the city artwork steps back behind the board', (tester) async {
    Future<double> opacity({required bool high}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MotionSettings(
            reduced: true,
            child: ContrastSettings(
              high: high,
              child: const GameScaffold(
                city: CityId.ankara,
                backdropOpacity: 0.5,
                body: SizedBox(),
              ),
            ),
          ),
        ),
      );
      return tester
          .widget<Opacity>(
            find.ancestor(
              of: find.byType(CityBackdrop),
              matching: find.byType(Opacity),
            ),
          )
          .opacity;
    }

    expect(await opacity(high: false), 0.5);
    expect(await opacity(high: true), lessThan(0.5));
  });
}
