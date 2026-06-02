import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';

class ArPreviewPage extends ConsumerStatefulWidget {
  const ArPreviewPage({super.key});

  @override
  ConsumerState<ArPreviewPage> createState() => _ArPreviewPageState();
}

class _ArPreviewPageState extends ConsumerState<ArPreviewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  int _selectedFinger = 0;

  final List<String> _fingerNames = [
    '拇指', '食指', '中指', '无名指', '小指',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeepDark,
      appBar: AppBar(
        title: const Text('AR 甲面试戴'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // AR 预览区
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 模拟摄像头画面
                Container(
                  color: AppTheme.bgSurfaceDark,
                  child: const Center(
                    child: Icon(
                      Icons.handshake,
                      size: 100,
                      color: AppTheme.textHint,
                    ),
                  ),
                ),
                
                // AR 扫描线
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: _scanAnimation.value * 300 + 50,
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
                              color: AppTheme.primaryNeonGreen.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // 手指覆盖层
                Center(
                  child: Container(
                    width: 160,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryNeonGreen.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '请将手指置于框内',
                        style: TextStyle(
                          color: AppTheme.primaryNeonGreen,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 扫描状态指示器
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCardDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNeonGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryNeonGreen.withOpacity(0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'V-ALIGN 3D 视觉定位中...',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryNeonGreen,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '1200 DPI',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryNeonGreen.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 底部手指选择器
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCardDark,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '选择手指预览',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final isSelected = _selectedFinger == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFinger = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppTheme.primaryNeonGreen.withOpacity(0.15)
                              : AppTheme.bgSurfaceDark,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryNeonGreen
                                : AppTheme.borderGlow.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _fingerNames[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.primaryNeonGreen
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                
                // 确认按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNeonGreen,
                      foregroundColor: AppTheme.bgDeepDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '确认设计 · 准备打印',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
