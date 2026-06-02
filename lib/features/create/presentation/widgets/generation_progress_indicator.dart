import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class GenerationProgressIndicator extends StatefulWidget {
  const GenerationProgressIndicator({super.key});

  @override
  State<GenerationProgressIndicator> createState() =>
      _GenerationProgressIndicatorState();
}

class _GenerationProgressIndicatorState
    extends State<GenerationProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryNeonGreen.withOpacity(0.15),
              ),
            ),
            child: Column(
              children: [
                // 动画图标
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(
                        AppTheme.primaryNeonGreen,
                        AppTheme.secondaryNeonPurple,
                        _animation.value,
                      )!,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 进度文字
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.gradientNeon.createShader(bounds),
                  child: const Text(
                    'nanobanana 3.0 正在生成...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SIMIAIOS 64智能体集群协同创作中',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                
                // 进度步骤
                _buildStep('OpenClaw 意图解析', true),
                _buildStep('nanobanana 图案生成', _animation.value > 0.3),
                _buildStep('甲型自适应形变', _animation.value > 0.6),
                _buildStep('1200 DPI 质量检查', _animation.value > 0.8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: completed
                ? AppTheme.primaryNeonGreen
                : AppTheme.textHint,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: completed
                  ? AppTheme.textPrimary
                  : AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
