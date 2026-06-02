import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/admin_models.dart';
import '../../../domain/services/admin_providers.dart';
import '../../widgets/admin_common_widgets.dart';
import '../../widgets/payment_integration_widgets.dart';

/// 系统5：终端个人用户系统
/// 用户管理、会员体系、消费分析、行为画像
class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  String _selectedLevel = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    ref.read(endUsersProvider.notifier).state = [
      EndUser(id: 'US-001', nickname: 'NailArtist_Lisa', email: 'lisa@email.com', country: '日本', totalDesigns: 256, totalOrders: 89, totalSpent: 4560, memberLevel: 'diamond', status: 'active', registerDate: DateTime(2024, 3, 1), lastActive: now.subtract(const Duration(hours: 1))),
      EndUser(id: 'US-002', nickname: 'BeautyQueen_Min', email: 'min@email.com', country: '韩国', totalDesigns: 198, totalOrders: 67, totalSpent: 3350, memberLevel: 'gold', status: 'active', registerDate: DateTime(2024, 5, 15), lastActive: now.subtract(const Duration(hours: 3))),
      EndUser(id: 'US-003', nickname: 'NYC_NailLover', email: 'nycnail@email.com', country: '美国', totalDesigns: 145, totalOrders: 52, totalSpent: 2800, memberLevel: 'gold', status: 'active', registerDate: DateTime(2024, 2, 20), lastActive: now.subtract(const Duration(minutes: 30))),
      EndUser(id: 'US-004', nickname: 'Shanghai_Chic', email: 'shchic@email.com', country: '中国', totalDesigns: 312, totalOrders: 120, totalSpent: 6200, memberLevel: 'diamond', status: 'active', registerDate: DateTime(2024, 1, 10), lastActive: now.subtract(const Duration(hours: 2))),
      EndUser(id: 'US-005', nickname: 'LondonGlam', email: 'ldnglam@email.com', country: '英国', totalDesigns: 87, totalOrders: 34, totalSpent: 1780, memberLevel: 'silver', status: 'active', registerDate: DateTime(2024, 8, 5), lastActive: now.subtract(const Duration(days: 1))),
      EndUser(id: 'US-006', nickname: 'DubaiRoyal', email: 'dxb@email.com', country: '阿联酋', totalDesigns: 210, totalOrders: 78, totalSpent: 4100, memberLevel: 'gold', status: 'active', registerDate: DateTime(2024, 6, 18), lastActive: now.subtract(const Duration(hours: 5))),
      EndUser(id: 'US-007', nickname: 'ParisArtiste', email: 'paris@email.com', country: '法国', totalDesigns: 56, totalOrders: 18, totalSpent: 920, memberLevel: 'bronze', status: 'active', registerDate: DateTime(2025, 1, 20), lastActive: now.subtract(const Duration(days: 2))),
      EndUser(id: 'US-008', nickname: 'RioSamba', email: 'rio@email.com', country: '巴西', totalDesigns: 34, totalOrders: 12, totalSpent: 580, memberLevel: 'bronze', status: 'active', registerDate: DateTime(2025, 3, 8), lastActive: now.subtract(const Duration(hours: 12))),
      EndUser(id: 'US-009', nickname: 'SpamAccount_01', email: 'spam01@email.com', country: '未知', totalDesigns: 0, totalOrders: 0, totalSpent: 0, memberLevel: 'bronze', status: 'banned', registerDate: DateTime(2025, 4, 1), lastActive: DateTime(2025, 4, 2)),
      EndUser(id: 'US-010', nickname: 'InactiveUser_X', email: 'inactive@email.com', country: '俄罗斯', totalDesigns: 12, totalOrders: 3, totalSpent: 150, memberLevel: 'bronze', status: 'inactive', registerDate: DateTime(2024, 12, 5), lastActive: DateTime(2025, 3, 15)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(endUsersProvider);
    final users = allUsers.where((u) {
      if (_selectedLevel != 'all' && u.memberLevel != _selectedLevel) return false;
      if (_selectedStatus != 'all' && u.status != _selectedStatus) return false;
      return true;
    }).toList();

    final totalSpent = users.fold<double>(0, (s, u) => s + u.totalSpent);
    final activeUsers = users.where((u) => u.status == 'active').length;
    final diamondUsers = users.where((u) => u.memberLevel == 'diamond').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '终端个人用户系统', subtitle: '用户管理与会员体系'),
          const SizedBox(height: 20),

          // 用户统计
          Row(
            children: [
              _buildUserStatCard('用户总数', '${users.length}', Icons.people, AppTheme.primaryNeonGreen),
              const SizedBox(width: 16),
              _buildUserStatCard('活跃用户', '$activeUsers', Icons.person, AppTheme.accentNeonCyan),
              const SizedBox(width: 16),
              _buildUserStatCard('钻石会员', '$diamondUsers', Icons.diamond, AppTheme.accentNeonPink),
              const SizedBox(width: 16),
              _buildUserStatCard('总消费额', '\$${(totalSpent / 10000).toStringAsFixed(1)}万', Icons.monetization_on, AppTheme.secondaryNeonPurple),
            ],
          ),
          const SizedBox(height: 24),

          // 会员等级分布
          _buildMemberLevelDistribution(allUsers),
          const SizedBox(height: 24),

          // 筛选
          Row(
            children: [
              const Text('等级：', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ...['all', 'diamond', 'gold', 'silver', 'bronze'].map((l) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: {'all': '全部', 'diamond': '钻石', 'gold': '金牌', 'silver': '银牌', 'bronze': '铜牌'}[l]!,
                  isSelected: _selectedLevel == l,
                  onTap: () => setState(() => _selectedLevel = l),
                ),
              )),
              const SizedBox(width: 24),
              const Text('状态：', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ...['all', 'active', 'inactive', 'banned'].map((s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: {'all': '全部', 'active': '活跃', 'inactive': '不活跃', 'banned': '已封禁'}[s]!,
                  isSelected: _selectedStatus == s,
                  onTap: () => setState(() => _selectedStatus = s),
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),

          // 用户表格
          AdminDataTable(
            columns: const ['ID', '昵称', '国家', '会员等级', '设计数', '订单数', '总消费', '状态', '注册日期', '最后活跃', '操作'],
            rows: users.map((u) => [
              Text('#${u.id}', style: const TextStyle(color: AppTheme.accentNeonCyan, fontSize: 12)),
              Text(u.nickname, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
              Text(u.country, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              StatusBadge(status: u.memberLevel),
              Text('${u.totalDesigns}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
              Text('${u.totalOrders}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
              Text('\$${u.totalSpent.toStringAsFixed(0)}', style: TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              StatusBadge(status: u.status),
              Text(_formatDate(u.registerDate), style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              Text(_formatDate(u.lastActive), style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniButton('详情', () {}),
                  const SizedBox(width: 4),
                  if (u.status == 'active')
                    _buildMiniButtonDanger('封禁', () {}),
                ],
              ),
            ]).toList(),
          ),
          const SizedBox(height: 24),

          // 用户支付快捷入口
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildUserStatCard(String label, String value, IconData icon, Color color) {
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
                Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberLevelDistribution(List<EndUser> allUsers) {
    final levels = ['diamond', 'gold', 'silver', 'bronze'];
    final colors = {
      'diamond': const Color(0xFF00E5FF),
      'gold': const Color(0xFFFFD700),
      'silver': const Color(0xFFC0C0C0),
      'bronze': const Color(0xFFCD7F32),
    };
    final labels = {
      'diamond': '钻石会员',
      'gold': '金牌会员',
      'silver': '银牌会员',
      'bronze': '铜牌会员',
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '会员等级分布'),
          const SizedBox(height: 16),
          Row(
            children: levels.map((level) {
              final count = allUsers.where((u) => u.memberLevel == level).length;
              final total = allUsers.length;
              final pct = total > 0 ? count / total : 0.0;
              final color = colors[level]!;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text('$count', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(labels[level]!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('${(pct * 100).toStringAsFixed(1)}%', style: const TextStyle(color: AppTheme.textHint, fontSize: 10)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
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

  Widget _buildMiniButtonDanger(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentNeonPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: const TextStyle(color: AppTheme.accentNeonPink, fontSize: 11)),
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
