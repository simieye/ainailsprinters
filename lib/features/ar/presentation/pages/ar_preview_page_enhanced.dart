import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// AR 滤镜试戴页面（增强版）
/// 白皮书 3.1 节：AR 滤镜试戴
/// 利用手机/桌面摄像头进行 AR 级指甲贴合试戴
class ArPreviewPageEnhanced extends StatefulWidget {
  const ArPreviewPageEnhanced({super.key});

  @override
  State<ArPreviewPageEnhanced> createState() => _ArPreviewPageEnhancedState();
}

class _ArPreviewPageEnhancedState extends State<ArPreviewPageEnhanced>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _isScanning = false;
  int _selectedFinger = 0;
  int _selectedDesign = 0;
  String _statusText = '将手指对准相机';

  final List<String> _fingerNames = [
    '拇指', '食指', '中指', '无名指', '小指'
  ];

  final List<Color> _designColors = [
    AppTheme.primaryNeonGreen,
    AppTheme.secondaryNeonPurple,
    AppTheme.accentNeonCyan,
    AppTheme.accentNeonPink,
    AppTheme.warningNeonOrange,
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _statusText = 'AI 识别中...';
    });

    // 模拟扫描过程
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _statusText = '识别完成 · 甲型已适配';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeepDark,
      appBar: AppBar(
        title: const Text('AR 试戴预览'),
        backgroundColor: Colors.transparent,
        actions: [
          // 闪光灯
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {},
          ),
          // 切换摄像头
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== AR 预览区域 =====
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 模拟摄像头画面
                Container(
                  color: AppTheme.bgSurfaceDark,
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: AppTheme.textHint,
                    ),
                  ),
                ),

                // 扫描线动画
                if (_isScanning)
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: 0,
                        right: 0,
                        top: _scanAnimation.value *
                            (MediaQuery.of(context).size.height * 0.6),
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppTheme.primaryNeonGreen,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryNeonGreen
                                    .withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // 指甲轮廓覆盖层
                if (!_isScanning) _buildNailOverlay(),

                // 状态提示
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCardDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isScanning
                            ? AppTheme.primaryNeonGreen.withOpacity(0.4)
                            : AppTheme.secondaryNeonPurple.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isScanning)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryNeonGreen,
                            ),
                          )
                        else
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.secondaryNeonPurple,
                            size: 16,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _statusText,
                          style: TextStyle(
                            color: _isScanning
                                ? AppTheme.primaryNeonGreen
                                : AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 手指热区指示
                ...List.generate(5, (i) {
                  return Positioned(
                    top: 60 + i * 50.0,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFinger = i),
                      child: Container(
                        width: _selectedFinger == i ? 80 : 60,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _selectedFinger == i
                              ? _designColors[i].withOpacity(0.2)
                              : AppTheme.bgCardDark.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _selectedFinger == i
                                ? _designColors[i]
                                : AppTheme.borderGlow.withOpacity(0.5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _fingerNames[i],
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedFinger == i
                                  ? _designColors[i]
                                  : AppTheme.textSecondary,
                              fontWeight: _selectedFinger == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // ===== 底部控制栏 =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCardDark,
              border: Border(
                top: BorderSide(
                  color: AppTheme.primaryNeonGreen.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 设计颜色选择
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_designColors.length, (i) {
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDesign = i),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                _designColors[i],
                                _designColors[i].withOpacity(0.5),
                              ],
                            ),
                            border: _selectedDesign == i
                                ? Border.all(
                                    color: Colors.white, width: 2)
                                : null,
                            boxShadow: _selectedDesign == i
                                ? [
                                    BoxShadow(
                                      color:
                                          _designColors[i].withOpacity(0.5),
                                      blurRadius: 8,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _startScanning,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('重新扫描'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isScanning
                            ? null
                            : () {
                                // 确认打印
                                Navigator.of(context).pop(true);
                              },
                        icon: const Icon(Icons.print, size: 20),
                        label: const Text('确认 · 开始打印'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNeonGreen,
                          foregroundColor: AppTheme.bgDeepDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建指甲轮廓覆盖层
  Widget _buildNailOverlay() {
    return CustomPaint(
      painter: _NailOverlayPainter(
        selectedFinger: _selectedFinger,
        selectedColor: _designColors[_selectedDesign],
      ),
      size: Size.infinite,
    );
  }
}

/// 指甲轮廓绘制器 — 模拟甲型自适应形变
class _NailOverlayPainter extends CustomPainter {
  final int selectedFinger;
  final Color selectedColor;

  _NailOverlayPainter({
    required this.selectedFinger,
    required this.selectedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // 绘制5个指甲轮廓
    for (int i = 0; i < 5; i++) {
      final isSelected = i == selectedFinger;
      final offsetY = 80.0 + i * 50;
      final nailWidth = isSelected ? 70.0 : 55.0;
      final nailHeight = isSelected ? 40.0 : 32.0;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - 20, offsetY),
          width: nailWidth,
          height: nailHeight,
        ),
        const Radius.circular(18),
      );

      // 指甲底色
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            (isSelected ? selectedColor : AppTheme.textHint)
                .withOpacity(isSelected ? 0.3 : 0.1),
            (isSelected ? selectedColor : AppTheme.textHint)
                .withOpacity(isSelected ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, fillPaint);

      // 指甲边框
      final borderPaint = Paint()
        ..color = isSelected
            ? selectedColor.withOpacity(0.6)
            : AppTheme.textHint.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.0 : 1.0;

      canvas.drawRRect(rect, borderPaint);

      // 选中指甲的高亮发光
      if (isSelected) {
        final glowPaint = Paint()
          ..color = selectedColor.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(rect, glowPaint);

        // 自适应形变标记点
        final nailPoints = _getNailAdaptivePoints(rect);
        for (final point in nailPoints) {
          canvas.drawCircle(
            point,
            3,
            Paint()..color = selectedColor.withOpacity(0.5),
          );
        }
      }
    }

    // 绘制甲型自适应形变引导线
    if (selectedFinger >= 0) {
      final y = 80.0 + selectedFinger * 50;
      final leftX = centerX - 20 - 35;
      final rightX = centerX - 20 + 35;

      final dashPaint = Paint()
        ..color = selectedColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      // 横向参考线
      canvas.drawLine(
        Offset(leftX - 20, y - 20),
        Offset(rightX + 20, y - 20),
        dashPaint,
      );
      canvas.drawLine(
        Offset(leftX - 20, y + 20),
        Offset(rightX + 20, y + 20),
        dashPaint,
      );
    }
  }

  List<Offset> _getNailAdaptivePoints(RRect rect) {
    // 模拟甲型自适应形变的关键控制点
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final hw = rect.width / 2;
    final hh = rect.height / 2;

    return [
      Offset(cx, cy - hh + 6), // 顶部
      Offset(cx - hw + 8, cy), // 左侧
      Offset(cx + hw - 8, cy), // 右侧
      Offset(cx, cy + hh - 6), // 底部
    ];
  }

  @override
  bool shouldRepaint(covariant _NailOverlayPainter oldDelegate) {
    return oldDelegate.selectedFinger != selectedFinger ||
        oldDelegate.selectedColor != selectedColor;
  }
}
