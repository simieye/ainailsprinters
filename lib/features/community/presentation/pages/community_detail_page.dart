import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/community_post.dart';
import '../../domain/services/community_service.dart';

/// 社区帖子详情页
class CommunityDetailPage extends ConsumerStatefulWidget {
  final CommunityPost post;

  const CommunityDetailPage({super.key, required this.post});

  @override
  ConsumerState<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends ConsumerState<CommunityDetailPage> {
  late CommunityPost _post;
  final _commentController = TextEditingController();
  bool _isTranslating = false;
  final List<CommunityComment> _comments = [];
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    // 模拟加载评论
    await Future.delayed(const Duration(milliseconds: 600));
    _comments.addAll([
      CommunityComment(
        id: 'c1', postId: _post.id,
        authorId: 'u1', authorName: 'NailLover_Tokyo', authorAvatar: '',
        content: 'このデザイン本当に素敵ですね！使ってみたいです💅',
        likes: 12, createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      CommunityComment(
        id: 'c2', postId: _post.id,
        authorId: 'u2', authorName: 'BeautyQueen', authorAvatar: '',
        content: 'Love the color combination! Already printed it 😍',
        likes: 8, createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ]);
    setState(() => _isLoadingComments = false);
  }

  Future<void> _translatePost() async {
    setState(() => _isTranslating = true);
    final translated = await CommunityService.instance.translatePost(
      _post,
      'en', // 默认翻译为英文
    );
    setState(() {
      _post = translated;
      _isTranslating = false;
    });
  }

  Future<void> _toggleLike() async {
    final updated = await CommunityService.instance.toggleLike(_post);
    setState(() => _post = updated);
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final comment = await CommunityService.instance.addComment(
      postId: _post.id,
      authorId: 'current_user',
      authorName: 'Me',
      authorAvatar: '',
      content: content,
    );

    setState(() {
      _comments.insert(0, comment);
      _post = _post.copyWith(comments: _post.comments + 1);
    });

    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Post Details',
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 作者信息
                  _buildAuthorHeader(),
                  const SizedBox(height: 16),
                  // 帖子内容
                  _buildPostContent(),
                  const SizedBox(height: 16),
                  // 标签
                  if (_post.tags.isNotEmpty) _buildTags(),
                  const SizedBox(height: 20),
                  // 互动栏
                  _buildInteractionBar(),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white12),
                  // 翻译按钮
                  if (_post.language != 'en' && _post.translatedLanguage == null)
                    _buildTranslateButton(),
                  const SizedBox(height: 16),
                  // 评论列表
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
          // 评论输入框
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.neonPurple.withOpacity(0.2),
          child: Text(
            _post.authorName[0].toUpperCase(),
            style: TextStyle(
              color: AppColors.neonPurple,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _post.authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildLevelBadge(_post.authorLevel),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _timeAgo(_post.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white38),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLevelBadge(String level) {
    final colors = {
      'bronze': const Color(0xFFCD7F32),
      'silver': const Color(0xFFC0C0C0),
      'gold': const Color(0xFFFFD700),
      'diamond': const Color(0xFFB9F2FF),
      'master': const Color(0xFFFF2D95),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (colors[level] ?? Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          color: colors[level] ?? Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _post.displayContent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          if (_post.translatedContent != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryNeonGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryNeonGreen.withOpacity(0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.translate,
                    size: 14,
                    color: AppColors.primaryNeonGreen.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _post.translatedContent!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _post.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 200,
                    color: AppColors.bgSecondary,
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.white24, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: _post.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: AppGradients.neon,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInteractionBar() {
    return Row(
      children: [
        _InteractionButton(
          icon: _post.isLiked ? Icons.favorite : Icons.favorite_border,
          label: '${_post.likes}',
          color: _post.isLiked ? AppColors.accentNeonPink : Colors.white38,
          onTap: _toggleLike,
        ),
        const SizedBox(width: 24),
        _InteractionButton(
          icon: Icons.chat_bubble_outline,
          label: '${_post.comments}',
          color: Colors.white38,
          onTap: () {},
        ),
        const SizedBox(width: 24),
        _InteractionButton(
          icon: Icons.share_outlined,
          label: '${_post.shares}',
          color: Colors.white38,
          onTap: () {},
        ),
        const Spacer(),
        if (_post.language != 'en')
          _InteractionButton(
            icon: Icons.bookmark_border,
            label: '',
            color: Colors.white38,
            onTap: () {},
          ),
      ],
    );
  }

  Widget _buildTranslateButton() {
    return GestureDetector(
      onTap: _isTranslating ? null : _translatePost,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.neonCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate,
              size: 16,
              color: _isTranslating
                  ? Colors.white38
                  : AppColors.neonCyan,
            ),
            const SizedBox(width: 8),
            Text(
              _isTranslating ? 'Translating...' : 'Translate to English',
              style: TextStyle(
                color: _isTranslating
                    ? Colors.white38
                    : AppColors.neonCyan,
                fontSize: 13,
              ),
            ),
            if (_isTranslating) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.neonCyan,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${_comments.length})',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingComments)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.neonPurple),
            ),
          )
        else if (_comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No comments yet. Be the first!',
                style: TextStyle(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          )
        else
          ..._comments.map((comment) => _buildCommentItem(comment)),
      ],
    );
  }

  Widget _buildCommentItem(CommunityComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.bgSecondary,
            child: Text(
              comment.authorName[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Text(
                        _timeAgo(comment.createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(
                Icons.favorite_border,
                size: 14,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.bgSecondary,
            child: Icon(Icons.person, color: Colors.white38, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: AppColors.bgSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _submitComment,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppGradients.neon,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
