class BusinessMetrics {
  final double initialInvestment;
  final double currentRevenue;
  final double roiPercent;
  final int paybackDays;
  final int estimatedPaybackDays;
  final double progressPercent;
  final List<double> dailyRevenue;
  final double projectedAnnualRevenue;
  final int todayPrints;
  final double todayRevenue;
  final double avgPrice;
  final List<DesignRanking> topDesigns;
  final List<String> peakHours;

  const BusinessMetrics({
    required this.initialInvestment,
    required this.currentRevenue,
    required this.roiPercent,
    required this.paybackDays,
    required this.estimatedPaybackDays,
    required this.progressPercent,
    required this.dailyRevenue,
    required this.projectedAnnualRevenue,
    required this.todayPrints,
    required this.todayRevenue,
    required this.avgPrice,
    required this.topDesigns,
    required this.peakHours,
  });

  factory BusinessMetrics.initial() => BusinessMetrics(
    initialInvestment: 15000,
    currentRevenue: 0,
    roiPercent: 0,
    paybackDays: 0,
    estimatedPaybackDays: 45,
    progressPercent: 0,
    dailyRevenue: [0, 0, 0, 0, 0, 0, 0],
    projectedAnnualRevenue: 0,
    todayPrints: 0,
    todayRevenue: 0,
    avgPrice: 0,
    topDesigns: [],
    peakHours: [],
  );
}

class DesignRanking {
  final String name;
  final int prints;
  final double revenue;

  const DesignRanking({
    required this.name,
    required this.prints,
    required this.revenue,
  });
}

class StoreMetrics {
  final String storeId;
  final String storeName;
  final int todayPrints;
  final double todayRevenue;
  final double uptimePercent;
  final String status;

  const StoreMetrics({
    required this.storeId,
    required this.storeName,
    required this.todayPrints,
    required this.todayRevenue,
    required this.uptimePercent,
    required this.status,
  });

  factory StoreMetrics.mock(int index) => StoreMetrics(
    storeId: 'store_$index',
    storeName: ['旗舰店', '万达店', '万象城店', '太古里店'][index % 4],
    todayPrints: 30 + (index * 17) % 60,
    todayRevenue: 600.0 + (index * 340) % 1200,
    uptimePercent: 0.95 + (index % 5) * 0.01,
    status: index % 5 == 0 ? 'maintenance' : 'online',
  );
}
