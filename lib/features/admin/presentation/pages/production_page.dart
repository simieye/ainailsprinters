import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/admin_models.dart';
import '../../../domain/services/admin_providers.dart';
import '../../widgets/admin_common_widgets.dart';
import '../../widgets/payment_integration_widgets.dart';

/// 系统8：生产管理中心
/// 生产工单管理、进度追踪、质检管理、物料库存、产能统计
class ProductionPage extends ConsumerStatefulWidget {
  const ProductionPage({super.key});

  @override
  ConsumerState<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends ConsumerState<ProductionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedWorkOrderStatus = 'all';
  String _selectedProductionLine = 'all';

  static const _tabs = ['工单管理', '生产进度', '质检管理', '物料库存', '产能统计'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadMockData();
  }

  void _loadMockData() {
    ref.read(productionWorkOrdersProvider.notifier).state =
        _mockWorkOrders;
    ref.read(productionLinesProvider.notifier).state = _mockProductionLines;
    ref.read(qualityInspectionsProvider.notifier).state =
        _mockQualityInspections;
    ref.read(materialInventoryProvider.notifier).state = _mockMaterials;
    ref.read(productionCapacityProvider.notifier).state = _mockCapacity;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 统计概览卡片（始终显示）
        _buildStatsOverview(),
        // Tab 导航
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.bgCardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppTheme.gradientCyber,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(3),
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        // Tab 内容
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWorkOrdersTab(),
              _buildProgressTab(),
              _buildQualityTab(),
              _buildInventoryTab(),
              _buildCapacityTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ========== 统计概览 ==========
  Widget _buildStatsOverview() {
    final workOrders = ref.watch(productionWorkOrdersProvider);
    final materials = ref.watch(materialInventoryProvider);
    final capacity = ref.watch(productionCapacityProvider);

    final pendingOrders =
        workOrders.where((w) => w.status == 'pending').length;
    final inProgressOrders =
        workOrders.where((w) => w.status == 'in_progress').length;
    final completedToday =
        workOrders.where((w) => w.status == 'completed').length;
    final lowStockMaterials =
        materials.where((m) => m.status == 'low').length;
    final totalCapacity = capacity.fold<double>(0, (s, c) => s + c.utilization);
    final avgUtilization =
        capacity.isEmpty ? 0 : totalCapacity / capacity.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          _buildOverviewCard('待处理工单', '$pendingOrders', '单', Icons.assignment,
              AppTheme.warningNeonOrange),
          const SizedBox(width: 12),
          _buildOverviewCard('生产中', '$inProgressOrders', '单', Icons.settings,
              const Color(0xFF00E5FF)),
          const SizedBox(width: 12),
          _buildOverviewCard('今日完成', '$completedToday', '单', Icons.check_circle,
              AppTheme.primaryNeonGreen),
          const SizedBox(width: 12),
          _buildOverviewCard('低库存物料', '$lowStockMaterials', '项', Icons.inventory,
              AppTheme.accentNeonPink),
          const SizedBox(width: 12),
          _buildOverviewCard('平均产能利用率', '${avgUtilization.toStringAsFixed(1)}', '%',
              Icons.speed, const Color(0xFFB44CFF)),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String label, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value,
                        style: TextStyle(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(unit,
                          style:
                              TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textHint, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== Tab 1: 工单管理 ==========
  Widget _buildWorkOrdersTab() {
    final allOrders = ref.watch(productionWorkOrdersProvider);
    final orders = _selectedWorkOrderStatus == 'all'
        ? allOrders
        : allOrders.where((o) => o.status == _selectedWorkOrderStatus).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '生产工单管理', subtitle: '创建、分配、追踪生产工单'),
          const SizedBox(height: 12),
          // 筛选栏
          Row(
            children: [
              const Text('状态：',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ..._workOrderStatusFilters.map((f) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: f['label']!,
                      isSelected: _selectedWorkOrderStatus == f['value'],
                      onTap: () => setState(
                          () => _selectedWorkOrderStatus = f['value']!),
                    ),
                  )),
              const Spacer(),
              _buildActionButton('+ 新建工单', AppTheme.primaryNeonGreen, () {}),
              const SizedBox(width: 8),
              _buildActionButton('批量派单', const Color(0xFF00E5FF), () {}),
            ],
          ),
          const SizedBox(height: 16),
          // 工单表格
          _buildWorkOrderTable(orders),
          const SizedBox(height: 24),
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildWorkOrderTable(List<ProductionWorkOrder> orders) {
    return AdminDataTable(
      columns: const [
        '工单号',
        '产品名称',
        '数量',
        '生产线',
        '优先级',
        '计划开始',
        '计划完成',
        '状态',
        '操作'
      ],
      rows: orders.map((o) {
        return [
          Text(o.id, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          Text(o.productName),
          Text('${o.quantity}'),
          Text(o.productionLine),
          _buildPriorityBadge(o.priority),
          Text(
              '${o.plannedStart.month}/${o.plannedStart.day}'),
          Text(
              '${o.plannedEnd.month}/${o.plannedEnd.day}'),
          StatusBadge(status: o.status),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTableAction('详情', AppTheme.primaryNeonGreen, () {}),
              const SizedBox(width: 6),
              _buildTableAction('编辑', const Color(0xFF00E5FF), () {}),
            ],
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final colors = {
      'urgent': AppTheme.accentNeonPink,
      'high': AppTheme.warningNeonOrange,
      'normal': AppTheme.primaryNeonGreen,
      'low': AppTheme.textSecondary,
    };
    final labels = {
      'urgent': '紧急',
      'high': '高',
      'normal': '普通',
      'low': '低',
    };
    final color = colors[priority] ?? AppTheme.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(labels[priority] ?? priority,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  // ========== Tab 2: 生产进度 ==========
  Widget _buildProgressTab() {
    final lines = ref.watch(productionLinesProvider);
    final allOrders = ref.watch(productionWorkOrdersProvider);
    final progressOrders = allOrders
        .where((o) => o.status == 'in_progress' || o.status == 'pending')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '生产进度追踪', subtitle: '实时监控各生产线状态'),
          const SizedBox(height: 16),
          // 产线状态概览
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: lines.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _buildProductionLineCard(lines[index]),
            ),
          ),
          const SizedBox(height: 24),
          // 在产工单进度
          const SectionTitle(title: '在产工单进度', subtitle: '${progressOrders.length} 个工单'),
          const SizedBox(height: 12),
          ...progressOrders.map((o) => _buildProgressCard(o)),
          const SizedBox(height: 24),
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildProductionLineCard(ProductionLine line) {
    final statusColor = {
      'running': AppTheme.primaryNeonGreen,
      'idle': AppTheme.warningNeonOrange,
      'maintenance': const Color(0xFF00E5FF),
      'offline': AppTheme.textHint,
    };
    final statusLabel = {
      'running': '运行中',
      'idle': '空闲',
      'maintenance': '维护中',
      'offline': '离线',
    };
    final color = statusColor[line.status] ?? AppTheme.textHint;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(line.name,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(statusLabel[line.status] ?? line.status,
              style: TextStyle(color: color, fontSize: 11)),
          const SizedBox(height: 12),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: line.currentProgress / 100,
              backgroundColor: AppTheme.bgSurfaceDark,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text('当前工单: ${line.currentOrder}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10)),
          Text('今日产出: ${line.todayOutput} 件',
              style: const TextStyle(
                  color: AppTheme.textHint, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ProductionWorkOrder order) {
    final colors = {
      'urgent': AppTheme.accentNeonPink,
      'high': AppTheme.warningNeonOrange,
      'normal': AppTheme.primaryNeonGreen,
      'low': AppTheme.textSecondary,
    };
    final color = colors[order.priority] ?? AppTheme.textHint;
    final progress = order.status == 'in_progress' ? order.progress : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(order.id,
                        style: const TextStyle(
                            color: AppTheme.primaryNeonGreen,
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Text(order.productName,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildProgressMetric('数量', '${order.quantity}件'),
              const SizedBox(width: 24),
              _buildProgressMetric('产线', order.productionLine),
              const SizedBox(width: 24),
              _buildProgressMetric('优先级', order.priority),
              const Spacer(),
              _buildProgressMetric('进度', '${order.progress.toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: AppTheme.bgSurfaceDark,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textHint, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ========== Tab 3: 质检管理 ==========
  Widget _buildQualityTab() {
    final inspections = ref.watch(qualityInspectionsProvider);
    final totalInspected =
        inspections.fold<int>(0, (s, i) => s + i.totalInspected);
    final totalDefects =
        inspections.fold<int>(0, (s, i) => s + i.defectCount);
    final passRate = totalInspected > 0
        ? ((totalInspected - totalDefects) / totalInspected * 100)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '质检管理', subtitle: '质量检测与缺陷追踪'),
          const SizedBox(height: 16),
          // 质检概览
          Row(
            children: [
              _buildQualityStatCard('总检验数', '$totalInspected', '件', Icons.fact_check,
                  AppTheme.primaryNeonGreen),
              const SizedBox(width: 12),
              _buildQualityStatCard('缺陷数', '$totalDefects', '件', Icons.warning,
                  AppTheme.accentNeonPink),
              const SizedBox(width: 12),
              _buildQualityStatCard('合格率', '${passRate.toStringAsFixed(1)}%', '',
                  Icons.verified, const Color(0xFF00E5FF)),
              const SizedBox(width: 12),
              _buildQualityStatCard('待复检', '${inspections.where((i) => i.status == 'pending_recheck').length}', '批',
                  Icons.replay, AppTheme.warningNeonOrange),
            ],
          ),
          const SizedBox(height: 24),
          // 质检记录表格
          const SectionTitle(title: '质检记录'),
          const SizedBox(height: 12),
          AdminDataTable(
            columns: const [
              '检验单号',
              '工单号',
              '产品名称',
              '检验数',
              '合格数',
              '缺陷数',
              '合格率',
              '检验员',
              '状态',
              '操作'
            ],
            rows: inspections.map((i) {
              final rate =
                  i.totalInspected > 0
                      ? ((i.totalInspected - i.defectCount) /
                              i.totalInspected *
                          100)
                      : 0.0;
              return [
                Text(i.id,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 11)),
                Text(i.workOrderId,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 11)),
                Text(i.productName),
                Text('${i.totalInspected}'),
                Text('${i.totalInspected - i.defectCount}'),
                Text('${i.defectCount}',
                    style: TextStyle(
                        color: i.defectCount > 0
                            ? AppTheme.accentNeonPink
                            : AppTheme.textPrimary)),
                Text('${rate.toStringAsFixed(1)}%',
                    style: TextStyle(
                        color: rate >= 95
                            ? AppTheme.primaryNeonGreen
                            : AppTheme.warningNeonOrange)),
                Text(i.inspector),
                StatusBadge(status: i.status),
                _buildTableAction('详情', AppTheme.primaryNeonGreen, () {}),
              ];
            }).toList(),
          ),
          const SizedBox(height: 24),
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQualityStatCard(
      String label, String value, String unit, IconData icon, Color color) {
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
              width: 44,
              height: 44,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value,
                        style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(unit,
                            style: TextStyle(
                                color: color.withOpacity(0.7), fontSize: 12)),
                      ),
                    ],
                  ],
                ),
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textHint, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== Tab 4: 物料库存 ==========
  Widget _buildInventoryTab() {
    final materials = ref.watch(materialInventoryProvider);
    final lowStockItems = materials.where((m) => m.status == 'low').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '物料库存管理', subtitle: '原材料与耗材库存追踪'),
          const SizedBox(height: 16),
          // 库存预警
          if (lowStockItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentNeonPink.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.accentNeonPink.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: AppTheme.accentNeonPink, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '库存预警：${lowStockItems.length} 项物料库存不足，请及时补货',
                    style: const TextStyle(
                        color: AppTheme.accentNeonPink, fontSize: 12),
                  ),
                  const Spacer(),
                  _buildActionButton(
                      '一键采购', AppTheme.accentNeonPink, () {}),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // 库存表格
          AdminDataTable(
            columns: const [
              '物料编号',
              '物料名称',
              '类别',
              '当前库存',
              '安全库存',
              '单位',
              '供应商',
              '状态',
              '操作'
            ],
            rows: materials.map((m) {
              return [
                Text(m.id,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 11)),
                Text(m.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(m.category),
                Text('${m.currentStock}',
                    style: TextStyle(
                        color: m.currentStock <= m.safetyStock
                            ? AppTheme.accentNeonPink
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
                Text('${m.safetyStock}'),
                Text(m.unit),
                Text(m.supplier),
                StatusBadge(status: m.status),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTableAction(
                        '采购', AppTheme.primaryNeonGreen, () {}),
                    const SizedBox(width: 6),
                    _buildTableAction(
                        '调拨', const Color(0xFF00E5FF), () {}),
                  ],
                ),
              ];
            }).toList(),
          ),
          const SizedBox(height: 24),
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  // ========== Tab 5: 产能统计 ==========
  Widget _buildCapacityTab() {
    final capacity = ref.watch(productionCapacityProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '产能统计与分析', subtitle: '生产线效率与产出分析'),
          const SizedBox(height: 16),
          // 产能卡片
          ...capacity.map((c) => _buildCapacityCard(c)),
          const SizedBox(height: 24),
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  Widget _buildCapacityCard(ProductionCapacity capacity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFB44CFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.precision_manufacturing,
                    color: Color(0xFFB44CFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(capacity.lineName,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text('产能利用率: ${capacity.utilization.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${capacity.monthlyOutput} 件',
                      style: const TextStyle(
                          color: AppTheme.primaryNeonGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const Text('月产出',
                      style: TextStyle(
                          color: AppTheme.textHint, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 利用率进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: capacity.utilization / 100,
              backgroundColor: AppTheme.bgSurfaceDark,
              valueColor: AlwaysStoppedAnimation(
                capacity.utilization > 80
                    ? AppTheme.accentNeonPink
                    : capacity.utilization > 60
                        ? AppTheme.warningNeonOrange
                        : AppTheme.primaryNeonGreen,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildCapacityMetric('日产能', '${capacity.dailyCapacity}件'),
              const SizedBox(width: 32),
              _buildCapacityMetric('月产出', '${capacity.monthlyOutput}件'),
              const SizedBox(width: 32),
              _buildCapacityMetric('良品率', '${capacity.yieldRate.toStringAsFixed(1)}%'),
              const SizedBox(width: 32),
              _buildCapacityMetric('运行时长', '${capacity.runningHours}h/天'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textHint, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ========== 通用组件 ==========
  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTableAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  static const _workOrderStatusFilters = [
    {'label': '全部', 'value': 'all'},
    {'label': '待处理', 'value': 'pending'},
    {'label': '生产中', 'value': 'in_progress'},
    {'label': '已完成', 'value': 'completed'},
    {'label': '已暂停', 'value': 'paused'},
    {'label': '已取消', 'value': 'cancelled'},
  ];
}

// ========== Mock Data ==========

final _mockWorkOrders = [
  ProductionWorkOrder(
      id: 'WO-2026-0891',
      productName: '霓虹幻彩甲片套装',
      quantity: 500,
      productionLine: 'L1-AI印刷线',
      priority: 'urgent',
      plannedStart: DateTime(2026, 7, 20),
      plannedEnd: DateTime(2026, 7, 28),
      status: 'in_progress',
      progress: 65),
  ProductionWorkOrder(
      id: 'WO-2026-0892',
      productName: '星空渐变美甲贴',
      quantity: 1200,
      productionLine: 'L2-激光产线',
      priority: 'high',
      plannedStart: DateTime(2026, 7, 22),
      plannedEnd: DateTime(2026, 7, 30),
      status: 'in_progress',
      progress: 35),
  ProductionWorkOrder(
      id: 'WO-2026-0893',
      productName: '樱花限定套装',
      quantity: 800,
      productionLine: 'L3-3D打印线',
      priority: 'normal',
      plannedStart: DateTime(2026, 7, 25),
      plannedEnd: DateTime(2026, 8, 5),
      status: 'pending',
      progress: 0),
  ProductionWorkOrder(
      id: 'WO-2026-0894',
      productName: '金属质感甲片',
      quantity: 600,
      productionLine: 'L1-AI印刷线',
      priority: 'high',
      plannedStart: DateTime(2026, 7, 28),
      plannedEnd: DateTime(2026, 8, 4),
      status: 'pending',
      progress: 0),
  ProductionWorkOrder(
      id: 'WO-2026-0895',
      productName: '水彩晕染美甲贴',
      quantity: 1500,
      productionLine: 'L2-激光产线',
      priority: 'normal',
      plannedStart: DateTime(2026, 7, 18),
      plannedEnd: DateTime(2026, 7, 26),
      status: 'completed',
      progress: 100),
  ProductionWorkOrder(
      id: 'WO-2026-0896',
      productName: '镭射幻彩套装',
      quantity: 400,
      productionLine: 'L3-3D打印线',
      priority: 'urgent',
      plannedStart: DateTime(2026, 7, 26),
      plannedEnd: DateTime(2026, 8, 1),
      status: 'pending',
      progress: 0),
  ProductionWorkOrder(
      id: 'WO-2026-0897',
      productName: '卡通IP联名款',
      quantity: 2000,
      productionLine: 'L1-AI印刷线',
      priority: 'normal',
      plannedStart: DateTime(2026, 8, 1),
      plannedEnd: DateTime(2026, 8, 10),
      status: 'pending',
      progress: 0),
  ProductionWorkOrder(
      id: 'WO-2026-0898',
      productName: '透明果冻甲片',
      quantity: 300,
      productionLine: 'L4-手工线',
      priority: 'low',
      plannedStart: DateTime(2026, 7, 24),
      plannedEnd: DateTime(2026, 7, 28),
      status: 'paused',
      progress: 40),
  ProductionWorkOrder(
      id: 'WO-2026-0899',
      productName: '婚礼限定套装',
      quantity: 200,
      productionLine: 'L4-手工线',
      priority: 'high',
      plannedStart: DateTime(2026, 7, 15),
      plannedEnd: DateTime(2026, 7, 22),
      status: 'completed',
      progress: 100),
  ProductionWorkOrder(
      id: 'WO-2026-0900',
      productName: '夜光美甲贴',
      quantity: 900,
      productionLine: 'L2-激光产线',
      priority: 'normal',
      plannedStart: DateTime(2026, 7, 27),
      plannedEnd: DateTime(2026, 8, 3),
      status: 'pending',
      progress: 0),
];

final _mockProductionLines = [
  ProductionLine(
      name: 'L1-AI印刷线',
      status: 'running',
      currentProgress: 78,
      currentOrder: 'WO-2026-0891',
      todayOutput: 85),
  ProductionLine(
      name: 'L2-激光产线',
      status: 'running',
      currentProgress: 45,
      currentOrder: 'WO-2026-0892',
      todayOutput: 62),
  ProductionLine(
      name: 'L3-3D打印线',
      status: 'idle',
      currentProgress: 0,
      currentOrder: '等待工单',
      todayOutput: 0),
  ProductionLine(
      name: 'L4-手工线',
      status: 'maintenance',
      currentProgress: 0,
      currentOrder: '维护保养',
      todayOutput: 0),
  ProductionLine(
      name: 'L5-质检包装线',
      status: 'running',
      currentProgress: 92,
      currentOrder: 'WO-2026-0895',
      todayOutput: 120),
];

final _mockQualityInspections = [
  QualityInspection(
      id: 'QC-2026-0151',
      workOrderId: 'WO-2026-0895',
      productName: '水彩晕染美甲贴',
      totalInspected: 500,
      defectCount: 8,
      inspector: '张质检',
      status: 'passed'),
  QualityInspection(
      id: 'QC-2026-0152',
      workOrderId: 'WO-2026-0891',
      productName: '霓虹幻彩甲片套装',
      totalInspected: 200,
      defectCount: 3,
      inspector: '李品控',
      status: 'in_progress'),
  QualityInspection(
      id: 'QC-2026-0153',
      workOrderId: 'WO-2026-0899',
      productName: '婚礼限定套装',
      totalInspected: 200,
      defectCount: 1,
      inspector: '王质检',
      status: 'passed'),
  QualityInspection(
      id: 'QC-2026-0154',
      workOrderId: 'WO-2026-0892',
      productName: '星空渐变美甲贴',
      totalInspected: 150,
      defectCount: 12,
      inspector: '张质检',
      status: 'pending_recheck'),
  QualityInspection(
      id: 'QC-2026-0155',
      workOrderId: 'WO-2026-0898',
      productName: '透明果冻甲片',
      totalInspected: 100,
      defectCount: 5,
      inspector: '赵品控',
      status: 'pending_recheck'),
];

final _mockMaterials = [
  MaterialInventory(
      id: 'MAT-001',
      name: 'UV光固化树脂',
      category: '原材料',
      currentStock: 250,
      safetyStock: 500,
      unit: 'kg',
      supplier: '3M中国',
      status: 'low'),
  MaterialInventory(
      id: 'MAT-002',
      name: '彩色颜料粉',
      category: '原材料',
      currentStock: 1800,
      safetyStock: 1000,
      unit: 'kg',
      supplier: '巴斯夫',
      status: 'normal'),
  MaterialInventory(
      id: 'MAT-003',
      name: '甲片基材(透明)',
      category: '半成品',
      currentStock: 50000,
      safetyStock: 20000,
      unit: '片',
      supplier: '台塑集团',
      status: 'normal'),
  MaterialInventory(
      id: 'MAT-004',
      name: '镭射覆膜',
      category: '辅料',
      currentStock: 300,
      safetyStock: 800,
      unit: '卷',
      supplier: '杜邦',
      status: 'low'),
  MaterialInventory(
      id: 'MAT-005',
      name: '包装盒套装',
      category: '包装',
      currentStock: 8000,
      safetyStock: 5000,
      unit: '套',
      supplier: '裕同科技',
      status: 'normal'),
  MaterialInventory(
      id: 'MAT-006',
      name: '纳米防护涂层',
      category: '原材料',
      currentStock: 120,
      safetyStock: 300,
      unit: 'L',
      supplier: '汉高',
      status: 'low'),
  MaterialInventory(
      id: 'MAT-007',
      name: 'UV灯管',
      category: '设备备件',
      currentStock: 45,
      safetyStock: 30,
      unit: '个',
      supplier: '飞利浦',
      status: 'normal'),
  MaterialInventory(
      id: 'MAT-008',
      name: '打印喷头',
      category: '设备备件',
      currentStock: 12,
      safetyStock: 20,
      unit: '个',
      supplier: '精工',
      status: 'low'),
];

final _mockCapacity = [
  ProductionCapacity(
      lineName: 'L1-AI印刷线',
      utilization: 78.5,
      dailyCapacity: 120,
      monthlyOutput: 2850,
      yieldRate: 97.2,
      runningHours: 20),
  ProductionCapacity(
      lineName: 'L2-激光产线',
      utilization: 65.3,
      dailyCapacity: 100,
      monthlyOutput: 2100,
      yieldRate: 95.8,
      runningHours: 18),
  ProductionCapacity(
      lineName: 'L3-3D打印线',
      utilization: 42.0,
      dailyCapacity: 60,
      monthlyOutput: 850,
      yieldRate: 93.5,
      runningHours: 14),
  ProductionCapacity(
      lineName: 'L4-手工线',
      utilization: 55.8,
      dailyCapacity: 40,
      monthlyOutput: 720,
      yieldRate: 99.1,
      runningHours: 12),
  ProductionCapacity(
      lineName: 'L5-质检包装线',
      utilization: 88.2,
      dailyCapacity: 200,
      monthlyOutput: 4200,
      yieldRate: 99.8,
      runningHours: 22),
];
