class CreatorProfile {
  final String id;
  final String name;
  final String avatarUrl;
  final String bio;
  final int followers;
  final int following;
  final int totalDesigns;
  final int totalPrints;
  final double totalEarnings;
  final double monthlyEarnings;
  final double promptAssetRevenue;
  final String level;
  final List<String> badges;
  final DateTime joinedAt;

  const CreatorProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    this.followers = 0,
    this.following = 0,
    this.totalDesigns = 0,
    this.totalPrints = 0,
    this.totalEarnings = 0,
    this.monthlyEarnings = 0,
    this.promptAssetRevenue = 0,
    this.level = 'Bronze',
    this.badges = const [],
    required this.joinedAt,
  });

  factory CreatorProfile.initial() => CreatorProfile(
    id: 'creator_001',
    name: 'AI Nails Creator',
    avatarUrl: '',
    bio: '',
    joinedAt: DateTime.now(),
  );
}

class PromptAsset {
  final String id;
  final String name;
  final String prompt;
  final String style;
  final String previewUrl;
  final int usageCount;
  final double earnings;
  final double price;
  final bool isPublic;
  final List<String> tags;
  final DateTime createdAt;

  const PromptAsset({
    required this.id,
    required this.name,
    required this.prompt,
    required this.style,
    required this.previewUrl,
    required this.usageCount,
    required this.earnings,
    required this.price,
    required this.isPublic,
    required this.tags,
    required this.createdAt,
  });

  factory PromptAsset.mock(int index) {
    final styles = ['cyberpunk', 'floral', 'minimalist', 'gradient', 'geometric'];
    return PromptAsset(
      id: 'pa_$index',
      name: '提示词资产 #$index',
      prompt: '高质量美甲设计，${styles[index % styles.length]}风格',
      style: styles[index % styles.length],
      previewUrl: 'https://picsum.photos/seed/prompt_asset_$index/200/200',
      usageCount: 50 + (index * 23) % 500,
      earnings: (50 + (index * 23) % 500) * 0.5,
      price: 0.99,
      isPublic: index % 2 == 0,
      tags: [styles[index % styles.length], 'AI', 'Premium'],
      createdAt: DateTime.now().subtract(Duration(days: index * 3)),
    );
  }
}
