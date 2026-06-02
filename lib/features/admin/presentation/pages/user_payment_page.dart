import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/payment_models.dart';
import '../../domain/services/payment_api_service.dart';

/// 用户端支付页面 — 充值 / 订阅购买 / 订单支付
/// 支持所有支付网关，智能路由选择最佳支付方式
class UserPaymentPage extends ConsumerStatefulWidget {
  final PaymentScene scene;
  final double? amount;
  final Currency? currency;
  final String? description;
  final SubscriptionTier? subscriptionTier;

  const UserPaymentPage({
    super.key,
    this.scene = PaymentScene.userRecharge,
    this.amount,
    this.currency,
    this.description,
    this.subscriptionTier,
  });

  @override
  ConsumerState<UserPaymentPage> createState() => _UserPaymentPageState();
}

class _UserPaymentPageState extends ConsumerState<UserPaymentPage> {
  // 金额输入
  late TextEditingController _amountController;
  late Currency _selectedCurrency;
  double _currentAmount = 0;

  // 订阅选择
  SubscriptionTier _selectedTier = SubscriptionTier.pro;

  // 支付方式
  PaymentGateway? _selectedGateway;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  PaymentOrderResult? _orderResult;

  // 汇率
  double _exchangeRate = 1.0;
  double _cnyAmount = 0;

  // 预定义充值金额
  static const _rechargePresets = [50.0, 100.0, 200.0, 500.0, 1000.0, 5000.0];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.amount?.toStringAsFixed(0) ?? '100',
    );
    _selectedCurrency = widget.currency ?? Currency.cny;
    _currentAmount = widget.amount ?? 100;
    _amountController.addListener(_onAmountChanged);
    _loadExchangeRate();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final value = double.tryParse(_amountController.text);
    if (value != null && value > 0) {
      setState(() {
        _currentAmount = value;
        _cnyAmount = value * _exchangeRate;
      });
    }
  }

  Future<void> _loadExchangeRate() async {
    try {
      final rate = await PaymentApiService.instance.convertCurrency(
        amount: 1,
        from: _selectedCurrency,
        to: Currency.cny,
      );
      if (mounted) {
        setState(() {
          _exchangeRate = rate;
          _cnyAmount = _currentAmount * rate;
        });
      }
    } catch (_) {}
  }

  // ============================================================
  // 发起支付
  // ============================================================

  Future<void> _handlePayment(PaymentGateway gateway) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _selectedGateway = gateway;
    });

    final result = await PaymentApiService.instance.createPaymentOrder(
      gateway: gateway,
      scene: widget.scene,
      currency: _selectedCurrency,
      amount: widget.subscriptionTier != null
          ? widget.subscriptionTier!.monthlyPrice
          : _currentAmount,
      description: widget.description ?? _sceneLabel(widget.scene),
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _orderResult = result;
    });

    if (result.isSuccess) {
      setState(() => _successMessage = '支付订单已创建: ${result.orderId}');

      // 根据支付方式引导用户完成支付
      if (result.checkoutUrl != null) {
        // 打开 WebView 完成支付 (Stripe Checkout / PayPal)
        _showCheckoutWebView(result.checkoutUrl!);
      } else if (result.qrCodeUrl != null) {
        // 显示二维码让用户扫码支付
        _showQrCodeDialog(result);
      } else if (result.walletAddress != null) {
        // 显示钱包地址
        _showCryptoPaymentDialog(result);
      } else if (result.bankInfo != null) {
        // 显示对公转账信息
        _showBankTransferDialog(result);
      } else if (result.appPayData != null) {
        // 唤起APP支付
        _triggerAppPayment(result);
      } else {
        // 模拟支付成功
        _simulatePaymentSuccess(result);
      }
    } else {
      setState(() => _errorMessage = result.message ?? '支付失败');
    }
  }

  void _showCheckoutWebView(String url) {
    // 实际项目中使用 webview_flutter
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardDark,
        title: const Text('完成支付',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('即将跳转到支付页面...\n$url',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _simulatePaymentSuccess(_orderResult!);
            },
            child: const Text('模拟支付成功',
                style: TextStyle(color: AppTheme.primaryNeonGreen)),
          ),
        ],
      ),
    );
  }

  void _showQrCodeDialog(PaymentOrderResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${result.gateway?.displayName ?? ''}扫码支付',
            style: const TextStyle(color: AppTheme.textPrimary),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 模拟二维码
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 100, color: Colors.black.withOpacity(0.8)),
                    const SizedBox(height: 8),
                    Text('订单: ${result.orderId}',
                        style: const TextStyle(color: Colors.black, fontSize: 10)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('${result.currency?.symbol ?? ''}${result.amount?.toStringAsFixed(2) ?? ''}',
                style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('请使用对应App扫描二维码完成支付',
                style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _simulatePaymentSuccess(result);
            },
            child: const Text('模拟支付成功',
                style: TextStyle(color: AppTheme.primaryNeonGreen)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showCryptoPaymentDialog(PaymentOrderResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.currency_bitcoin, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Text('${result.gateway?.displayName ?? '数字货币'}支付',
                style: const TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.qr_code_2, size: 150, color: Colors.black.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgSurfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('转账地址',
                      style: TextStyle(color: AppTheme.textHint, fontSize: 11)),
                  const SizedBox(height: 4),
                  SelectableText(
                    result.walletAddress ?? '',
                    style: const TextStyle(
                      color: AppTheme.primaryNeonGreen,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('${result.currency?.symbol ?? ''}${result.amount?.toStringAsFixed(6) ?? ''}',
                style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('≈ ¥${(_cnyAmount).toStringAsFixed(2)} CNY',
                style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _simulatePaymentSuccess(result);
            },
            child: const Text('已完成转账',
                style: TextStyle(color: AppTheme.primaryNeonGreen)),
          ),
        ],
      ),
    );
  }

  void _showBankTransferDialog(PaymentOrderResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.account_balance, color: AppTheme.primaryNeonGreen),
            SizedBox(width: 8),
            Text('对公转账', style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bankInfoRow('公司名称', result.bankInfo!.companyName),
            _bankInfoRow('英文名称', result.bankInfo!.companyNameEn),
            _bankInfoRow('开户银行', result.bankInfo!.bankName),
            _bankInfoRow('银行账号', result.bankInfo!.accountNumber),
            _bankInfoRow('统一信用代码', result.bankInfo!.unifiedCode),
            _bankInfoRow('注册地址', result.bankInfo!.address),
            const Divider(color: AppTheme.borderGlow),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('转账金额', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                Text('${result.currency?.symbol ?? ''}${result.amount?.toStringAsFixed(2) ?? ''}',
                    style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            Text('订单号: ${result.orderId}',
                style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _bankInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
          const SizedBox(height: 2),
          SelectableText(value,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }

  void _triggerAppPayment(PaymentOrderResult result) {
    // 实际项目中调用微信/支付宝 SDK 唤起支付
    _simulatePaymentSuccess(result);
  }

  void _simulatePaymentSuccess(PaymentOrderResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryNeonGreen, size: 32),
            SizedBox(width: 8),
            Text('支付成功', style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: AppTheme.primaryNeonGreen, size: 48),
            const SizedBox(height: 16),
            Text('${result.currency?.symbol ?? ''}${result.amount?.toStringAsFixed(2) ?? ''}',
                style: const TextStyle(color: AppTheme.primaryNeonGreen, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('订单号: ${result.orderId}',
                style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNeonGreen,
              foregroundColor: AppTheme.bgDeepDark,
            ),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  String _sceneLabel(PaymentScene scene) {
    switch (scene) {
      case PaymentScene.userRecharge: return '账户充值';
      case PaymentScene.saasSubscription: return 'SaaS订阅';
      case PaymentScene.deviceSale: return '设备购买';
      case PaymentScene.aiServiceFee: return 'AI服务费';
      case PaymentScene.coursePurchase: return '课程购买';
      default: return 'AI NAILS 支付';
    }
  }

  // ============================================================
  // UI Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeepDark,
      appBar: AppBar(
        title: Text(_sceneLabel(widget.scene)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 场景选择
            if (widget.subscriptionTier != null)
              _buildSubscriptionSection()
            else
              _buildAmountSection(),

            const SizedBox(height: 24),

            // 币种选择
            _buildCurrencySelector(),
            const SizedBox(height: 24),

            // 支付方式选择
            const SectionTitle(title: '选择支付方式'),
            const SizedBox(height: 12),
            _buildPaymentGateways(),
            const SizedBox(height: 24),

            // 支付信息摘要
            _buildPaymentSummary(),

            // 消息
            if (_errorMessage != null) _buildMessageBanner(_errorMessage!, false),
            if (_successMessage != null) _buildMessageBanner(_successMessage!, true),

            const SizedBox(height: 24),

            // 支付按钮
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: '充值金额'),
        const SizedBox(height: 12),
        // 预设金额
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _rechargePresets.map((amount) {
            final isSelected = _currentAmount == amount;
            return GestureDetector(
              onTap: () {
                _amountController.text = amount.toStringAsFixed(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryNeonGreen.withOpacity(0.15)
                      : AppTheme.bgCardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryNeonGreen.withOpacity(0.5)
                        : AppTheme.borderGlow.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${_selectedCurrency.symbol}${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryNeonGreen : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // 自定义金额
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            color: AppTheme.primaryNeonGreen,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Text(_selectedCurrency.symbol,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 24)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderGlow.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderGlow.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryNeonGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: '选择套餐'),
        const SizedBox(height: 12),
        ...SubscriptionTier.values.map((tier) {
          final isSelected = _selectedTier == tier;
          final isRecommended = tier == SubscriptionTier.business;
          return GestureDetector(
            onTap: () => setState(() => _selectedTier = tier),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryNeonGreen.withOpacity(0.08)
                    : AppTheme.bgCardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryNeonGreen.withOpacity(0.5)
                      : AppTheme.borderGlow.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(tier.displayName,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            if (isRecommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryNeonGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('推荐',
                                    style: TextStyle(
                                        color: AppTheme.primaryNeonGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(_tierDescription(tier),
                            style: const TextStyle(
                                color: AppTheme.textHint, fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${Currency.usd.symbol}${tier.monthlyPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: AppTheme.primaryNeonGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                      ),
                      const Text('/月',
                          style: TextStyle(
                              color: AppTheme.textHint, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _tierDescription(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return '基础功能 · 100次AI生成 · 基础模板库';
      case SubscriptionTier.pro:
        return '专业功能 · 无限AI生成 · 全模板库 · 优先支持';
      case SubscriptionTier.business:
        return '商业功能 · 多店管理 · API接口 · 数据分析 · 白标';
      case SubscriptionTier.enterprise:
        return '企业功能 · 定制开发 · 专属服务器 · SLA保障 · 培训';
    }
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: '支付币种'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Currency.cny,
              Currency.usd,
              Currency.eur,
              Currency.gbp,
              Currency.jpy,
              Currency.usdt,
              Currency.btc,
            ].map((currency) {
              final isSelected = _selectedCurrency == currency;
              return GestureDetector(
                onTap: () async {
                  setState(() => _selectedCurrency = currency);
                  await _loadExchangeRate();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryNeonGreen.withOpacity(0.15)
                        : AppTheme.bgCardDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryNeonGreen.withOpacity(0.5)
                          : AppTheme.borderGlow.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(currency.symbol,
                          style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryNeonGreen
                                  : AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      Text(currency.name,
                          style: TextStyle(
                              color: AppTheme.textHint, fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentGateways() {
    // 根据地区和币种智能排序支付方式
    final gateways = _getAvailableGateways();

    return Column(
      children: [
        // 推荐支付方式
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('💡 推荐', style: TextStyle(color: AppTheme.textHint, fontSize: 11)),
        ),
        ...gateways.where((g) => _isRecommended(g)).map(_buildGatewayOption),
        const SizedBox(height: 12),
        // 更多支付方式
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('更多支付方式', style: TextStyle(color: AppTheme.textHint, fontSize: 11)),
        ),
        ...gateways.where((g) => !_isRecommended(g)).map(_buildGatewayOption),
      ],
    );
  }

  List<PaymentGateway> _getAvailableGateways() {
    // 根据币种过滤可用的支付方式
    if (_selectedCurrency == Currency.cny) {
      return [
        PaymentGateway.wechatPay,
        PaymentGateway.alipay,
        PaymentGateway.bankTransfer,
        PaymentGateway.stripe,
        PaymentGateway.paypal,
        PaymentGateway.applePay,
        PaymentGateway.googlePay,
        PaymentGateway.usdt,
      ];
    }
    return [
      PaymentGateway.stripe,
      PaymentGateway.paypal,
      PaymentGateway.applePay,
      PaymentGateway.googlePay,
      PaymentGateway.usdt,
      PaymentGateway.usdc,
      PaymentGateway.btc,
      PaymentGateway.eth,
    ];
  }

  bool _isRecommended(PaymentGateway gateway) {
    if (_selectedCurrency == Currency.cny) {
      return gateway == PaymentGateway.wechatPay ||
          gateway == PaymentGateway.alipay;
    }
    return gateway == PaymentGateway.stripe ||
        gateway == PaymentGateway.applePay;
  }

  Widget _buildGatewayOption(PaymentGateway gateway) {
    final isSelected = _selectedGateway == gateway;
    return GestureDetector(
      onTap: () => setState(() => _selectedGateway = gateway),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryNeonGreen.withOpacity(0.08)
              : AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryNeonGreen.withOpacity(0.5)
                : AppTheme.borderGlow.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _gatewayColor(gateway).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_gatewayIcon(gateway),
                  color: _gatewayColor(gateway), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gateway.displayName,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(_gatewayDescription(gateway),
                      style: const TextStyle(
                          color: AppTheme.textHint, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppTheme.primaryNeonGreen, size: 24),
          ],
        ),
      ),
    );
  }

  Color _gatewayColor(PaymentGateway gateway) {
    switch (gateway) {
      case PaymentGateway.wechatPay: return const Color(0xFF07C160);
      case PaymentGateway.alipay: return const Color(0xFF1677FF);
      case PaymentGateway.stripe: return const Color(0xFF635BFF);
      case PaymentGateway.paypal: return const Color(0xFF003087);
      case PaymentGateway.applePay: return Colors.white;
      case PaymentGateway.googlePay: return const Color(0xFF4285F4);
      case PaymentGateway.usdt: return const Color(0xFF26A17B);
      case PaymentGateway.btc: return const Color(0xFFF7931A);
      case PaymentGateway.eth: return const Color(0xFF627EEA);
      default: return AppTheme.textSecondary;
    }
  }

  IconData _gatewayIcon(PaymentGateway gateway) {
    switch (gateway) {
      case PaymentGateway.wechatPay: return Icons.chat_bubble;
      case PaymentGateway.alipay: return Icons.account_balance_wallet;
      case PaymentGateway.stripe: return Icons.credit_card;
      case PaymentGateway.paypal: return Icons.monetization_on;
      case PaymentGateway.applePay: return Icons.apple;
      case PaymentGateway.googlePay: return Icons.android;
      case PaymentGateway.bankTransfer: return Icons.account_balance;
      case PaymentGateway.usdt: case PaymentGateway.usdc: return Icons.token;
      case PaymentGateway.btc: return Icons.currency_bitcoin;
      case PaymentGateway.eth: return Icons.diamond;
      default: return Icons.payment;
    }
  }

  String _gatewayDescription(PaymentGateway gateway) {
    switch (gateway) {
      case PaymentGateway.wechatPay: return '微信扫码/APP支付 · 即时到账';
      case PaymentGateway.alipay: return '支付宝扫码/APP支付 · 即时到账';
      case PaymentGateway.stripe: return 'Visa/Mastercard/Amex · 全球通用';
      case PaymentGateway.paypal: return 'PayPal余额/信用卡 · 买家保护';
      case PaymentGateway.applePay: return 'Face ID/Touch ID · 一键支付';
      case PaymentGateway.googlePay: return 'Android设备 · 一键支付';
      case PaymentGateway.bankTransfer: return '企业对公转账 · 1-3工作日';
      case PaymentGateway.usdt: return 'USDT-TRC20 · 即时到账';
      case PaymentGateway.usdc: return 'USDC-ERC20 · 即时到账';
      case PaymentGateway.btc: return 'Bitcoin网络 · 1-6确认';
      case PaymentGateway.eth: return 'Ethereum网络 · 12确认';
      default: return '';
    }
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _summaryRow('支付金额', '${_selectedCurrency.symbol}${widget.subscriptionTier != null ? widget.subscriptionTier!.monthlyPrice.toStringAsFixed(0) : _currentAmount.toStringAsFixed(2)}'),
          if (_selectedCurrency != Currency.cny) ...[
            const SizedBox(height: 4),
            _summaryRow('≈ 人民币', '¥${_cnyAmount.toStringAsFixed(2)}'),
          ],
          const SizedBox(height: 4),
          _summaryRow('支付场景', _sceneLabel(widget.scene)),
          if (_selectedGateway != null) ...[
            const SizedBox(height: 4),
            _summaryRow('支付方式', _selectedGateway!.displayName),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMessageBanner(String message, bool isSuccess) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isSuccess ? AppTheme.primaryNeonGreen : AppTheme.accentNeonPink)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isSuccess ? AppTheme.primaryNeonGreen : AppTheme.accentNeonPink)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error_outline,
            color: isSuccess ? AppTheme.primaryNeonGreen : AppTheme.accentNeonPink,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: isSuccess
                        ? AppTheme.primaryNeonGreen
                        : AppTheme.accentNeonPink,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: (_selectedGateway != null && !_isLoading)
            ? () => _handlePayment(_selectedGateway!)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryNeonGreen,
          foregroundColor: AppTheme.bgDeepDark,
          disabledBackgroundColor: AppTheme.primaryNeonGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: AppTheme.bgDeepDark, strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('处理中...', style: TextStyle(fontSize: 16)),
                ],
              )
            : Text(
                _selectedGateway == null
                    ? '请选择支付方式'
                    : '确认支付 ${_selectedCurrency.symbol}${widget.subscriptionTier != null ? widget.subscriptionTier!.monthlyPrice.toStringAsFixed(0) : _currentAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

/// 区块标题
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primaryNeonGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(subtitle!,
              style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
        ],
      ],
    );
  }
}
