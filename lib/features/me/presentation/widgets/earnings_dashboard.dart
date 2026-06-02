import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/creator_profile.dart';

class EarningsDashboard extends StatelessWidget {
  final CreatorProfile profile;
  const EarningsDashboard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryNeonGreen.withOpacity(0.08),
              AppTheme.accentNeonCyan.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryNeonGreen.withOpacity(0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: AppTheme.primaryNeonGreen),
                SizedBox(width: 8),
                Text(
                  '收益看板',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildEarningCard(
                  '本月收入',
                  '\$${profile.monthlyEarnings}',
                  AppTheme.primaryNeonGreen,
                  Icons.trending_up,
                ),
                const SizedBox(width: 12),
                _buildEarningCard(
                  'Prompt分成',
                  '\$${profile.promptAssetRevenue}',
                  AppTheme.secondaryNeonPurple,
                  Icons.auto_awesome,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEarningCard(
                  '累计收入',
                  '\$${profile.totalEarnings}',
                  AppTheme.accentNeonCyan,
                  Icons.savings,
                ),
                const SizedBox(width: 12),
                _buildEarningCard(
                  '粉丝打赏',
                  '\$520',
                  AppTheme.accentNeonPink,
                  Icons.favorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgSurfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
