import 'dart:ui';

/// One ordered stroke within a [CharacterDefinition], expressed in
/// normalized 0.0-1.0 canvas coordinates so it scales to any screen size.
class ReferenceStroke {
  const ReferenceStroke({
    required this.order,
    required this.points,
    this.startZoneRadius,
    this.endZoneRadius,
  });

  /// 1-based position of this stroke within the character (stroke order).
  final int order;

  /// Ordered centerline points describing the stroke, normalized to the
  /// unit square (0.0-1.0 on both axes).
  final List<Offset> points;

  /// Overrides the character-level starting zone radius for this stroke.
  /// Normalized units. Null means "use the character default".
  final double? startZoneRadius;

  /// Overrides the character-level ending zone radius for this stroke.
  final double? endZoneRadius;

  Offset get start => points.first;
  Offset get end => points.last;
}
