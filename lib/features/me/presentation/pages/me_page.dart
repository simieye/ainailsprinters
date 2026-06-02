import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../domain/models/creator_profile.dart';
import '../widgets/creator_stats_card.dart';
import '../widgets/prompt_asset_card.dart';
import '../widgets/earnings_dashboard.dart';
import '../widgets/community_feed.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({super.key});

  @override
  ConsumerState<MePage> createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = CreatorProfile(
      id: 'creator_001',
      name: 'NailArt_Master',
      avatarUrl: '',
      bio: 'AI美甲设计师 · 赛博朋克风格专家 · 全球Top100创作者',
      followers: 12800,
      following: 342,
      totalDesigns: 156,
      totalPrints: 45230,
      totalEarnings: 28650,
      monthlyEarnings: 3420,
      promptAssetRevenue: 1580,
      level: 'Diamond',
      badges: const ['Top Creator', 'Verified', 'TrendSetter', '100K Prints'],
      joinedAt: DateTime(2024, 6, 15),
    );

    ref.read(creatorProfileProvider.notifier).state = profile;

    final assets = List.generate(8, (i) => PromptAsset.mock(i));
    ref.read(creatorAssetsProvider.notifier).state = assets;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(creatorProfileProvider);
    final assets = ref.watch(creatorAssetsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部个人资料
            SliverToBoxAdapter(
              child: _buildProfileHeader(profile),
            ),

            // 创作者统计
            SliverToBoxAdapter(
              child: CreatorStatsCard(profile: profile),
            ),

            // 收益仪表盘
            SliverToBoxAdapter(
              child: EarningsDashboard(profile: profile),
            ),

            // 提示词资产
            SliverToBoxAdapter(
              child: _buildPromptAssetsSection(assets),
            ),

            // 等级与成就
            SliverToBoxAdapter(
              child: _buildLevelSection(profile),
            ),

            // 全球社区动态
            SliverToBoxAdapter(
              child: const CommunityFeed(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(CreatorProfile profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          // 头像和等级
          Row(
            children: [
              // 头像
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.gradientCyber,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryNeonPurple.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // 名称和等级
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.bio,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // 等级徽章
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB9F2FF), Color(0xFFE0B0FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '💎 Diamond Creator',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.bgDeepDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 设置
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 勋章
          Wrap(
            spacing: 8,
            children: profile.badges.map((badge) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.bgSurfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderGlow.withOpacity(0.3),
                ),
              ),
              child: Text(
                '🏅 $badge',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptAssetsSection(List<PromptAsset> assets) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: AppTheme.secondaryNeonPurple),
                  SizedBox(width: 8),
                  Text(
                    '我的提示词资产',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryNeonPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: assets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return PromptAssetCard(asset: assets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSection(CreatorProfile profile) {
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
            const Text(
              '创作者成长',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLevelStep('Bronze', true),
                _buildLevelConnector(true),
                _buildLevelStep('Silver', true),
                _buildLevelConnector(true),
                _buildLevelStep('Gold', true),
                _buildLevelConnector(true),
                _buildLevelStep('Diamond', true),
                _buildLevelConnector(false),
                _buildLevelStep('Master', false),
              ],
            ),
            const SizedBox(height: 12),
            // 升级进度
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.68,
                backgroundColor: AppTheme.bgSurfaceDark,
                valueColor: const AlwaysStoppedAnimation(AppTheme.secondaryNeonPurple),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '距 Master 等级还需 3200 次打印',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelStep(String label, bool achieved) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: achieved
                ? AppTheme.secondaryNeonPurple
                : AppTheme.bgSurfaceDark,
            border: Border.all(
              color: achieved
                  ? AppTheme.secondaryNeonPurple
                  : AppTheme.borderGlow,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              achieved ? Icons.check : Icons.lock,
              size: 14,
              color: achieved ? Colors.white : AppTheme.textHint,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: achieved ? AppTheme.textPrimary : AppTheme.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelConnector(bool achieved) {
    return Container(
      width: 16,
      height: 2,
      color: achieved
          ? AppTheme.secondaryNeonPurple
          : AppTheme.borderGlow,
    );
  }
}
