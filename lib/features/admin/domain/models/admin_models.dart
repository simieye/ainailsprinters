/// 后台管理系统通用数据模型

/// 管理员角色枚举
enum AdminRole {
  superAdmin,      // 超级管理员（总部）
  channelManager,  // 渠道管理员
  storeManager,    // 门店管理员
  techSupport,     // 技术支持Tim
  contentEditor,   // 内容编辑
}

/// 后台用户模型
class AdminUser {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final String avatarUrl;
  final DateTime lastLogin;
  final List<String> permissions;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl = '',
    required this.lastLogin,
    this.permissions = const [],
  });

  factory AdminUser.initial() => AdminUser(
    id: 'admin_001',
    name: '系统管理员',
    email: 'admin@ainails.com',
    role: AdminRole.superAdmin,
    lastLogin: DateTime.now(),
    permissions: ['all'],
  );
}

/// 品牌总部 - 全局统计
class BrandOverviewStats {
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalDealers;
  final int totalStores;
  final int totalUsers;
  final int totalDevices;
  final double revenueGrowth;
  final double userGrowth;
  final double storeGrowth;

  const BrandOverviewStats({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.totalDealers,
    required this.totalStores,
    required this.totalUsers,
    required this.totalDevices,
    required this.revenueGrowth,
    required this.userGrowth,
    required this.storeGrowth,
  });

  factory BrandOverviewStats.initial() => const BrandOverviewStats(
    totalRevenue: 28500000,
    monthlyRevenue: 3200000,
    totalDealers: 156,
    totalStores: 2840,
    totalUsers: 1250000,
    totalDevices: 3200,
    revenueGrowth: 23.5,
    userGrowth: 18.2,
    storeGrowth: 12.8,
  );
}

/// 设备健康状态
class DeviceHealthStatus {
  final String deviceId;
  final String storeName;
  final String status; // online/offline/warning/error
  final double cpuUsage;
  final double memoryUsage;
  final Map<String, double> cartridgeLevels;
  final int totalPrints;
  final DateTime lastHeartbeat;

  const DeviceHealthStatus({
    required this.deviceId,
    required this.storeName,
    required this.status,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.cartridgeLevels,
    required this.totalPrints,
    required this.lastHeartbeat,
  });
}

/// 经销商模型
class Dealer {
  final String id;
  final String name;
  final String region;
  final String country;
  final String tier; // gold/silver/bronze
  final int storeCount;
  final double monthlyRevenue;
  final double commissionRate;
  final String contactName;
  final String contactPhone;
  final String status; // active/inactive/suspended
  final DateTime joinDate;

  const Dealer({
    required this.id,
    required this.name,
    required this.region,
    required this.country,
    required this.tier,
    required this.storeCount,
    required this.monthlyRevenue,
    required this.commissionRate,
    required this.contactName,
    required this.contactPhone,
    required this.status,
    required this.joinDate,
  });
}

/// 门店模型
class Store {
  final String id;
  final String name;
  final String dealerId;
  final String dealerName;
  final String address;
  final String city;
  final String country;
  final String type; // standalone/store-in-store
  final int deviceCount;
  final double monthlyRevenue;
  final int dailyOrders;
  final double rating;
  final String status; // active/inactive/pending
  final DateTime openDate;

  const Store({
    required this.id,
    required this.name,
    required this.dealerId,
    required this.dealerName,
    required this.address,
    required this.city,
    required this.country,
    required this.type,
    required this.deviceCount,
    required this.monthlyRevenue,
    required this.dailyOrders,
    required this.rating,
    required this.status,
    required this.openDate,
  });
}

/// 终端用户模型
class EndUser {
  final String id;
  final String nickname;
  final String email;
  final String avatarUrl;
  final String country;
  final int totalDesigns;
  final int totalOrders;
  final double totalSpent;
  final String memberLevel; // bronze/silver/gold/diamond
  final String status; // active/inactive/banned
  final DateTime registerDate;
  final DateTime lastActive;

  const EndUser({
    required this.id,
    required this.nickname,
    required this.email,
    this.avatarUrl = '',
    required this.country,
    required this.totalDesigns,
    required this.totalOrders,
    required this.totalSpent,
    required this.memberLevel,
    required this.status,
    required this.registerDate,
    required this.lastActive,
  });
}

/// 社区内容模型
class CommunityContent {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final String type; // post/tutorial/showcase/news
  final int likes;
  final int comments;
  final int shares;
  final String status; // published/draft/flagged/removed
  final DateTime publishDate;

  const CommunityContent({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.type,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.status,
    required this.publishDate,
  });
}

/// 技术工单模型
class SupportTicket {
  final String id;
  final String storeId;
  final String storeName;
  final String deviceId;
  final String issueType;
  final String severity; // low/medium/high/critical
  final String description;
  final String status; // open/in_progress/resolved/closed
  final String assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const SupportTicket({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.deviceId,
    required this.issueType,
    required this.severity,
    required this.description,
    required this.status,
    required this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
  });
}

/// 营收趋势数据点
class RevenueTrendPoint {
  final DateTime date;
  final double revenue;
  final double profit;

  const RevenueTrendPoint({
    required this.date,
    required this.revenue,
    required this.profit,
  });
}

/// 区域营收分布
class RegionRevenue {
  final String region;
  final double revenue;
  final int storeCount;

  const RegionRevenue({
    required this.region,
    required this.revenue,
    required this.storeCount,
  });
}
