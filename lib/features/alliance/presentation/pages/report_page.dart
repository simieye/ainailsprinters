import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/services/report_service.dart';

/// B端数据报表页面
///
/// 提供 ROI 分析、客流热力图、漏斗分析、AI 智能建议、
/// 数据导出等完整的 B 端运营分析工具。
class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _reportService = ReportService.instance;

  // 报表数据状态
  Map<String, dynamic>? _roiData;
  Map<String, dynamic>? _hourlyData;
  Map<String, dynamic>? _funnelData;
  List<Map<String, dynamic>>? _insights;
  bool _isLoading = true;

  // 筛选状态
  ReportService.ReportType _selectedPeriod = ReportService.weekly;
  String? _selectedStore;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _reportService.getROIReport(period: _selectedPeriod, storeId: _selectedStore),
      _reportService.getHourlyAnalysis(storeId: _selectedStore),
      _reportService.getFunnelAnalysis(period: _selectedPeriod, storeId: _selectedStore),
      _reportService.getAIInsights(storeId: _selectedStore),
    ]);

    if (mounted) {
      setState(() {
        _roiData = results[0] as Map<String, dynamic>;
        _hourlyData = results[1] as Map<String, dynamic>;
        _funnelData = results[2] as Map<String, dynamic>;
        _insights = results[3] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    }
  }

  Future<void> _exportReport() async {
    final csv = await _reportService.exportToCSV(
      type: _selectedPeriod,
      storeId: _selectedStore,
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text('Export Report', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            height: 300,
            width: 400,
            child: SingleChildScrollView(
              child: Text(
                csv,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // TODO: 实际文件导出
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Report exported to CSV'),
                    backgroundColor: AppColors.primaryNeonGreen.withOpacity(0.8),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Download', style: TextStyle(color: AppColors.primaryNeonGreen)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Data Reports', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 筛选
          _buildPeriodSelector(),
          const SizedBox(width: 8),
          // 导出按钮
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white54),
            onPressed: _exportReport,
            tooltip: 'Export CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _loadAllData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryNeonGreen,
          unselectedLabelColor: Colors.white38,
          indicatorColor: AppColors.primaryNeonGreen,
          tabs: const [
            Tab(text: 'ROI'),
            Tab(text: 'Traffic'),
            Tab(text: 'Funnel'),
            Tab(text: 'AI Insights'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonPurple))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildROITab(),
                _buildTrafficTab(),
                _buildFunnelTab(),
                _buildInsightsTab(),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return PopupMenuButton<ReportService.ReportType>(
      icon: const Icon(Icons.filter_list, color: Colors.white54),
      color: AppColors.bgCard,
      onSelected: (type) {
        setState(() => _selectedPeriod = type);
        _loadAllData();
      },
      itemBuilder: (_) => [
        _periodItem('Daily', ReportService.ReportType.daily),
        _periodItem('Weekly', ReportService.ReportType.weekly),
        _periodItem('Monthly', ReportService.ReportType.monthly),
        _periodItem('Quarterly', ReportService.ReportType.quarterly),
      ],
    );
  }

  PopupMenuItem<ReportService.ReportType> _periodItem(
    String label,
    ReportService.ReportType type,
  ) {
    final isSelected = _selectedPeriod == type;
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          if (isSelected)
            Icon(Icons.check, size: 16, color: AppColors.primaryNeonGreen)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryNeonGreen : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Tab 1: ROI 分析 =====
  Widget _buildROITab() {
    if (_roiData == null) return const SizedBox();
    final data = _roiData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 核心指标卡片
          Row(
            children: [
              _buildMetricCard(
                'ROI',
                '${(data['roi_percent'] as num).toStringAsFixed(1)}%',
                AppColors.primaryNeonGreen,
                Icons.trending_up,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Net Profit',
                '\$${(data['net_profit'] as num).toStringAsFixed(0)}',
                AppColors.neonCyan,
                Icons.account_balance_wallet,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricCard(
                'Total Revenue',
                '\$${(data['total_revenue'] as num).toStringAsFixed(0)}',
                AppColors.neonPurple,
                Icons.attach_money,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Daily Avg',
                '\$${(data['daily_avg_revenue'] as num).toStringAsFixed(2)}',
                AppColors.accentNeonPink,
                Icons.show_chart,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 成本明细
          _buildSectionTitle('Cost Breakdown'),
          const SizedBox(height: 8),
          _buildCostBreakdown(data['cost_breakdown'] as Map<String, dynamic>),
          const SizedBox(height: 20),

          // 月度营收趋势
          _buildSectionTitle('Monthly Revenue Trend'),
          const SizedBox(height: 12),
          _buildRevenueTrend(data['revenue_trend'] as List),
        ],
      ),
    );
  }

  Widget _buildCostBreakdown(Map<String, dynamic> costs) {
    final items = [
      ('Device', costs['device'], AppColors.neonPurple),
      ('Supplies', costs['supplies'], AppColors.neonCyan),
      ('Maintenance', costs['maintenance'], AppColors.primaryNeonGreen),
      ('Electricity', costs['electricity'], Colors.amber),
    ];

    final total = (costs['total'] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: items.map((item) {
          final percent = ((item.$2 as num).toDouble() / total * 100);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.$1, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(
                      '\$${item.$2} (${percent.toStringAsFixed(1)}%)',
                      style: TextStyle(color: item.$3, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    color: item.$3,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueTrend(List trends) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _RevenueTrendPainter(
                data: trends
                    .map((t) => (t['revenue'] as num).toDouble())
                    .toList(),
                labels: trends.map((t) => t['month'] as String).toList(),
              ),
              size: const Size(double.infinity, 200),
            ),
          ),
          const SizedBox(height: 12),
          // 数据表格
          ...trends.map((t) {
            final growth = (t['growth'] as num).toDouble();
            final isPositive = growth >= 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t['month'], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  Text(
                    '\$${t['revenue']}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isPositive ? AppColors.primaryNeonGreen : AppColors.accentNeonPink,
                      fontSize: 13,
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

  // ===== Tab 2: 客流热力图 =====
  Widget _buildTrafficTab() {
    if (_hourlyData == null) return const SizedBox();
    final data = _hourlyData!;
    final hourlyData = data['hourly_data'] as List;
    final peakHours = data['peak_hours'] as List;
    final lowHours = data['low_hours'] as List;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Hourly Traffic Heatmap'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: CustomPaint(
                    painter: _TrafficHeatmapPainter(
                      data: hourlyData
                          .map((h) => (h['prints'] as num).toDouble())
                          .toList(),
                      labels: hourlyData
                          .map((h) => '${h['hour']}:00')
                          .toList(),
                    ),
                    size: const Size(double.infinity, 220),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLegendItem('Peak', AppColors.primaryNeonGreen),
                    const SizedBox(width: 16),
                    _buildLegendItem('Normal', AppColors.neonCyan),
                    const SizedBox(width: 16),
                    _buildLegendItem('Low', Colors.white24),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeBlock('Peak Hours 🚀', peakHours, AppColors.primaryNeonGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeBlock('Low Hours 😴', lowHours, Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(String title, List times, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...times.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  t.toString(),
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15),
                ),
              )),
        ],
      ),
    );
  }

  // ===== Tab 3: 漏斗分析 =====
  Widget _buildFunnelTab() {
    if (_funnelData == null) return const SizedBox();
    final data = _funnelData!;
    final funnel = data['funnel'] as List;
    final maxCount = (funnel.first['count'] as num).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 核心转化指标
          Row(
            children: [
              _buildMetricCard(
                'Conversion',
                '${(data['conversion_rate'] as num).toStringAsFixed(1)}%',
                AppColors.primaryNeonGreen,
                Icons.transform,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Repeat Rate',
                '${(data['repeat_customer_rate'] as num).toStringAsFixed(1)}%',
                AppColors.neonCyan,
                Icons.repeat,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Conversion Funnel'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: CustomPaint(
                    painter: _FunnelPainter(
                      stages: funnel
                          .map((f) => _FunnelStage(
                                label: f['stage'] as String,
                                count: (f['count'] as num).toDouble(),
                                rate: (f['rate'] as num).toDouble(),
                              ))
                          .toList(),
                    ),
                    size: const Size(double.infinity, 300),
                  ),
                ),
                const SizedBox(height: 16),
                ...funnel.map((f) => _buildFunnelRow(f, maxCount)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelRow(Map<String, dynamic> stage, double maxCount) {
    final count = (stage['count'] as num).toDouble();
    final rate = (stage['rate'] as num).toDouble();
    final width = count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              stage['stage'],
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: width,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: AppColors.neonPurple.withOpacity(0.3 + width * 0.5),
                minHeight: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              '${count.toInt()} (${rate}%)',
              style: const TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Tab 4: AI 智能建议 =====
  Widget _buildInsightsTab() {
    if (_insights == null) return const SizedBox();

    final iconMap = {
      'trending_up': Icons.trending_up,
      'warning': Icons.warning_amber_rounded,
      'lightbulb': Icons.lightbulb_outline,
      'build': Icons.build_outlined,
      'location_on': Icons.location_on_outlined,
    };

    final impactColors = {
      'high': AppColors.accentNeonPink,
      'medium': AppColors.neonCyan,
      'low': Colors.white38,
    };

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _insights!.length,
      itemBuilder: (context, index) {
        final insight = _insights![index];
        final color = impactColors[insight['impact']] ?? Colors.white38;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconMap[insight['icon']] ?? Icons.info_outline,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            insight['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            insight['impact']?.toString().toUpperCase() ?? '',
                            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight['message'] ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== 通用组件 =====

  Widget _buildMetricCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                Icon(icon, size: 16, color: color.withOpacity(0.6)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    );
  }
}

// ===== 自定义 Painter =====

class _RevenueTrendPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  _RevenueTrendPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primaryNeonGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryNeonGreen.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;
    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = padding + (chartWidth / (data.length - 1)) * i;
      final y = size.height - padding - ((data[i] - minVal) / (range == 0 ? 1 : range)) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // 数据点
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.primaryNeonGreen);
      canvas.drawCircle(Offset(x, y), 8, Paint()..color = AppColors.primaryNeonGreen.withOpacity(0.2));
    }

    fillPath.lineTo(padding + chartWidth, size.height - padding);
    fillPath.close();
    canvas.drawPath(fillPath, glowPaint);
    canvas.drawPath(path, paint);

    // 标签
    final labelPaint = Paint()
      ..color = Colors.white.withOpacity(0.4);
    for (int i = 0; i < labels.length; i++) {
      final x = padding + (chartWidth / (labels.length - 1)) * i;
      final textSpan = TextSpan(text: labels[i], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10));
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TrafficHeatmapPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  _TrafficHeatmapPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = (size.width - 40) / data.length;
    final maxVal = data.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxVal) * (size.height - 40);
      final x = 20 + barWidth * i;
      final y = size.height - 20 - barHeight;

      final isPeak = data[i] >= maxVal * 0.7;
      final color = isPeak ? AppColors.primaryNeonGreen : AppColors.neonCyan.withOpacity(0.6);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 2, y, barWidth - 4, barHeight),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, Paint()..color = color);
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // 标签
      if (i % 2 == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + barWidth / 2 - tp.width / 2, size.height - 18));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FunnelStage {
  final String label;
  final double count;
  final double rate;
  _FunnelStage({required this.label, required this.count, required this.rate});
}

class _FunnelPainter extends CustomPainter {
  final List<_FunnelStage> stages;

  _FunnelPainter({required this.stages});

  @override
  void paint(Canvas canvas, Size size) {
    if (stages.isEmpty) return;

    final stageHeight = size.height / stages.length;
    final maxWidth = size.width * 0.85;
    final centerX = size.width / 2;
    final maxCount = stages.first.count;

    for (int i = 0; i < stages.length; i++) {
      final ratio = stages[i].count / maxCount;
      final width = maxWidth * ratio * 0.9 + maxWidth * 0.1;
      final y = stageHeight * i;
      final left = centerX - width / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, y + 4, width, stageHeight - 8),
        const Radius.circular(6),
      );

      final opacity = 0.2 + (ratio * 0.6);
      canvas.drawRRect(rect, Paint()..color = AppColors.neonPurple.withOpacity(opacity));

      // 标签
      final tp = TextPainter(
        text: TextSpan(
          text: '${stages[i].label}  ${stages[i].count.toInt()}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(centerX - tp.width / 2, y + stageHeight / 2 - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
