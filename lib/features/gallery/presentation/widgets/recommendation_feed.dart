import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';

/// 太极64卦偏好推荐矩阵 - 卡片式流推荐
class RecommendationFeed extends ConsumerWidget {
  const RecommendationFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(userPreferencesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPurple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '太极64卦 · 为你推荐',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.refresh,
                size: 16,
                color: AppTheme.secondaryNeonPurple.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                '基于你的偏好更新',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // 偏好标签云
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: preferences.entries
                .where((e) => e.value > 0.5)
                .map((e) => _PreferenceChip(
                      label: _getLabel(e.key),
                      value: e.value,
                      icon: _getIcon(e.key),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          
          // 推荐卡片横滚
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _RecommendationCard(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel(String key) {
    return switch (key) {
      'cyberpunk' => '赛博朋克',
      'minimalist' => '极简',
      'floral' => '花卉',
      'geometric' => '几何',
      'gradient' => '渐变',
      _ => key,
    };
  }

  IconData _getIcon(String key) {
    return switch (key) {
      'cyberpunk' => Icons.memory,
      'minimalist' => Icons.auto_fix_high,
      'floral' => Icons.local_florist,
      'geometric' => Icons.hexagon,
      'gradient' => Icons.gradient,
      _ => Icons.auto_awesome,
    };
  }
}

class _PreferenceChip extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _PreferenceChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNeonPurple.withOpacity(value * 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryNeonPurple.withOpacity(value * 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.secondaryNeonPurple),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryNeonPurple.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.secondaryNeonPurple.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final int index;
  const _RecommendationCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final titles = [
      '赛博霓虹', '极光之舞', '暗夜玫瑰',
      '星空渐变', '国风竹韵', '几何脉冲',
    ];

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderGlow.withOpacity(0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondaryNeonPurple.withOpacity(0.3),
                        AppTheme.primaryNeonGreen.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 28,
                      color: AppTheme.secondaryNeonPurple.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: AppTheme.bgCardDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        titles[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '匹配度 ${85 + index * 2}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textHint,
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
    );
  }
}
