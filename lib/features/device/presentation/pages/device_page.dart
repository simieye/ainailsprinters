import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/lkbox_service.dart';
import '../../domain/models/device_status.dart';
import '../widgets/device_3d_view.dart';
import '../widgets/cartridge_monitor.dart';
import '../widgets/print_history_chart.dart';

class DevicePage extends ConsumerStatefulWidget {
  const DevicePage({super.key});

  @override
  ConsumerState<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends ConsumerState<DevicePage> {
  @override
  void initState() {
    super.initState();
    _connectDevice();
  }

  Future<void> _connectDevice() async {
    final lkbox = ref.read(lkboxServiceProvider);
    final connected = await lkbox.connect('LK-2025-0001');
    ref.read(isDeviceConnectedProvider.notifier).state = connected;
    
    if (connected) {
      final status = await lkbox.getDeviceStatus();
      ref.read(deviceStatusProvider.notifier).state = DeviceStatus.fromMap(status);
      
      final stats = await lkbox.getPrintStats();
      // Update business metrics with print stats
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(isDeviceConnectedProvider);
    final deviceStatus = ref.watch(deviceStatusProvider);
    final cartridgeLevels = ref.watch(cartridgeLevelsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.gradientNeon.createShader(bounds),
                      child: const Text(
                        '龙虾智控',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'CyberNeon',
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    // 连接状态
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? AppTheme.primaryNeonGreen.withOpacity(0.1)
                            : AppTheme.warningNeonOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isConnected
                              ? AppTheme.primaryNeonGreen.withOpacity(0.3)
                              : AppTheme.warningNeonOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
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
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected ? 'LK Box 在线' : '未连接',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isConnected
                                  ? AppTheme.primaryNeonGreen
                                  : AppTheme.warningNeonOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3D 设备建模透视图
            SliverToBoxAdapter(
              child: Device3DView(isConnected: isConnected),
            ),

            // 设备状态卡片
            SliverToBoxAdapter(
              child: _buildDeviceStatusGrid(deviceStatus),
            ),

            // CMYK 墨盒监控
            SliverToBoxAdapter(
              child: CartridgeMonitor(levels: cartridgeLevels),
            ),

            // 打印历史图表
            SliverToBoxAdapter(
              child: const PrintHistoryChart(),
            ),

            // 耗材订购
            SliverToBoxAdapter(
              child: _buildSupplyOrderCard(),
            ),

            // 远程管理
            SliverToBoxAdapter(
              child: _buildRemoteManagementCard(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatusGrid(DeviceStatus status) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          _StatusCard(
            icon: Icons.thermostat,
            label: '喷头温度',
            value: '${status.temperature}°C',
            color: status.temperature > 40
                ? AppTheme.warningNeonOrange
                : AppTheme.primaryNeonGreen,
          ),
          _StatusCard(
            icon: Icons.water_drop,
            label: '湿度',
            value: '${status.humidity}%',
            color: AppTheme.accentNeonCyan,
          ),
          _StatusCard(
            icon: Icons.print,
            label: '总打印次数',
            value: '${status.totalPrints}',
            color: AppTheme.secondaryNeonPurple,
          ),
          _StatusCard(
            icon: Icons.speed,
            label: '网络延迟',
            value: '${status.networkLatency}ms',
            color: status.networkLatency > 50
                ? AppTheme.warningNeonOrange
                : AppTheme.primaryNeonGreen,
          ),
          _StatusCard(
            icon: Icons.memory,
            label: 'CPU 负载',
            value: '${(status.cpuLoad * 100).toInt()}%',
            color: AppTheme.accentNeonCyan,
          ),
          _StatusCard(
            icon: Icons.life,
            label: '打印生命周期',
            value: '${(status.printLifecycle * 100).toInt()}% (50k)',
            color: status.printLifecycle > 0.8
                ? AppTheme.warningNeonOrange
                : AppTheme.primaryNeonGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyOrderCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryNeonGreen.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryNeonGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: AppTheme.primaryNeonGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MagSafe 耗材一键续订',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'K 墨盒余量较低，建议续订',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeonGreen,
                foregroundColor: AppTheme.bgDeepDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10,
                ),
              ),
              child: const Text('续订', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteManagementCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
            const Text(
              '远程管理',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRemoteAction(
                  icon: Icons.system_update,
                  label: 'OTA 更新',
                  subtitle: '固件 v3.2.1',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _buildRemoteAction(
                  icon: Icons.bug_report,
                  label: '故障诊断',
                  subtitle: '无异常',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _buildRemoteAction(
                  icon: Icons.restart_alt,
                  label: '远程重启',
                  subtitle: '已运行 127h',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteAction({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bgSurfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderGlow.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.accentNeonCyan, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
