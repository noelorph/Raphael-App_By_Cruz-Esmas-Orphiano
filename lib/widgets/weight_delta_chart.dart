import 'package:flutter/material.dart';

import '../models/weight_entry_model.dart';

class WeightDeltaChart extends StatelessWidget {
  const WeightDeltaChart({
    super.key,
    required this.entries,
    required this.lineColor,
    required this.fillColor,
    required this.labelColor,
    required this.startLabel,
    required this.endLabel,
  });

  final List<WeightEntryModel> entries;
  final Color lineColor;
  final Color fillColor;
  final Color labelColor;
  final String startLabel;
  final String endLabel;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeightDeltaChartPainter(
        entries: entries,
        lineColor: lineColor,
        fillColor: fillColor,
        labelColor: labelColor,
        startLabel: startLabel,
        endLabel: endLabel,
      ),
    );
  }
}

class _WeightDeltaChartPainter extends CustomPainter {
  const _WeightDeltaChartPainter({
    required this.entries,
    required this.lineColor,
    required this.fillColor,
    required this.labelColor,
    required this.startLabel,
    required this.endLabel,
  });

  final List<WeightEntryModel> entries;
  final Color lineColor;
  final Color fillColor;
  final Color labelColor;
  final String startLabel;
  final String endLabel;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    const labelHeight = 10.0;
    final chartHeight = size.height - labelHeight;
    final weights = entries.map((entry) => entry.weight);
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight == minWeight ? 1.0 : maxWeight - minWeight;
    final startTime = entries.first.date.millisecondsSinceEpoch;
    final endTime = entries.last.date.millisecondsSinceEpoch;
    final duration = endTime - startTime;

    double yFor(double weight) {
      final normalized = (weight - minWeight) / range;
      return chartHeight - (normalized * (chartHeight - 4)) - 2;
    }

    double xFor(int index, WeightEntryModel entry) {
      if (entries.length == 1) return size.width;
      if (duration <= 0) return size.width * (index / (entries.length - 1));

      final elapsed = entry.date.millisecondsSinceEpoch - startTime;
      return size.width * (elapsed / duration);
    }

    final points = [
      for (var index = 0; index < entries.length; index++)
        Offset(xFor(index, entries[index]), yFor(entries[index].weight)),
    ];

    final fillPath = Path()
      ..moveTo(points.first.dx, chartHeight)
      ..lineTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, chartHeight)
      ..close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(linePath, linePaint);

    _paintLabel(canvas, startLabel, Offset(0, chartHeight), TextAlign.left);
    _paintLabel(
      canvas,
      endLabel,
      Offset(size.width, chartHeight),
      TextAlign.right,
    );
  }

  void _paintLabel(
    Canvas canvas,
    String label,
    Offset offset,
    TextAlign align,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = align == TextAlign.right ? offset.dx - painter.width : offset.dx;
    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _WeightDeltaChartPainter oldDelegate) {
    return entries != oldDelegate.entries ||
        lineColor != oldDelegate.lineColor ||
        fillColor != oldDelegate.fillColor ||
        labelColor != oldDelegate.labelColor ||
        startLabel != oldDelegate.startLabel ||
        endLabel != oldDelegate.endLabel;
  }
}
