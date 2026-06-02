import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/business_metrics.dart';

class TopDesignsRanking extends StatelessWidget {
  final List<DesignRanking> designs;
  const TopDesignsRanking({super.key, required this.designs});

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
                Icon(Icons.local_fire_department, size: 16, color: AppTheme.accentNeonPink),
                SizedBox(width: 8),
                Text(
                  '热点图案排行',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...designs.asMap().entries.map((e) {
              final rank = e.key + 1;
              final design = e.value;
              return _RankingRow(
                rank: rank,
                name: design.name,
                prints: design.prints,
                revenue: design.revenue,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int rank;
  final String name;
  final int prints;
  final double revenue;

  const _RankingRow({
    required this.rank,
    required this.name,
    required this.prints,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppTheme.textHint,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGlow.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // 排名
          SizedBox(
            width: 24,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 名称
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          // 打印量
          SizedBox(
            width: 50,
            child: Text(
              '$prints次',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 营收
          SizedBox(
            width: 60,
            child: Text(
              '\$${revenue.toInt()}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNeonGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
