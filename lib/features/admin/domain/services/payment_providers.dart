import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_models.dart';

/// 全球支付中枢 — Payment Agent Providers

// ============================================================
// Payment Hub 核心状态
// ============================================================

/// 支付汇总统计
final paymentSummaryProvider = StateProvider<PaymentSummary>(
  (ref) => PaymentSummary.initial(),
);

/// 支付交易列表
final paymentTransactionsProvider = StateProvider<List<PaymentTransaction>>(
  (ref) => _mockTransactions(),
);

/// 支付趋势数据
final paymentTrendProvider = StateProvider<List<PaymentTrendPoint>>(
  (ref) => _mockTrend(),
);

// ============================================================
// 网关配置
// ============================================================

/// 所有支付网关配置
final gatewayConfigsProvider = StateProvider<List<GatewayConfig>>(
  (ref) => _mockGatewayConfigs(),
);

// ============================================================
// SaaS订阅管理
// ============================================================

/// 订阅列表
final subscriptionsProvider = StateProvider<List<Subscription>>(
  (ref) => _mockSubscriptions(),
);

/// 活跃订阅数
final activeSubscriptionsCountProvider = Provider<int>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs.where((s) => s.status == 'active').length;
});

/// MRR (月经常性收入)
final mrrProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs
      .where((s) => s.status == 'active')
      .fold(0.0, (sum, s) => sum + s.amount);
});

// ============================================================
// 全球代理结算
// ============================================================

/// 代理结算列表
final agentSettlementsProvider = StateProvider<List<AgentSettlement>>(
  (ref) => _mockSettlements(),
);

/// 待结算金额
final pendingSettlementAmountProvider = Provider<double>((ref) {
  final settlements = ref.watch(agentSettlementsProvider);
  return settlements
      .where((s) => s.status == 'pending')
      .fold(0.0, (sum, s) => sum + s.commissionAmount);
});

// ============================================================
// 账单/发票
// ============================================================

/// 发票列表
final invoicesProvider = StateProvider<List<Invoice>>(
  (ref) => _mockInvoices(),
);

// ============================================================
// 筛选器
// ============================================================

/// 支付网关筛选
final paymentGatewayFilterProvider = StateProvider<String>((ref) => 'all');

/// 支付场景筛选
final paymentSceneFilterProvider = StateProvider<String>((ref) => 'all');

/// 支付状态筛选
final paymentStatusFilterProvider = StateProvider<String>((ref) => 'all');

/// 币种筛选
final paymentCurrencyFilterProvider = StateProvider<String>((ref) => 'all');

/// 支付时间范围
final paymentDateRangeProvider = StateProvider<String>((ref) => 'month');

/// 支付搜索关键词
final paymentSearchQueryProvider = StateProvider<String>((ref) => '');

// ============================================================
// 筛选后的交易列表
// ============================================================

final filteredTransactionsProvider = Provider<List<PaymentTransaction>>((ref) {
  final transactions = ref.watch(paymentTransactionsProvider);
  final gateway = ref.watch(paymentGatewayFilterProvider);
  final scene = ref.watch(paymentSceneFilterProvider);
  final status = ref.watch(paymentStatusFilterProvider);
  final currency = ref.watch(paymentCurrencyFilterProvider);
  final query = ref.watch(paymentSearchQueryProvider);

  return transactions.where((tx) {
    if (gateway != 'all' && tx.gateway.name != gateway) return false;
    if (scene != 'all' && tx.scene.name != scene) return false;
    if (status != 'all' && tx.status.name != status) return false;
    if (currency != 'all' && tx.currency.name != currency) return false;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      return tx.orderId.toLowerCase().contains(q) ||
          tx.transactionId.toLowerCase().contains(q) ||
          (tx.payerName?.toLowerCase().contains(q) ?? false) ||
          (tx.payerEmail?.toLowerCase().contains(q) ?? false);
    }
    return true;
  }).toList();
});

// ============================================================
// Mock Data
// ============================================================

List<PaymentTransaction> _mockTransactions() {
  final now = DateTime.now();
  return [
    PaymentTransaction(
      transactionId: 'TXN20260601001',
      orderId: 'AI-NAILS-2026-001',
      userId: 'USR_001',
      gateway: PaymentGateway.wechatPay,
      scene: PaymentScene.deviceSale,
      currency: Currency.cny,
      amount: 29900,
      settlementCurrency: Currency.cny,
      settlementAmount: 29900,
      status: PaymentStatus.completed,
      payerName: '北京朝阳旗舰店',
      createdAt: now.subtract(const Duration(hours: 2)),
      completedAt: now.subtract(const Duration(hours: 1, minutes: 55)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601002',
      orderId: 'AI-NAILS-2026-002',
      userId: 'USR_002',
      gateway: PaymentGateway.alipay,
      scene: PaymentScene.saasSubscription,
      currency: Currency.cny,
      amount: 299,
      status: PaymentStatus.completed,
      payerName: '上海静安美甲店',
      createdAt: now.subtract(const Duration(hours: 4)),
      completedAt: now.subtract(const Duration(hours: 3, minutes: 55)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601003',
      orderId: 'AI-NAILS-2026-003',
      userId: 'USR_003',
      storeId: 'STORE_JP_001',
      gateway: PaymentGateway.stripe,
      scene: PaymentScene.saasSubscription,
      currency: Currency.usd,
      amount: 99,
      settlementCurrency: Currency.cny,
      settlementAmount: 719,
      exchangeRate: 7.27,
      status: PaymentStatus.completed,
      payerName: 'Tokyo Beauty Studio',
      payerEmail: 'info@tokyobeauty.jp',
      createdAt: now.subtract(const Duration(hours: 6)),
      completedAt: now.subtract(const Duration(hours: 5, minutes: 55)),
      autoSettled: true,
      commissionAmount: 14.85,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601004',
      orderId: 'AI-NAILS-2026-004',
      dealerId: 'DLR_EU_001',
      gateway: PaymentGateway.paypal,
      scene: PaymentScene.franchiseFee,
      currency: Currency.eur,
      amount: 50000,
      settlementCurrency: Currency.cny,
      settlementAmount: 389500,
      exchangeRate: 7.79,
      status: PaymentStatus.completed,
      payerName: 'Paris Beauty Group',
      payerEmail: 'contact@parisbeauty.fr',
      createdAt: now.subtract(const Duration(days: 1)),
      completedAt: now.subtract(const Duration(days: 1)),
      autoSettled: true,
      commissionAmount: 10000,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601005',
      orderId: 'AI-NAILS-2026-005',
      userId: 'USR_005',
      gateway: PaymentGateway.applePay,
      scene: PaymentScene.aiServiceFee,
      currency: Currency.usd,
      amount: 49.99,
      settlementCurrency: Currency.cny,
      settlementAmount: 363,
      exchangeRate: 7.27,
      status: PaymentStatus.completed,
      payerName: 'Sarah Johnson',
      payerEmail: 'sarah@me.com',
      createdAt: now.subtract(const Duration(hours: 8)),
      completedAt: now.subtract(const Duration(hours: 7, minutes: 59)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601006',
      orderId: 'AI-NAILS-2026-006',
      userId: 'USR_006',
      gateway: PaymentGateway.googlePay,
      scene: PaymentScene.aiServiceFee,
      currency: Currency.usd,
      amount: 29.99,
      settlementCurrency: Currency.cny,
      settlementAmount: 218,
      exchangeRate: 7.27,
      status: PaymentStatus.completed,
      payerName: 'Mike Chen',
      payerEmail: 'mike.chen@gmail.com',
      createdAt: now.subtract(const Duration(hours: 10)),
      completedAt: now.subtract(const Duration(hours: 9, minutes: 55)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601007',
      orderId: 'AI-NAILS-2026-007',
      dealerId: 'DLR_US_002',
      gateway: PaymentGateway.bankTransfer,
      scene: PaymentScene.agentDeposit,
      currency: Currency.cny,
      amount: 99800,
      status: PaymentStatus.processing,
      payerName: '深圳市斯密爱科技有限公司',
      createdAt: now.subtract(const Duration(hours: 12)),
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601008',
      orderId: 'AI-NAILS-2026-008',
      userId: 'USR_008',
      gateway: PaymentGateway.usdt,
      scene: PaymentScene.storePurchase,
      currency: Currency.usdt,
      amount: 500,
      settlementCurrency: Currency.cny,
      settlementAmount: 3625,
      exchangeRate: 7.25,
      status: PaymentStatus.completed,
      payerName: '0x8a3B...f92E',
      createdAt: now.subtract(const Duration(days: 1, hours: 5)),
      completedAt: now.subtract(const Duration(days: 1, hours: 4)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601009',
      orderId: 'AI-NAILS-2026-009',
      storeId: 'STORE_UK_003',
      gateway: PaymentGateway.stripe,
      scene: PaymentScene.storePurchase,
      currency: Currency.gbp,
      amount: 15000,
      settlementCurrency: Currency.cny,
      settlementAmount: 137100,
      exchangeRate: 9.14,
      status: PaymentStatus.pending,
      payerName: 'London Nail Art Ltd',
      createdAt: now.subtract(const Duration(hours: 1)),
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601010',
      orderId: 'AI-NAILS-2026-010',
      userId: 'USR_010',
      gateway: PaymentGateway.wechatPay,
      scene: PaymentScene.coursePurchase,
      currency: Currency.cny,
      amount: 199,
      status: PaymentStatus.completed,
      payerName: '广州天河美甲师',
      createdAt: now.subtract(const Duration(hours: 14)),
      completedAt: now.subtract(const Duration(hours: 13, minutes: 59)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601011',
      orderId: 'AI-NAILS-2026-011',
      dealerId: 'DLR_SG_001',
      gateway: PaymentGateway.paypal,
      scene: PaymentScene.franchiseFee,
      currency: Currency.sgd,
      amount: 35000,
      settlementCurrency: Currency.cny,
      settlementAmount: 188300,
      exchangeRate: 5.38,
      status: PaymentStatus.completed,
      payerName: 'Singapore Nails Pte Ltd',
      payerEmail: 'hello@sgnails.sg',
      createdAt: now.subtract(const Duration(days: 2)),
      completedAt: now.subtract(const Duration(days: 2)),
      autoSettled: true,
      commissionAmount: 7000,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601012',
      orderId: 'AI-NAILS-2026-012',
      userId: 'USR_012',
      gateway: PaymentGateway.venmo,
      scene: PaymentScene.aiServiceFee,
      currency: Currency.usd,
      amount: 15,
      settlementCurrency: Currency.cny,
      settlementAmount: 109,
      exchangeRate: 7.27,
      status: PaymentStatus.completed,
      payerName: 'Emily Davis',
      payerEmail: 'emily@venmo.com',
      createdAt: now.subtract(const Duration(days: 1, hours: 8)),
      completedAt: now.subtract(const Duration(days: 1, hours: 7)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601013',
      orderId: 'AI-NAILS-2026-013',
      storeId: 'STORE_KR_001',
      gateway: PaymentGateway.stripe,
      scene: PaymentScene.deviceSale,
      currency: Currency.usd,
      amount: 29900,
      settlementCurrency: Currency.cny,
      settlementAmount: 217373,
      exchangeRate: 7.27,
      status: PaymentStatus.processing,
      payerName: 'Seoul Beauty Tech',
      payerEmail: 'sales@seoulbeauty.kr',
      createdAt: now.subtract(const Duration(minutes: 30)),
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601014',
      orderId: 'AI-NAILS-2026-014',
      userId: 'USR_014',
      gateway: PaymentGateway.alipay,
      scene: PaymentScene.userRecharge,
      currency: Currency.cny,
      amount: 500,
      status: PaymentStatus.completed,
      payerName: '深圳南山区用户',
      createdAt: now.subtract(const Duration(days: 1, hours: 20)),
      completedAt: now.subtract(const Duration(days: 1, hours: 19)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601015',
      orderId: 'AI-NAILS-2026-015',
      userId: 'USR_015',
      gateway: PaymentGateway.btc,
      scene: PaymentScene.saasSubscription,
      currency: Currency.btc,
      amount: 0.015,
      settlementCurrency: Currency.cny,
      settlementAmount: 7685,
      exchangeRate: 512333,
      status: PaymentStatus.completed,
      payerName: 'bc1q...9x4k',
      createdAt: now.subtract(const Duration(days: 3)),
      completedAt: now.subtract(const Duration(days: 3)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601016',
      orderId: 'AI-NAILS-2026-016',
      dealerId: 'DLR_AE_001',
      gateway: PaymentGateway.bankTransfer,
      scene: PaymentScene.franchiseFee,
      currency: Currency.aed,
      amount: 180000,
      settlementCurrency: Currency.cny,
      settlementAmount: 356400,
      exchangeRate: 1.98,
      status: PaymentStatus.pending,
      payerName: 'Dubai Luxury Nails LLC',
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601017',
      orderId: 'AI-NAILS-2026-017',
      userId: 'USR_017',
      gateway: PaymentGateway.wechatPay,
      scene: PaymentScene.saasSubscription,
      currency: Currency.cny,
      amount: 99,
      status: PaymentStatus.failed,
      payerName: '成都高新区用户',
      failureReason: '余额不足',
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601018',
      orderId: 'AI-NAILS-2026-018',
      userId: 'USR_018',
      gateway: PaymentGateway.stripe,
      scene: PaymentScene.saasSubscription,
      currency: Currency.usd,
      amount: 299,
      settlementCurrency: Currency.cny,
      settlementAmount: 2174,
      exchangeRate: 7.27,
      status: PaymentStatus.refunded,
      payerName: 'Nail Art Studio NYC',
      payerEmail: 'refund@nailartnyc.com',
      createdAt: now.subtract(const Duration(days: 5)),
      completedAt: now.subtract(const Duration(days: 3)),
      autoSettled: true,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601019',
      orderId: 'AI-NAILS-2026-019',
      storeId: 'STORE_TH_001',
      gateway: PaymentGateway.adyen,
      scene: PaymentScene.deviceSale,
      currency: Currency.thb,
      amount: 29900 * 36,
      settlementCurrency: Currency.cny,
      settlementAmount: 215280,
      exchangeRate: 0.20,
      status: PaymentStatus.completed,
      payerName: 'Bangkok Beauty Supply',
      createdAt: now.subtract(const Duration(days: 2, hours: 10)),
      completedAt: now.subtract(const Duration(days: 2, hours: 9)),
      autoSettled: true,
      commissionAmount: 43056,
    ),
    PaymentTransaction(
      transactionId: 'TXN20260601020',
      orderId: 'AI-NAILS-2026-020',
      userId: 'USR_020',
      gateway: PaymentGateway.opcToken,
      scene: PaymentScene.commissionSettle,
      currency: Currency.opc,
      amount: 10000,
      settlementCurrency: Currency.cny,
      settlementAmount: 50000,
      exchangeRate: 5.0,
      status: PaymentStatus.completed,
      payerName: 'OPC社区奖励池',
      createdAt: now.subtract(const Duration(days: 1)),
      completedAt: now.subtract(const Duration(days: 1)),
      autoSettled: true,
      commissionAmount: 10000,
    ),
  ];
}

List<GatewayConfig> _mockGatewayConfigs() {
  return [
    // 中国支付
    GatewayConfig(
      gateway: PaymentGateway.wechatPay,
      enabled: true,
      merchantId: 'WX_MCH_AI_NAILS',
      supportedCurrencies: [Currency.cny],
      feeRate: 0.6,
      minAmount: 0.01,
      maxAmount: 50000,
      webhookUrl: 'https://api.ainails.com/payment/wechat/callback',
      status: 'active',
      dailyVolume: 1250,
      dailyRevenue: 385000,
    ),
    GatewayConfig(
      gateway: PaymentGateway.alipay,
      enabled: true,
      merchantId: 'ALIPAY_AI_NAILS',
      supportedCurrencies: [Currency.cny],
      feeRate: 0.55,
      minAmount: 0.01,
      maxAmount: 100000,
      webhookUrl: 'https://api.ainails.com/payment/alipay/callback',
      status: 'active',
      dailyVolume: 890,
      dailyRevenue: 245000,
    ),
    GatewayConfig(
      gateway: PaymentGateway.bankTransfer,
      enabled: true,
      merchantId: 'ICBC_SHENZHEN_HUACHENG',
      supportedCurrencies: [
        Currency.cny, Currency.usd, Currency.eur, Currency.hkd,
      ],
      feeRate: 0.1,
      minAmount: 100,
      maxAmount: 99999999,
      status: 'active',
      dailyVolume: 35,
      dailyRevenue: 520000,
    ),
    // 全球信用卡
    GatewayConfig(
      gateway: PaymentGateway.stripe,
      enabled: true,
      apiKey: 'sk_live_****',
      supportedCurrencies: [
        Currency.usd, Currency.eur, Currency.gbp, Currency.aud,
        Currency.cad, Currency.jpy, Currency.sgd, Currency.hkd,
      ],
      feeRate: 2.9,
      webhookUrl: 'https://api.ainails.com/payment/stripe/webhook',
      status: 'active',
      dailyVolume: 680,
      dailyRevenue: 185000,
    ),
    GatewayConfig(
      gateway: PaymentGateway.paypal,
      enabled: true,
      apiKey: 'hmwhtm@yeah.net',
      supportedCurrencies: [
        Currency.usd, Currency.eur, Currency.gbp, Currency.aud,
        Currency.cad, Currency.jpy,
      ],
      feeRate: 3.49,
      webhookUrl: 'https://api.ainails.com/payment/paypal/webhook',
      status: 'active',
      dailyVolume: 320,
      dailyRevenue: 128000,
    ),
    GatewayConfig(
      gateway: PaymentGateway.checkoutCom,
      enabled: true,
      supportedCurrencies: [
        Currency.usd, Currency.eur, Currency.gbp, Currency.aed,
        Currency.myr, Currency.thb, Currency.hkd, Currency.sgd,
      ],
      feeRate: 2.5,
      status: 'active',
      dailyVolume: 150,
      dailyRevenue: 62000,
    ),
    GatewayConfig(
      gateway: PaymentGateway.adyen,
      enabled: true,
      supportedCurrencies: [
        Currency.usd, Currency.eur, Currency.gbp, Currency.jpy,
        Currency.aud, Currency.cad, Currency.thb,
      ],
      feeRate: 2.4,
      status: 'active',
      dailyVolume: 200,
      dailyRevenue: 89000,
    ),
    // 数字钱包
    GatewayConfig(
      gateway: PaymentGateway.applePay,
      enabled: true,
      supportedCurrencies: [Currency.usd, Currency.eur, Currency.gbp],
      feeRate: 2.9,
      status: 'active',
      dailyVolume: 85,
      dailyRevenue: 12500,
    ),
    GatewayConfig(
      gateway: PaymentGateway.googlePay,
      enabled: true,
      supportedCurrencies: [Currency.usd, Currency.eur, Currency.gbp, Currency.jpy],
      feeRate: 2.9,
      status: 'active',
      dailyVolume: 120,
      dailyRevenue: 18500,
    ),
    GatewayConfig(
      gateway: PaymentGateway.samsungPay,
      enabled: true,
      supportedCurrencies: [Currency.usd, Currency.eur, Currency.jpy, Currency.krw],
      feeRate: 2.9,
      status: 'active',
      dailyVolume: 45,
      dailyRevenue: 6500,
    ),
    GatewayConfig(
      gateway: PaymentGateway.venmo,
      enabled: true,
      supportedCurrencies: [Currency.usd],
      feeRate: 1.9,
      status: 'active',
      dailyVolume: 65,
      dailyRevenue: 3200,
    ),
    GatewayConfig(
      gateway: PaymentGateway.cashApp,
      enabled: true,
      supportedCurrencies: [Currency.usd],
      feeRate: 1.5,
      status: 'active',
      dailyVolume: 40,
      dailyRevenue: 1800,
    ),
    // 数字货币
    GatewayConfig(
      gateway: PaymentGateway.usdt,
      enabled: true,
      supportedCurrencies: [Currency.usdt],
      feeRate: 0.5,
      minAmount: 10,
      status: 'active',
      dailyVolume: 28,
      dailyRevenue: 18500,
    ),
    GatewayConfig(
      gateway: PaymentGateway.usdc,
      enabled: true,
      supportedCurrencies: [Currency.usdc],
      feeRate: 0.5,
      minAmount: 10,
      status: 'active',
      dailyVolume: 15,
      dailyRevenue: 8500,
    ),
    GatewayConfig(
      gateway: PaymentGateway.btc,
      enabled: true,
      supportedCurrencies: [Currency.btc],
      feeRate: 0.8,
      minAmount: 0.001,
      status: 'active',
      dailyVolume: 5,
      dailyRevenue: 28000,
    ),
    GatewayConfig(
      gateway: PaymentGateway.eth,
      enabled: true,
      supportedCurrencies: [Currency.eth],
      feeRate: 0.8,
      minAmount: 0.01,
      status: 'active',
      dailyVolume: 3,
      dailyRevenue: 12000,
    ),
    GatewayConfig(
      gateway: PaymentGateway.opcToken,
      enabled: true,
      supportedCurrencies: [Currency.opc],
      feeRate: 0.3,
      minAmount: 100,
      status: 'active',
      dailyVolume: 12,
      dailyRevenue: 45000,
    ),
  ];
}

List<Subscription> _mockSubscriptions() {
  final now = DateTime.now();
  return [
    Subscription(
      subscriptionId: 'SUB_001', userId: 'USR_001', userName: '北京朝阳旗舰店',
      tier: SubscriptionTier.enterprise, currency: Currency.cny, amount: 999,
      status: 'active', autoRenew: true, startDate: now.subtract(const Duration(days: 180)),
      nextBillingDate: now.add(const Duration(days: 10)), totalPayments: 6, totalPaid: 5994,
    ),
    Subscription(
      subscriptionId: 'SUB_002', userId: 'USR_003', userName: 'Tokyo Beauty Studio',
      tier: SubscriptionTier.pro, currency: Currency.usd, amount: 99,
      status: 'active', autoRenew: true, startDate: now.subtract(const Duration(days: 90)),
      nextBillingDate: now.add(const Duration(days: 15)), totalPayments: 3, totalPaid: 297,
    ),
    Subscription(
      subscriptionId: 'SUB_003', userId: 'USR_005', userName: 'Sarah Johnson',
      tier: SubscriptionTier.basic, currency: Currency.usd, amount: 29,
      status: 'active', autoRenew: true, startDate: now.subtract(const Duration(days: 45)),
      nextBillingDate: now.add(const Duration(days: 20)), totalPayments: 1, totalPaid: 29,
    ),
    Subscription(
      subscriptionId: 'SUB_004', userId: 'USR_008', userName: 'Crypto Nail Studio',
      tier: SubscriptionTier.business, currency: Currency.usdt, amount: 299,
      status: 'active', autoRenew: true, startDate: now.subtract(const Duration(days: 120)),
      nextBillingDate: now.add(const Duration(days: 5)), totalPayments: 4, totalPaid: 1196,
    ),
    Subscription(
      subscriptionId: 'SUB_005', userId: 'USR_012', userName: 'Emily Davis',
      tier: SubscriptionTier.basic, currency: Currency.usd, amount: 29,
      status: 'paused', autoRenew: false, startDate: now.subtract(const Duration(days: 60)),
      totalPayments: 2, totalPaid: 58,
    ),
    Subscription(
      subscriptionId: 'SUB_006', userId: 'USR_015', userName: '上海静安美甲店',
      tier: SubscriptionTier.pro, currency: Currency.cny, amount: 99,
      status: 'active', autoRenew: true, startDate: now.subtract(const Duration(days: 150)),
      nextBillingDate: now.add(const Duration(days: 8)), totalPayments: 5, totalPaid: 495,
    ),
    Subscription(
      subscriptionId: 'SUB_007', userId: 'USR_018', userName: 'Nail Art Studio NYC',
      tier: SubscriptionTier.business, currency: Currency.usd, amount: 299,
      status: 'cancelled', autoRenew: false,
      startDate: now.subtract(const Duration(days: 200)),
      endDate: now.subtract(const Duration(days: 5)), totalPayments: 6, totalPaid: 1794,
    ),
    Subscription(
      subscriptionId: 'SUB_008', userId: 'USR_020', userName: 'OPC社区创作者',
      tier: SubscriptionTier.enterprise, currency: Currency.opc, amount: 999,
      status: 'active', autoRenew: true, startDate: now.subtract(const Duration(days: 30)),
      nextBillingDate: now.add(const Duration(days: 25)), totalPayments: 1, totalPaid: 999,
    ),
  ];
}

List<AgentSettlement> _mockSettlements() {
  final now = DateTime.now();
  return [
    AgentSettlement(
      settlementId: 'SET_202605_001', dealerId: 'DLR_EU_001',
      dealerName: 'Paris Beauty Group', level: AgentLevel.regionalPartner,
      totalSales: 520000, commissionRate: 0.20, commissionAmount: 104000,
      currency: Currency.eur, paymentMethod: PaymentGateway.paypal,
      status: 'paid', period: '2026-05',
      createdAt: now.subtract(const Duration(days: 3)),
      paidAt: now.subtract(const Duration(days: 1)),
      transactionId: 'TXN20260601004',
    ),
    AgentSettlement(
      settlementId: 'SET_202605_002', dealerId: 'DLR_US_002',
      dealerName: 'American Nail Tech Inc', level: AgentLevel.countryPartner,
      totalSales: 380000, commissionRate: 0.15, commissionAmount: 57000,
      currency: Currency.usd, paymentMethod: PaymentGateway.stripe,
      status: 'pending', period: '2026-05',
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    AgentSettlement(
      settlementId: 'SET_202605_003', dealerId: 'DLR_SG_001',
      dealerName: 'Singapore Nails Pte Ltd', level: AgentLevel.countryPartner,
      totalSales: 280000, commissionRate: 0.15, commissionAmount: 42000,
      currency: Currency.sgd, paymentMethod: PaymentGateway.paypal,
      status: 'processing', period: '2026-05',
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    AgentSettlement(
      settlementId: 'SET_202605_004', dealerId: 'DLR_CN_003',
      dealerName: '广州天河区经销商', level: AgentLevel.cityPartner,
      totalSales: 150000, commissionRate: 0.10, commissionAmount: 15000,
      currency: Currency.cny, paymentMethod: PaymentGateway.wechatPay,
      status: 'paid', period: '2026-05',
      createdAt: now.subtract(const Duration(days: 5)),
      paidAt: now.subtract(const Duration(days: 3)),
    ),
    AgentSettlement(
      settlementId: 'SET_202605_005', dealerId: 'DLR_AE_001',
      dealerName: 'Dubai Luxury Nails LLC', level: AgentLevel.globalPartner,
      totalSales: 650000, commissionRate: 0.25, commissionAmount: 162500,
      currency: Currency.aed, paymentMethod: PaymentGateway.bankTransfer,
      status: 'pending', period: '2026-05',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    AgentSettlement(
      settlementId: 'SET_202605_006', dealerId: 'DLR_KR_001',
      dealerName: 'Seoul Beauty Tech', level: AgentLevel.cityPartner,
      totalSales: 120000, commissionRate: 0.10, commissionAmount: 12000,
      currency: Currency.usd, paymentMethod: PaymentGateway.stripe,
      status: 'paid', period: '2026-05',
      createdAt: now.subtract(const Duration(days: 6)),
      paidAt: now.subtract(const Duration(days: 4)),
      transactionId: 'TXN20260601013',
    ),
  ];
}

List<Invoice> _mockInvoices() {
  final now = DateTime.now();
  return [
    Invoice(
      invoiceId: 'INV-2026-001', orderId: 'AI-NAILS-2026-001',
      recipientName: '北京朝阳旗舰店', recipientEmail: 'beijing@ainails.cn',
      companyName: '北京朝阳美甲科技有限公司', taxId: '91110108MA01XXXXX',
      items: [
        const InvoiceItem(description: 'AI NAILS Pro 智能美甲设备 x2', quantity: 2, unitPrice: 14950, totalPrice: 29900),
      ],
      currency: Currency.cny, subtotal: 29900, taxRate: 13, taxAmount: 3887, totalAmount: 33787,
      status: 'paid', issuedDate: now.subtract(const Duration(days: 1)),
      dueDate: now.add(const Duration(days: 29)), paidDate: now.subtract(const Duration(days: 1)),
    ),
    Invoice(
      invoiceId: 'INV-2026-002', orderId: 'AI-NAILS-2026-003',
      recipientName: 'Tokyo Beauty Studio', recipientEmail: 'info@tokyobeauty.jp',
      items: [
        const InvoiceItem(description: 'AI NAILS Pro 月费订阅', quantity: 1, unitPrice: 99, totalPrice: 99),
      ],
      currency: Currency.usd, subtotal: 99, taxRate: 0, taxAmount: 0, totalAmount: 99,
      status: 'paid', issuedDate: now.subtract(const Duration(days: 1)),
      dueDate: now.add(const Duration(days: 29)), paidDate: now.subtract(const Duration(days: 1)),
    ),
    Invoice(
      invoiceId: 'INV-2026-003', orderId: 'AI-NAILS-2026-004',
      recipientName: 'Paris Beauty Group', recipientEmail: 'contact@parisbeauty.fr',
      companyName: 'Paris Beauty Group SAS', taxId: 'FR12345678901',
      items: [
        const InvoiceItem(description: 'AI NAILS Regional Partner 加盟费', quantity: 1, unitPrice: 50000, totalPrice: 50000),
      ],
      currency: Currency.eur, subtotal: 50000, taxRate: 20, taxAmount: 10000, totalAmount: 60000,
      status: 'paid', issuedDate: now.subtract(const Duration(days: 2)),
      dueDate: now.add(const Duration(days: 28)), paidDate: now.subtract(const Duration(days: 1)),
    ),
    Invoice(
      invoiceId: 'INV-2026-004', orderId: 'AI-NAILS-2026-007',
      recipientName: '深圳市斯密爱科技有限公司', recipientEmail: 'finance@simiai.cn',
      companyName: '深圳市斯密爱科技有限公司', taxId: '91440300MAG1CEBT8B',
      items: [
        const InvoiceItem(description: 'AI NAILS 全球代理保证金', quantity: 1, unitPrice: 99800, totalPrice: 99800),
      ],
      currency: Currency.cny, subtotal: 99800, taxRate: 6, taxAmount: 5988, totalAmount: 105788,
      status: 'sent', issuedDate: now.subtract(const Duration(hours: 12)),
      dueDate: now.add(const Duration(days: 30)),
    ),
    Invoice(
      invoiceId: 'INV-2026-005', orderId: 'AI-NAILS-2026-009',
      recipientName: 'London Nail Art Ltd', recipientEmail: 'accounts@londonnailart.co.uk',
      companyName: 'London Nail Art Ltd', taxId: 'GB123456789',
      items: [
        const InvoiceItem(description: 'AI NAILS Pro 智能美甲设备 x5', quantity: 5, unitPrice: 3000, totalPrice: 15000),
      ],
      currency: Currency.gbp, subtotal: 15000, taxRate: 20, taxAmount: 3000, totalAmount: 18000,
      status: 'draft', issuedDate: now.subtract(const Duration(hours: 1)),
      dueDate: now.add(const Duration(days: 30)),
    ),
  ];
}

List<PaymentTrendPoint> _mockTrend() {
  final now = DateTime.now();
  return List.generate(30, (i) {
    final day = now.subtract(Duration(days: 29 - i));
    return PaymentTrendPoint(
      date: day,
      revenue: 38000 + (i * 1500) + (i % 7 == 0 ? 15000 : 0),
      transactions: 350 + (i * 8) + (i % 7 == 0 ? 80 : 0),
      commission: 4500 + (i * 200) + (i % 7 == 0 ? 2500 : 0),
    );
  });
}
