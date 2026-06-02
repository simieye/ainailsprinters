import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/business_metrics.dart';

class RevenueChart extends StatefulWidget {
  final BusinessMetrics metrics;
  const RevenueChart({super.key, required this.metrics});

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.show_chart,
                      size: 16,
                      color: AppTheme.primaryNeonGreen,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '7日营收趋势',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${widget.metrics.projectedAnnualRevenue}/年 预估',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryNeonGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    size: const Size(double.infinity, 160),
                    painter: _RevenueChartPainter(
                      data: widget.metrics.dailyRevenue,
                      animation: _animation.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  final List<double> data;
  final double animation;

  _RevenueChartPainter({required this.data, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.reduce(max);
    final minValue = data.reduce(min);
    final range = maxValue - minValue;
    final stepX = size.width / (data.length - 1);

    // 绘制网格线
    final gridPaint = Paint()
      ..color = AppTheme.borderGlow.withOpacity(0.2)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 计算控制点
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = stepX * i;
      final y = size.height - ((data[i] - minValue) / range * size.height * 0.8 + size.height * 0.1);
      points.add(Offset(x, y));
    }

    // 绘制填充区域
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final prevPoint = points[i - 1];
        final currentPoint = points[i];
        final controlX = (prevPoint.dx + currentPoint.dx) / 2;
        fillPath.quadraticBezierTo(
          prevPoint.dx,
          prevPoint.dy,
          controlX,
          (prevPoint.dy + currentPoint.dy) / 2,
        );
      }
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryNeonGreen.withOpacity(0.3 * animation),
          AppTheme.primaryNeonGreen.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // 绘制线条
    final linePaint = Paint()
      ..color = AppTheme.primaryNeonGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prevPoint = points[i - 1];
      final currentPoint = points[i];
      final controlX = (prevPoint.dx + currentPoint.dx) / 2;
      linePath.quadraticBezierTo(
        prevPoint.dx,
        prevPoint.dy,
        controlX,
        (prevPoint.dy + currentPoint.dy) / 2,
      );
    }

    canvas.drawPath(linePath, linePaint);

    // 绘制数据点
    final dotPaint = Paint()..color = AppTheme.primaryNeonGreen;
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = AppTheme.bgDeepDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
