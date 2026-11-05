import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/presentation/city/city_backdrop.dart';
import 'package:swipeout_last_train/game/presentation/city/city_theme.dart';
import 'package:swipeout_last_train/game/presentation/kit/motion_settings.dart';

void _paintAll(CityTheme theme, Size size) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  theme.art.paintPattern(canvas, size, theme);
  theme.art.paintSkyline(canvas, size, theme, parallax: 0.3);
  theme.art.paintAmbient(canvas, size, theme, 0.5);
  theme.art.paintStamp(canvas, size, theme, gold: theme.city == CityId.moscow);
  recorder.endRecording().dispose();
}

void main() {
  test('every city has its own art', () {
    final arts = CityId.values
        .map((c) => CityTheme.of(c).art.runtimeType)
        .toSet();
    expect(arts, hasLength(CityId.values.length));
  });

  test('each city has a distinct ambient effect', () {
    expect(
      CityId.values.map((c) => CityTheme.of(c).art.ambient).toSet(),
      hasLength(5),
    );
  });

  for (final city in CityId.values) {
    test('${city.name} art paints at phone and icon sizes', () {
      for (final size in const [
        Size(320, 568),
        Size(1024, 1024),
        Size(120, 120),
      ]) {
        expect(() => _paintAll(CityTheme.of(city), size), returnsNormally);
      }
    });
  }

  testWidgets('the backdrop animates its ambience, unless motion is reduced', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CityBackdrop(city: CityId.moscow)),
    );
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: MotionSettings(
          reduced: true,
          child: CityBackdrop(city: CityId.moscow),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
