import 'package:flutter_test/flutter_test.dart';
import 'package:ai_nails_app/features/community/domain/models/community_post.dart';
import 'package:ai_nails_app/features/community/domain/services/community_service.dart';

void main() {
  late CommunityService service;

  setUp(() {
    service = CommunityService.instance;
  });

  group('CommunityPost', () {
    test('should create post with default values', () {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Test Author',
        authorAvatar: '',
        content: 'Test content',
        createdAt: DateTime.now(),
      );

      expect(post.likes, 0);
      expect(post.comments, 0);
      expect(post.shares, 0);
      expect(post.isLiked, false);
      expect(post.language, 'en');
      expect(post.authorLevel, 'bronze');
      expect(post.images, isEmpty);
      expect(post.tags, isEmpty);
    });

    test('should return display content with translation', () {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Test Author',
        authorAvatar: '',
        content: 'Original',
        translatedContent: 'Translated',
        createdAt: DateTime.now(),
      );

      expect(post.displayContent, 'Translated');
    });

    test('should return original content without translation', () {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Test Author',
        authorAvatar: '',
        content: 'Original',
        createdAt: DateTime.now(),
      );

      expect(post.displayContent, 'Original');
    });

    test('should detect need for translation', () {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Test Author',
        authorAvatar: '',
        content: '안녕하세요',
        language: 'ko',
        createdAt: DateTime.now(),
      );

      expect(post.needTranslation('en'), true);
      expect(post.needTranslation('ko'), false);
    });

    test('should not need translation if already translated', () {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Test Author',
        authorAvatar: '',
        content: '안녕하세요',
        language: 'ko',
        translatedContent: 'Hello',
        translatedLanguage: 'en',
        createdAt: DateTime.now(),
      );

      expect(post.needTranslation('en'), false);
    });

    test('should copyWith correctly', () {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Test Author',
        authorAvatar: '',
        content: 'Original',
        likes: 10,
        isLiked: false,
        createdAt: DateTime.now(),
      );

      final updated = post.copyWith(likes: 11, isLiked: true);

      expect(updated.likes, 11);
      expect(updated.isLiked, true);
      expect(updated.content, 'Original'); // unchanged
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': 'post_001',
        'author_id': 'author_001',
        'author_name': 'Kim',
        'author_avatar': '',
        'author_level': 'diamond',
        'content': 'Great design!',
        'images': ['img1.jpg'],
        'tags': ['cyberpunk', 'neon'],
        'design_id': 'design_001',
        'language': 'ko',
        'translated_content': null,
        'translated_language': null,
        'likes': 234,
        'comments': 45,
        'shares': 89,
        'is_liked': false,
        'created_at': '2026-06-02T10:00:00.000',
      };

      final post = CommunityPost.fromJson(json);

      expect(post.id, 'post_001');
      expect(post.authorName, 'Kim');
      expect(post.authorLevel, 'diamond');
      expect(post.tags.length, 2);
      expect(post.likes, 234);
      expect(post.createdAt.year, 2026);
    });
  });

  group('CommunityService', () {
    test('should get feed with pagination', () async {
      final posts = await service.getFeed(page: 1, limit: 3);
      expect(posts.length, lessThanOrEqualTo(3));
    });

    test('should translate post', () async {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Kim',
        authorAvatar: '',
        content: '안녕하세요',
        language: 'ko',
        createdAt: DateTime.now(),
      );

      final translated = await service.translatePost(post, 'en');

      expect(translated.translatedLanguage, 'en');
      expect(translated.translatedContent, isNotNull);
      expect(translated.translatedContent, isNot(equals(post.content)));
    });

    test('should not translate if same language', () async {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Kim',
        authorAvatar: '',
        content: 'Hello',
        language: 'en',
        createdAt: DateTime.now(),
      );

      final translated = await service.translatePost(post, 'en');
      expect(translated.translatedContent, isNull);
    });

    test('should toggle like on and off', () async {
      final post = CommunityPost(
        id: 'test_001',
        authorId: 'author_001',
        authorName: 'Kim',
        authorAvatar: '',
        content: 'Test',
        likes: 10,
        isLiked: false,
        createdAt: DateTime.now(),
      );

      final liked = await service.toggleLike(post);
      expect(liked.likes, 11);
      expect(liked.isLiked, true);

      final unliked = await service.toggleLike(liked);
      expect(unliked.likes, 10);
      expect(unliked.isLiked, false);
    });

    test('should publish new post', () async {
      final post = await service.publishPost(
        authorId: 'author_001',
        authorName: 'New Creator',
        authorAvatar: '',
        content: 'My new design',
        tags: ['cyberpunk'],
      );

      expect(post.authorName, 'New Creator');
      expect(post.content, 'My new design');
      expect(post.tags, contains('cyberpunk'));
    });

    test('should search posts', () async {
      final results = await service.searchPosts('cyberpunk');
      expect(results.any((p) => p.tags.contains('cyberpunk')), true);
    });

    test('should add comment', () async {
      final comment = await service.addComment(
        postId: 'post_001',
        authorId: 'author_001',
        authorName: 'Commenter',
        authorAvatar: '',
        content: 'Nice!',
      );

      expect(comment.postId, 'post_001');
      expect(comment.authorName, 'Commenter');
      expect(comment.content, 'Nice!');
    });
  });

  group('Mock Data', () {
    test('should generate 5 mock posts', () {
      final posts = CommunityPost.mockPosts();
      expect(posts.length, 5);
    });

    test('should have posts in different languages', () {
      final posts = CommunityPost.mockPosts();
      final languages = posts.map((p) => p.language).toSet();
      expect(languages.length, greaterThan(1));
    });
  });
}
