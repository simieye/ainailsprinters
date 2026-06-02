import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/business_metrics.dart';

class RoiProgressCard extends StatefulWidget {
  final BusinessMetrics metrics;
  const RoiProgressCard({super.key, required this.metrics});

  @override
  State<RoiProgressCard> createState() => _RoiProgressCardState();
}

class _RoiProgressCardState extends State<RoiProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    final m = widget.metrics;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondaryNeonPurple.withOpacity(0.1),
                  AppTheme.primaryNeonGreen.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.secondaryNeonPurple.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    const Icon(
                      Icons.rocket_launch,
                      size: 18,
                      color: AppTheme.secondaryNeonPurple,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '45天 ROI 回本进度',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNeonGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(m.progressPercent * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryNeonGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        color: AppTheme.bgSurfaceDark,
                      ),
                      FractionallySizedBox(
                        widthFactor: m.progressPercent * _animation.value,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: AppTheme.gradientNeon,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 数据行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildROIStat(
                      '初始投入',
                      '\$${m.initialInvestment}',
                      AppTheme.textSecondary,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.borderGlow,
                    ),
                    _buildROIStat(
                      '当前收入',
                      '\$${m.currentRevenue}',
                      AppTheme.accentNeonCyan,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.borderGlow,
                    ),
                    _buildROIStat(
                      'ROI',
                      '${m.roiPercent}%',
                      AppTheme.primaryNeonGreen,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.borderGlow,
                    ),
                    _buildROIStat(
                      '回本天数',
                      '${m.paybackDays}/45',
                      AppTheme.warningNeonOrange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildROIStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textHint,
          ),
        ),
      ],
    );
  }
}
