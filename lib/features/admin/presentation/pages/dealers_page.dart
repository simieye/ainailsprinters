import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/admin_models.dart';
import '../../../domain/services/admin_providers.dart';
import '../../widgets/admin_common_widgets.dart';
import '../../widgets/payment_integration_widgets.dart';

/// 系统3：全球经销商渠道系统
/// 经销商管理、佣金设置、区域授权、业绩排名
class DealersPage extends ConsumerStatefulWidget {
  const DealersPage({super.key});

  @override
  ConsumerState<DealersPage> createState() => _DealersPageState();
}

class _DealersPageState extends ConsumerState<DealersPage> {
  String _selectedTier = 'all';
  String _selectedRegion = 'all';

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    ref.read(dealersProvider.notifier).state = [
      Dealer(id: 'DL-001', name: '东京美甲株式会社', region: '亚太', country: '日本', tier: 'gold', storeCount: 85, monthlyRevenue: 420000, commissionRate: 0.15, contactName: '山田太郎', contactPhone: '+81-3-1234-5678', status: 'active', joinDate: DateTime(2024, 3, 15)),
      Dealer(id: 'DL-002', name: 'Seoul Beauty Corp', region: '亚太', country: '韩国', tier: 'gold', storeCount: 72, monthlyRevenue: 380000, commissionRate: 0.15, contactName: 'Kim Minji', contactPhone: '+82-2-9876-5432', status: 'active', joinDate: DateTime(2024, 5, 20)),
      Dealer(id: 'DL-003', name: 'NYC Nail Empire', region: '北美', country: '美国', tier: 'gold', storeCount: 65, monthlyRevenue: 520000, commissionRate: 0.15, contactName: 'John Smith', contactPhone: '+1-212-555-0199', status: 'active', joinDate: DateTime(2024, 1, 10)),
      Dealer(id: 'DL-004', name: 'London Glamour Ltd', region: '欧洲', country: '英国', tier: 'silver', storeCount: 38, monthlyRevenue: 210000, commissionRate: 0.12, contactName: 'Emma Wilson', contactPhone: '+44-20-7946-0958', status: 'active', joinDate: DateTime(2024, 7, 5)),
      Dealer(id: 'DL-005', name: 'Dubai Luxury Nails', region: '中东', country: '阿联酋', tier: 'silver', storeCount: 25, monthlyRevenue: 180000, commissionRate: 0.12, contactName: 'Ahmed Al-Rashid', contactPhone: '+971-4-567-8901', status: 'active', joinDate: DateTime(2024, 9, 12)),
      Dealer(id: 'DL-006', name: '上海美业集团', region: '亚太', country: '中国', tier: 'gold', storeCount: 120, monthlyRevenue: 650000, commissionRate: 0.15, contactName: '张伟', contactPhone: '+86-21-5555-6666', status: 'active', joinDate: DateTime(2024, 2, 28)),
      Dealer(id: 'DL-007', name: 'São Paulo Beauty', region: '拉美', country: '巴西', tier: 'bronze', storeCount: 12, monthlyRevenue: 85000, commissionRate: 0.10, contactName: 'Carlos Silva', contactPhone: '+55-11-3456-7890', status: 'active', joinDate: DateTime(2025, 1, 18)),
      Dealer(id: 'DL-008', name: 'Paris Élégance', region: '欧洲', country: '法国', tier: 'silver', storeCount: 30, monthlyRevenue: 195000, commissionRate: 0.12, contactName: 'Sophie Martin', contactPhone: '+33-1-4567-8901', status: 'active', joinDate: DateTime(2024, 8, 1)),
      Dealer(id: 'DL-009', name: 'Moscow Style Pro', region: '欧洲', country: '俄罗斯', tier: 'bronze', storeCount: 15, monthlyRevenue: 95000, commissionRate: 0.10, contactName: 'Ivan Petrov', contactPhone: '+7-495-123-4567', status: 'inactive', joinDate: DateTime(2024, 11, 3)),
      Dealer(id: 'DL-010', name: 'Singapore Elite', region: '亚太', country: '新加坡', tier: 'silver', storeCount: 22, monthlyRevenue: 160000, commissionRate: 0.12, contactName: 'Lee Wei Ming', contactPhone: '+65-6789-0123', status: 'active', joinDate: DateTime(2025, 3, 8)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allDealers = ref.watch(dealersProvider);
    final dealers = allDealers.where((d) {
      if (_selectedTier != 'all' && d.tier != _selectedTier) return false;
      if (_selectedRegion != 'all' && d.region != _selectedRegion) return false;
      return true;
    }).toList();

    final totalRevenue = dealers.fold<double>(0, (s, d) => s + d.monthlyRevenue);
    final activeCount = dealers.where((d) => d.status == 'active').length;
    final goldCount = dealers.where((d) => d.tier == 'gold').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '全球经销商渠道系统', subtitle: '渠道管理与业绩分析'),
          const SizedBox(height: 20),

          // 统计卡片
          Row(
            children: [
              _buildDealerStatCard('活跃经销商', '$activeCount/${dealers.length}', Icons.business, AppTheme.primaryNeonGreen),
              const SizedBox(width: 16),
              _buildDealerStatCard('月渠道营收', '\$${(totalRevenue / 10000).toStringAsFixed(0)}万', Icons.monetization_on, AppTheme.accentNeonCyan),
              const SizedBox(width: 16),
              _buildDealerStatCard('金牌经销商', '$goldCount家', Icons.stars, Color(0xFFFFD700)),
              const SizedBox(width: 16),
              _buildDealerStatCard('覆盖国家', '15国', Icons.language, AppTheme.secondaryNeonPurple),
            ],
          ),
          const SizedBox(height: 24),

          // 筛选栏
          _buildFilterBar(),
          const SizedBox(height: 20),

          // 经销商列表
          AdminDataTable(
            columns: const ['ID', '经销商名称', '区域/国家', '等级', '门店数', '月营收', '佣金率', '状态', '联系人', '操作'],
            rows: dealers.map((d) => [
              Text('#${d.id}', style: const TextStyle(color: AppTheme.accentNeonCyan, fontSize: 12)),
              Text(d.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
              Text('${d.region} · ${d.country}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              StatusBadge(status: d.tier, colorMap: {
                'gold': const Color(0xFFFFD700),
                'silver': const Color(0xFFC0C0C0),
                'bronze': const Color(0xFFCD7F32),
              }),
              Text('${d.storeCount}家', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
              Text('\$${(d.monthlyRevenue / 1000).toStringAsFixed(0)}K', style: TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${(d.commissionRate * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppTheme.secondaryNeonPurple, fontSize: 12)),
              StatusBadge(status: d.status),
              Text('${d.contactName}\n${d.contactPhone}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniButton('详情', () {}),
                  const SizedBox(width: 4),
                  _buildMiniButton('编辑', () {}),
                ],
              ),
            ]).toList(),
          ),
          const SizedBox(height: 24),

          // 经销商支付信息
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildDealerStatCard(String label, String value, IconData icon, Color color) {
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
                Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        const Text('等级：', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ...['all', 'gold', 'silver', 'bronze'].map((t) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: FilterChip(
            label: {'all': '全部', 'gold': '金牌', 'silver': '银牌', 'bronze': '铜牌'}[t]!,
            isSelected: _selectedTier == t,
            onTap: () => setState(() => _selectedTier = t),
          ),
        )),
        const SizedBox(width: 24),
        const Text('区域：', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ...['all', '亚太', '北美', '欧洲', '中东', '拉美'].map((r) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: FilterChip(
            label: r == 'all' ? '全部' : r,
            isSelected: _selectedRegion == r,
            onTap: () => setState(() => _selectedRegion = r),
          ),
        )),
      ],
    );
  }

  Widget _buildMiniButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryNeonGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 11)),
      ),
    );
  }
}
