import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CommunityFeed extends StatelessWidget {
  const CommunityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      {
        'user': 'TokyoNail_AI',
        'avatar': '🇯🇵',
        'content': 'Just created a new Sakura x Cyberpunk fusion design! The nanobanana engine is incredible 🚀',
        'likes': 342,
        'comments': 56,
        'time': '2小时前',
        'lang': 'en',
      },
      {
        'user': 'SeoulBeauty',
        'avatar': '🇰🇷',
        'content': 'K-뷰티를 위한 새로운 AI 네일 디자인을 공유합니다! 정말 예뻐요 💅',
        'likes': 289,
        'comments': 43,
        'time': '5小时前',
        'lang': 'ko',
      },
      {
        'user': 'ParisNailArt',
        'avatar': '🇫🇷',
        'content': 'Nouveau design minimaliste français - parfait pour l\'été! ☀️',
        'likes': 215,
        'comments': 38,
        'time': '8小时前',
        'lang': 'fr',
      },
      {
        'user': 'ShanghaiInk',
        'avatar': '🇨🇳',
        'content': '国风水墨新作！用AI重新演绎传统美学 🖌️',
        'likes': 567,
        'comments': 89,
        'time': '12小时前',
        'lang': 'zh',
      },
    ];

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
            const Row(
              children: [
                Icon(Icons.public, size: 16, color: AppTheme.accentNeonCyan),
                SizedBox(width: 8),
                Text(
                  '全球创作者社区',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  '13+ 语言',
                  style: TextStyle(fontSize: 11, color: AppTheme.textHint),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...posts.map((post) => _CommunityPost(
                  user: post['user'] as String,
                  avatar: post['avatar'] as String,
                  content: post['content'] as String,
                  likes: post['likes'] as int,
                  comments: post['comments'] as int,
                  time: post['time'] as String,
                )),
          ],
        ),
      ),
    );
  }
}

class _CommunityPost extends StatelessWidget {
  final String user;
  final String avatar;
  final String content;
  final int likes;
  final int comments;
  final String time;

  const _CommunityPost({
    required this.user,
    required this.avatar,
    required this.content,
    required this.likes,
    required this.comments,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGlow.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户行
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.bgSurfaceDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(avatar, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              // 翻译按钮
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentNeonCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.translate, size: 12, color: AppTheme.accentNeonCyan),
                    SizedBox(width: 3),
                    Text(
                      '翻译',
                      style: TextStyle(fontSize: 10, color: AppTheme.accentNeonCyan),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 内容
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          
          // 互动
          Row(
            children: [
              _buildInteraction(Icons.favorite_border, '$likes'),
              const SizedBox(width: 20),
              _buildInteraction(Icons.chat_bubble_outline, '$comments'),
              const SizedBox(width: 20),
              _buildInteraction(Icons.share, '分享'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteraction(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textHint),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
        ),
      ],
    );
  }
}
