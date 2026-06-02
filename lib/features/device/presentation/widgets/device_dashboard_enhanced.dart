import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 龙虾智控 — 设备仪表盘增强版
/// 白皮书 2.4 & 5.2 节：远程设备管理与商务 SaaS
/// B2C 家庭版 + B2B 店中店双模切换
class DeviceDashboard extends StatefulWidget {
  const DeviceDashboard({super.key});

  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isBusinessMode = false;
  final Random _rng = Random(42);

  // 设备状态数据
  final Map<String, dynamic> _deviceStatus = {
    'printer_name': 'AI NAILS Printer Pro X1',
    'serial': 'ANP-2025-00001',
    'firmware': 'v3.2.1',
    'status': 'online',
    'total_prints': 12450,
    'max_prints': 50000,
    'last_maintenance': '2025-05-15',
    'uptime_hours': 8760,
  };

  // 耗材数据
  final Map<String, dynamic> _consumables = {
    'cmyk': {
      'cyan': 0.72,
      'magenta': 0.45,
      'yellow': 0.88,
      'black': 0.61,
    },
    'coating': 0.53,
    'cleaning_fluid': 0.78,
  };

  // B2B 业务数据
  final Map<String, dynamic> _businessData = {
    'daily_revenue': 1280.50,
    'monthly_revenue': 38415.00,
    'roi_progress': 0.67,
    'roi_days_remaining': 15,
    'active_hours': 12.5,
    'avg_order_value': 38.50,
    'top_designs': [
      {'name': '赛博朋克霓虹', 'prints': 342, 'revenue': 13167.0},
      {'name': '法式极简金边', 'prints': 287, 'revenue': 11049.5},
      {'name': '国风水墨蝶', 'prints': 254, 'revenue': 9779.0},
    ],
    'multi_store': [
      {'name': '涩谷旗舰店', 'revenue': 52400, 'status': 'online'},
      {'name': '明洞店', 'revenue': 38200, 'status': 'online'},
      {'name': '新天地店', 'revenue': 45600, 'status': 'maintenance'},
      {'name': '银座店', 'revenue': 61800, 'status': 'online'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _isBusinessMode ? 4 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isBusinessMode = !_isBusinessMode;
      _tabController.dispose();
      _tabController = TabController(
        length: _isBusinessMode ? 4 : 2,
        vsync: this,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeepDark,
      appBar: AppBar(
        title: const Text(
          '龙虾智控',
          style: TextStyle(
            fontFamily: 'CyberNeon',
            letterSpacing: 2,
          ),
        ),
        backgroundColor: AppTheme.bgDeepDark,
        actions: [
          // B2C/B2B 切换
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'B2C',
                  style: TextStyle(
                    fontSize: 11,
                    color: !_isBusinessMode
                        ? AppTheme.primaryNeonGreen
                        : AppTheme.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: _isBusinessMode,
                  onChanged: (_) => _toggleMode(),
                  activeColor: AppTheme.goldAccent,
                ),
                Text(
                  'B2B',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isBusinessMode
                        ? AppTheme.goldAccent
                        : AppTheme.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryNeonGreen,
          labelColor: AppTheme.primaryNeonGreen,
          unselectedLabelColor: AppTheme.textHint,
          isScrollable: true,
          tabs: [
            const Tab(text: '设备状态'),
            const Tab(text: '耗材管理'),
            if (_isBusinessMode) ...[
              const Tab(text: '营收看板'),
              const Tab(text: '多店管理'),
            ],
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeviceStatusTab(),
          _buildConsumablesTab(),
          if (_isBusinessMode) ...[
            _buildRevenueTab(),
            _buildMultiStoreTab(),
          ],
        ],
      ),
    );
  }

  // ===== 设备状态 =====
  Widget _buildDeviceStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 设备3D透视示意
          _buildDeviceModel(),
          const SizedBox(height: 16),

          // 状态卡片
          _buildStatusCards(),
          const SizedBox(height: 16),

          // LK Box 连接状态
          _buildLKBoxStatus(),
          const SizedBox(height: 16),

          // 打印生命周期
          _buildPrintLifecycle(),
        ],
      ),
    );
  }

  Widget _buildDeviceModel() {
    final printPercent = (_deviceStatus['total_prints'] as int) /
        (_deviceStatus['max_prints'] as int);

    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentNeonCyan.withOpacity(0.1),
            AppTheme.primaryNeonGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentNeonCyan.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          // 3D 设备轮廓示意
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.print,
                  size: 60,
                  color: AppTheme.accentNeonCyan,
                ),
                const SizedBox(height: 8),
                Text(
                  _deviceStatus['printer_name'] as String,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/N: ${_deviceStatus['serial']} · FW ${_deviceStatus['firmware']}',
                  style: const TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // 在线状态
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.successGreen.withOpacity(0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingDot(color: AppTheme.successGreen),
                  SizedBox(width: 6),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            icon: Icons.print,
            label: '总打印量',
            value: '${_deviceStatus['total_prints']}',
            unit: '次',
            color: AppTheme.primaryNeonGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusCard(
            icon: Icons.timer,
            label: '运行时间',
            value: '${_deviceStatus['uptime_hours']}',
            unit: '小时',
            color: AppTheme.accentNeonCyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusCard(
            icon: Icons.build,
            label: '上次维护',
            value: _deviceStatus['last_maintenance'] as String,
            unit: '',
            color: AppTheme.warningNeonOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildLKBoxStatus() {
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
          Row(
            children: [
              const Icon(Icons.cloud,
                  color: AppTheme.accentNeonCyan, size: 20),
              const SizedBox(width: 8),
              const Text(
                'LK Box 龙虾云盒',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PulsingDot(color: AppTheme.successGreen),
                    SizedBox(width: 4),
                    Text(
                      'Connected',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LKBoxMetric(
                icon: Icons.cloud_upload,
                label: '算力负载',
                value: '42%',
                color: AppTheme.primaryNeonGreen,
              ),
              const SizedBox(width: 20),
              _LKBoxMetric(
                icon: Icons.speed,
                label: '延迟',
                value: '85ms',
                color: AppTheme.accentNeonCyan,
              ),
              const SizedBox(width: 20),
              _LKBoxMetric(
                icon: Icons.storage,
                label: '本地存储',
                value: '128GB',
                color: AppTheme.secondaryNeonPurple,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.42,
              backgroundColor: AppTheme.bgSurfaceDark,
              valueColor: const AlwaysStoppedAnimation(
                AppTheme.primaryNeonGreen,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintLifecycle() {
    final percent = (_deviceStatus['total_prints'] as int) /
        (_deviceStatus['max_prints'] as int);

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
            '打印生命周期管理',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_deviceStatus['total_prints']} / ${_deviceStatus['max_prints']} 次',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  color: percent > 0.8
                      ? AppTheme.errorRed
                      : AppTheme.primaryNeonGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppTheme.bgSurfaceDark,
              valueColor: AlwaysStoppedAnimation(
                percent > 0.8
                    ? AppTheme.errorRed
                    : AppTheme.primaryNeonGreen,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '预计剩余寿命: ${((1 - percent) * _deviceStatus['max_prints'] as int).toInt()} 次打印',
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ===== 耗材管理 =====
  Widget _buildConsumablesTab() {
    final cmyk = _consumables['cmyk'] as Map<String, double>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // CMYK 墨盒
          _buildSectionTitle('CMYK 墨盒余量'),
          const SizedBox(height: 12),
          _InkLevelCard(
            label: 'C 青色',
            percent: cmyk['cyan']!,
            color: const Color(0xFF00BCD4),
          ),
          _InkLevelCard(
            label: 'M 品红',
            percent: cmyk['magenta']!,
            color: const Color(0xFFE91E63),
          ),
          _InkLevelCard(
            label: 'Y 黄色',
            percent: cmyk['yellow']!,
            color: const Color(0xFFFFEB3B),
          ),
          _InkLevelCard(
            label: 'K 黑色',
            percent: cmyk['black']!,
            color: const Color(0xFF9E9E9E),
          ),
          const SizedBox(height: 16),

          // 涂层液 + 清洁液
          _buildSectionTitle('其他耗材'),
          const SizedBox(height: 12),
          _InkLevelCard(
            label: '涂层液',
            percent: (_consumables['coating'] as num).toDouble(),
            color: AppTheme.secondaryNeonPurple,
          ),
          _InkLevelCard(
            label: '清洁液',
            percent: (_consumables['cleaning_fluid'] as num).toDouble(),
            color: AppTheme.accentNeonCyan,
          ),
          const SizedBox(height: 16),

          // MagSafe 一键续订
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryNeonGreen.withOpacity(0.1),
                  AppTheme.accentNeonCyan.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryNeonGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.subscriptions,
                    color: AppTheme.primaryNeonGreen, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MagSafe 耗材一键续订',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '墨量低于20%自动下单 · 次日送达',
                        style: TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 12,
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
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text('管理订阅',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== B2B 营收看板 =====
  Widget _buildRevenueTab() {
    final biz = _businessData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 今日/本月营收
          Row(
            children: [
              Expanded(
                child: _RevenueCard(
                  title: '今日营收',
                  value: '¥${biz['daily_revenue']}',
                  trend: '+12.5%',
                  color: AppTheme.primaryNeonGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RevenueCard(
                  title: '本月营收',
                  value: '¥${(biz['monthly_revenue'] as double).toStringAsFixed(0)}',
                  trend: '+8.3%',
                  color: AppTheme.goldAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ROI 回本进度
          _buildROIProgress(),
          const SizedBox(height: 16),

          // 客单价漏斗
          _buildFunnelChart(),
          const SizedBox(height: 16),

          // 热点图案排行
          _buildTopDesigns(),
        ],
      ),
    );
  }

  Widget _buildROIProgress() {
    final progress = (_businessData['roi_progress'] as num).toDouble();
    final daysRemaining = _businessData['roi_days_remaining'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.goldAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up,
                  color: AppTheme.goldAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                '45天 ROI 回本进度',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '还剩 $daysRemaining 天',
                style: TextStyle(
                  color: daysRemaining <= 10
                      ? AppTheme.errorRed
                      : AppTheme.goldAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.bgSurfaceDark,
              valueColor:
                  const AlwaysStoppedAnimation(AppTheme.goldAccent),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% · 预计提前 $daysRemaining 天回本',
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelChart() {
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
            '客单价漏斗分析',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _FunnelBar(
            label: '浏览',
            value: 100,
            color: AppTheme.accentNeonCyan,
          ),
          _FunnelBar(
            label: 'AR试戴',
            value: 65,
            color: AppTheme.primaryNeonGreen,
          ),
          _FunnelBar(
            label: '加入购物车',
            value: 42,
            color: AppTheme.secondaryNeonPurple,
          ),
          _FunnelBar(
            label: '完成打印',
            value: 28,
            color: AppTheme.goldAccent,
          ),
          const SizedBox(height: 8),
          Text(
            '平均客单价: ¥${_businessData['avg_order_value']}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDesigns() {
    final designs =
        _businessData['top_designs'] as List<dynamic>;

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
            '🔥 热点图案排行',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...designs.asMap().entries.map((entry) {
            final d = entry.value as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: entry.key < 3
                          ? AppTheme.goldAccent.withOpacity(0.2)
                          : AppTheme.bgSurfaceDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: entry.key < 3
                              ? AppTheme.goldAccent
                              : AppTheme.textHint,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      d['name'] as String,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '${d['prints']}次 · ¥${d['revenue']}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===== 多店管理 =====
  Widget _buildMultiStoreTab() {
    final stores =
        _businessData['multi_store'] as List<dynamic>;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index] as Map<String, dynamic>;
        final isOnline = store['status'] == 'online';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOnline
                  ? AppTheme.primaryNeonGreen.withOpacity(0.3)
                  : AppTheme.warningNeonOrange.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppTheme.primaryNeonGreen.withOpacity(0.1)
                      : AppTheme.warningNeonOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store,
                  color: isOnline
                      ? AppTheme.primaryNeonGreen
                      : AppTheme.warningNeonOrange,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store['name'] as String,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '月营收 ¥${store['revenue']}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? AppTheme.successGreen.withOpacity(0.1)
                          : AppTheme.warningNeonOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOnline ? '营业中' : '维护中',
                      style: TextStyle(
                        color: isOnline
                            ? AppTheme.successGreen
                            : AppTheme.warningNeonOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '日均 ¥${((store['revenue'] as num) / 30).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 状态卡片
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 10,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// 营收卡片
class _RevenueCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final Color color;

  const _RevenueCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            AppTheme.bgCardDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.arrow_upward,
                  size: 14, color: AppTheme.successGreen),
              Text(
                trend,
                style: const TextStyle(
                  color: AppTheme.successGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// LK Box 指标
class _LKBoxMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _LKBoxMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 墨量卡片
class _InkLevelCard extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _InkLevelCard({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderGlow.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppTheme.bgSurfaceDark,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(percent * 100).toInt()}%',
            style: TextStyle(
              color: percent < 0.2 ? AppTheme.errorRed : color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 漏斗条
class _FunnelBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _FunnelBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100.0,
                backgroundColor: AppTheme.bgSurfaceDark,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$value%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// 脉冲点
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withOpacity(0.4 + _controller.value * 0.3),
                blurRadius: 4 + _controller.value * 4,
              ),
            ],
          ),
        );
      },
    );
  }
}
