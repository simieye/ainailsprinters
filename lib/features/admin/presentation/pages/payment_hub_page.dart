import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/models/payment_models.dart';
import '../../domain/services/payment_providers.dart';
import '../widgets/admin_common_widgets.dart';

/// 全球支付中枢 — Payment Hub 仪表盘
class PaymentHubPage extends ConsumerStatefulWidget {
  const PaymentHubPage({super.key});

  @override
  ConsumerState<PaymentHubPage> createState() => _PaymentHubPageState();
}

class _PaymentHubPageState extends ConsumerState<PaymentHubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    '概览', '交易流水', '网关管理', 'SaaS订阅', '代理结算', '发票管理',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(),
              _TransactionsTab(),
              _GatewaysTab(),
              _SubscriptionsTab(),
              _SettlementsTab(),
              _InvoicesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.bgCardDark,
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorColor: AppTheme.primaryNeonGreen,
        indicatorWeight: 2,
        labelColor: AppTheme.primaryNeonGreen,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// ============================================================
// Tab 1: 概览
// ============================================================
class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(paymentSummaryProvider);
    final trend = ref.watch(paymentTrendProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI 卡片行
          Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  title: '今日营收',
                  value: '${Currency.cny.symbol}${_fmt(summary.todayRevenue)}',
                  subtitle: '实时更新',
                  icon: Icons.today,
                  iconColor: AppTheme.primaryNeonGreen,
                  growth: 12.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStatCard(
                  title: '本月营收',
                  value: '${Currency.cny.symbol}${_fmtW(summary.monthlyRevenue)}',
                  subtitle: '环比增长',
                  icon: Icons.calendar_month,
                  iconColor: AppTheme.primaryNeonGreen,
                  growth: 23.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStatCard(
                  title: 'MRR',
                  value: '${Currency.cny.symbol}${_fmtW(summary.monthlyRecurringRevenue)}',
                  subtitle: '${summary.activeSubscriptions} 活跃订阅',
                  icon: Icons.repeat,
                  iconColor: const Color(0xFF00E5FF),
                  growth: 8.3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStatCard(
                  title: '佣金支出',
                  value: '${Currency.cny.symbol}${_fmtW(summary.totalCommission)}',
                  subtitle: '待结算 ${_fmtW(summary.pendingSettlement)}',
                  icon: Icons.account_balance,
                  iconColor: const Color(0xFFB44CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 第二行 KPI
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: '30日支付趋势'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppTheme.borderGlow.withOpacity(0.1),
                                strokeWidth: 0.5,
                              ),
                            ),
                            titlesData: const FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            minY: 0,
                            lineBarsData: [
                              LineChartBarData(
                                spots: trend.asMap().entries.map((e) {
                                  return FlSpot(e.key.toDouble(), e.value.revenue / 1000);
                                }).toList(),
                                isCurved: true,
                                color: AppTheme.primaryNeonGreen,
                                barWidth: 2.5,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppTheme.primaryNeonGreen.withOpacity(0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: '支付成功率'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: summary.successRate,
                                color: AppTheme.primaryNeonGreen,
                                title: '${summary.successRate.toStringAsFixed(1)}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
                                ),
                                radius: 55,
                              ),
                              PieChartSectionData(
                                value: 100 - summary.successRate,
                                color: AppTheme.accentNeonPink.withOpacity(0.3),
                                title: '',
                                radius: 45,
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _legendDot(AppTheme.primaryNeonGreen, '成功 ${summary.successRate.toStringAsFixed(1)}%'),
                          _legendDot(AppTheme.accentNeonPink, '失败 ${(100 - summary.successRate).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 支付方式分布 & 场景分布
          Row(
            children: [
              Expanded(
                child: _BarChartCard(
                  title: '支付方式分布',
                  data: summary.gatewayDistribution,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BarChartCard(
                  title: '支付场景分布',
                  data: summary.sceneDistribution,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BarChartCard(
                  title: '结算币种分布',
                  data: summary.currencyDistribution,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 关键指标行
          Row(
            children: [
              Expanded(child: _metricCard('总交易笔数', '${summary.totalTransactions}', Icons.receipt_long, const Color(0xFF00E5FF))),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('客单价', '${Currency.cny.symbol}${summary.avgOrderValue.toStringAsFixed(1)}', Icons.shopping_bag, const Color(0xFFFF8C00))),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('退款率', '${summary.refundRate}%', Icons.undo, const Color(0xFFFF2D95))),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('活跃订阅', '${summary.activeSubscriptions}', Icons.card_membership, const Color(0xFFB44CFF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
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
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0);
  String _fmtW(double v) {
    if (v >= 10000) return '${(v / 10000).toStringAsFixed(1)}万';
    return v.toStringAsFixed(0);
  }
}

/// 简易柱状图卡片
class _BarChartCard extends StatelessWidget {
  final String title;
  final Map<String, double> data;

  const _BarChartCard({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = entries.map((e) => e.value).reduce(max);
    final colors = [
      AppTheme.primaryNeonGreen,
      const Color(0xFF00E5FF),
      const Color(0xFFB44CFF),
      const Color(0xFFFF8C00),
      const Color(0xFFFF2D95),
      const Color(0xFFFFD700),
      const Color(0xFF00FF88),
    ];

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
          SectionTitle(title: title),
          const SizedBox(height: 12),
          ...entries.asMap().entries.map((e) {
            final i = e.key;
            final entry = e.value;
            final pct = entry.value / maxVal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      Text('${entry.value.toStringAsFixed(1)}%',
                          style: TextStyle(color: colors[i % colors.length], fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppTheme.bgSurfaceDark,
                      color: colors[i % colors.length],
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// Tab 2: 交易流水
// ============================================================
class _TransactionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final gatewayFilter = ref.watch(paymentGatewayFilterProvider);
    final sceneFilter = ref.watch(paymentSceneFilterProvider);
    final statusFilter = ref.watch(paymentStatusFilterProvider);
    final currencyFilter = ref.watch(paymentCurrencyFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 筛选行
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterRow(
                label: '支付方式',
                value: gatewayFilter,
                items: const ['all', 'wechatPay', 'alipay', 'stripe', 'paypal', 'bankTransfer', 'usdt', 'btc'],
                labels: const ['全部', '微信支付', '支付宝', 'Stripe', 'PayPal', '对公转账', 'USDT', 'BTC'],
                onChanged: (v) => ref.read(paymentGatewayFilterProvider.notifier).state = v,
              ),
              _buildFilterRow(
                label: '场景',
                value: sceneFilter,
                items: const ['all', 'deviceSale', 'saasSubscription', 'aiServiceFee', 'franchiseFee', 'storePurchase'],
                labels: const ['全部', '设备销售', 'SaaS订阅', 'AI服务费', '加盟费', '门店采购'],
                onChanged: (v) => ref.read(paymentSceneFilterProvider.notifier).state = v,
              ),
              _buildFilterRow(
                label: '状态',
                value: statusFilter,
                items: const ['all', 'completed', 'pending', 'processing', 'failed', 'refunded'],
                labels: const ['全部', '已完成', '待支付', '处理中', '失败', '已退款'],
                onChanged: (v) => ref.read(paymentStatusFilterProvider.notifier).state = v,
              ),
              _buildFilterRow(
                label: '币种',
                value: currencyFilter,
                items: const ['all', 'cny', 'usd', 'eur', 'gbp', 'usdt', 'btc'],
                labels: const ['全部', 'CNY', 'USD', 'EUR', 'GBP', 'USDT', 'BTC'],
                onChanged: (v) => ref.read(paymentCurrencyFilterProvider.notifier).state = v,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 汇总
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.bgCardDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text('共 ${transactions.length} 笔交易',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(width: 16),
                Text('总金额: ${Currency.cny.symbol}${_fmtTotal(transactions)}',
                    style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 交易表格
          Expanded(
            child: AdminDataTable(
              columns: const ['交易ID', '订单号', '支付方式', '场景', '币种', '金额', '结算金额', '状态', '时间', '付款方'],
              rows: transactions.take(50).map((tx) => [
                Text(tx.transactionId, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                Text(tx.orderId, style: const TextStyle(fontSize: 11)),
                _gatewayBadge(tx.gateway),
                Text(tx.scene.displayName, style: const TextStyle(fontSize: 12)),
                Text(tx.currency.symbol, style: const TextStyle(fontSize: 12, color: AppTheme.primaryNeonGreen)),
                Text(_fmtAmt(tx.amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(tx.settlementAmount != null
                    ? '${Currency.cny.symbol}${tx.settlementAmount!.toStringAsFixed(0)}'
                    : '-',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                StatusBadge(status: tx.status.name),
                Text('${tx.createdAt.month}/${tx.createdAt.day} ${tx.createdAt.hour}:${tx.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                Text(tx.payerName ?? '-', style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
              ]).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gatewayBadge(PaymentGateway gw) {
    Color c;
    switch (gw.category) {
      case 'China': c = const Color(0xFFFF2D95); break;
      case 'Global': c = const Color(0xFF00E5FF); break;
      case 'Digital Wallet': c = const Color(0xFFB44CFF); break;
      case 'Crypto': c = const Color(0xFFFFD700); break;
      default: c = AppTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(gw.displayName, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildFilterRow({
    required String label,
    required String value,
    required List<String> items,
    required List<String> labels,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
        DropdownButton<String>(
          value: value,
          isDense: true,
          underline: const SizedBox(),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
          dropdownColor: AppTheme.bgCardDark,
          items: List.generate(items.length, (i) {
            return DropdownMenuItem(value: items[i], child: Text(labels[i]));
          }),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  String _fmtAmt(double v) {
    if (v >= 10000) return '${(v / 10000).toStringAsFixed(1)}万';
    return v.toStringAsFixed(2);
  }

  String _fmtTotal(List<PaymentTransaction> txs) {
    final total = txs.where((t) => t.status == PaymentStatus.completed).fold<double>(0, (sum, t) {
      if (t.settlementAmount != null) return sum + t.settlementAmount!;
      return sum + t.amount * t.exchangeRate;
    });
    if (total >= 10000) return '${(total / 10000).toStringAsFixed(1)}万';
    return total.toStringAsFixed(0);
  }
}

// ============================================================
// Tab 3: 网关管理
// ============================================================
class _GatewaysTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(gatewayConfigsProvider);

    final categories = ['China', 'Global', 'Digital Wallet', 'Crypto'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((cat) {
          final catConfigs = configs.where((c) => c.gateway.category == cat).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: _catLabel(cat),
                subtitle: '${catConfigs.where((c) => c.enabled).length}/${catConfigs.length} 已启用',
              ),
              ...catConfigs.map((cfg) => _buildGatewayCard(cfg)),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGatewayCard(GatewayConfig cfg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cfg.enabled
              ? AppTheme.primaryNeonGreen.withOpacity(0.3)
              : AppTheme.borderGlow.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // 网关图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (cfg.enabled ? AppTheme.primaryNeonGreen : AppTheme.textHint).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _gatewayIcon(cfg.gateway),
              color: cfg.enabled ? AppTheme.primaryNeonGreen : AppTheme.textHint,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(cfg.gateway.displayName,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    StatusBadge(status: cfg.enabled ? 'active' : 'inactive'),
                    const SizedBox(width: 8),
                    if (cfg.status == 'maintenance')
                      StatusBadge(status: 'warning'),
                  ],
                ),
                const SizedBox(height: 6),
                Text('手续费: ${cfg.feeRate}%  |  日交易: ${cfg.dailyVolume}笔  |  日营收: ${Currency.cny.symbol}${(cfg.dailyRevenue / 10000).toStringAsFixed(1)}万',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                Text('支持币种: ${cfg.supportedCurrencies.map((c) => c.name).join(', ')}',
                    style: const TextStyle(color: AppTheme.textHint, fontSize: 10)),
              ],
            ),
          ),
          // 操作
          PopupMenuButton<String>(
            color: AppTheme.bgCardDark,
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 18),
            onSelected: (action) {
              // TODO: 实现网关操作
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('编辑配置', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
              const PopupMenuItem(value: 'toggle', child: Text(cfg.enabled ? '暂停' : '启用', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
              const PopupMenuItem(value: 'webhook', child: Text('Webhook测试', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
              const PopupMenuItem(value: 'logs', child: Text('查看日志', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }

  IconData _gatewayIcon(PaymentGateway gw) {
    switch (gw) {
      case PaymentGateway.wechatPay: return Icons.chat_bubble;
      case PaymentGateway.alipay: return Icons.account_balance_wallet;
      case PaymentGateway.bankTransfer: return Icons.account_balance;
      case PaymentGateway.stripe: return Icons.credit_card;
      case PaymentGateway.paypal: return Icons.monetization_on;
      case PaymentGateway.checkoutCom: return Icons.shopping_cart_checkout;
      case PaymentGateway.adyen: return Icons.payment;
      case PaymentGateway.applePay: return Icons.apple;
      case PaymentGateway.googlePay: return Icons.android;
      case PaymentGateway.samsungPay: return Icons.phone_android;
      case PaymentGateway.venmo: return Icons.person;
      case PaymentGateway.cashApp: return Icons.attach_money;
      case PaymentGateway.usdt: case PaymentGateway.usdc: return Icons.token;
      case PaymentGateway.btc: return Icons.currency_bitcoin;
      case PaymentGateway.eth: return Icons.diamond;
      case PaymentGateway.opcToken: return Icons.workspace_premium;
    }
  }

  String _catLabel(String cat) {
    switch (cat) {
      case 'China': return '🇨🇳 中国支付';
      case 'Global': return '🌍 全球信用卡支付';
      case 'Digital Wallet': return '📱 数字钱包';
      case 'Crypto': return '₿ 数字货币支付';
      default: return cat;
    }
  }
}

// ============================================================
// Tab 4: SaaS订阅管理
// ============================================================
class _SubscriptionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final activeCount = ref.watch(activeSubscriptionsCountProvider);
    final mrr = ref.watch(mrrProvider);

    final tiers = SubscriptionTier.values;
    final tierCounts = <SubscriptionTier, int>{};
    for (final t in tiers) {
      tierCounts[t] = subscriptions.where((s) => s.tier == t && s.status == 'active').length;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 订阅统计卡片
          Row(
            children: [
              _subStatCard('活跃订阅', '$activeCount', Icons.card_membership, AppTheme.primaryNeonGreen),
              const SizedBox(width: 12),
              _subStatCard('MRR', '${Currency.cny.symbol}${(mrr / 10000).toStringAsFixed(1)}万', Icons.trending_up, const Color(0xFF00E5FF)),
              const SizedBox(width: 12),
              _subStatCard('Basic', '${tierCounts[SubscriptionTier.basic] ?? 0}', Icons.star_border, const Color(0xFFCD7F32)),
              const SizedBox(width: 12),
              _subStatCard('Pro', '${tierCounts[SubscriptionTier.pro] ?? 0}', Icons.star_half, const Color(0xFFC0C0C0)),
              const SizedBox(width: 12),
              _subStatCard('Business', '${tierCounts[SubscriptionTier.business] ?? 0}', Icons.star, const Color(0xFFFFD700)),
              const SizedBox(width: 12),
              _subStatCard('Enterprise', '${tierCounts[SubscriptionTier.enterprise] ?? 0}', Icons.workspace_premium, const Color(0xFF00E5FF)),
            ],
          ),
          const SizedBox(height: 20),

          // 套餐定价
          const SectionTitle(title: 'SaaS套餐定价'),
          const SizedBox(height: 8),
          Row(
            children: tiers.map((tier) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: tier == SubscriptionTier.enterprise
                          ? AppTheme.primaryNeonGreen.withOpacity(0.5)
                          : AppTheme.borderGlow.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(tier.displayName,
                          style: TextStyle(
                            color: tier == SubscriptionTier.enterprise ? AppTheme.primaryNeonGreen : AppTheme.textPrimary,
                            fontSize: 16, fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 8),
                      Text('${Currency.usd.symbol}${tier.monthlyPrice.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                      const Text('/月', style: TextStyle(color: AppTheme.textHint, fontSize: 11)),
                      const SizedBox(height: 8),
                      Text('年付 ${Currency.usd.symbol}${tier.monthlyPrice * 10}',
                          style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 订阅列表
          const SectionTitle(title: '活跃订阅列表'),
          const SizedBox(height: 8),
          Expanded(
            child: AdminDataTable(
              columns: const ['订阅ID', '用户', '套餐', '金额', '币种', '状态', '自动续费', '开始日期', '下次扣款', '累计付款'],
              rows: subscriptions.map((sub) => [
                Text(sub.subscriptionId, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                Text(sub.userName, style: const TextStyle(fontSize: 12)),
                _tierBadge(sub.tier),
                Text('${sub.currency.symbol}${sub.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(sub.currency.symbol, style: const TextStyle(fontSize: 11, color: AppTheme.primaryNeonGreen)),
                StatusBadge(status: sub.status),
                Icon(sub.autoRenew ? Icons.check_circle : Icons.cancel,
                    color: sub.autoRenew ? AppTheme.primaryNeonGreen : AppTheme.textHint, size: 16),
                Text('${sub.startDate.year}/${sub.startDate.month}/${sub.startDate.day}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text(sub.nextBillingDate != null
                    ? '${sub.nextBillingDate!.month}/${sub.nextBillingDate!.day}'
                    : '-',
                    style: const TextStyle(fontSize: 11)),
                Text('${sub.currency.symbol}${sub.totalPaid.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ]).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
                Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _tierBadge(SubscriptionTier tier) {
    Color c;
    switch (tier) {
      case SubscriptionTier.basic: c = const Color(0xFFCD7F32); break;
      case SubscriptionTier.pro: c = const Color(0xFFC0C0C0); break;
      case SubscriptionTier.business: c = const Color(0xFFFFD700); break;
      case SubscriptionTier.enterprise: c = const Color(0xFF00E5FF); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(tier.displayName, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ============================================================
// Tab 5: 全球代理结算
// ============================================================
class _SettlementsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlements = ref.watch(agentSettlementsProvider);
    final pending = ref.watch(pendingSettlementAmountProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 结算统计
          Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  title: '待结算金额',
                  value: '${Currency.cny.symbol}${(pending / 10000).toStringAsFixed(1)}万',
                  subtitle: '${settlements.where((s) => s.status == 'pending').length} 笔待处理',
                  icon: Icons.pending_actions,
                  iconColor: AppTheme.warningNeonOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStatCard(
                  title: '本月已结算',
                  value: '${Currency.cny.symbol}${(settlements.where((s) => s.status == 'paid').fold<double>(0, (sum, s) => sum + s.commissionAmount) / 10000).toStringAsFixed(1)}万',
                  subtitle: '已结算${settlements.where((s) => s.status == 'paid').length}笔',
                  icon: Icons.check_circle,
                  iconColor: AppTheme.primaryNeonGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStatCard(
                  title: '总佣金支出',
                  value: '${Currency.cny.symbol}${(settlements.fold<double>(0, (sum, s) => sum + s.commissionAmount) / 10000).toStringAsFixed(1)}万',
                  subtitle: '${settlements.length} 笔结算',
                  icon: Icons.account_balance_wallet,
                  iconColor: const Color(0xFFB44CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 代理等级结算比例
          const SectionTitle(title: '代理等级分佣比例'),
          const SizedBox(height: 8),
          Row(
            children: AgentLevel.values.map((level) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(level.displayName,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('${(level.commissionRate * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 22, fontWeight: FontWeight.w800)),
                      const Text('分佣比例', style: TextStyle(color: AppTheme.textHint, fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 结算列表
          const SectionTitle(title: '结算记录'),
          const SizedBox(height: 8),
          Expanded(
            child: AdminDataTable(
              columns: const ['结算ID', '代理商', '等级', '销售额', '佣金率', '佣金金额', '支付方式', '周期', '状态', '时间'],
              rows: settlements.map((s) => [
                Text(s.settlementId, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                Text(s.dealerName, style: const TextStyle(fontSize: 12)),
                Text(s.level.displayName, style: const TextStyle(fontSize: 11, color: AppTheme.primaryNeonGreen)),
                Text('${s.currency.symbol}${(s.totalSales / 10000).toStringAsFixed(1)}万',
                    style: const TextStyle(fontSize: 12)),
                Text('${(s.commissionRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('${s.currency.symbol}${(s.commissionAmount / 10000).toStringAsFixed(1)}万',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryNeonGreen)),
                Text(s.paymentMethod.displayName, style: const TextStyle(fontSize: 11)),
                Text(s.period, style: const TextStyle(fontSize: 11)),
                StatusBadge(status: s.status),
                Text('${s.createdAt.month}/${s.createdAt.day}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ]).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Tab 6: 发票管理
// ============================================================
class _InvoicesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  title: '已开发票',
                  value: '${invoices.length}',
                  subtitle: '${invoices.where((i) => i.status == 'paid').length} 已付款',
                  icon: Icons.receipt_long,
                  iconColor: AppTheme.primaryNeonGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStatCard(
                  title: '开票总额',
                  value: '${Currency.cny.symbol}${_invTotal(invoices)}',
                  subtitle: '多币种合计',
                  icon: Icons.summarize,
                  iconColor: const Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStatCard(
                  title: '待付款',
                  value: '${invoices.where((i) => i.status == 'sent' || i.status == 'draft').length}',
                  subtitle: '需跟进催收',
                  icon: Icons.pending,
                  iconColor: AppTheme.warningNeonOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const SectionTitle(title: '发票列表'),
          const SizedBox(height: 8),
          Expanded(
            child: AdminDataTable(
              columns: const ['发票号', '订单号', '客户', '公司', '币种', '金额', '税额', '含税合计', '状态', '开票日期', '到期日'],
              rows: invoices.map((inv) => [
                Text(inv.invoiceId, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                Text(inv.orderId, style: const TextStyle(fontSize: 11)),
                Text(inv.recipientName, style: const TextStyle(fontSize: 12)),
                Text(inv.companyName ?? '-', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text(inv.currency.symbol, style: const TextStyle(fontSize: 11, color: AppTheme.primaryNeonGreen)),
                Text(inv.subtotal.toStringAsFixed(0), style: const TextStyle(fontSize: 12)),
                Text(inv.taxAmount.toStringAsFixed(0), style: const TextStyle(fontSize: 11, color: AppTheme.warningNeonOrange)),
                Text(inv.totalAmount.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                StatusBadge(status: inv.status),
                Text('${inv.issuedDate.month}/${inv.issuedDate.day}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text('${inv.dueDate.month}/${inv.dueDate.day}',
                    style: const TextStyle(fontSize: 11)),
              ]).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _invTotal(List<Invoice> invoices) {
    // Simplified: convert all to approximate CNY
    final total = invoices.fold<double>(0, (sum, inv) => sum + inv.totalAmount);
    if (total >= 10000) return '${(total / 10000).toStringAsFixed(1)}万';
    return total.toStringAsFixed(0);
  }
}
