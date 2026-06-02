import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 太极64卦偏好推荐矩阵
/// 白皮书 2.2 节：根据用户浏览、打印历史、地域流行趋势、天气/穿搭场景进行精准推荐
class RecommendationFeed extends StatefulWidget {
  const RecommendationFeed({super.key});

  @override
  State<RecommendationFeed> createState() => _RecommendationFeedState();
}

class _RecommendationFeedState extends State<RecommendationFeed>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final Random _rng = Random(42);

  // 模拟的64卦推荐数据
  final List<_TrigramRecommendation> _recommendations = [];
  int _activeHexagram = 1;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 初始化推荐数据
    final hexagramNames = [
      '乾为天', '坤为地', '水雷屯', '山水蒙', '水天需', '天水讼', '地水师', '水地比',
      '风天小畜', '天泽履', '地天泰', '天地否', '天火同人', '火天大有', '地山谦', '雷地豫',
    ];

    final trends = [
      '东京涩谷 · 霓虹渐变',
      '巴黎时装周 · 法式极简',
      '首尔明洞 · 糖果马卡龙',
      '纽约时装周 · 金属质感',
      '米兰设计周 · 几何抽象',
      '上海时装周 · 国风新韵',
      '伦敦时装周 · 暗黑哥特',
      '迪拜 · 奢华金箔',
    ];

    for (int i = 0; i < 8; i++) {
      _recommendations.add(_TrigramRecommendation(
        hexagramName: hexagramNames[i],
        trend: trends[i],
        confidence: 0.75 + _rng.nextDouble() * 0.25,
        color: [
          AppTheme.primaryNeonGreen,
          AppTheme.secondaryNeonPurple,
          AppTheme.accentNeonCyan,
          AppTheme.accentNeonPink,
          AppTheme.warningNeonOrange,
          AppTheme.goldAccent,
          AppTheme.infoBlue,
          AppTheme.successGreen,
        ][i],
      ));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.gradientPurple.createShader(bounds),
                child: const Text(
                  '太极64卦 · 智能推荐',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              _buildHexagramBadge(),
            ],
          ),
        ),

        // 推荐卡片横向滚动
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final rec = _recommendations[index];
              return _RecommendationCard(
                recommendation: rec,
                isActive: _activeHexagram == index + 1,
                onTap: () =>
                    setState(() => _activeHexagram = index + 1),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHexagramBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentNeonPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentNeonPink.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: AppTheme.accentNeonPink,
          ),
          const SizedBox(width: 4),
          Text(
            '卦 $_activeHexagram / 64',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.accentNeonPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrigramRecommendation {
  final String hexagramName;
  final String trend;
  final double confidence;
  final Color color;

  const _TrigramRecommendation({
    required this.hexagramName,
    required this.trend,
    required this.confidence,
    required this.color,
  });
}

class _RecommendationCard extends StatelessWidget {
  final _TrigramRecommendation recommendation;
  final bool isActive;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              recommendation.color.withOpacity(isActive ? 0.2 : 0.08),
              AppTheme.bgSurfaceDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: recommendation.color
                .withOpacity(isActive ? 0.5 : 0.2),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: recommendation.color.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 卦名
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: recommendation.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: recommendation.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.hexagramName,
                      style: TextStyle(
                        color: recommendation.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 推荐趋势
              Text(
                recommendation.trend,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // 置信度条
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: recommendation.confidence,
                        backgroundColor: AppTheme.bgElevatedDark,
                        valueColor: AlwaysStoppedAnimation(
                          recommendation.color,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(recommendation.confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: recommendation.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 太极64卦旋转罗盘组件
class TrigramCompass extends StatefulWidget {
  final int activeHexagram;
  final ValueChanged<int>? onHexagramChanged;

  const TrigramCompass({
    super.key,
    required this.activeHexagram,
    this.onHexagramChanged,
  });

  @override
  State<TrigramCompass> createState() => _TrigramCompassState();
}

class _TrigramCompassState extends State<TrigramCompass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _TrigramCompassPainter(
            rotation: _controller.value * 2 * 3.14159,
            activeHexagram: widget.activeHexagram,
          ),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class _TrigramCompassPainter extends CustomPainter {
  final double rotation;
  final int activeHexagram;

  _TrigramCompassPainter({
    required this.rotation,
    required this.activeHexagram,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // 外圈
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppTheme.borderGlow.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 64卦标记
    for (int i = 0; i < 64; i++) {
      final angle = (i / 64.0) * 2 * 3.14159 - 3.14159 / 2 + rotation;
      final x = center.dx + cos(angle) * (radius - 14);
      final y = center.dy + sin(angle) * (radius - 14);

      final isActive = i == activeHexagram - 1;
      final color = isActive ? AppTheme.primaryNeonGreen : AppTheme.textHint;

      canvas.drawCircle(
        Offset(x, y),
        isActive ? 4 : 2,
        Paint()..color = color,
      );

      if (isActive) {
        canvas.drawCircle(
          Offset(x, y),
          8,
          Paint()
            ..color = AppTheme.primaryNeonGreen.withOpacity(0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    // 内圈太极图
    canvas.drawCircle(
      center,
      40,
      Paint()
        ..color = AppTheme.bgSurfaceDark
        ..style = PaintingStyle.fill,
    );

    // 太极阴阳鱼
    final yinPaint = Paint()..color = AppTheme.textPrimary;
    final yangPaint = Paint()..color = AppTheme.bgDeepDark;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 40),
      -3.14159 / 2 + rotation,
      3.14159,
      true,
      yinPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 40),
      3.14159 / 2 + rotation,
      3.14159,
      true,
      yangPaint,
    );

    // 阴阳眼
    canvas.drawCircle(
      Offset(center.dx, center.dy - 20),
      8,
      Paint()..color = AppTheme.bgDeepDark,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + 20),
      8,
      Paint()..color = AppTheme.textPrimary,
    );

    // 中心卦数
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$activeHexagram',
        style: const TextStyle(
          color: AppTheme.primaryNeonGreen,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _TrigramCompassPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.activeHexagram != activeHexagram;
  }
}
