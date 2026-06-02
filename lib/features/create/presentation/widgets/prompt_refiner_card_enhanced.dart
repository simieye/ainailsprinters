import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// PromptRefinerCard — 提示词优化卡片（增强版）
/// 展示 OpenClaw 对用户原始提示词的 AI 优化结果
class PromptRefinerCard extends StatefulWidget {
  final String rawPrompt;
  final String refinedPrompt;
  final String intent;
  final double confidence;
  final List<String>? styleTags;

  const PromptRefinerCard({
    super.key,
    required this.rawPrompt,
    required this.refinedPrompt,
    required this.intent,
    required this.confidence,
    this.styleTags,
  });

  @override
  State<PromptRefinerCard> createState() => _PromptRefinerCardState();
}

class _PromptRefinerCardState extends State<PromptRefinerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (widget.confidence * 100).toInt();
    final confidenceColor = confidencePercent >= 90
        ? AppTheme.primaryNeonGreen
        : confidencePercent >= 70
            ? AppTheme.warningNeonOrange
            : AppTheme.accentNeonPink;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: _toggleExpand,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.secondaryNeonPurple.withOpacity(0.15),
                AppTheme.accentNeonCyan.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.secondaryNeonPurple.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：意图识别 + 置信度
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology,
                      color: AppTheme.secondaryNeonPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'OpenClaw AI 提示词优化',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // 置信度标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: confidenceColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: confidenceColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            confidencePercent >= 90
                                ? Icons.check_circle
                                : Icons.info_outline,
                            size: 14,
                            color: confidenceColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$confidencePercent% 置信度',
                            style: TextStyle(
                              fontSize: 11,
                              color: confidenceColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.expand_more,
                        color: AppTheme.textHint,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // 检测到的意图
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNeonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryNeonGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '🎯 ${widget.intent}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryNeonGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.styleTags != null)
                      ...widget.styleTags!.take(3).map(
                            (tag) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgElevatedDark,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 优化后的提示词
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  widget.refinedPrompt,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // 展开详情
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(
                      color: AppTheme.borderGlow,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            '原始输入',
                            widget.rawPrompt,
                            Icons.chat_bubble_outline,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            '优化引擎',
                            'nanobanana 3.0 Prompt Refiner Agent',
                            Icons.auto_awesome,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            '增强参数',
                            '1200 DPI · Nail-Adaptive Deformation · 4 candidates',
                            Icons.tune,
                          ),
                          if (widget.styleTags != null &&
                              widget.styleTags!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              '风格标签',
                              widget.styleTags!.join(' · '),
                              Icons.local_offer,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.textHint),
        const SizedBox(width: 8),
        Text(
          '$label：',
          style: const TextStyle(
            color: AppTheme.textHint,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
