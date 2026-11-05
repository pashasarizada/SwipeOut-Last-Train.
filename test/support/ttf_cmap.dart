import 'dart:io';
import 'dart:typed_data';

/// Code points a TrueType font maps to glyphs (cmap formats 4 and 12).
/// Enough to prove glyph coverage without rendering.
Set<int> ttfCodePoints(String path) {
  final data = ByteData.sublistView(File(path).readAsBytesSync());
  final tables = data.getUint16(4);
  int? cmap;
  for (var i = 0; i < tables; i++) {
    final record = 12 + i * 16;
    final tag = String.fromCharCodes([
      for (var j = 0; j < 4; j++) data.getUint8(record + j),
    ]);
    if (tag == 'cmap') cmap = data.getUint32(record + 8);
  }
  if (cmap == null) throw StateError('no cmap in $path');

  final points = <int>{};
  final subtables = data.getUint16(cmap + 2);
  for (var i = 0; i < subtables; i++) {
    final offset = cmap + data.getUint32(cmap + 4 + i * 8 + 4);
    switch (data.getUint16(offset)) {
      case 4:
        final segX2 = data.getUint16(offset + 6);
        final ends = offset + 14;
        final starts = ends + segX2 + 2;
        final deltas = starts + segX2;
        final ranges = deltas + segX2;
        for (var s = 0; s < segX2; s += 2) {
          final end = data.getUint16(ends + s);
          final start = data.getUint16(starts + s);
          final delta = data.getInt16(deltas + s);
          final range = data.getUint16(ranges + s);
          for (var c = start; c <= end && c != 0xFFFF; c++) {
            final glyph = range == 0
                ? (c + delta) & 0xFFFF
                : data.getUint16(ranges + s + range + 2 * (c - start));
            if (glyph != 0) points.add(c);
          }
        }
      case 12:
        final groups = data.getUint32(offset + 12);
        for (var g = 0; g < groups; g++) {
          final group = offset + 16 + g * 12;
          final start = data.getUint32(group);
          final end = data.getUint32(group + 4);
          for (var c = start; c <= end; c++) {
            points.add(c);
          }
        }
    }
  }
  return points;
}
