import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

typedef TrendPoint = ({num x, num value});

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.points,
    required this.label,
    required this.color,
  });

  final List<TrendPoint> points;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: 98,
        child: CustomPaint(
          painter: _TrendPainter(
            points,
            color,
            Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter(this.points, this.color, this.grid);
  final List<TrendPoint> points;
  final Color color;
  final Color grid;

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
    final values = points.map((point) => point.value);
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final span = math.max(high - low, 1);
    final middle = (low + high) / 2;
    final first = points.first.x;
    final timeSpan = points.last.x - first;

    Offset position(TrendPoint point) {
      final x = timeSpan > 0
          ? (point.x - first) / timeSpan * (size.width - 8) + 4
          : size.width / 2;
      final y = (0.5 - ((point.value - middle) / span) * 0.66) * size.height;
      return Offset(x, y);
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
      oldDelegate.grid != grid;
}
