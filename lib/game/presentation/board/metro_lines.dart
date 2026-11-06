import 'dart:math' as math;

import '../../domain/level_definition.dart';
import '../../domain/switch_def.dart';
import 'board_layout.dart';
import 'rail_geometry.dart';
import 'station_labels.dart';

/// Splits a level's rails into metro lines, the way a map colours them:
/// a line runs on through every two-rail stop, and at a switch the trunk
/// continues into its straightest branch while the other branch starts a
/// line of its own. Lines that meet at a node get different colours.
final class MetroLines {
  MetroLines(this.level, RailGeometry geometry) {
    final parent = {for (final id in level.edges.keys) id: id};
    String find(String id) {
      while (parent[id] != id) {
        id = parent[id] = parent[parent[id]!]!;
      }
      return id;
    }

    void join(String a, String b) => parent[find(a)] = find(b);

    for (final node in level.nodes.keys) {
      final edges = level.edgesOf(node);
      if (level.switches[node] case final sw?) {
        join(sw.trunkEdge, _straightest(sw, geometry));
      } else if (edges.length == 2) {
        join(edges[0].id, edges[1].id);
      }
    }

    final index = <String, int>{};
    for (final id in level.edges.keys) {
      _line[id] = index.putIfAbsent(find(id), () => index.length);
    }
    lineCount = index.length;
    _colourLines();
  }

  final LevelDefinition level;
  final Map<String, int> _line = {};
  final Map<int, int> _colour = {};

  late final int lineCount;

  /// Colours the greedy pass needed; the palettes hold three.
  int colorsNeeded = 0;

  int lineOf(String edgeId) => _line[edgeId]!;

  /// Index into the city's line palette.
  int colorOf(String edgeId) => _colour[lineOf(edgeId)]! % 3;

  /// The branch that bends least on from the trunk.
  static String _straightest(SwitchDef sw, RailGeometry g) {
    final inbound = g.from(sw.nodeId, sw.trunkEdge).headingAt(0);
    double turn(String branch) {
      final out = g.from(sw.nodeId, branch).headingAt(0);
      var d = (inbound - out).abs() % (2 * math.pi);
      d = math.min(d, 2 * math.pi - d);
      return math.pi - d;
    }

    return turn(sw.branchAEdge) <= turn(sw.branchBEdge)
        ? sw.branchAEdge
        : sw.branchBEdge;
  }

  /// Greedy colouring: each line takes the first colour no line it meets
  /// at a node already has.
  void _colourLines() {
    final meets = {for (var i = 0; i < lineCount; i++) i: <int>{}};
    for (final node in level.nodes.keys) {
      final here = {for (final e in level.edgesOf(node)) lineOf(e.id)};
      for (final a in here) {
        meets[a]!.addAll(here.where((b) => b != a));
      }
    }
    for (var line = 0; line < lineCount; line++) {
      final taken = {for (final other in meets[line]!) _colour[other]};
      var c = 0;
      while (taken.contains(c)) {
        c++;
      }
      _colour[line] = c;
      colorsNeeded = math.max(colorsNeeded, c + 1);
    }
    assert(
      colorsNeeded <= 3,
      '${level.id} needs $colorsNeeded line colours; palettes hold three',
    );
  }
}

/// A level's metro map on one board layout: paths and lines, built once
/// per layout and shared by every painter and the trains.
final class MetroMap {
  MetroMap(LevelDefinition level, BoardLayout layout)
    : geometry = RailGeometry(level, layout) {
    lines = MetroLines(level, geometry);
  }

  final RailGeometry geometry;
  late final MetroLines lines;

  /// Where the goals' station names go.
  late final StationLabels labels = StationLabels(geometry.level, geometry);

  void dispose() => labels.dispose();

  /// Reuses [previous] while the level and layout are unchanged; a
  /// replaced map is disposed.
  static MetroMap reuse(
    MetroMap? previous,
    LevelDefinition level,
    BoardLayout layout,
  ) {
    if (previous != null &&
        identical(previous.geometry.level, level) &&
        previous.geometry.layout == layout) {
      return previous;
    }
    previous?.dispose();
    return MetroMap(level, layout);
  }
}
