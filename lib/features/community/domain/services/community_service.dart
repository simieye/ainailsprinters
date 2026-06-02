import 'dart:async';
import '../../../core/services/simiai_service.dart';
import 'models/community_post.dart';

/// 社区服务
///
/// 管理全球多语言社区动态、帖子发布、评论、翻译等功能。
/// 通过 SIMIAIOS translator 智能体实现 13 种语言实时翻译。
class CommunityService {
  CommunityService._();
  static final CommunityService instance = CommunityService._();

  final _postsController = StreamController<List<CommunityPost>>.broadcast();
  final _mockPosts = CommunityPost.mockPosts();

  Stream<List<CommunityPost>> get postsStream => _postsController.stream;

  /// 获取社区动态（分页）
  Future<List<CommunityPost>> getFeed({
    int page = 1,
    int limit = 20,
    String? language,
    String? category,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    var posts = List<CommunityPost>.from(_mockPosts);

    // 按类别筛选
    if (category != null && category != 'all') {
      posts = posts
          .where((p) => p.tags.any((t) => t.toLowerCase() == category))
          .toList();
    }

    // 分页
    final start = (page - 1) * limit;
    final end = start + limit;
    final pagePosts = posts.sublist(
      start.clamp(0, posts.length),
      end.clamp(0, posts.length),
    );

    _postsController.add(pagePosts);
    return pagePosts;
  }

  /// 翻译帖子内容
  Future<CommunityPost> translatePost(
    CommunityPost post,
    String targetLanguage,
  ) async {
    if (post.language == targetLanguage) return post;

    // 模拟调用 translator 智能体
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟翻译结果
    final translatedContent = _mockTranslate(post.content, targetLanguage);

    return post.copyWith(
      translatedContent: '[${_getLangName(targetLanguage)}] $translatedContent',
      translatedLanguage: targetLanguage,
    );
  }

  /// 点赞帖子
  Future<CommunityPost> toggleLike(CommunityPost post) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return post.copyWith(
      likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      isLiked: !post.isLiked,
    );
  }

  /// 发布新帖子
  Future<CommunityPost> publishPost({
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required String content,
    List<String> images = const [],
    List<String> tags = const [],
    String? designId,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final post = CommunityPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content,
      images: images,
      tags: tags,
      designId: designId,
      language: language,
      createdAt: DateTime.now(),
    );

    _mockPosts.insert(0, post);
    _postsController.add(List.from(_mockPosts));
    return post;
  }

  /// 发表评论
  Future<CommunityComment> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required String content,
    String? parentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return CommunityComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content,
      parentId: parentId,
      createdAt: DateTime.now(),
    );
  }

  /// 搜索帖子
  Future<List<CommunityPost>> searchPosts(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPosts.where((p) {
      final q = query.toLowerCase();
      return p.content.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q)) ||
          p.authorName.toLowerCase().contains(q);
    }).toList();
  }

  void dispose() {
    _postsController.close();
  }

  // ===== 辅助方法 =====

  String _mockTranslate(String text, String targetLang) {
    // 简单的模拟翻译（实际应由 translator 智能体处理）
    const prefixes = {
      'en': '[EN] ',
      'zh': '[中文] ',
      'ja': '[日本語] ',
      'ko': '[한국어] ',
      'fr': '[FR] ',
      'de': '[DE] ',
      'es': '[ES] ',
      'pt': '[PT] ',
      'ru': '[RU] ',
      'ar': '[AR] ',
      'th': '[TH] ',
      'vi': '[VI] ',
      'id': '[ID] ',
    };
    return '${prefixes[targetLang] ?? ''}$text';
  }

  String _getLangName(String code) {
    const names = {
      'en': 'English',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
      'fr': 'Français',
      'de': 'Deutsch',
      'es': 'Español',
      'pt': 'Português',
      'ru': 'Русский',
      'ar': 'العربية',
      'th': 'ไทย',
      'vi': 'Tiếng Việt',
      'id': 'Bahasa Indonesia',
    };
    return names[code] ?? code.toUpperCase();
  }
}
