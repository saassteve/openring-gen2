import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

typedef TrendPoint = ({num x, num value});

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.points,
    required this.label,
    required this.color,
    this.threshold,
    this.thresholdColor,
    this.minValue,
    this.maxValue,
  });

  final List<TrendPoint> points;
  final String label;
  final Color color;
  final double? threshold;
  final Color? thresholdColor;
  final double? minValue;
  final double? maxValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: 98,
        child: CustomPaint(
          painter: _TrendPainter(
            points,
            color,
            scheme.outlineVariant,
            threshold: threshold,
            thresholdColor: thresholdColor ?? scheme.tertiary,
            minValue: minValue,
            maxValue: maxValue,
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter(
    this.points,
    this.color,
    this.grid, {
    this.threshold,
    required this.thresholdColor,
    this.minValue,
    this.maxValue,
  });

  final List<TrendPoint> points;
  final Color color;
  final Color grid;
  final double? threshold;
  final Color thresholdColor;
  final double? minValue;
  final double? maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    for (final fraction in [0.16, 0.5, 0.84]) {
      final y = size.height * fraction;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()..color = grid,
      );
    }
    if (points.isEmpty) return;
    final values = points.map((point) => point.value.toDouble());
    final dataLow = values.reduce(math.min);
    final dataHigh = values.reduce(math.max);
    final low = minValue != null ? math.min(minValue!, dataLow) : dataLow;
    var high = maxValue != null ? math.max(maxValue!, dataHigh) : dataHigh;
    if (threshold != null) high = math.max(high, threshold! * 1.15);
    final span = math.max(high - low, minValue != null ? 0.5 : 1.0);
    final middle = (low + high) / 2;
    final first = points.first.x;
    final timeSpan = points.last.x - first;

    double yFor(num value) =>
        (0.5 - ((value - middle) / span) * 0.66) * size.height;

    Offset position(TrendPoint point) {
      final x = timeSpan > 0
          ? (point.x - first) / timeSpan * (size.width - 8) + 4
          : size.width / 2;
      return Offset(x, yFor(point.value));
    }

    if (threshold case final t?) {
      final ty = yFor(t);
      final dashPaint = Paint()
        ..color = thresholdColor.withValues(alpha: 0.75)
        ..strokeWidth = 1.25;
      for (double x = 0; x < size.width; x += 10) {
        canvas.drawLine(
          Offset(x, ty),
          Offset(math.min(x + 5, size.width), ty),
          dashPaint,
        );
      }
    }

    final start = position(points.first);
    final line = Path()..moveTo(start.dx, start.dy);
    for (final point in points.skip(1)) {
      final next = position(point);
      line.lineTo(next.dx, next.dy);
    }
    final end = position(points.last);
    if (points.length > 1) {
      final fill = Path.from(line)
        ..lineTo(end.dx, size.height)
        ..lineTo(start.dx, size.height)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.drawCircle(end, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.grid != grid ||
      oldDelegate.threshold != threshold ||
      oldDelegate.thresholdColor != thresholdColor ||
      oldDelegate.minValue != minValue ||
      oldDelegate.maxValue != maxValue;
}
