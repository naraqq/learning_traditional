// Converts an SVG trace of a letterform into a ready-to-paste
// CharacterDefinition for lib/src/data/mongolian_letters.dart.
//
// Usage:
//   dart run tool/svg_letter_import.dart --svg path/to/letter.svg \
//     --id n_initial --cyrillic Н --translit N --form initial [--points 8]
//
// SVG requirements:
//   - One <path> element per stroke, in drawing order (document order = stroke order).
//   - Each path is a single OPEN centerline trace — the line a pen travels,
//     not the filled outline of the letter's ink. First point = pen-down,
//     last point = pen-up.
//   - Supported path commands: M/m L/l H/h V/v C/c S/s Q/q T/t Z/z.
//     Arcs (A/a) are not supported — convert them to curves in your vector
//     tool first (most editors have a "flatten"/"convert to path" option).
//   - The SVG needs a viewBox (or width+height) so points can be normalized.
//
// This is a dev-time tool only — it has no effect on the shipped app and
// adds no new package dependency.

import 'dart:io';
import 'dart:math' as math;

void main(List<String> arguments) {
  final args = _parseArgs(arguments);
  final svgPath = args['svg'];
  final id = args['id'];
  final cyrillic = args['cyrillic'];
  final translit = args['translit'];
  final form = args['form'];
  final pointsPerStroke = int.tryParse(args['points'] ?? '8') ?? 8;

  if (svgPath == null || id == null || cyrillic == null || translit == null || form == null) {
    stderr.writeln(
      'Usage: dart run tool/svg_letter_import.dart --svg <file.svg> --id <id> '
      '--cyrillic <Х> --translit <X> --form <isolated|initial|medial|final> [--points 8]',
    );
    exit(64);
  }
  if (!{'isolated', 'initial', 'medial', 'final'}.contains(form)) {
    stderr.writeln('--form must be one of: isolated, initial, medial, final');
    exit(64);
  }

  final svg = File(svgPath).readAsStringSync();
  final viewBox = _extractViewBox(svg);
  final pathDs = _extractPathData(svg);

  if (pathDs.isEmpty) {
    stderr.writeln('No <path> elements found in $svgPath.');
    exit(1);
  }

  final strokes = <List<_Pt>>[];
  for (final d in pathDs) {
    final dense = _flattenPath(d);
    if (dense.length < 2) {
      stderr.writeln('Warning: a path produced fewer than 2 points and was skipped.');
      continue;
    }
    strokes.add(_resample(dense, pointsPerStroke));
  }

  final dart = _emitDart(
    id: id,
    displayName: '$translit — ${_formLabel(form)}',
    cyrillic: cyrillic,
    translit: translit,
    form: form,
    strokes: strokes,
    viewBox: viewBox,
  );

  stdout.writeln(dart);
}

// --- CLI args -------------------------------------------------------------

Map<String, String> _parseArgs(List<String> arguments) {
  final result = <String, String>{};
  for (var i = 0; i < arguments.length - 1; i++) {
    final arg = arguments[i];
    if (arg.startsWith('--')) {
      result[arg.substring(2)] = arguments[i + 1];
    }
  }
  return result;
}

String _formLabel(String form) => switch (form) {
  'isolated' => 'Isolated form',
  'initial' => 'Initial form',
  'medial' => 'Medial form',
  _ => 'Final form',
};

// --- SVG parsing ------------------------------------------------------------

class _ViewBox {
  const _ViewBox(this.minX, this.minY, this.width, this.height);
  final double minX;
  final double minY;
  final double width;
  final double height;
}

_ViewBox _extractViewBox(String svg) {
  final viewBoxMatch = RegExp(r'viewBox="([-\d.\s]+)"').firstMatch(svg);
  if (viewBoxMatch != null) {
    final parts = viewBoxMatch.group(1)!.trim().split(RegExp(r'[\s,]+')).map(double.parse).toList();
    return _ViewBox(parts[0], parts[1], parts[2], parts[3]);
  }
  final width = double.tryParse(RegExp(r'width="([\d.]+)').firstMatch(svg)?.group(1) ?? '');
  final height = double.tryParse(RegExp(r'height="([\d.]+)').firstMatch(svg)?.group(1) ?? '');
  if (width != null && height != null) {
    return _ViewBox(0, 0, width, height);
  }
  stderr.writeln('No viewBox or width/height found in the SVG — cannot normalize points.');
  exit(1);
}

List<String> _extractPathData(String svg) {
  return RegExp(
    r'<path[^>]*\sd="([^"]+)"',
  ).allMatches(svg).map((m) => m.group(1)!).toList();
}

// --- Path data ("d" attribute) parsing -------------------------------------

class _Pt {
  const _Pt(this.x, this.y);
  final double x;
  final double y;
}

/// Flattens one SVG path `d` string into a dense polyline. Only the first
/// subpath (up to a second M/m or a Z/z) is used — a stroke should be one
/// continuous open trace; split disjoint strokes into separate <path>
/// elements instead.
List<_Pt> _flattenPath(String d) {
  double curX = 0, curY = 0;
  double startX = 0, startY = 0;
  double? prevCtrlX, prevCtrlY; // for S/T reflection
  String? prevCommand;
  final points = <_Pt>[];
  var seenMove = false;

  for (final seg in _splitCommands(d)) {
    final cmd = seg.command;
    final relative = cmd.toLowerCase() == cmd && cmd != 'Z' && cmd != 'z';
    final upper = cmd.toUpperCase();
    final nums = seg.args;
    var argIndex = 0;

    switch (upper) {
      case 'M':
        while (argIndex + 1 < nums.length + 1 && argIndex < nums.length) {
          final x = nums[argIndex] + (relative && argIndex > 0 ? curX : 0);
          final y = nums[argIndex + 1] + (relative && argIndex > 0 ? curY : 0);
          final absX = relative ? curX + nums[argIndex] : nums[argIndex];
          final absY = relative ? curY + nums[argIndex + 1] : nums[argIndex + 1];
          if (!seenMove) {
            curX = absX;
            curY = absY;
            startX = curX;
            startY = curY;
            points.add(_Pt(curX, curY));
            seenMove = true;
          } else {
            // A second moveto starts a new subpath — stop here; strokes
            // should be single continuous traces.
            return points;
          }
          argIndex += 2;
          // ignore unused x,y locals from the loop header calc above
          assert(x == x && y == y);
        }
      case 'L':
        for (var k = 0; k + 1 < nums.length; k += 2) {
          curX = relative ? curX + nums[k] : nums[k];
          curY = relative ? curY + nums[k + 1] : nums[k + 1];
          points.add(_Pt(curX, curY));
        }
      case 'H':
        for (final v in nums) {
          curX = relative ? curX + v : v;
          points.add(_Pt(curX, curY));
        }
      case 'V':
        for (final v in nums) {
          curY = relative ? curY + v : v;
          points.add(_Pt(curX, curY));
        }
      case 'C':
        for (var k = 0; k + 5 < nums.length; k += 6) {
          final x1 = relative ? curX + nums[k] : nums[k];
          final y1 = relative ? curY + nums[k + 1] : nums[k + 1];
          final x2 = relative ? curX + nums[k + 2] : nums[k + 2];
          final y2 = relative ? curY + nums[k + 3] : nums[k + 3];
          final x = relative ? curX + nums[k + 4] : nums[k + 4];
          final y = relative ? curY + nums[k + 5] : nums[k + 5];
          points.addAll(_cubicBezier(curX, curY, x1, y1, x2, y2, x, y));
          prevCtrlX = x2;
          prevCtrlY = y2;
          curX = x;
          curY = y;
        }
      case 'S':
        for (var k = 0; k + 3 < nums.length; k += 4) {
          final x2 = relative ? curX + nums[k] : nums[k];
          final y2 = relative ? curY + nums[k + 1] : nums[k + 1];
          final x = relative ? curX + nums[k + 2] : nums[k + 2];
          final y = relative ? curY + nums[k + 3] : nums[k + 3];
          final reflectedX = prevCommand != null && 'CS'.contains(prevCommand!.toUpperCase())
              ? 2 * curX - (prevCtrlX ?? curX)
              : curX;
          final reflectedY = prevCommand != null && 'CS'.contains(prevCommand!.toUpperCase())
              ? 2 * curY - (prevCtrlY ?? curY)
              : curY;
          points.addAll(_cubicBezier(curX, curY, reflectedX, reflectedY, x2, y2, x, y));
          prevCtrlX = x2;
          prevCtrlY = y2;
          curX = x;
          curY = y;
        }
      case 'Q':
        for (var k = 0; k + 3 < nums.length; k += 4) {
          final x1 = relative ? curX + nums[k] : nums[k];
          final y1 = relative ? curY + nums[k + 1] : nums[k + 1];
          final x = relative ? curX + nums[k + 2] : nums[k + 2];
          final y = relative ? curY + nums[k + 3] : nums[k + 3];
          points.addAll(_quadraticBezier(curX, curY, x1, y1, x, y));
          prevCtrlX = x1;
          prevCtrlY = y1;
          curX = x;
          curY = y;
        }
      case 'T':
        for (var k = 0; k + 1 < nums.length; k += 2) {
          final x = relative ? curX + nums[k] : nums[k];
          final y = relative ? curY + nums[k + 1] : nums[k + 1];
          final reflectedX = prevCommand != null && 'QT'.contains(prevCommand!.toUpperCase())
              ? 2 * curX - (prevCtrlX ?? curX)
              : curX;
          final reflectedY = prevCommand != null && 'QT'.contains(prevCommand!.toUpperCase())
              ? 2 * curY - (prevCtrlY ?? curY)
              : curY;
          points.addAll(_quadraticBezier(curX, curY, reflectedX, reflectedY, x, y));
          prevCtrlX = reflectedX;
          prevCtrlY = reflectedY;
          curX = x;
          curY = y;
        }
      case 'Z':
        points.add(_Pt(startX, startY));
        return points;
      default:
        stderr.writeln(
          'Unsupported path command "$cmd" — arcs and unusual commands '
          'aren\'t supported. Convert curves/arcs to cubic beziers in your '
          'vector tool ("flatten"/"convert to path") and try again.',
        );
        exit(1);
    }
    prevCommand = cmd;
  }
  return points;
}

class _PathSegment {
  const _PathSegment(this.command, this.args);
  final String command;
  final List<double> args;
}

List<_PathSegment> _splitCommands(String d) {
  final segments = <_PathSegment>[];
  final commandPattern = RegExp('[MmLlHhVvCcSsQqTtAaZz]');
  final matches = commandPattern.allMatches(d).toList();
  for (var i = 0; i < matches.length; i++) {
    final start = matches[i].start;
    final end = i + 1 < matches.length ? matches[i + 1].start : d.length;
    final command = d[start];
    final argsStr = d.substring(start + 1, end);
    final args = RegExp(r'-?\d*\.?\d+(?:e-?\d+)?').allMatches(argsStr).map((m) => double.parse(m.group(0)!)).toList();
    segments.add(_PathSegment(command, args));
  }
  return segments;
}

List<double> _tokenizePath(String d) => const []; // unused placeholder

List<_Pt> _cubicBezier(double x0, double y0, double x1, double y1, double x2, double y2, double x3, double y3) {
  const steps = 16;
  return [
    for (var s = 1; s <= steps; s++)
      () {
        final t = s / steps;
        final mt = 1 - t;
        final x = mt * mt * mt * x0 + 3 * mt * mt * t * x1 + 3 * mt * t * t * x2 + t * t * t * x3;
        final y = mt * mt * mt * y0 + 3 * mt * mt * t * y1 + 3 * mt * t * t * y2 + t * t * t * y3;
        return _Pt(x, y);
      }(),
  ];
}

List<_Pt> _quadraticBezier(double x0, double y0, double x1, double y1, double x2, double y2) {
  const steps = 12;
  return [
    for (var s = 1; s <= steps; s++)
      () {
        final t = s / steps;
        final mt = 1 - t;
        final x = mt * mt * x0 + 2 * mt * t * x1 + t * t * x2;
        final y = mt * mt * y0 + 2 * mt * t * y1 + t * t * y2;
        return _Pt(x, y);
      }(),
  ];
}

// --- Resampling (arc-length even spacing, same idea as the app's own
// GeometryUtils.resample) --------------------------------------------------

double _dist(_Pt a, _Pt b) => math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));

List<_Pt> _resample(List<_Pt> points, int count) {
  if (points.length < 2 || count < 2) return points;
  final total = () {
    var t = 0.0;
    for (var i = 1; i < points.length; i++) {
      t += _dist(points[i - 1], points[i]);
    }
    return t;
  }();
  if (total <= 0) return List.filled(count, points.first);

  final step = total / (count - 1);
  final result = <_Pt>[points.first];
  var segmentIndex = 0;
  var accumulated = 0.0;
  for (var i = 1; i < count - 1; i++) {
    final targetDist = step * i;
    while (segmentIndex < points.length - 2 &&
        accumulated + _dist(points[segmentIndex], points[segmentIndex + 1]) < targetDist) {
      accumulated += _dist(points[segmentIndex], points[segmentIndex + 1]);
      segmentIndex++;
    }
    final segStart = points[segmentIndex];
    final segEnd = points[segmentIndex + 1];
    final segLen = _dist(segStart, segEnd);
    final t = segLen == 0 ? 0.0 : ((targetDist - accumulated) / segLen).clamp(0.0, 1.0);
    result.add(_Pt(segStart.x + (segEnd.x - segStart.x) * t, segStart.y + (segEnd.y - segStart.y) * t));
  }
  result.add(points.last);
  return result;
}

// --- Dart code generation ---------------------------------------------------

String _emitDart({
  required String id,
  required String displayName,
  required String cyrillic,
  required String translit,
  required String form,
  required List<List<_Pt>> strokes,
  required _ViewBox viewBox,
}) {
  final buffer = StringBuffer();
  final dartForm = form == 'final' ? 'final_' : form;
  buffer.writeln('final CharacterDefinition letter${_pascalCase(id)} = _letter(');
  buffer.writeln("  id: '$id',");
  buffer.writeln("  displayName: '$displayName',");
  buffer.writeln("  cyrillic: '$cyrillic',");
  buffer.writeln("  transliteration: '$translit',");
  buffer.writeln('  form: CharacterForm.$dartForm,');
  buffer.writeln('  strokes: [');
  for (var s = 0; s < strokes.length; s++) {
    buffer.writeln('    ReferenceStroke(');
    buffer.writeln('      order: ${s + 1},');
    buffer.writeln('      points: const [');
    for (final p in strokes[s]) {
      final nx = ((p.x - viewBox.minX) / viewBox.width).clamp(0.0, 1.0);
      final ny = ((p.y - viewBox.minY) / viewBox.height).clamp(0.0, 1.0);
      buffer.writeln('        Offset(${nx.toStringAsFixed(3)}, ${ny.toStringAsFixed(3)}),');
    }
    buffer.writeln('      ],');
    buffer.writeln('    ),');
  }
  buffer.writeln('  ],');
  buffer.writeln(');');
  return buffer.toString();
}

String _pascalCase(String id) => id.split('_').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join();
