// Builds the native branding images from the logo artwork:
//
//   flutter test tool/render_branding_test.dart
//
// Source: assets/branding/logo_source.png (1254², provided by the project
// owner). Outputs:
//   icon_1024.png  – square crop inside the artwork's own rounded frame, so no
//                    black corners show under the iOS/Android icon mask.
//   logo_512.png / launch_480.png – the whole rounded artwork on transparency.
// Then drop the icon's alpha (App Store rule) with a sips JPEG round-trip and
// resize with `sips -z` into the iOS AppIcon set and Android mipmaps
// (V2-UX plan, Task 1).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

const String _source = 'assets/branding/logo_source.png';

/// The artwork's rounded frame, measured on the 1254² source.
const ui.Rect _frame = ui.Rect.fromLTRB(26, 25, 1212, 1219);
const double _frameRadius = 300;

/// Largest square inside [_frame] whose corners stay clear of its rounding.
const ui.Rect _iconCrop = ui.Rect.fromLTWH(136, 135, 966, 966);

Future<void> _write(
  String path,
  int side,
  void Function(ui.Canvas canvas, double side) paint,
) async {
  final recorder = ui.PictureRecorder();
  paint(ui.Canvas(recorder), side.toDouble());
  final image = await recorder.endRecording().toImage(side, side);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render branding images', () async {
    final codec = await ui.instantiateImageCodec(
      File(_source).readAsBytesSync(),
    );
    final logo = (await codec.getNextFrame()).image;
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;

    await _write('assets/branding/icon_1024.png', 1024, (canvas, side) {
      canvas.drawImageRect(
        logo,
        _iconCrop,
        ui.Offset.zero & ui.Size.square(side),
        paint,
      );
    });

    void rounded(ui.Canvas canvas, double side) {
      final dest = ui.Offset.zero & ui.Size.square(side);
      final scale = side / _frame.width;
      canvas.clipRRect(
        ui.RRect.fromRectAndRadius(
          dest,
          ui.Radius.circular(_frameRadius * scale),
        ),
      );
      canvas.drawImageRect(logo, _frame, dest, paint);
    }

    await _write('assets/branding/logo_512.png', 512, rounded);
    await _write('assets/branding/launch_480.png', 480, rounded);
  });
}
