import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PrintHistoryChart extends StatefulWidget {
  const PrintHistoryChart({super.key});

  @override
  State<PrintHistoryChart> createState() => _PrintHistoryChartState();
}

class _PrintHistoryChartState extends State<PrintHistoryChart>
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
    final random = Random(42);
    final data = List.generate(7, (_) => 20 + random.nextDouble() * 40);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderGlow.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart, size: 16, color: AppTheme.primaryNeonGreen),
                    SizedBox(width: 8),
                    Text(
                      '本周打印趋势',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '+12% ↑',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryNeonGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final value = data[index] * _animation.value;
                      final days = ['一', '二', '三', '四', '五', '六', '日'];
                      final isToday = index == 6;
                      
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isToday
                                      ? AppTheme.primaryNeonGreen
                                      : AppTheme.textHint,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: value * 2.2,
                                decoration: BoxDecoration(
                                  gradient: isToday
                                      ? AppTheme.gradientNeon
                                      : LinearGradient(
                                          colors: [
                                            AppTheme.primaryNeonGreen.withOpacity(0.3),
                                            AppTheme.primaryNeonGreen.withOpacity(0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                days[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                                  color: isToday
                                      ? AppTheme.primaryNeonGreen
                                      : AppTheme.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
