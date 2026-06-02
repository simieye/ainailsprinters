import 'package:flutter_test/flutter_test.dart';
import 'package:ai_nails_app/features/alliance/domain/models/business_metrics.dart';
import 'package:ai_nails_app/features/alliance/domain/services/report_service.dart';

void main() {
  late ReportService service;

  setUp(() {
    service = ReportService.instance;
  });

  group('ReportService - ROI', () {
    test('should return ROI report with all fields', () async {
      final report = await service.getROIReport();

      expect(report.containsKey('device_cost'), true);
      expect(report.containsKey('total_revenue'), true);
      expect(report.containsKey('roi_percent'), true);
      expect(report.containsKey('net_profit'), true);
      expect(report.containsKey('revenue_trend'), true);
      expect(report.containsKey('cost_breakdown'), true);
    });

    test('should return positive net profit', () async {
      final report = await service.getROIReport();
      final netProfit = report['net_profit'] as double;
      expect(netProfit, greaterThan(0));
    });

    test('should include 6 months of trend data', () async {
      final report = await service.getROIReport();
      final trends = report['revenue_trend'] as List;
      expect(trends.length, 6);
    });
  });

  group('ReportService - Top Designs', () {
    test('should return top designs sorted by prints', () async {
      final designs = await service.getTopDesigns(limit: 5);

      expect(designs.length, lessThanOrEqualTo(5));
      for (int i = 1; i < designs.length; i++) {
        expect(designs[i - 1].prints, greaterThanOrEqualTo(designs[i].prints));
      }
    });

    test('should filter by category', () async {
      final designs = await service.getTopDesigns(category: 'cyberpunk');

      for (final d in designs) {
        expect(d.category, 'cyberpunk');
      }
    });
  });

  group('ReportService - Hourly Analysis', () {
    test('should return 14 hours of data (9-22)', () async {
      final analysis = await service.getHourlyAnalysis();
      final hourlyData = analysis['hourly_data'] as List;

      expect(hourlyData.length, 14);
      expect(hourlyData.first['hour'], 9);
      expect(hourlyData.last['hour'], 22);
    });

    test('should identify peak hours', () async {
      final analysis = await service.getHourlyAnalysis();
      final peakHours = analysis['peak_hours'] as List;

      expect(peakHours, isNotEmpty);
      expect(peakHours.length, 4);
    });
  });

  group('ReportService - Funnel Analysis', () {
    test('should return 6 funnel stages', () async {
      final funnel = await service.getFunnelAnalysis();
      final stages = funnel['funnel'] as List;

      expect(stages.length, 6);
      expect(stages.first['stage'], '浏览');
    });

    test('should have decreasing counts through funnel', () async {
      final funnel = await service.getFunnelAnalysis();
      final stages = funnel['funnel'] as List;

      for (int i = 1; i < stages.length; i++) {
        final prevCount = (stages[i - 1]['count'] as num);
        final currCount = (stages[i]['count'] as num);
        expect(currCount, lessThanOrEqualTo(prevCount));
      }
    });
  });

  group('ReportService - AI Insights', () {
    test('should return 5 insights', () async {
      final insights = await service.getAIInsights();

      expect(insights.length, 5);
    });

    test('should have required fields', () async {
      final insights = await service.getAIInsights();

      for (final insight in insights) {
        expect(insight.containsKey('type'), true);
        expect(insight.containsKey('title'), true);
        expect(insight.containsKey('message'), true);
        expect(insight.containsKey('icon'), true);
        expect(insight.containsKey('impact'), true);
      }
    });

    test('should have valid impact values', () async {
      final insights = await service.getAIInsights();
      const validImpacts = {'high', 'medium', 'low'};

      for (final insight in insights) {
        expect(validImpacts.contains(insight['impact']), true);
      }
    });
  });

  group('ReportService - Export', () {
    test('should export CSV with headers', () async {
      final csv = await service.exportToCSV(type: ReportService.ReportType.weekly);

      expect(csv.contains('Metric,Value'), true);
      expect(csv.contains('Device Cost'), true);
      expect(csv.contains('Total Revenue'), true);
      expect(csv.contains('ROI %'), true);
      expect(csv.contains('Month,Revenue,Growth'), true);
    });
  });

  group('BusinessMetrics Model', () {
    test('should create initial metrics with zero values', () {
      final metrics = BusinessMetrics.initial();

      expect(metrics.todayPrints, 0);
      expect(metrics.todayRevenue, 0);
      expect(metrics.totalStores, 1);
    });

    test('should calculate ROI correctly', () {
      final metrics = BusinessMetrics.initial();
      expect(metrics.roiPercent, 0);
    });
  });

  group('DesignRanking Model', () {
    test('should create mock rankings', () {
      final rankings = DesignRanking.mockRankings();

      expect(rankings, isNotEmpty);
      expect(rankings.length, greaterThan(3));
    });

    test('should have valid fields', () {
      final rankings = DesignRanking.mockRankings();

      for (final r in rankings) {
        expect(r.name, isNotEmpty);
        expect(r.prints, greaterThan(0));
        expect(r.revenue, greaterThan(0));
      }
    });
  });

  group('StoreMetrics Model', () {
    test('should create mock stores', () {
      final stores = StoreMetrics.mockStores();

      expect(stores.length, 4);
    });

    test('should have consistent data', () {
      final stores = StoreMetrics.mockStores();

      for (final store in stores) {
        expect(store.id, isNotEmpty);
        expect(store.name, isNotEmpty);
        expect(store.status, isNotEmpty);
      }
    });
  });
}
