/// 社区帖子模型
class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String authorLevel;
  final String content;
  final List<String> images;
  final List<String> tags;
  final String? designId;
  final String language;
  final String? translatedContent;
  final String? translatedLanguage;
  int likes;
  int comments;
  int shares;
  bool isLiked;
  final DateTime createdAt;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    this.authorLevel = 'bronze',
    required this.content,
    this.images = const [],
    this.tags = const [],
    this.designId,
    this.language = 'en',
    this.translatedContent,
    this.translatedLanguage,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatar: json['author_avatar'] as String,
      authorLevel: json['author_level'] as String? ?? 'bronze',
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      designId: json['design_id'] as String?,
      language: json['language'] as String? ?? 'en',
      translatedContent: json['translated_content'] as String?,
      translatedLanguage: json['translated_language'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CommunityPost copyWith({
    String? translatedContent,
    String? translatedLanguage,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
  }) {
    return CommunityPost(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorLevel: authorLevel,
      content: content,
      images: images,
      tags: tags,
      designId: designId,
      language: language,
      translatedContent: translatedContent ?? this.translatedContent,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }

  /// 获取当前显示的内容（优先翻译版本）
  String get displayContent => translatedContent ?? content;

  /// 是否需要翻译（与当前语言不同）
  bool needTranslation(String currentLang) {
    return language != currentLang && translatedLanguage != currentLang;
  }

  static List<CommunityPost> mockPosts() {
    return [
      CommunityPost(
        id: 'post_001',
        authorId: 'creator_001',
        authorName: 'NailArtist_Kim',
        authorAvatar: '',
        authorLevel: 'diamond',
        content: '새로운 오로라 그라데이션 시리즈가 출시되었습니다! ❄️✨ 자연의 빛을 네일 위에 담아보세요.',
        images: [],
        tags: ['aurora', 'gradient', 'winter'],
        designId: 'design_aurora_001',
        language: 'ko',
        likes: 234,
        comments: 45,
        shares: 89,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        id: 'post_002',
        authorId: 'creator_002',
        authorName: 'Sakura_Nail',
        authorAvatar: '',
        authorLevel: 'gold',
        content: '春の桜をイメージしたネイルデザインを作りました🌸 淡いピンクと白のグラデーションがとても可愛いです！',
        images: [],
        tags: ['sakura', 'spring', 'kawaii'],
        designId: 'design_sakura_001',
        language: 'ja',
        likes: 189,
        comments: 32,
        shares: 56,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        id: 'post_003',
        authorId: 'creator_003',
        authorName: 'CyberNails_CN',
        authorAvatar: '',
        authorLevel: 'master',
        content: '赛博朋克2077主题美甲上线！霓虹灯效 + 全息幻彩，每一个角度都是不同的色彩 🎮💜',
        images: [],
        tags: ['cyberpunk', 'holographic', 'neon'],
        designId: 'design_cyber_001',
        language: 'zh',
        likes: 567,
        comments: 123,
        shares: 234,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      CommunityPost(
        id: 'post_004',
        authorId: 'creator_004',
        authorName: 'Luna_Nails_FR',
        authorAvatar: '',
        authorLevel: 'silver',
        content: 'Minimaliste et élégant ✨ Mon nouveau design "French Moon" combine la french classique avec une touche lunaire moderne.',
        images: [],
        tags: ['french', 'minimalist', 'moon'],
        language: 'fr',
        likes: 98,
        comments: 15,
        shares: 22,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      CommunityPost(
        id: 'post_005',
        authorId: 'creator_005',
        authorName: 'StarNails_BR',
        authorAvatar: '',
        authorLevel: 'gold',
        content: 'Coleção "Galáxia Tropical" 🏝️🌟 Unindo o azul profundo do cosmos com as cores vibrantes do Brasil!',
        images: [],
        tags: ['galaxy', 'tropical', 'vibrant'],
        language: 'pt',
        likes: 145,
        comments: 28,
        shares: 67,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

/// 帖子评论模型
class CommunityComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final String? parentId;
  int likes;
  bool isLiked;
  final DateTime createdAt;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    this.parentId,
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatar: json['author_avatar'] as String,
      content: json['content'] as String,
      parentId: json['parent_id'] as String?,
      likes: json['likes'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
