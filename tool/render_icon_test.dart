// Renders the emblem to PNG files used by the native shell:
//
//   flutter test tool/render_icon_test.dart
//
// The App Store icon must have no alpha channel: round-trip it through JPEG
// (`sips -s format jpeg` then `-s format png`) before resizing with `sips -z`
// into the iOS AppIcon set and Android mipmaps (V2-UX plan, Task 1).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/presentation/kit/emblem_painter.dart';

Future<void> _render(
  WidgetTester tester,
  EmblemPainter painter,
  double side,
  String path,
) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        key: key,
        child: SizedBox.square(
          dimension: side,
          child: CustomPaint(painter: painter),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render emblem PNGs', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _render(
      tester,
      const EmblemPainter(),
      1024,
      'assets/branding/icon_1024.png',
    );
    await _render(
      tester,
      const EmblemPainter(withBackground: false),
      480,
      'assets/branding/launch_480.png',
    );
  });
}
