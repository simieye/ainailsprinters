import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../widgets/payment_integration_widgets.dart';
import '../../../domain/models/admin_models.dart';
import '../../../domain/services/admin_providers.dart';
import '../../widgets/admin_common_widgets.dart';

/// 系统6：AINails品牌宣传官网社区系统
/// 内容审核、社区管理、品牌宣传、数据统计
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    ref.read(communityContentsProvider.notifier).state = [
      CommunityContent(id: 'CC-001', authorId: 'US-001', authorName: 'NailArtist_Lisa', title: '夏日霓虹渐变美甲教程', content: '详细教程...', type: 'tutorial', likes: 2340, comments: 156, shares: 89, status: 'published', publishDate: now.subtract(const Duration(days: 2))),
      CommunityContent(id: 'CC-002', authorId: 'US-004', authorName: 'Shanghai_Chic', title: '我的AI美甲设计合集', content: '展示作品...', type: 'showcase', likes: 1890, comments: 98, shares: 120, status: 'published', publishDate: now.subtract(const Duration(days: 1))),
      CommunityContent(id: 'CC-003', authorId: 'US-003', authorName: 'NYC_NailLover', title: 'AI Nails v3.0新功能体验', content: '体验分享...', type: 'post', likes: 567, comments: 34, shares: 23, status: 'published', publishDate: now.subtract(const Duration(hours: 12))),
      CommunityContent(id: 'CC-004', authorId: 'US-006', authorName: 'DubaiRoyal', title: '迪拜旗舰店盛大开业', content: '新闻...', type: 'news', likes: 3200, comments: 210, shares: 450, status: 'published', publishDate: now.subtract(const Duration(days: 5))),
      CommunityContent(id: 'CC-005', authorId: 'US-002', authorName: 'BeautyQueen_Min', title: '秋冬美甲色彩趋势2025', content: '趋势分析...', type: 'tutorial', likes: 1500, comments: 89, shares: 56, status: 'published', publishDate: now.subtract(const Duration(days: 3))),
      CommunityContent(id: 'CC-006', authorId: 'US-007', authorName: 'ParisArtiste', title: '（待审核内容）', content: '待审核...', type: 'post', likes: 0, comments: 0, shares: 0, status: 'draft', publishDate: now.subtract(const Duration(hours: 1))),
      CommunityContent(id: 'CC-007', authorId: 'US-009', authorName: 'SpamAccount_01', title: '违规广告内容', content: '违规...', type: 'post', likes: 0, comments: 0, shares: 0, status: 'flagged', publishDate: now.subtract(const Duration(days: 1))),
      CommunityContent(id: 'CC-008', authorId: 'US-005', authorName: 'LondonGlam', title: 'AINails伦敦快闪店打卡', content: '打卡分享...', type: 'showcase', likes: 890, comments: 45, shares: 67, status: 'published', publishDate: now.subtract(const Duration(days: 4))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final contents = ref.watch(communityContentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '品牌宣传官网社区系统', subtitle: '内容管理与社区运营'),
          const SizedBox(height: 20),

          // Tab切换
          Row(
            children: ['content', 'analytics', 'banners', 'seo'].map((t) {
              final tabs = {'content': 0, 'analytics': 1, 'banners': 2, 'seo': 3};
              final labels = {'content': '内容审核', 'analytics': '社区分析', 'banners': '品牌宣传', 'seo': 'SEO优化'};
              final icons = {'content': Icons.rate_review, 'analytics': Icons.analytics, 'banners': Icons.campaign, 'seo': Icons.search};
              final idx = tabs[t]!;
              final isSelected = _selectedTab == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryNeonGreen.withOpacity(0.1) : AppTheme.bgCardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppTheme.primaryNeonGreen.withOpacity(0.4) : AppTheme.borderGlow.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(icons[t]!, size: 16, color: isSelected ? AppTheme.primaryNeonGreen : AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(labels[t]!, style: TextStyle(
                          color: isSelected ? AppTheme.primaryNeonGreen : AppTheme.textSecondary,
                          fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          IndexedStack(
            index: _selectedTab,
            children: [
              _buildContentReview(contents),
              _buildCommunityAnalytics(contents),
              _buildBrandPromotion(),
              _buildSeoOptimization(),
            ],
          ),
          const SizedBox(height: 24),

          // 支付快捷入口
          const PaymentQuickActions(),
        ],
      ),
    );
  }

  // ===== 内容审核 =====
  Widget _buildContentReview(List<CommunityContent> contents) {
    final pending = contents.where((c) => c.status == 'draft' || c.status == 'flagged').length;
    final published = contents.where((c) => c.status == 'published').length;

    return Column(
      children: [
        Row(
          children: [
            _buildContentStatCard('待审核', '$pending', Icons.pending, AppTheme.warningNeonOrange),
            const SizedBox(width: 16),
            _buildContentStatCard('已发布', '$published', Icons.check_circle, AppTheme.primaryNeonGreen),
            const SizedBox(width: 16),
            _buildContentStatCard('总互动', '${contents.fold<int>(0, (s, c) => s + c.likes + c.comments)}', Icons.favorite, AppTheme.accentNeonPink),
            const SizedBox(width: 16),
            _buildContentStatCard('总分享', '${contents.fold<int>(0, (s, c) => s + c.shares)}', Icons.share, AppTheme.accentNeonCyan),
          ],
        ),
        const SizedBox(height: 24),

        AdminDataTable(
          columns: const ['ID', '作者', '标题', '类型', '点赞', '评论', '分享', '状态', '发布时间', '操作'],
          rows: contents.map((c) => [
            Text('#${c.id}', style: const TextStyle(color: AppTheme.accentNeonCyan, fontSize: 12)),
            Text(c.authorName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
            SizedBox(
              width: 160,
              child: Text(c.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12), overflow: TextOverflow.ellipsis),
            ),
            StatusBadge(status: c.type, colorMap: {
              'tutorial': AppTheme.secondaryNeonPurple,
              'showcase': AppTheme.accentNeonCyan,
              'post': AppTheme.textSecondary,
              'news': AppTheme.primaryNeonGreen,
            }),
            Text('${c.likes}', style: const TextStyle(color: AppTheme.accentNeonPink, fontSize: 12)),
            Text('${c.comments}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text('${c.shares}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            StatusBadge(status: c.status),
            Text(_formatTime(c.publishDate), style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (c.status == 'draft' || c.status == 'flagged') ...[
                  _buildMiniButton('通过', () {}, AppTheme.primaryNeonGreen),
                  const SizedBox(width: 4),
                  _buildMiniButton('驳回', () {}, AppTheme.accentNeonPink),
                ] else ...[
                  _buildMiniButton('编辑', () {}, AppTheme.accentNeonCyan),
                  const SizedBox(width: 4),
                  _buildMiniButton('下架', () {}, AppTheme.warningNeonOrange),
                ],
              ],
            ),
          ]).toList(),
        ),
      ],
    );
  }

  Widget _buildContentStatCard(String label, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                Text(label, style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== 社区分析 =====
  Widget _buildCommunityAnalytics(List<CommunityContent> contents) {
    final totalLikes = contents.fold<int>(0, (s, c) => s + c.likes);
    final totalComments = contents.fold<int>(0, (s, c) => s + c.comments);
    final totalShares = contents.fold<int>(0, (s, c) => s + c.shares);
    final topContent = contents.isNotEmpty ? contents.reduce((a, b) => a.likes > b.likes ? a : b) : null;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: '社区互动概览'),
                    const SizedBox(height: 16),
                    _buildInteractionBar('点赞总数', totalLikes, totalLikes + totalComments + totalShares, AppTheme.accentNeonPink),
                    const SizedBox(height: 12),
                    _buildInteractionBar('评论总数', totalComments, totalLikes + totalComments + totalShares, AppTheme.accentNeonCyan),
                    const SizedBox(height: 12),
                    _buildInteractionBar('分享总数', totalShares, totalLikes + totalComments + totalShares, AppTheme.primaryNeonGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: '热门内容TOP'),
                    const SizedBox(height: 16),
                    if (topContent != null) ...[
                      Icon(Icons.local_fire_department, color: AppTheme.warningNeonOrange, size: 32),
                      const SizedBox(height: 8),
                      Text(topContent.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text('${topContent.likes}赞 · ${topContent.comments}评 · ${topContent.shares}分享', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractionBar(String label, int value, int total, Color color) {
    final pct = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text('$value (${(pct * 100).toStringAsFixed(1)}%)', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppTheme.bgSurfaceDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // ===== 品牌宣传 =====
  Widget _buildBrandPromotion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('品牌宣传素材管理', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            final banners = [
              _BannerData('首页主KV', '1920x600', '已发布', Icons.web, AppTheme.primaryNeonGreen),
              _BannerData('新品上市Banner', '1200x400', '已发布', Icons.new_releases, AppTheme.accentNeonCyan),
              _BannerData('经销商招募', '1920x600', '已发布', Icons.business, AppTheme.secondaryNeonPurple),
              _BannerData('App下载引导', '1080x1920', '已发布', Icons.phone_android, AppTheme.accentNeonPink),
              _BannerData('节日活动模板', '1200x400', '草稿', Icons.celebration, AppTheme.warningNeonOrange),
              _BannerData('品牌视频', '1920x1080', '已发布', Icons.play_circle, AppTheme.accentNeonCyan),
              _BannerData('社交媒体素材包', '1080x1080', '已发布', Icons.photo_library, AppTheme.secondaryNeonPurple),
              _BannerData('品牌VI规范', '-', '已发布', Icons.palette, AppTheme.primaryNeonGreen),
            ];
            final b = banners[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: b.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(b.icon, color: b.color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(b.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(b.size, style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
                  const SizedBox(height: 8),
                  StatusBadge(status: b.status),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ===== SEO优化 =====
  Widget _buildSeoOptimization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SEO优化与网站分析', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),

        // 网站流量统计
        Row(
          children: [
            _buildSeoMetricCard('官网月访问量', '850K', '+23%', AppTheme.primaryNeonGreen),
            const SizedBox(width: 16),
            _buildSeoMetricCard('搜索排名', 'TOP 3', 'AI美甲关键词', AppTheme.accentNeonCyan),
            const SizedBox(width: 16),
            _buildSeoMetricCard('页面加载速度', '1.2s', '全球CDN', AppTheme.secondaryNeonPurple),
            const SizedBox(width: 16),
            _buildSeoMetricCard('自然流量占比', '68%', 'SEO贡献', AppTheme.warningNeonOrange),
          ],
        ),
        const SizedBox(height: 24),

        // 关键词排名
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.bgCardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: '关键词排名追踪'),
              const SizedBox(height: 16),
              AdminDataTable(
                columns: const ['关键词', '搜索量/月', '排名', '趋势', '竞争度'],
                rows: [
                  _buildKeywordRow('AI美甲', '120K', 1, '+2', '高'),
                  _buildKeywordRow('智能美甲设计', '45K', 2, '+1', '中'),
                  _buildKeywordRow('nail art AI', '85K', 1, '0', '高'),
                  _buildKeywordRow('美甲打印设备', '28K', 3, '-1', '中'),
                  _buildKeywordRow('AI nail printer', '52K', 2, '+3', '高'),
                  _buildKeywordRow('自助美甲机', '18K', 4, '+5', '低'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeoMetricCard(String title, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGlow.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKeywordRow(String keyword, String volume, int rank, String trend, String competition) {
    final trendColor = trend.startsWith('+') ? AppTheme.primaryNeonGreen : (trend.startsWith('-') ? AppTheme.accentNeonPink : AppTheme.textSecondary);
    return [
      Text(keyword, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
      Text(volume, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: rank <= 3 ? AppTheme.primaryNeonGreen : AppTheme.warningNeonOrange),
          const SizedBox(width: 4),
          Text('#$rank', style: TextStyle(color: rank <= 3 ? AppTheme.primaryNeonGreen : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trend.startsWith('+') ? Icons.trending_up : (trend.startsWith('-') ? Icons.trending_down : Icons.remove), size: 14, color: trendColor),
          const SizedBox(width: 2),
          Text(trend, style: TextStyle(color: trendColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
      StatusBadge(status: competition == '高' ? 'high' : (competition == '中' ? 'medium' : 'low'), colorMap: {
        'high': AppTheme.accentNeonPink,
        'medium': AppTheme.warningNeonOrange,
        'low': AppTheme.primaryNeonGreen,
      }),
    ];
  }

  Widget _buildMiniButton(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 11)),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

class _BannerData {
  final String title;
  final String size;
  final String status;
  final IconData icon;
  final Color color;
  const _BannerData(this.title, this.size, this.status, this.icon, this.color);
}
