import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../widgets/payment_integration_widgets.dart';
import '../../../domain/models/admin_models.dart';
import '../../../domain/services/admin_providers.dart';
import '../../widgets/admin_common_widgets.dart';

/// 系统2：技术维护管理员Tim系统
/// 工单管理、设备监控、OTA更新、故障诊断、知识库
class TechSupportPage extends ConsumerStatefulWidget {
  const TechSupportPage({super.key});

  @override
  ConsumerState<TechSupportPage> createState() => _TechSupportPageState();
}

class _TechSupportPageState extends ConsumerState<TechSupportPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    ref.read(supportTicketsProvider.notifier).state = [
      SupportTicket(
        id: 'TK-001', storeId: 'ST-001', storeName: '东京旗舰店',
        deviceId: 'DEV-1000', issueType: '打印模糊', severity: 'medium',
        description: 'CMYK墨盒M色打印出现条纹，需要校准', status: 'open',
        assignedTo: 'Tim-工程师A', createdAt: now.subtract(const Duration(hours: 2)),
      ),
      SupportTicket(
        id: 'TK-002', storeId: 'ST-002', storeName: '首尔明洞店',
        deviceId: 'DEV-1001', issueType: '设备无法启动', severity: 'critical',
        description: '开机后屏幕无显示，电源灯闪烁', status: 'in_progress',
        assignedTo: 'Tim-工程师B', createdAt: now.subtract(const Duration(hours: 5)),
      ),
      SupportTicket(
        id: 'TK-003', storeId: 'ST-003', storeName: '上海南京路店',
        deviceId: 'DEV-1002', issueType: '网络连接异常', severity: 'high',
        description: '设备频繁断网，影响订单接收', status: 'in_progress',
        assignedTo: 'Tim-工程师C', createdAt: now.subtract(const Duration(hours: 8)),
      ),
      SupportTicket(
        id: 'TK-004', storeId: 'ST-004', storeName: '纽约时代广场店',
        deviceId: 'DEV-1003', issueType: '软件更新', severity: 'low',
        description: '申请固件OTA升级到v3.2.1', status: 'resolved',
        assignedTo: 'Tim-工程师A', createdAt: now.subtract(const Duration(days: 1)),
        resolvedAt: now.subtract(const Duration(hours: 12)),
      ),
      SupportTicket(
        id: 'TK-005', storeId: 'ST-005', storeName: '伦敦牛津街店',
        deviceId: 'DEV-1004', issueType: '打印头过热', severity: 'high',
        description: '连续打印后打印头温度超过警戒值', status: 'open',
        assignedTo: 'Tim-工程师B', createdAt: now.subtract(const Duration(hours: 1)),
      ),
      SupportTicket(
        id: 'TK-006', storeId: 'ST-006', storeName: '迪拜MALL店',
        deviceId: 'DEV-1005', issueType: '耗材不足', severity: 'medium',
        description: 'M色墨盒剩余不足10%', status: 'open',
        assignedTo: 'Tim-工程师C', createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(supportTicketsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '技术维护管理员Tim', subtitle: '设备运维与技术支持'),
          const SizedBox(height: 20),

          // Tab切换
          _buildTabBar(),
          const SizedBox(height: 24),

          // Tab内容
          IndexedStack(
            index: _selectedTab,
            children: [
              _buildTicketDashboard(tickets),
              _buildDeviceMonitor(),
              _buildOtaManagement(),
              _buildKnowledgeBase(),
            ],
          ),
          const SizedBox(height: 24),

          // 支付快捷入口
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = ['工单管理', '设备监控', 'OTA更新', '知识库'];
    const icons = [Icons.support_agent, Icons.monitor_heart, Icons.system_update, Icons.menu_book];
    return Row(
      children: List.generate(4, (i) {
        final isSelected = _selectedTab == i;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryNeonGreen.withOpacity(0.1) : AppTheme.bgCardDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryNeonGreen.withOpacity(0.4) : AppTheme.borderGlow.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(icons[i], size: 16, color: isSelected ? AppTheme.primaryNeonGreen : AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(tabs[i], style: TextStyle(
                    color: isSelected ? AppTheme.primaryNeonGreen : AppTheme.textSecondary,
                    fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  )),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ===== 工单管理 =====
  Widget _buildTicketDashboard(List<SupportTicket> tickets) {
    final openCount = tickets.where((t) => t.status == 'open').length;
    final inProgress = tickets.where((t) => t.status == 'in_progress').length;
    final resolved = tickets.where((t) => t.status == 'resolved').length;
    final critical = tickets.where((t) => t.severity == 'critical').length;

    return Column(
      children: [
        // 工单统计
        Row(
          children: [
            _buildTicketStatCard('待处理', '$openCount', Icons.pending_actions, AppTheme.warningNeonOrange),
            const SizedBox(width: 16),
            _buildTicketStatCard('处理中', '$inProgress', Icons.sync, AppTheme.accentNeonCyan),
            const SizedBox(width: 16),
            _buildTicketStatCard('已解决', '$resolved', Icons.check_circle, AppTheme.primaryNeonGreen),
            const SizedBox(width: 16),
            _buildTicketStatCard('紧急', '$critical', Icons.warning_amber, AppTheme.accentNeonPink),
          ],
        ),
        const SizedBox(height: 24),

        // 工单列表
        AdminDataTable(
          columns: const ['工单ID', '门店', '问题类型', '严重级别', '状态', '负责人', '创建时间', '操作'],
          rows: tickets.map((t) => [
            Text('#${t.id}', style: const TextStyle(color: AppTheme.accentNeonCyan, fontSize: 12)),
            Text(t.storeName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
            Text(t.issueType, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            StatusBadge(status: t.severity, colorMap: {
              'critical': AppTheme.accentNeonPink,
              'high': AppTheme.warningNeonOrange,
              'medium': AppTheme.accentNeonCyan,
              'low': AppTheme.textSecondary,
            }),
            StatusBadge(status: t.status),
            Text(t.assignedTo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text(_formatTime(t.createdAt), style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(Icons.visibility, '查看', () {}),
                const SizedBox(width: 4),
                _buildActionButton(Icons.edit, '处理', () {}),
                if (t.status != 'resolved') ...[
                  const SizedBox(width: 4),
                  _buildActionButton(Icons.check, '解决', () {}),
                ],
              ],
            ),
          ]).toList(),
        ),
      ],
    );
  }

  Widget _buildTicketStatCard(String label, String count, IconData icon, Color color) {
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.bgSurfaceDark,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppTheme.textSecondary),
      ),
    );
  }

  // ===== 设备监控 =====
  Widget _buildDeviceMonitor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('全局设备健康概览', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final stores = ['东京旗舰店', '首尔明洞店', '上海南京路店', '纽约时代广场店', '伦敦牛津街店', '迪拜MALL店'];
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
                      Text(stores[index], style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      Container(width: 8, height: 8, decoration: BoxDecoration(
                        color: AppTheme.primaryNeonGreen, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.primaryNeonGreen.withOpacity(0.5), blurRadius: 6)],
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDeviceMetric('CPU使用率', '${35 + index * 5}%', (35 + index * 5) / 100, AppTheme.accentNeonCyan),
                  _buildDeviceMetric('内存使用率', '${45 + index * 3}%', (45 + index * 3) / 100, AppTheme.secondaryNeonPurple),
                  _buildDeviceMetric('打印头温度', '${42 + index}°C', (42 + index) / 80, AppTheme.warningNeonOrange),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeviceMetric(String label, String value, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 11))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.bgSurfaceDark,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 40, child: Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ===== OTA更新管理 =====
  Widget _buildOtaManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('固件OTA升级管理', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.bgCardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildOtaVersionCard('v3.2.1', '稳定版', '2025-06-01', '已推送至 2,840 台设备', true),
              _buildOtaVersionCard('v3.3.0-beta', '测试版', '2025-05-28', '灰度测试中 (120台)', false),
              _buildOtaVersionCard('v3.2.0', '稳定版', '2025-05-15', '已全量部署', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtaVersionCard(String version, String type, String date, String status, bool isLatest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLatest ? AppTheme.primaryNeonGreen.withOpacity(0.05) : AppTheme.bgSurfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLatest ? AppTheme.primaryNeonGreen.withOpacity(0.2) : AppTheme.borderGlow.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isLatest ? AppTheme.primaryNeonGreen.withOpacity(0.1) : AppTheme.bgSurfaceDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.system_update, color: isLatest ? AppTheme.primaryNeonGreen : AppTheme.textSecondary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(version, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    StatusBadge(status: type, colorMap: {
                      '稳定版': AppTheme.primaryNeonGreen,
                      '测试版': AppTheme.warningNeonOrange,
                    }),
                    if (isLatest) ...[
                      const SizedBox(width: 8),
                      const StatusBadge(status: 'LATEST'),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text('$date · $status', style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              ],
            ),
          ),
          if (isLatest)
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cloud_upload, size: 14),
              label: const Text('推送更新'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeonGreen,
                foregroundColor: AppTheme.bgDeepDark,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: const TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  // ===== 知识库 =====
  Widget _buildKnowledgeBase() {
    final articles = [
      _KbArticle('常见打印问题排查指南', '故障排查', '已发布', 15234),
      _KbArticle('CMYK墨盒更换标准流程', '操作指南', '已发布', 12890),
      _KbArticle('设备网络配置最佳实践', '部署指南', '已发布', 9876),
      _KbArticle('OTA固件升级安全规范', '安全规范', '已发布', 7654),
      _KbArticle('打印头清洁与保养手册', '维护手册', '已发布', 6543),
      _KbArticle('v3.2.1 版本发布说明', '版本说明', '草稿', 0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('技术知识库', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600))),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 14),
              label: const Text('新建文章'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeonGreen,
                foregroundColor: AppTheme.bgDeepDark,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...articles.map((a) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryNeonPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.article, color: AppTheme.secondaryNeonPurple, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusBadge(status: a.category),
                        const SizedBox(width: 8),
                        StatusBadge(status: a.status),
                        if (a.views > 0) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.visibility, size: 12, color: AppTheme.textHint),
                          const SizedBox(width: 4),
                          Text('${a.views}', style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                color: AppTheme.textSecondary,
                onPressed: () {},
              ),
            ],
          ),
        )),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

class _KbArticle {
  final String title;
  final String category;
  final String status;
  final int views;
  const _KbArticle(this.title, this.category, this.status, this.views);
}
