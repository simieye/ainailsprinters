import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_models.dart';

/// 后台管理模块 Provider

// ===== 后台认证 =====
final adminUserProvider = StateProvider<AdminUser?>((ref) => null);

final adminSelectedSystemProvider = StateProvider<int>((ref) => 0);

// ===== 品牌总部数据 =====
final brandOverviewStatsProvider = StateProvider<BrandOverviewStats>(
  (ref) => BrandOverviewStats.initial(),
);

final revenueTrendProvider = StateProvider<List<RevenueTrendPoint>>((ref) => []);
final regionRevenueProvider = StateProvider<List<RegionRevenue>>((ref) => []);

// ===== 设备监控 =====
final deviceHealthListProvider = StateProvider<List<DeviceHealthStatus>>((ref) => []);
final selectedDeviceIdProvider = StateProvider<String?>((ref) => null);

// ===== 经销商数据 =====
final dealersProvider = StateProvider<List<Dealer>>((ref) => []);
final selectedDealerIdProvider = StateProvider<String?>((ref) => null);

// ===== 门店数据 =====
final storesProvider = StateProvider<List<Store>>((ref) => []);
final selectedStoreIdProvider = StateProvider<String?>((ref) => null);

// ===== 终端用户数据 =====
final endUsersProvider = StateProvider<List<EndUser>>((ref) => []);
final selectedEndUserIdProvider = StateProvider<String?>((ref) => null);

// ===== 社区内容 =====
final communityContentsProvider = StateProvider<List<CommunityContent>>((ref) => []);
final selectedContentIdProvider = StateProvider<String?>((ref) => null);

// ===== 技术工单 =====
final supportTicketsProvider = StateProvider<List<SupportTicket>>((ref) => []);
final selectedTicketIdProvider = StateProvider<String?>((ref) => null);

// ===== 仪表盘筛选 =====
final adminDateRangeProvider = StateProvider<String>((ref) => 'month'); // day/week/month/quarter/year
final adminSearchQueryProvider = StateProvider<String>((ref) => '');
final adminFilterStatusProvider = StateProvider<String>((ref) => 'all');
