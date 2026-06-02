import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PromptRefinerCard extends StatelessWidget {
  final String rawPrompt;
  final String refinedPrompt;
  final String intent;
  final double confidence;

  const PromptRefinerCard({
    super.key,
    required this.rawPrompt,
    required this.refinedPrompt,
    required this.intent,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.secondaryNeonPurple.withOpacity(0.1),
              AppTheme.primaryNeonGreen.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondaryNeonPurple.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryNeonPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_fix_high,
                    size: 16,
                    color: AppTheme.secondaryNeonPurple,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'nanobanana 提示词专家 · 已优化',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryNeonPurple,
                  ),
                ),
                const Spacer(),
                // 置信度
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeonGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(confidence * 100).toInt()}% 置信度',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primaryNeonGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 原始输入
            _buildSection(
              label: '原始输入',
              content: rawPrompt,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 10),
            
            // 优化后的提示词
            _buildSection(
              label: '优化提示词',
              content: refinedPrompt,
              color: AppTheme.primaryNeonGreen,
            ),
            const SizedBox(height: 10),
            
            // 识别的意图
            Row(
              children: [
                const Icon(Icons.psychology, size: 14, color: AppTheme.accentNeonCyan),
                const SizedBox(width: 6),
                Text(
                  '意图: $intent',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentNeonCyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required String content,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: color,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
