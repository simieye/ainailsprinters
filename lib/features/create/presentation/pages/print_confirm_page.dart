import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/lkbox_service.dart';

class PrintConfirmPage extends ConsumerStatefulWidget {
  const PrintConfirmPage({super.key});

  @override
  ConsumerState<PrintConfirmPage> createState() => _PrintConfirmPageState();
}

class _PrintConfirmPageState extends ConsumerState<PrintConfirmPage>
    with SingleTickerProviderStateMixin {
  bool _isPrinting = false;
  double _printProgress = 0;
  late AnimationController _printController;

  @override
  void initState() {
    super.initState();
    _printController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _printController.dispose();
    super.dispose();
  }

  Future<void> _startPrint() async {
    setState(() => _isPrinting = true);

    // 模拟 10 秒打印过程
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _printProgress = i / 100);
    }

    if (!mounted) return;
    setState(() {
      _isPrinting = false;
      _printProgress = 1.0;
    });

    // 显示完成弹窗
    _showPrintCompleteDialog();
  }

  void _showPrintCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.gradientNeon,
              ),
              child: const Icon(
                Icons.check,
                size: 36,
                color: AppTheme.bgDeepDark,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '打印完成！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1200 DPI 纳米级精度\n10秒快速喷印',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final design = ref.watch(selectedDesignProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeepDark,
      appBar: AppBar(
        title: const Text('确认打印'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 设计预览
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderGlow.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: AppTheme.gradientCyber,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            design?.title ?? '自定义设计',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 打印参数
                  _buildInfoCard(),
                  const SizedBox(height: 16),

                  // 设备状态
                  _buildDeviceStatusCard(),
                  const SizedBox(height: 16),

                  // 耗材信息
                  _buildCartridgeCard(),
                ],
              ),
            ),
          ),

          // 打印进度条 / 按钮
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
                if (_isPrinting) ...[
                  // 打印进度
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _printProgress,
                      backgroundColor: AppTheme.bgSurfaceDark,
                      valueColor: const AlwaysStoppedAnimation(
                        AppTheme.primaryNeonGreen,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '打印中... ${(_printProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryNeonGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPrinting ? null : _startPrint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNeonGreen,
                      foregroundColor: AppTheme.bgDeepDark,
                      disabledBackgroundColor: AppTheme.bgElevatedDark,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isPrinting ? '打印中...' : '开始打印 · 10s 快速喷印',
                      style: const TextStyle(
                        fontSize: 17,
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

  Widget _buildInfoCard() {
    return Container(
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
          const Text(
            '打印参数',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('分辨率', '1200 DPI'),
          _buildInfoRow('打印速度', '10秒/指甲'),
          _buildInfoRow('颜色模式', 'CMYK + 涂层'),
          _buildInfoRow('引擎', 'nanobanana 3.0'),
          _buildInfoRow('形变算法', 'Nail-Adaptive'),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusCard() {
    final isConnected = ref.watch(isDeviceConnectedProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isConnected
                  ? AppTheme.primaryNeonGreen
                  : AppTheme.warningNeonOrange)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? AppTheme.primaryNeonGreen
                  : AppTheme.warningNeonOrange,
              boxShadow: [
                BoxShadow(
                  color: (isConnected
                          ? AppTheme.primaryNeonGreen
                          : AppTheme.warningNeonOrange)
                      .withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isConnected ? 'AI NAILS Printer 已连接' : '设备未连接',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isConnected
                      ? AppTheme.primaryNeonGreen
                      : AppTheme.warningNeonOrange,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'LK Box · 固件 v3.2.1',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartridgeCard() {
    final levels = ref.watch(cartridgeLevelsProvider);

    return Container(
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
          const Text(
            '耗材余量',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...levels.entries.map((e) => _buildCartridgeRow(
                e.key,
                e.value,
                _getCartridgeColor(e.key),
              )),
        ],
      ),
    );
  }

  Widget _buildCartridgeRow(String label, double level, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: level,
                backgroundColor: AppTheme.bgSurfaceDark,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 42,
            child: Text(
              '${(level * 100).toInt()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: level < 0.3
                    ? AppTheme.accentNeonPink
                    : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCartridgeColor(String key) {
    return switch (key) {
      'C' => const Color(0xFF00BCD4),
      'M' => const Color(0xFFE91E63),
      'Y' => const Color(0xFFFFEB3B),
      'K' => const Color(0xFF607D8B),
      _ => AppTheme.textSecondary,
    };
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryNeonGreen,
            ),
          ),
        ],
      ),
    );
  }
}
