import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/admin_models.dart';
import '../../../domain/services/admin_providers.dart';
import '../../widgets/admin_common_widgets.dart';
import '../../widgets/payment_integration_widgets.dart';

/// 系统4：终端门店/店中店系统
/// 门店管理、设备分配、营收统计、评分管理
class StoresPage extends ConsumerStatefulWidget {
  const StoresPage({super.key});

  @override
  ConsumerState<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends ConsumerState<StoresPage> {
  String _selectedType = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    ref.read(storesProvider.notifier).state = [
      Store(id: 'ST-001', name: '东京旗舰店', dealerId: 'DL-001', dealerName: '东京美甲株式会社', address: '東京都渋谷区神宮前1-1-1', city: '东京', country: '日本', type: 'standalone', deviceCount: 5, monthlyRevenue: 85000, dailyOrders: 45, rating: 4.8, status: 'active', openDate: DateTime(2024, 4, 1)),
      Store(id: 'ST-002', name: '首尔明洞店', dealerId: 'DL-002', dealerName: 'Seoul Beauty Corp', address: '서울 중구 명동8길 27', city: '首尔', country: '韩国', type: 'store-in-store', deviceCount: 3, monthlyRevenue: 62000, dailyOrders: 32, rating: 4.6, status: 'active', openDate: DateTime(2024, 6, 15)),
      Store(id: 'ST-003', name: '上海南京路店', dealerId: 'DL-006', dealerName: '上海美业集团', address: '上海市黄浦区南京东路100号', city: '上海', country: '中国', type: 'standalone', deviceCount: 4, monthlyRevenue: 95000, dailyOrders: 58, rating: 4.9, status: 'active', openDate: DateTime(2024, 3, 20)),
      Store(id: 'ST-004', name: '纽约时代广场店', dealerId: 'DL-003', dealerName: 'NYC Nail Empire', address: '234 W 42nd St, New York', city: '纽约', country: '美国', type: 'standalone', deviceCount: 6, monthlyRevenue: 110000, dailyOrders: 65, rating: 4.7, status: 'active', openDate: DateTime(2024, 2, 14)),
      Store(id: 'ST-005', name: '伦敦牛津街店', dealerId: 'DL-004', dealerName: 'London Glamour Ltd', address: '100 Oxford St, London', city: '伦敦', country: '英国', type: 'store-in-store', deviceCount: 2, monthlyRevenue: 48000, dailyOrders: 25, rating: 4.5, status: 'active', openDate: DateTime(2024, 8, 10)),
      Store(id: 'ST-006', name: '迪拜MALL店', dealerId: 'DL-005', dealerName: 'Dubai Luxury Nails', address: 'The Dubai Mall, Level 1', city: '迪拜', country: '阿联酋', type: 'store-in-store', deviceCount: 3, monthlyRevenue: 72000, dailyOrders: 38, rating: 4.8, status: 'active', openDate: DateTime(2024, 10, 5)),
      Store(id: 'ST-007', name: '新加坡乌节路店', dealerId: 'DL-010', dealerName: 'Singapore Elite', address: 'Orchard Rd 304', city: '新加坡', country: '新加坡', type: 'standalone', deviceCount: 2, monthlyRevenue: 45000, dailyOrders: 22, rating: 4.4, status: 'active', openDate: DateTime(2025, 4, 12)),
      Store(id: 'ST-008', name: '巴黎香榭丽舍店', dealerId: 'DL-008', dealerName: 'Paris Élégance', address: '78 Av. des Champs-Élysées', city: '巴黎', country: '法国', type: 'standalone', deviceCount: 3, monthlyRevenue: 55000, dailyOrders: 28, rating: 4.6, status: 'active', openDate: DateTime(2024, 9, 20)),
      Store(id: 'ST-009', name: '圣保罗中心店', dealerId: 'DL-007', dealerName: 'São Paulo Beauty', address: 'Av. Paulista 1000', city: '圣保罗', country: '巴西', type: 'store-in-store', deviceCount: 1, monthlyRevenue: 28000, dailyOrders: 14, rating: 4.2, status: 'active', openDate: DateTime(2025, 2, 5)),
      Store(id: 'ST-010', name: '莫斯科红场店', dealerId: 'DL-009', dealerName: 'Moscow Style Pro', address: 'Red Square 1', city: '莫斯科', country: '俄罗斯', type: 'standalone', deviceCount: 2, monthlyRevenue: 32000, dailyOrders: 16, rating: 4.0, status: 'pending', openDate: DateTime(2025, 5, 1)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allStores = ref.watch(storesProvider);
    final stores = allStores.where((s) {
      if (_selectedType != 'all' && s.type != _selectedType) return false;
      if (_selectedStatus != 'all' && s.status != _selectedStatus) return false;
      return true;
    }).toList();

    final totalRevenue = stores.fold<double>(0, (sum, s) => sum + s.monthlyRevenue);
    final totalDevices = stores.fold<int>(0, (sum, s) => sum + s.deviceCount);
    final avgRating = stores.isEmpty ? 0 : stores.fold<double>(0, (sum, s) => sum + s.rating) / stores.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '终端门店/店中店系统', subtitle: '门店运营与设备管理'),
          const SizedBox(height: 20),

          // 统计卡片
          Row(
            children: [
              _buildStoreStatCard('门店总数', '${stores.length}', '家', Icons.store, AppTheme.primaryNeonGreen),
              const SizedBox(width: 16),
              _buildStoreStatCard('月总营收', '\$${(totalRevenue / 10000).toStringAsFixed(0)}万', 'USD', Icons.trending_up, AppTheme.accentNeonCyan),
              const SizedBox(width: 16),
              _buildStoreStatCard('设备总量', '$totalDevices', '台', Icons.devices, AppTheme.secondaryNeonPurple),
              const SizedBox(width: 16),
              _buildStoreStatCard('平均评分', avgRating.toStringAsFixed(1), '/5.0', Icons.star, AppTheme.warningNeonOrange),
            ],
          ),
          const SizedBox(height: 24),

          // 筛选栏
          Row(
            children: [
              const Text('类型：', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ...['all', 'standalone', 'store-in-store'].map((t) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: {'all': '全部', 'standalone': '独立门店', 'store-in-store': '店中店'}[t]!,
                  isSelected: _selectedType == t,
                  onTap: () => setState(() => _selectedType = t),
                ),
              )),
              const SizedBox(width: 24),
              const Text('状态：', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ...['all', 'active', 'pending', 'inactive'].map((s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: {'all': '全部', 'active': '运营中', 'pending': '待审核', 'inactive': '已停业'}[s]!,
                  isSelected: _selectedStatus == s,
                  onTap: () => setState(() => _selectedStatus = s),
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),

          // 门店卡片网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: stores.length,
            itemBuilder: (context, index) => _buildStoreCard(stores[index]),
          ),
          const SizedBox(height: 24),

          // 门店支付快捷入口
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStoreStatCard(String label, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(unit, style: TextStyle(color: color, fontSize: 12)),
                    ),
                  ],
                ),
                Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(Store store) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNeonGreen.withOpacity(0.03),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(store.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ),
              StatusBadge(status: store.type),
            ],
          ),
          const SizedBox(height: 4),
          Text('${store.city}, ${store.country}', style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStoreMetric(Icons.storefront, '${store.deviceCount}台设备'),
              const SizedBox(width: 16),
              _buildStoreMetric(Icons.shopping_cart, '${store.dailyOrders}单/日'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildStoreMetric(Icons.attach_money, '\$${(store.monthlyRevenue / 1000).toStringAsFixed(0)}K/月'),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                  const SizedBox(width: 4),
                  Text(store.rating.toStringAsFixed(1), style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: store.status),
              Row(
                children: [
                  _buildMiniButton('详情', () {}),
                  const SizedBox(width: 6),
                  _buildMiniButton('设备', () {}),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreMetric(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textHint, size: 13),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildMiniButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primaryNeonGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.primaryNeonGreen.withOpacity(0.2)),
        ),
        child: Text(text, style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
