import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/admin_models.dart';
import '../../../domain/services/admin_providers.dart';
import '../../widgets/admin_common_widgets.dart';
import '../../widgets/payment_integration_widgets.dart';

/// 系统1：AINails品牌总部管理系统
/// 全局数据看板、营收趋势、区域分布、品牌健康度
class HeadquartersPage extends ConsumerStatefulWidget {
  const HeadquartersPage({super.key});

  @override
  ConsumerState<HeadquartersPage> createState() => _HeadquartersPageState();
}

class _HeadquartersPageState extends ConsumerState<HeadquartersPage> {
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // 营收趋势数据
    final now = DateTime.now();
    final trendData = List.generate(30, (i) => RevenueTrendPoint(
      date: now.subtract(Duration(days: 29 - i)),
      revenue: 2500000 + (i * 50000) + (Random().nextDouble() * 200000),
      profit: 800000 + (i * 20000) + (Random().nextDouble() * 80000),
    ));
    ref.read(revenueTrendProvider.notifier).state = trendData;

    // 区域分布
    ref.read(regionRevenueProvider.notifier).state = const [
      RegionRevenue(region: '亚太', revenue: 12500000, storeCount: 1240),
      RegionRevenue(region: '北美', revenue: 8200000, storeCount: 680),
      RegionRevenue(region: '欧洲', revenue: 4800000, storeCount: 520),
      RegionRevenue(region: '中东', revenue: 1800000, storeCount: 240),
      RegionRevenue(region: '拉美', revenue: 1200000, storeCount: 160),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(brandOverviewStatsProvider);
    final trend = ref.watch(revenueTrendProvider);
    final regions = ref.watch(regionRevenueProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          Row(
            children: [
              const SectionTitle(title: '品牌总部仪表盘', subtitle: '全局数据概览'),
              const Spacer(),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 20),

          // 核心KPI卡片
          _buildKpiGrid(stats),
          const SizedBox(height: 24),

          // 营收趋势图
          _buildRevenueChart(trend),
          const SizedBox(height: 24),

          // 区域分布 + 业务指标
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildRegionDistribution(regions)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildBusinessMetrics(stats)),
            ],
          ),
          const SizedBox(height: 24),

          // 实时设备状态
          _buildDeviceStatusOverview(),
          const SizedBox(height: 24),

          // 全球支付中枢快捷入口
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: ['day', 'week', 'month', 'quarter', 'year'].map((p) {
        final selected = _selectedPeriod == p;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: FilterChip(
            label: {
              'day': '今日', 'week': '本周', 'month': '本月',
              'quarter': '本季', 'year': '全年'
            }[p]!,
            isSelected: selected,
            onTap: () => setState(() {
              _selectedPeriod = p;
              ref.read(adminDateRangeProvider.notifier).state = p;
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKpiGrid(BrandOverviewStats stats) {
    final kpis = [
      _KpiData('总营收', '\$${(stats.totalRevenue / 1000000).toStringAsFixed(1)}M', '环比增长', Icons.monetization_on, AppTheme.primaryNeonGreen, stats.revenueGrowth),
      _KpiData('月营收', '\$${(stats.monthlyRevenue / 10000).toStringAsFixed(0)}万', '本月累计', Icons.trending_up, AppTheme.accentNeonCyan, null),
      _KpiData('经销商', '${stats.totalDealers}家', '全球渠道', Icons.business, AppTheme.secondaryNeonPurple, stats.storeGrowth),
      _KpiData('门店', '${stats.totalStores}家', '终端覆盖', Icons.store, AppTheme.warningNeonOrange, null),
      _KpiData('用户', '${(stats.totalUsers / 10000).toStringAsFixed(0)}万', '注册用户', Icons.people, AppTheme.accentNeonPink, stats.userGrowth),
      _KpiData('设备', '${stats.totalDevices}台', 'IoT在线率94%', Icons.devices, AppTheme.accentNeonCyan, null),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return AdminStatCard(
          title: kpi.title,
          value: kpi.value,
          subtitle: kpi.subtitle,
          icon: kpi.icon,
          iconColor: kpi.color,
          growth: kpi.growth,
        );
      },
    );
  }

  Widget _buildRevenueChart(List<RevenueTrendPoint> trend) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '营收趋势', subtitle: '近30天'),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.borderGlow.withOpacity(0.1),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.now().subtract(Duration(days: 29 - value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.month}/${date.day}',
                            style: const TextStyle(color: AppTheme.textHint, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(
                        '\$${(value / 1000000).toStringAsFixed(1)}M',
                        style: const TextStyle(color: AppTheme.textHint, fontSize: 10),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trend.asMap().entries.map((e) =>
                      FlSpot(e.key.toDouble(), e.value.revenue)).toList(),
                    isCurved: true,
                    color: AppTheme.primaryNeonGreen,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryNeonGreen.withOpacity(0.08),
                    ),
                  ),
                  LineChartBarData(
                    spots: trend.asMap().entries.map((e) =>
                      FlSpot(e.key.toDouble(), e.value.profit)).toList(),
                    isCurved: true,
                    color: AppTheme.secondaryNeonPurple,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.secondaryNeonPurple.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('营收', AppTheme.primaryNeonGreen),
              const SizedBox(width: 24),
              _buildLegend('利润', AppTheme.secondaryNeonPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildRegionDistribution(List<RegionRevenue> regions) {
    final total = regions.fold<double>(0, (s, r) => s + r.revenue);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '区域营收分布'),
          const SizedBox(height: 16),
          ...regions.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.region, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                    Text(
                      '\$${(r.revenue / 1000000).toStringAsFixed(2)}M',
                      style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: r.revenue / total,
                          backgroundColor: AppTheme.bgSurfaceDark,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryNeonGreen.withOpacity(0.6),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${r.storeCount}家门店',
                      style: const TextStyle(color: AppTheme.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBusinessMetrics(BrandOverviewStats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '品牌健康度'),
          const SizedBox(height: 16),
          _buildMetricRow('门店活跃率', '94.2%', 0.942, AppTheme.primaryNeonGreen),
          _buildMetricRow('设备在线率', '93.8%', 0.938, AppTheme.accentNeonCyan),
          _buildMetricRow('用户留存率', '76.5%', 0.765, AppTheme.secondaryNeonPurple),
          _buildMetricRow('经销商满意度', '4.6/5.0', 0.92, AppTheme.warningNeonOrange),
          _buildMetricRow('工单解决率', '95.1%', 0.951, AppTheme.accentNeonPink),
          const SizedBox(height: 20),
          const Divider(color: AppTheme.borderGlow, height: 1),
          const SizedBox(height: 16),
          _buildAlertItem('⚠ 日本区域经销商库存不足', AppTheme.warningNeonOrange),
          _buildAlertItem('✓ 北美Q3目标已达成110%', AppTheme.primaryNeonGreen),
          _buildAlertItem('⚠ 3台设备需要固件更新', AppTheme.warningNeonOrange),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.bgSurfaceDark,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildDeviceStatusOverview() {
    final devices = ref.watch(deviceHealthListProvider);
    if (devices.isEmpty) {
      // 加载模拟数据
      Future.microtask(() {
        ref.read(deviceHealthListProvider.notifier).state = List.generate(8, (i) => DeviceHealthStatus(
          deviceId: 'DEV-${1000 + i}',
          storeName: ['东京旗舰店', '首尔明洞店', '上海南京路店', '纽约时代广场店', '伦敦牛津街店', '迪拜MALL店', '新加坡乌节路店', '悉尼CBD店'][i],
          status: i < 6 ? 'online' : (i == 6 ? 'warning' : 'offline'),
          cpuUsage: 30 + (i * 5.0),
          memoryUsage: 45 + (i * 3.0),
          cartridgeLevels: {'C': 0.8, 'M': 0.6, 'Y': 0.7, 'K': 0.5},
          totalPrints: 15000 - (i * 1000),
          lastHeartbeat: DateTime.now().subtract(Duration(minutes: i * 5)),
        ));
      });
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '实时设备监控', subtitle: '全球IoT设备状态'),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final d = devices[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurfaceDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: {
                          'online': AppTheme.primaryNeonGreen,
                          'warning': AppTheme.warningNeonOrange,
                          'offline': AppTheme.textHint,
                          'error': AppTheme.accentNeonPink,
                        }[d.status],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ({
                              'online': AppTheme.primaryNeonGreen,
                              'warning': AppTheme.warningNeonOrange,
                              'offline': AppTheme.textHint,
                              'error': AppTheme.accentNeonPink,
                            }[d.status] ?? AppTheme.textHint).withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(d.storeName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text('CPU ${d.cpuUsage.toStringAsFixed(0)}% | 打印 ${d.totalPrints}次',
                            style: const TextStyle(color: AppTheme.textHint, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? growth;
  const _KpiData(this.title, this.value, this.subtitle, this.icon, this.color, this.growth);
}
