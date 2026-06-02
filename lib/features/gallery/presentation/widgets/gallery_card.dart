import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/nail_design.dart';

class GalleryCard extends StatelessWidget {
  final NailDesign design;

  const GalleryCard({super.key, required this.design});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDesignDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderGlow.withOpacity(0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 图案预览
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStyleColor().withOpacity(0.4),
                        _getStyleColor().withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Icon(
                          _getStyleIcon(),
                          size: 36,
                          color: _getStyleColor().withOpacity(0.5),
                        ),
                      ),
                      // AI 标记
                      if (design.isAIGenerated)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNeonGreen.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.bgDeepDark,
                              ),
                            ),
                          ),
                        ),
                      // 价格标签
                      if (design.price > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentNeonPink.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '\$${design.price}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 信息栏
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: AppTheme.bgCardDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 12,
                            color: AppTheme.accentNeonPink.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${design.likes}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.print,
                            size: 12,
                            color: AppTheme.primaryNeonGreen.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${design.prints}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${design.creatorName}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDesignDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DesignDetailSheet(design: design),
    );
  }

  Color _getStyleColor() {
    return switch (design.style) {
      'cyberpunk' => AppTheme.accentNeonCyan,
      'floral' => AppTheme.accentNeonPink,
      'minimalist' => AppTheme.textSecondary,
      'gradient' => AppTheme.secondaryNeonPurple,
      'geometric' => AppTheme.warningNeonOrange,
      'chinese_ink' => AppTheme.textPrimary,
      'cosmic' => AppTheme.secondaryNeonPurple,
      _ => AppTheme.primaryNeonGreen,
    };
  }

  IconData _getStyleIcon() {
    return switch (design.style) {
      'cyberpunk' => Icons.memory,
      'floral' => Icons.local_florist,
      'minimalist' => Icons.auto_fix_high,
      'gradient' => Icons.gradient,
      'geometric' => Icons.hexagon,
      'chinese_ink' => Icons.brush,
      'cosmic' => Icons.nightlight_round,
      _ => Icons.auto_awesome,
    };
  }
}

class _DesignDetailSheet extends StatelessWidget {
  final NailDesign design;
  const _DesignDetailSheet({required this.design});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // 大图预览
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.bgSurfaceDark,
            ),
            child: const Center(
              child: Icon(Icons.image, size: 60, color: AppTheme.textHint),
            ),
          ),
          const SizedBox(height: 16),
          
          // 设计信息
          Text(
            design.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: design.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.bgSurfaceDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$tag',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('使用此设计'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNeonGreen,
                    foregroundColor: AppTheme.bgDeepDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
                color: AppTheme.accentNeonPink,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.bgSurfaceDark,
                  padding: const EdgeInsets.all(14),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share),
                color: AppTheme.textSecondary,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.bgSurfaceDark,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
