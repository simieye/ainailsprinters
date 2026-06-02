import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';

/// 支付集成通用组件 - 用于嵌入各系统页面的支付快捷入口

/// 支付快捷操作卡片（用于嵌入品牌总部等仪表盘）
class PaymentQuickActions extends StatelessWidget {
  final VoidCallback? onViewAll;

  const PaymentQuickActions({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.payments, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '全球支付中枢',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll ?? () => context.go('/admin/payments'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('进入支付中心 →',
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAction(
                icon: Icons.credit_card,
                label: '新交易',
                color: AppTheme.primaryNeonGreen,
                onTap: () => context.go('/admin/payments'),
              ),
              const SizedBox(width: 8),
              _QuickAction(
                icon: Icons.receipt_long,
                label: '开发票',
                color: const Color(0xFF00E5FF),
                onTap: () => context.go('/admin/payments'),
              ),
              const SizedBox(width: 8),
              _QuickAction(
                icon: Icons.account_balance,
                label: '代理商结算',
                color: const Color(0xFFB44CFF),
                onTap: () => context.go('/admin/payments'),
              ),
              const SizedBox(width: 8),
              _QuickAction(
                icon: Icons.repeat,
                label: '订阅管理',
                color: const Color(0xFFFF8C00),
                onTap: () => context.go('/admin/payments'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 经销商/门店支付信息卡片
class PaymentInfoCard extends StatelessWidget {
  final String title;
  final double monthlyRevenue;
  final double commissionRate;
  final int paymentCount;
  final String? lastPaymentMethod;
  final VoidCallback? onViewDetails;

  const PaymentInfoCard({
    super.key,
    required this.title,
    required this.monthlyRevenue,
    this.commissionRate = 0,
    required this.paymentCount,
    this.lastPaymentMethod,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const Icon(Icons.payments, color: Color(0xFFFFD700), size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem('月营收', '¥${(monthlyRevenue / 10000).toStringAsFixed(1)}万'),
              _infoItem('支付笔数', '$paymentCount'),
              if (commissionRate > 0)
                _infoItem('佣金率', '${(commissionRate * 100).toStringAsFixed(0)}%'),
            ],
          ),
          if (lastPaymentMethod != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('最近支付: ',
                    style: TextStyle(color: AppTheme.textHint, fontSize: 10)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(lastPaymentMethod!,
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// 用户支付信息卡片
class UserPaymentCard extends StatelessWidget {
  final String userName;
  final double totalSpent;
  final String memberLevel;
  final int subscriptionTier; // 0:none, 1:basic, 2:pro, 3:business, 4:enterprise
  final VoidCallback? onViewDetails;

  const UserPaymentCard({
    super.key,
    required this.userName,
    required this.totalSpent,
    required this.memberLevel,
    required this.subscriptionTier,
    this.onViewDetails,
  });

  static const _tierNames = ['无订阅', 'Basic', 'Pro', 'Business', 'Enterprise'];
  static const _tierPrices = [0, 29, 99, 299, 999];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(userName,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const Icon(Icons.payments, color: Color(0xFFFFD700), size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem('累计消费', '¥${totalSpent.toStringAsFixed(0)}'),
              _infoItem('会员等级', memberLevel),
              _infoItem('订阅', subscriptionTier > 0
                  ? '${_tierNames[subscriptionTier]} \$ ${_tierPrices[subscriptionTier]}/月'
                  : '无'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// 支持的支付方式展示
class SupportedPaymentsBar extends StatelessWidget {
  const SupportedPaymentsBar({super.key});

  static const _methods = [
    ('微信支付', 0xFFFF2D95),
    ('支付宝', 0xFF00E5FF),
    ('Stripe', 0xFFB44CFF),
    ('PayPal', 0xFFFF8C00),
    ('对公转账', 0xFF00FF88),
    ('USDT/BTC', 0xFFFFD700),
    ('Apple Pay', 0xFFC0C0C0),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _methods.map((m) {
          return Tooltip(
            message: m.$1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(m.$2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(m.$2).withOpacity(0.5), blurRadius: 4),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
