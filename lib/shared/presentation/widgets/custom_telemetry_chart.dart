import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Lightweight, pure-Flutter chart widget rendering deterministic telemetry history
/// without requiring any external dependencies.
class CustomTelemetryChart extends StatelessWidget {
  final List<double> series1;
  final List<double> series2;
  final String label1;
  final String label2;
  final double height;
  final double? minY;
  final double? maxY;

  const CustomTelemetryChart({
    super.key,
    required this.series1,
    required this.series2,
    this.label1 = 'D1',
    this.label2 = 'D2',
    this.height = 120,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildLegendItem(AppColors.gold, label1),
            const SizedBox(width: 14),
            _buildLegendItem(AppColors.secondaryText, label2),
          ],
        ),
        const SizedBox(height: 8),
        // Chart Canvas
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.raisedSurface, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: CustomPaint(
            painter: _ChartPainter(
              series1: series1,
              series2: series2,
              minY: minY,
              maxY: maxY,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> series1;
  final List<double> series2;
  final double? minY;
  final double? maxY;

  _ChartPainter({
    required this.series1,
    required this.series2,
    this.minY,
    this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.raisedSurface
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    const horizontalDivisions = 3;
    for (int i = 0; i <= horizontalDivisions; i++) {
      final y = size.height * (i / horizontalDivisions);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (series1.isEmpty && series2.isEmpty) return;

    // Compute min and max
    double computedMin = minY ?? double.infinity;
    double computedMax = maxY ?? -double.infinity;

    for (final v in [...series1, ...series2]) {
      if (minY == null && v < computedMin) computedMin = v;
      if (maxY == null && v > computedMax) computedMax = v;
    }

    if (computedMin == computedMax) {
      computedMin -= 10;
      computedMax += 10;
    }
    final range = computedMax - computedMin;

    void drawSeries(List<double> values, Color color) {
      if (values.length < 2) return;

      final path = Path();
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final dx = size.width / (values.length - 1);

      for (int i = 0; i < values.length; i++) {
        final x = i * dx;
        final normalized = (values[i] - computedMin) / range;
        final y = size.height - (normalized * size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }

      canvas.drawPath(path, paint);
    }

    drawSeries(series1, AppColors.gold);
    drawSeries(series2, AppColors.secondaryText);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.series1 != series1 || oldDelegate.series2 != series2;
  }
}

