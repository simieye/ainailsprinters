class NailDesign {
  final String id;
  final String imageUrl;
  final String title;
  final String category;
  final List<String> tags;
  final String style;
  final String creatorId;
  final String creatorName;
  final int likes;
  final int prints;
  final double price;
  final bool isAIGenerated;
  final String? promptAssetId;
  final DateTime createdAt;

  const NailDesign({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.tags,
    required this.style,
    required this.creatorId,
    required this.creatorName,
    this.likes = 0,
    this.prints = 0,
    this.price = 0.0,
    this.isAIGenerated = true,
    this.promptAssetId,
    required this.createdAt,
  });

  factory NailDesign.mock(int index) {
    final categories = ['cyberpunk', 'floral', 'minimalist', 'gradient', 'geometric', 'chinese_ink', 'french_tip', 'cosmic'];
    final titles = [
      '赛博霓虹', '樱花物语', '极简几何', '梦幻渐变', '星空宇宙',
      '国风水墨', '法式优雅', '暗夜玫瑰', '未来脉冲', '蝶翼微光',
      '极光之舞', '深海秘境', '金属光泽', '糖果甜心', '月下竹林',
    ];
    
    return NailDesign(
      id: 'nd_$index',
      imageUrl: 'https://picsum.photos/seed/nail_design_$index/400/600',
      title: titles[index % titles.length],
      category: categories[index % categories.length],
      tags: [categories[index % categories.length], 'AI生成', '1200DPI'],
      style: categories[index % categories.length],
      creatorId: 'creator_${index % 5}',
      creatorName: '创作者${index % 5 + 1}',
      likes: 100 + (index * 37) % 5000,
      prints: 50 + (index * 23) % 2000,
      price: index % 3 == 0 ? 9.9 : 0.0,
      isAIGenerated: true,
      createdAt: DateTime.now().subtract(Duration(hours: index * 3)),
    );
  }
}
