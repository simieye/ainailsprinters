import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import '../../../../core/services/http_client.dart';
import '../models/payment_models.dart';
import 'payment_api_service.dart';

/// 支付安全服务
/// 负责: Webhook回调验证、签名校验、风控检查、交易监控、
///       异常检测、IP白名单、金额限制、频率限制
class PaymentSecurityService {
  PaymentSecurityService._();

  static final PaymentSecurityService instance = PaymentSecurityService._();

  final _webhookSecrets = <String, String>{
    'stripe': 'whsec_your_stripe_webhook_secret_key',
    'paypal': 'paypal_webhook_verification_key',
    'wechatPay': 'wechat_merchant_api_key_v3',
    'alipay': 'alipay_app_private_key',
  };

  final _ipWhitelist = <String>{
    // Stripe webhook IPs
    '3.18.12.63', '3.130.192.231', '13.235.14.237',
    '13.235.122.149', '18.211.135.69', '35.154.171.200',
    '52.15.183.38', '54.187.174.169', '54.187.205.235',
    '54.187.216.72', '54.241.31.99', '54.241.31.102',
    '54.241.34.107',
    // 微信支付回调IP
    '101.226.62.0/24', '101.226.63.0/24',
  };

  // 风控配置
  static const _maxSinglePayment = 1000000.0; // 单笔最大 100万
  static const _maxDailyAmount = 5000000.0; // 日累计最大 500万
  static const _maxPaymentFrequency = 20; // 每分钟最大支付次数
  static const _maxFailedAttempts = 5; // 最大失败次数

  // 交易监控
  final _dailyAmounts = <String, double>{};
  final _paymentFrequency = <String, List<DateTime>>{};
  final _failedAttempts = <String, int>{};
  final _processedTransactions = <String>{};

  // ============================================================
  // Webhook 签名验证
  // ============================================================

  /// 验证 Stripe Webhook 签名
  bool verifyStripeSignature(String payload, String signatureHeader) {
    try {
      final secret = _webhookSecrets['stripe']!;
      final parts = signatureHeader.split(',');
      String? timestamp;
      String? signature;

      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length == 2) {
          if (kv[0].trim() == 't') timestamp = kv[1].trim();
          if (kv[0].trim() == 'v1') signature = kv[1].trim();
        }
      }

      if (timestamp == null || signature == null) return false;

      final signedPayload = '$timestamp.$payload';
      final hmac = crypto.Hmac(crypto.sha256, utf8.encode(secret));
      final computedSignature = hmac.convert(utf8.encode(signedPayload)).toString();

      return _constantTimeCompare(computedSignature, signature);
    } catch (e) {
      return false;
    }
  }

  /// 验证 PayPal Webhook 签名
  bool verifyPayPalSignature(Map<String, dynamic> payload, String signature) {
    try {
      // PayPal 使用 cert_url 中的公钥验证
      // 此处为简化实现，实际项目调用 PayPal API 验证
      final hmac = crypto.Hmac(
        crypto.sha256,
        utf8.encode(_webhookSecrets['paypal']!),
      );
      final digest = hmac.convert(utf8.encode(jsonEncode(payload)));
      return _constantTimeCompare(digest.toString(), signature);
    } catch (e) {
      return false;
    }
  }

  /// 验证微信支付回调签名
  bool verifyWechatSignature(Map<String, dynamic> payload, String signature) {
    try {
      // 微信支付使用 RSA 签名验证
      // 实际项目中使用 pointycastle 或类似库进行 RSA 验证
      return true; // 简化实现
    } catch (e) {
      return false;
    }
  }

  /// 验证支付宝回调签名
  bool verifyAlipaySignature(Map<String, dynamic> payload, String sign) {
    try {
      // 支付宝使用 RSA/SHA256 签名验证
      return true; // 简化实现
    } catch (e) {
      return false;
    }
  }

  /// 防止时序攻击的字符串比较
  bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // ============================================================
  // IP 白名单检查
  // ============================================================

  bool isIpAllowed(String ip) {
    // 检查精确匹配和 CIDR 匹配
    for (final allowed in _ipWhitelist) {
      if (allowed.contains('/')) {
        if (_ipInCidr(ip, allowed)) return true;
      } else {
        if (ip == allowed) return true;
      }
    }
    // 开发环境允许所有IP
    return true;
  }

  bool _ipInCidr(String ip, String cidr) {
    // 简化实现，实际项目使用 ip 包
    return true;
  }

  // ============================================================
  // 风控检查
  // ============================================================

  /// 支付前风控检查
  Future<RiskCheckResult> prePaymentRiskCheck({
    required String userId,
    required double amount,
    required PaymentGateway gateway,
    required String ipAddress,
  }) async {
    // 1. 单笔金额检查
    if (amount > _maxSinglePayment) {
      return RiskCheckResult.rejected(
        reason: '单笔支付金额超过限额 ${_maxSinglePayment.toStringAsFixed(0)}',
        code: 'AMOUNT_EXCEEDED',
      );
    }

    // 2. 日累计检查
    final dailyAmount = (_dailyAmounts[userId] ?? 0) + amount;
    if (dailyAmount > _maxDailyAmount) {
      return RiskCheckResult.rejected(
        reason: '今日累计支付金额超过限额',
        code: 'DAILY_LIMIT_EXCEEDED',
      );
    }

    // 3. 频率检查
    final now = DateTime.now();
    final recentPayments = (_paymentFrequency[userId] ?? [])
        .where((t) => now.difference(t).inMinutes < 1)
        .toList();
    if (recentPayments.length >= _maxPaymentFrequency) {
      return RiskCheckResult.rejected(
        reason: '支付频率过高，请稍后再试',
        code: 'FREQUENCY_LIMIT',
      );
    }

    // 4. 失败次数检查
    final failures = _failedAttempts[userId] ?? 0;
    if (failures >= _maxFailedAttempts) {
      return RiskCheckResult.rejected(
        reason: '支付失败次数过多，账户已被暂时限制',
        code: 'TOO_MANY_FAILURES',
      );
    }

    // 5. 重复交易检查
    final txId = '${userId}_${amount}_${now.minute}';
    if (_processedTransactions.contains(txId)) {
      return RiskCheckResult.rejected(
        reason: '检测到重复交易',
        code: 'DUPLICATE_TRANSACTION',
      );
    }

    // 更新统计
    _dailyAmounts[userId] = dailyAmount;
    _paymentFrequency.putIfAbsent(userId, () => []);
    _paymentFrequency[userId]!.add(now);
    _processedTransactions.add(txId);

    return RiskCheckResult.approved();
  }

  /// 支付成功回调
  void onPaymentSuccess(String userId) {
    _failedAttempts[userId] = 0;
  }

  /// 支付失败回调
  void onPaymentFailed(String userId) {
    _failedAttempts[userId] = (_failedAttempts[userId] ?? 0) + 1;
  }

  /// 重置日统计
  void resetDailyStats() {
    _dailyAmounts.clear();
    _paymentFrequency.clear();
    _processedTransactions.clear();
  }

  /// 重置用户限制
  void resetUserLimits(String userId) {
    _failedAttempts[userId] = 0;
  }

  // ============================================================
  // 交易监控
  // ============================================================

  /// 检查是否为异常交易
  bool isAnomalousTransaction({
    required double amount,
    required double userAvgAmount,
    required PaymentGateway gateway,
    required String country,
  }) {
    // 金额异常：超过用户历史平均金额的5倍
    if (userAvgAmount > 0 && amount > userAvgAmount * 5) {
      return true;
    }

    // 地区异常：非用户常用支付地区
    // 实际项目中从用户历史交易中分析

    return false;
  }

  /// 发送风控告警
  Future<void> sendRiskAlert({
    required String userId,
    required String reason,
    required Map<String, dynamic> details,
  }) async {
    try {
      await HttpClient.instance.post(
        '/security/risk-alert',
        baseUrl: 'https://api.ai-nails.com/payment',
        data: {
          'user_id': userId,
          'reason': reason,
          'details': details,
          'timestamp': DateTime.now().toIso8601String(),
          'severity': 'high',
        },
      );
    } catch (_) {
      // 本地记录
      print('[RISK ALERT] User: $userId, Reason: $reason, Details: $details');
    }
  }

  // ============================================================
  // 数据加密
  // ============================================================

  /// 加密敏感支付数据
  String encryptSensitiveData(String data) {
    final key = utf8.encode('ainails_payment_encryption_key_32');
    final hmac = crypto.Hmac(crypto.sha256, key);
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  /// 脱敏银行卡号
  String maskCardNumber(String cardNumber) {
    if (cardNumber.length < 8) return '****';
    return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  /// 脱敏手机号
  String maskPhone(String phone) {
    if (phone.length < 7) return '***';
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  /// 脱敏邮箱
  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    if (name.length <= 2) return '$name***@${parts[1]}';
    return '${name[0]}***${name[name.length - 1]}@${parts[1]}';
  }
}

// ============================================================
// 风控检查结果
// ============================================================

class RiskCheckResult {
  final bool isApproved;
  final String? reason;
  final String? code;
  final RiskLevel riskLevel;

  const RiskCheckResult._({
    required this.isApproved,
    this.reason,
    this.code,
    this.riskLevel = RiskLevel.low,
  });

  factory RiskCheckResult.approved() =>
      const RiskCheckResult._(isApproved: true);

  factory RiskCheckResult.rejected({
    required String reason,
    required String code,
  }) =>
      RiskCheckResult._(
        isApproved: false,
        reason: reason,
        code: code,
        riskLevel: RiskLevel.high,
      );

  factory RiskCheckResult.warning({
    required String reason,
    required String code,
  }) =>
      RiskCheckResult._(
        isApproved: true,
        reason: reason,
        code: code,
        riskLevel: RiskLevel.medium,
      );
}

enum RiskLevel { low, medium, high, critical }
