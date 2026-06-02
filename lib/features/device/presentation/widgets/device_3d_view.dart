import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class Device3DView extends StatefulWidget {
  final bool isConnected;

  const Device3DView({super.key, required this.isConnected});

  @override
  State<Device3DView> createState() => _Device3DViewState();
}

class _Device3DViewState extends State<Device3DView>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AnimatedBuilder(
        animation: _rotateController,
        builder: (context, child) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.bgSurfaceDark,
                  AppTheme.bgElevatedDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isConnected
                    ? AppTheme.primaryNeonGreen.withOpacity(0.2)
                    : AppTheme.borderGlow.withOpacity(0.3),
              ),
            ),
            child: Stack(
              children: [
                // 3D 设备建模（模拟）
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 打印机轮廓
                      Container(
                        width: 160,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.bgElevatedDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryNeonGreen.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryNeonGreen.withOpacity(
                                0.1 * (1 + 0.5 * (_rotateController.value - 0.5).abs()),
                              ),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.print,
                              size: 32,
                              color: AppTheme.primaryNeonGreen,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'AI NAILS Printer',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryNeonGreen.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'V-ALIGN 3D',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppTheme.primaryNeonGreen.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // LK Box
                      Container(
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                          color: widget.isConnected
                              ? AppTheme.primaryNeonGreen.withOpacity(0.1)
                              : AppTheme.bgSurfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.isConnected
                                ? AppTheme.primaryNeonGreen.withOpacity(0.4)
                                : AppTheme.borderGlow.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'LK Box',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: widget.isConnected
                                  ? AppTheme.primaryNeonGreen
                                  : AppTheme.textHint,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 网格背景
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPainter(
                      animation: _rotateController.value,
                      color: AppTheme.primaryNeonGreen.withOpacity(0.05),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double animation;
  final Color color;

  _GridPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 20.0;
    final offset = animation * spacing;

    for (double x = offset; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = offset; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
