part of 'network_painter.dart';

/// Rails drawn as metro lines: a dark casing, then the line colour along
/// the shared metro path; closed switch arms faint and cut short.
extension RailMarks on NetworkPainter {
  /// Colour of [edgeId]'s rail: its line colour, or white in High Contrast.
  Color railColor(String edgeId) {
    final open = isOpen(edgeId);
    if (highContrast) {
      return NetworkPainter.railStyle(open: open, high: true).$1;
    }
    final line = theme.lines[map.lines.colorOf(edgeId)];
    return open ? line : line.withValues(alpha: 0.35);
  }

  /// The drawn part of [edgeId]'s path, as distances from `edge.a`: all of
  /// it, or a closed arm stopped [NetworkPainter.closedGap] short of its
  /// switch, measured along the path.
  (double, double) visibleSpan(String edgeId) {
    final length = map.geometry.pathOf(edgeId).length;
    if (isOpen(edgeId)) return (0, length);
    final edge = level.edges[edgeId]!;
    final gap = NetworkPainter.closedGap.clamp(0, length * 0.45).toDouble();
    return (
      level.switches.containsKey(edge.a) ? gap : 0,
      level.switches.containsKey(edge.b) ? length - gap : length,
    );
  }

  void _paintRails(Canvas canvas) {
    final preview = switch (pending) {
      ToggleSwitch(:final nodeId) => level.switches[nodeId]!.edgeFor(
        state.switches[nodeId]!.toggled,
      ),
      _ => null,
    };
    final geometry = map.geometry;
    // All casings first, so where lines cross the later line sits on top
    // of a clean dark gap, as on a printed metro map.
    for (final edge in level.edges.values) {
      final (from, to) = visibleSpan(edge.id);
      final width = _width(edge.id);
      canvas.drawPath(
        geometry.pathOf(edge.id).segment(from, to),
        NetworkPainter._stroke(theme.background, width + 4),
      );
    }
    for (final edge in level.edges.values) {
      final path = geometry.pathOf(edge.id);
      if (edge.id == preview) {
        canvas.drawPath(
          path.path,
          NetworkPainter._stroke(
            AppColors.accentTurquoise.withValues(alpha: 0.45),
            14,
          ),
        );
      }
      final (from, to) = visibleSpan(edge.id);
      final colour = isOpen(edge.id)
          ? Color.lerp(railColor(edge.id), AppColors.textPrimary, wave * 0.6)!
          : railColor(edge.id);
      canvas.drawPath(
        path.segment(from, to),
        NetworkPainter._stroke(colour, _width(edge.id)),
      );
    }
  }

  double _width(String edgeId) =>
      NetworkPainter.railStyle(open: isOpen(edgeId), high: highContrast).$2;
}
