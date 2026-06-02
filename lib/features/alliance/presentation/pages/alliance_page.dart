import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../domain/models/business_metrics.dart';
import '../widgets/roi_progress_card.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/store_grid.dart';
import '../widgets/top_designs_ranking.dart';

class AlliancePage extends ConsumerStatefulWidget {
  const AlliancePage({super.key});

  @override
  ConsumerState<AlliancePage> createState() => _AlliancePageState();
}

class _AlliancePageState extends ConsumerState<AlliancePage> {
  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  void _loadMetrics() {
    // 加载商业指标数据
    final metrics = BusinessMetrics(
      initialInvestment: 15000,
      currentRevenue: 27000,
      roiPercent: 180,
      paybackDays: 25,
      estimatedPaybackDays: 45,
      progressPercent: 0.72,
      dailyRevenue: [180, 220, 195, 240, 260, 230, 280],
      projectedAnnualRevenue: 324000,
      todayPrints: 47,
      todayRevenue: 940,
      avgPrice: 20,
      topDesigns: const [
        DesignRanking(name: '赛博霓虹', prints: 89, revenue: 1780),
        DesignRanking(name: '樱花物语', prints: 76, revenue: 1520),
        DesignRanking(name: '星空渐变', prints: 65, revenue: 1300),
        DesignRanking(name: '国风竹韵', prints: 58, revenue: 1160),
        DesignRanking(name: '极光之舞', prints: 52, revenue: 1040),
      ],
      peakHours: const ['14:00', '15:00', '19:00', '20:00'],
    );
    
    ref.read(businessMetricsProvider.notifier).state = metrics;
    
    // 加载多店数据
    final stores = List.generate(6, (i) => StoreMetrics.mock(i));
    ref.read(multiStoreDataProvider.notifier).state = stores;
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(businessMetricsProvider);
    final stores = ref.watch(multiStoreDataProvider);

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
                        '商业协同',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'CyberNeon',
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    // B2B 模式标记
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningNeonOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.warningNeonOrange.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.store,
                            size: 14,
                            color: AppTheme.warningNeonOrange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'B2B · 店中店',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.warningNeonOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 今日概览
            SliverToBoxAdapter(
              child: _buildTodayOverview(metrics),
            ),

            // 45天 ROI 回本进度
            SliverToBoxAdapter(
              child: RoiProgressCard(metrics: metrics),
            ),

            // 营收图表
            SliverToBoxAdapter(
              child: RevenueChart(metrics: metrics),
            ),

            // 多店并联管理
            SliverToBoxAdapter(
              child: StoreGrid(stores: stores),
            ),

            // 热点图案排行
            SliverToBoxAdapter(
              child: TopDesignsRanking(designs: metrics.topDesigns),
            ),

            // 运营建议
            SliverToBoxAdapter(
              child: _buildInsightCard(metrics),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayOverview(BusinessMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildMetricCard(
            '今日打印',
            '${metrics.todayPrints}',
            '次',
            AppTheme.primaryNeonGreen,
            Icons.print,
          ),
          const SizedBox(width: 12),
          _buildMetricCard(
            '今日营收',
            '\$${metrics.todayRevenue}',
            '',
            AppTheme.accentNeonCyan,
            Icons.attach_money,
          ),
          const SizedBox(width: 12),
          _buildMetricCard(
            '客单价',
            '\$${metrics.avgPrice}',
            '/次',
            AppTheme.secondaryNeonPurple,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 2),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
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
        ),
      ),
    );
  }

  Widget _buildInsightCard(BusinessMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentNeonCyan.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, size: 18, color: AppTheme.accentNeonCyan),
                SizedBox(width: 8),
                Text(
                  'AI 智能运营建议',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInsight(
              '高峰时段为 ${metrics.peakHours.join('、')}，建议在此期间增加耗材储备。',
            ),
            _buildInsight(
              '预计 ${metrics.estimatedPaybackDays - metrics.paybackDays} 天后完全回本，当前进度 ${(metrics.progressPercent * 100).toInt()}%。',
            ),
            _buildInsight(
              '年化预计营收 \$${metrics.projectedAnnualRevenue}，建议拓展第二台设备。',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsight(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.accentNeonCyan, fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
