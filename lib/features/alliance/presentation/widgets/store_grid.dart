import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/business_metrics.dart';

class StoreGrid extends StatelessWidget {
  final List<StoreMetrics> stores;
  const StoreGrid({super.key, required this.stores});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.store_mall_directory, size: 16, color: AppTheme.warningNeonOrange),
                SizedBox(width: 8),
                Text(
                  '多店并联营收管理',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  '6家门店',
                  style: TextStyle(fontSize: 12, color: AppTheme.textHint),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...stores.map((store) => _StoreRow(store: store)),
          ],
        ),
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  final StoreMetrics store;
  const _StoreRow({required this.store});

  @override
  Widget build(BuildContext context) {
    final isOnline = store.status == 'online';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 状态灯
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppTheme.primaryNeonGreen : AppTheme.warningNeonOrange,
              boxShadow: [
                BoxShadow(
                  color: (isOnline ? AppTheme.primaryNeonGreen : AppTheme.warningNeonOrange)
                      .withOpacity(0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // 店名
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.storeName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '开机率 ${(store.uptimePercent * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
          ),
          
          // 打印量
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${store.todayPrints}次',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  '今日打印',
                  style: TextStyle(fontSize: 10, color: AppTheme.textHint),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // 营收
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${store.todayRevenue}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNeonGreen,
                  ),
                ),
                const Text(
                  '今日营收',
                  style: TextStyle(fontSize: 10, color: AppTheme.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
