import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/app_theme.dart';

/// 后台管理通用组件

/// 统计卡片
class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final double? growth;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.growth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (growth != null) ...[
                Icon(
                  growth! >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: growth! >= 0 ? AppTheme.primaryNeonGreen : AppTheme.accentNeonPink,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${growth! >= 0 ? '+' : ''}${growth!.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: growth! >= 0 ? AppTheme.primaryNeonGreen : AppTheme.accentNeonPink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 数据表格
class AdminDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.bgSurfaceDark),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            return Colors.transparent;
          }),
          headingTextStyle: const TextStyle(
            color: AppTheme.primaryNeonGreen,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          dataTextStyle: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
          ),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: AppTheme.borderGlow.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          columns: columns
              .map((c) => DataColumn(
                    label: Text(c),
                  ))
              .toList(),
          rows: rows
              .map((r) => DataRow(
                    cells: r.map((cell) => DataCell(cell)).toList(),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// 状态徽章
class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, Color>? colorMap;

  const StatusBadge({
    super.key,
    required this.status,
    this.colorMap,
  });

  static const _defaultColors = {
    'active': AppTheme.primaryNeonGreen,
    'online': AppTheme.primaryNeonGreen,
    'resolved': AppTheme.primaryNeonGreen,
    'published': AppTheme.primaryNeonGreen,
    'gold': Color(0xFFFFD700),
    'diamond': Color(0xFF00E5FF),
    'inactive': AppTheme.textHint,
    'offline': AppTheme.textHint,
    'draft': AppTheme.textHint,
    'suspended': AppTheme.warningNeonOrange,
    'pending': AppTheme.warningNeonOrange,
    'in_progress': AppTheme.warningNeonOrange,
    'warning': AppTheme.warningNeonOrange,
    'silver': Color(0xFFC0C0C0),
    'bronze': Color(0xFFCD7F32),
    'flagged': AppTheme.accentNeonPink,
    'banned': AppTheme.accentNeonPink,
    'error': AppTheme.accentNeonPink,
    'critical': AppTheme.accentNeonPink,
    'closed': AppTheme.textSecondary,
    'removed': AppTheme.textSecondary,
    'standalone': Color(0xFFB44CFF),
    'store-in-store': Color(0xFF00E5FF),
  };

  @override
  Widget build(BuildContext context) {
    final colors = colorMap ?? _defaultColors;
    final color = colors[status] ?? AppTheme.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 简易折线图卡片
class SimpleLineChartCard extends StatelessWidget {
  final String title;
  final List<double> data;
  final Color lineColor;
  final String? valueLabel;

  const SimpleLineChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.lineColor,
    this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (valueLabel != null)
                Text(
                  valueLabel!,
                  style: TextStyle(
                    color: lineColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.borderGlow.withOpacity(0.1),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withOpacity(0.08),
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
}

/// 区块标题
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientNeon,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 12,
              ),
            ),
          ],
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 筛选标签
class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryNeonGreen.withOpacity(0.15)
              : AppTheme.bgSurfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryNeonGreen.withOpacity(0.4)
                : AppTheme.borderGlow.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryNeonGreen : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
