import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../../domain/models/nail_design.dart';
import '../widgets/gallery_card.dart';
import '../widgets/recommendation_feed.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = const [
    {'name': '全部', 'id': 'all', 'icon': Icons.dashboard},
    {'name': '赛博朋克', 'id': 'cyberpunk', 'icon': Icons.memory},
    {'name': '国风水墨', 'id': 'chinese_ink', 'icon': Icons.brush},
    {'name': '法式极简', 'id': 'french_tip', 'icon': Icons.auto_fix_high},
    {'name': '星空宇宙', 'id': 'cosmic', 'icon': Icons.nightlight_round},
    {'name': '花卉自然', 'id': 'floral', 'icon': Icons.local_florist},
    {'name': '几何抽象', 'id': 'geometric', 'icon': Icons.hexagon},
    {'name': '梦幻渐变', 'id': 'gradient', 'icon': Icons.gradient},
  ];

  @override
  void initState() {
    super.initState();
    // 加载初始图案数据
    final designs = List.generate(20, (i) => NailDesign.mock(i));
    ref.read(galleryDesignsProvider.notifier).state = designs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final designs = ref.watch(galleryDesignsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.gradientPurple.createShader(bounds),
                      child: const Text(
                        '灵感矩阵',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'CyberNeon',
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    // 每日更新标识
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryNeonPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.secondaryNeonPurple.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppTheme.secondaryNeonPurple,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '10000+ 图案',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondaryNeonPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 搜索栏
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: '搜索图案、风格或创作者...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textHint,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: AppTheme.textHint,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() {}),
                ),
              ),
            ),

            // 太极64卦偏好推荐区
            const SliverToBoxAdapter(
              child: RecommendationFeed(),
            ),

            // 分类标签
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['id'];
                    return GestureDetector(
                      onTap: () => setState(
                        () => _selectedCategory = cat['id'] as String,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.secondaryNeonPurple.withOpacity(0.15)
                              : AppTheme.bgSurfaceDark,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.secondaryNeonPurple.withOpacity(0.4)
                                : AppTheme.borderGlow.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 16,
                              color: isSelected
                                  ? AppTheme.secondaryNeonPurple
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppTheme.secondaryNeonPurple
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 瀑布流图案网格
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => GalleryCard(design: designs[index]),
                  childCount: designs.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
