import 'dart:async';
import '../models/business_metrics.dart';

/// 报表服务
///
/// 为 B 端运营提供数据报表生成、多维度筛选、
/// 导出（CSV/PDF）及定期自动推送功能。
class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  /// 报表类型
  enum ReportType {
    daily,
    weekly,
    monthly,
    quarterly,
    custom,
  }

  /// 筛选维度
  enum FilterDimension {
    store,
    region,
    designCategory,
    timeSlot,
    priceRange,
  }

  /// 获取多店并联管理数据
  Future<List<StoreMetrics>> getMultiStoreData({
    String? region,
    ReportType period = ReportType.weekly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return StoreMetrics.mockStores();
  }

  /// 获取热点图案排行（支持筛选）
  Future<List<DesignRanking>> getTopDesigns({
    String? category,
    String? storeId,
    ReportType period = ReportType.weekly,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var designs = DesignRanking.mockRankings();

    if (category != null) {
      designs = designs.where((d) => d.category == category).toList();
    }

    designs.sort((a, b) => b.prints.compareTo(a.prints));
    return designs.take(limit).toList();
  }

  /// 生成 ROI 分析报表
  Future<Map<String, dynamic>> getROIReport({
    String? storeId,
    ReportType period = ReportType.monthly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    return {
      'device_cost': 2999.00,
      'total_revenue': 8750.50,
      'total_prints': 12450,
      'daily_avg_revenue': 49.90,
      'roi_percent': 291.8,
      'break_even_days': 60,
      'current_day': 175,
      'projected_monthly_revenue': 1497.00,
      'projected_annual_roi': 598.8,
      'revenue_trend': [
        {'month': 'Jan', 'revenue': 1200, 'growth': 0},
        {'month': 'Feb', 'revenue': 1350, 'growth': 12.5},
        {'month': 'Mar', 'revenue': 1480, 'growth': 9.6},
        {'month': 'Apr', 'revenue': 1420, 'growth': -4.1},
        {'month': 'May', 'revenue': 1550, 'growth': 9.2},
        {'month': 'Jun', 'revenue': 1750, 'growth': 12.9},
      ],
      'cost_breakdown': {
        'device': 2999,
        'supplies': 1250,
        'maintenance': 200,
        'electricity': 150,
        'total': 4599,
      },
      'net_profit': 8750.50 - 4599,
    };
  }

  /// 获取小时段分析（客流热力图数据）
  Future<Map<String, dynamic>> getHourlyAnalysis({
    String? storeId,
    DateTime? date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return {
      'peak_hours': ['14:00', '15:00', '19:00', '20:00'],
      'low_hours': ['09:00', '10:00', '22:00'],
      'hourly_data': [
        {'hour': 9, 'prints': 2, 'revenue': 10.00},
        {'hour': 10, 'prints': 5, 'revenue': 25.00},
        {'hour': 11, 'prints': 8, 'revenue': 40.00},
        {'hour': 12, 'prints': 12, 'revenue': 60.00},
        {'hour': 13, 'prints': 15, 'revenue': 75.00},
        {'hour': 14, 'prints': 22, 'revenue': 110.00},
        {'hour': 15, 'prints': 25, 'revenue': 125.00},
        {'hour': 16, 'prints': 18, 'revenue': 90.00},
        {'hour': 17, 'prints': 16, 'revenue': 80.00},
        {'hour': 18, 'prints': 20, 'revenue': 100.00},
        {'hour': 19, 'prints': 28, 'revenue': 140.00},
        {'hour': 20, 'prints': 24, 'revenue': 120.00},
        {'hour': 21, 'prints': 10, 'revenue': 50.00},
        {'hour': 22, 'prints': 3, 'revenue': 15.00},
      ],
    };
  }

  /// 获取客单价漏斗分析
  Future<Map<String, dynamic>> getFunnelAnalysis({
    String? storeId,
    ReportType period = ReportType.monthly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'funnel': [
        {'stage': '浏览', 'count': 15000, 'rate': 100},
        {'stage': '详情查看', 'count': 4500, 'rate': 30},
        {'stage': 'AR试戴', 'count': 1800, 'rate': 12},
        {'stage': '加入打印队列', 'count': 900, 'rate': 6},
        {'stage': '完成打印', 'count': 850, 'rate': 5.7},
        {'stage': '分享/复购', 'count': 340, 'rate': 2.3},
      ],
      'conversion_rate': 5.7,
      'avg_order_value': 5.00,
      'repeat_customer_rate': 40.0,
    };
  }

  /// 获取 AI 智能运营建议
  Future<List<Map<String, dynamic>>> getAIInsights({
    String? storeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      {
        'type': 'opportunity',
        'title': '周五下午客流高峰',
        'message': '周五 14:00-16:00 时段打印需求增长 35%，建议增加耗材备货并安排专人值守。',
        'icon': 'trending_up',
        'impact': 'high',
      },
      {
        'type': 'warning',
        'title': '墨盒消耗加速',
        'message': '品红(M)墨盒近3天消耗速度比均值快 40%，预计 3 天后需更换，建议提前下单。',
        'icon': 'warning',
        'impact': 'medium',
      },
      {
        'type': 'suggestion',
        'title': '热门图案推荐',
        'message': '「渐变极光」系列近7天打印量增长 120%，建议在首页置顶推广并推出关联图案。',
        'icon': 'lightbulb',
        'impact': 'high',
      },
      {
        'type': 'info',
        'title': '设备维护提醒',
        'message': '设备已累计打印 12,450 次，建议在第 15,000 次时进行喷头深度清洁。',
        'icon': 'build',
        'impact': 'low',
      },
      {
        'type': 'opportunity',
        'title': '新店选址建议',
        'message': '根据当前区域打印热力分析，XX商圈美甲需求密度为当前店址的 2.3 倍。',
        'icon': 'location_on',
        'impact': 'medium',
      },
    ];
  }

  /// 导出报表为 CSV 字符串
  Future<String> exportToCSV({
    required ReportType type,
    String? storeId,
  }) async {
    final data = await getROIReport(storeId: storeId, period: type);

    final buffer = StringBuffer();
    buffer.writeln('Metric,Value');
    buffer.writeln('Device Cost,${data['device_cost']}');
    buffer.writeln('Total Revenue,${data['total_revenue']}');
    buffer.writeln('Total Prints,${data['total_prints']}');
    buffer.writeln('Daily Avg Revenue,${data['daily_avg_revenue']}');
    buffer.writeln('ROI %,${data['roi_percent']}');
    buffer.writeln('Net Profit,${data['net_profit']}');

    buffer.writeln();
    buffer.writeln('Month,Revenue,Growth %');
    final trends = data['revenue_trend'] as List;
    for (final t in trends) {
      buffer.writeln('${t['month']},${t['revenue']},${t['growth']}');
    }

    return buffer.toString();
  }

  /// 定时推送报表（可由自动化任务触发）
  Future<void> scheduleReport({
    required ReportType type,
    required String recipientEmail,
    String? storeId,
  }) async {
    // 模拟定时推送
    await Future.delayed(const Duration(milliseconds: 200));
    // 实际实现：调用邮件服务或推送通知
  }
}
