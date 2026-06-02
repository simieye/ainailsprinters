/// 全球支付系统数据模型 — AI NAILS Global Payment Hub

/// 支付网关枚举
enum PaymentGateway {
  // 中国支付
  wechatPay,      // 微信支付
  alipay,          // 支付宝
  bankTransfer,    // 对公转账

  // 全球支付
  stripe,
  paypal,
  checkoutCom,
  adyen,

  // 数字钱包
  applePay,
  googlePay,
  samsungPay,
  venmo,
  cashApp,

  // 数字货币
  usdt,
  usdc,
  btc,
  eth,
  opcToken,
}

extension PaymentGatewayX on PaymentGateway {
  String get displayName {
    switch (this) {
      case PaymentGateway.wechatPay: return '微信支付';
      case PaymentGateway.alipay: return '支付宝';
      case PaymentGateway.bankTransfer: return '对公转账';
      case PaymentGateway.stripe: return 'Stripe';
      case PaymentGateway.paypal: return 'PayPal';
      case PaymentGateway.checkoutCom: return 'Checkout.com';
      case PaymentGateway.adyen: return 'Adyen';
      case PaymentGateway.applePay: return 'Apple Pay';
      case PaymentGateway.googlePay: return 'Google Pay';
      case PaymentGateway.samsungPay: return 'Samsung Pay';
      case PaymentGateway.venmo: return 'Venmo';
      case PaymentGateway.cashApp: return 'Cash App';
      case PaymentGateway.usdt: return 'USDT';
      case PaymentGateway.usdc: return 'USDC';
      case PaymentGateway.btc: return 'BTC';
      case PaymentGateway.eth: return 'ETH';
      case PaymentGateway.opcToken: return 'OPC Token';
    }
  }

  String get category {
    switch (this) {
      case PaymentGateway.wechatPay:
      case PaymentGateway.alipay:
      case PaymentGateway.bankTransfer:
        return 'China';
      case PaymentGateway.stripe:
      case PaymentGateway.paypal:
      case PaymentGateway.checkoutCom:
      case PaymentGateway.adyen:
        return 'Global';
      case PaymentGateway.applePay:
      case PaymentGateway.googlePay:
      case PaymentGateway.samsungPay:
      case PaymentGateway.venmo:
      case PaymentGateway.cashApp:
        return 'Digital Wallet';
      case PaymentGateway.usdt:
      case PaymentGateway.usdc:
      case PaymentGateway.btc:
      case PaymentGateway.eth:
      case PaymentGateway.opcToken:
        return 'Crypto';
    }
  }
}

/// 支付场景
enum PaymentScene {
  deviceSale,
  saasSubscription,
  aiServiceFee,
  franchiseFee,
  coursePurchase,
  commissionSettle,
  agentDeposit,
  storePurchase,
  userRecharge,
  custom,
}

extension PaymentSceneX on PaymentScene {
  String get displayName {
    switch (this) {
      case PaymentScene.deviceSale: return '设备销售';
      case PaymentScene.saasSubscription: return 'SaaS订阅';
      case PaymentScene.aiServiceFee: return 'AI服务费';
      case PaymentScene.franchiseFee: return '加盟费';
      case PaymentScene.coursePurchase: return '课程购买';
      case PaymentScene.commissionSettle: return '分佣结算';
      case PaymentScene.agentDeposit: return '代理商保证金';
      case PaymentScene.storePurchase: return '门店采购';
      case PaymentScene.userRecharge: return '用户充值';
      case PaymentScene.custom: return '自定义';
    }
  }
}

/// 币种
enum Currency {
  cny, usd, eur, gbp, aud, cad, jpy, sgd, hkd, aed, myr, thb,
  usdt, usdc, btc, eth, opc,
}

extension CurrencyX on Currency {
  String get symbol {
    switch (this) {
      case Currency.cny: return '¥';
      case Currency.usd: return '\$';
      case Currency.eur: return '€';
      case Currency.gbp: return '£';
      case Currency.aud: return 'A\$';
      case Currency.cad: return 'C\$';
      case Currency.jpy: return '¥';
      case Currency.sgd: return 'S\$';
      case Currency.hkd: return 'HK\$';
      case Currency.aed: return 'د.إ';
      case Currency.myr: return 'RM';
      case Currency.thb: return '฿';
      case Currency.usdt: return '₮';
      case Currency.usdc: return '₮';
      case Currency.btc: return '₿';
      case Currency.eth: return 'Ξ';
      case Currency.opc: return 'OPC';
    }
  }

  String get name {
    switch (this) {
      case Currency.cny: return '人民币';
      case Currency.usd: return '美元';
      case Currency.eur: return '欧元';
      case Currency.gbp: return '英镑';
      case Currency.aud: return '澳元';
      case Currency.cad: return '加元';
      case Currency.jpy: return '日元';
      case Currency.sgd: return '新加坡元';
      case Currency.hkd: return '港币';
      case Currency.aed: return '迪拉姆';
      case Currency.myr: return '林吉特';
      case Currency.thb: return '泰铢';
      case Currency.usdt: return 'USDT';
      case Currency.usdc: return 'USDC';
      case Currency.btc: return 'Bitcoin';
      case Currency.eth: return 'Ethereum';
      case Currency.opc: return 'OPC Token';
    }
  }
}

/// 支付状态
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partialRefund,
  cancelled,
  expired,
}

extension PaymentStatusX on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending: return '待支付';
      case PaymentStatus.processing: return '处理中';
      case PaymentStatus.completed: return '已完成';
      case PaymentStatus.failed: return '失败';
      case PaymentStatus.refunded: return '已退款';
      case PaymentStatus.partialRefund: return '部分退款';
      case PaymentStatus.cancelled: return '已取消';
      case PaymentStatus.expired: return '已过期';
    }
  }
}

/// SaaS订阅等级
enum SubscriptionTier {
  basic,
  pro,
  business,
  enterprise,
}

extension SubscriptionTierX on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.basic: return 'Basic';
      case SubscriptionTier.pro: return 'Pro';
      case SubscriptionTier.business: return 'Business';
      case SubscriptionTier.enterprise: return 'Enterprise';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.basic: return 29;
      case SubscriptionTier.pro: return 99;
      case SubscriptionTier.business: return 299;
      case SubscriptionTier.enterprise: return 999;
    }
  }
}

/// 代理等级
enum AgentLevel {
  cityPartner,
  countryPartner,
  regionalPartner,
  globalPartner,
}

extension AgentLevelX on AgentLevel {
  String get displayName {
    switch (this) {
      case AgentLevel.cityPartner: return 'City Partner';
      case AgentLevel.countryPartner: return 'Country Partner';
      case AgentLevel.regionalPartner: return 'Regional Partner';
      case AgentLevel.globalPartner: return 'Global Partner';
    }
  }

  double get commissionRate {
    switch (this) {
      case AgentLevel.cityPartner: return 0.10;
      case AgentLevel.countryPartner: return 0.15;
      case AgentLevel.regionalPartner: return 0.20;
      case AgentLevel.globalPartner: return 0.25;
    }
  }
}

/// 支付交易记录
class PaymentTransaction {
  final String transactionId;
  final String orderId;
  final String? userId;
  final String? storeId;
  final String? dealerId;
  final PaymentGateway gateway;
  final PaymentScene scene;
  final Currency currency;
  final double amount;
  final Currency? settlementCurrency;
  final double? settlementAmount;
  final double exchangeRate;
  final PaymentStatus status;
  final String? payerName;
  final String? payerEmail;
  final String? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final bool autoSettled;
  final double? commissionAmount;
  final String? invoiceUrl;

  const PaymentTransaction({
    required this.transactionId,
    required this.orderId,
    this.userId,
    this.storeId,
    this.dealerId,
    required this.gateway,
    required this.scene,
    required this.currency,
    required this.amount,
    this.settlementCurrency,
    this.settlementAmount,
    this.exchangeRate = 1.0,
    required this.status,
    this.payerName,
    this.payerEmail,
    this.metadata,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.autoSettled = false,
    this.commissionAmount,
    this.invoiceUrl,
  });
}

/// 支付汇总统计
class PaymentSummary {
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final double annualRevenue;
  final int totalTransactions;
  final int completedTransactions;
  final double avgOrderValue;
  final double refundRate;
  final double successRate;
  final Map<String, double> gatewayDistribution;
  final Map<String, double> sceneDistribution;
  final Map<String, double> currencyDistribution;
  final double totalCommission;
  final double pendingSettlement;
  final int activeSubscriptions;
  final double monthlyRecurringRevenue;

  const PaymentSummary({
    required this.todayRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.annualRevenue,
    required this.totalTransactions,
    required this.completedTransactions,
    required this.avgOrderValue,
    required this.refundRate,
    required this.successRate,
    required this.gatewayDistribution,
    required this.sceneDistribution,
    required this.currencyDistribution,
    required this.totalCommission,
    required this.pendingSettlement,
    required this.activeSubscriptions,
    required this.monthlyRecurringRevenue,
  });

  factory PaymentSummary.initial() => PaymentSummary(
    todayRevenue: 52800,
    weeklyRevenue: 385600,
    monthlyRevenue: 1650000,
    annualRevenue: 19800000,
    totalTransactions: 12450,
    completedTransactions: 11820,
    avgOrderValue: 132.5,
    refundRate: 2.3,
    successRate: 95.2,
    gatewayDistribution: {
      '微信支付': 35.2,
      '支付宝': 22.8,
      'Stripe': 18.5,
      'PayPal': 10.2,
      '对公转账': 6.8,
      '数字货币': 4.5,
      'Apple Pay': 2.0,
    },
    sceneDistribution: {
      'SaaS订阅': 30.5,
      '设备销售': 25.2,
      'AI服务费': 20.8,
      '加盟费': 12.5,
      '课程购买': 8.0,
      '其他': 3.0,
    },
    currencyDistribution: {
      'CNY': 42.5,
      'USD': 30.2,
      'EUR': 12.8,
      'GBP': 5.5,
      'JPY': 4.0,
      'Crypto': 5.0,
    },
    totalCommission: 185000,
    pendingSettlement: 42500,
    activeSubscriptions: 3280,
    monthlyRecurringRevenue: 980000,
  );
}

/// SaaS订阅
class Subscription {
  final String subscriptionId;
  final String userId;
  final String userName;
  final SubscriptionTier tier;
  final Currency currency;
  final double amount;
  final String status;
  final bool autoRenew;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final int totalPayments;
  final double totalPaid;
  final String? lastInvoiceId;

  const Subscription({
    required this.subscriptionId,
    required this.userId,
    required this.userName,
    required this.tier,
    required this.currency,
    required this.amount,
    required this.status,
    required this.autoRenew,
    required this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.totalPayments = 0,
    this.totalPaid = 0,
    this.lastInvoiceId,
  });
}

/// 代理商结算记录
class AgentSettlement {
  final String settlementId;
  final String dealerId;
  final String dealerName;
  final AgentLevel level;
  final double totalSales;
  final double commissionRate;
  final double commissionAmount;
  final Currency currency;
  final PaymentGateway paymentMethod;
  final String status;
  final String period;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? transactionId;
  final String? invoiceUrl;

  const AgentSettlement({
    required this.settlementId,
    required this.dealerId,
    required this.dealerName,
    required this.level,
    required this.totalSales,
    required this.commissionRate,
    required this.commissionAmount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.period,
    required this.createdAt,
    this.paidAt,
    this.transactionId,
    this.invoiceUrl,
  });
}

/// 支付网关配置
class GatewayConfig {
  final PaymentGateway gateway;
  final bool enabled;
  final String? apiKey;
  final String? merchantId;
  final List<Currency> supportedCurrencies;
  final double feeRate;
  final double minAmount;
  final double maxAmount;
  final String? webhookUrl;
  final String status;
  final int dailyVolume;
  final double dailyRevenue;

  const GatewayConfig({
    required this.gateway,
    required this.enabled,
    this.apiKey,
    this.merchantId,
    required this.supportedCurrencies,
    required this.feeRate,
    this.minAmount = 0.01,
    this.maxAmount = 999999,
    this.webhookUrl,
    this.status = 'active',
    this.dailyVolume = 0,
    this.dailyRevenue = 0,
  });
}

/// 支付趋势点
class PaymentTrendPoint {
  final DateTime date;
  final double revenue;
  final int transactions;
  final double commission;

  const PaymentTrendPoint({
    required this.date,
    required this.revenue,
    required this.transactions,
    required this.commission,
  });
}

/// 账单/发票
class Invoice {
  final String invoiceId;
  final String orderId;
  final String recipientName;
  final String recipientEmail;
  final String? companyName;
  final String? taxId;
  final List<InvoiceItem> items;
  final Currency currency;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String status;
  final DateTime issuedDate;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? pdfUrl;

  const Invoice({
    required this.invoiceId,
    required this.orderId,
    required this.recipientName,
    required this.recipientEmail,
    this.companyName,
    this.taxId,
    required this.items,
    required this.currency,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    required this.issuedDate,
    required this.dueDate,
    this.paidDate,
    this.pdfUrl,
  });
}

/// 账单条目
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}
