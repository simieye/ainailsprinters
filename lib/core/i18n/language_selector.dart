import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'app_i18n.dart';

/// 语言切换选择器组件
/// 在设置页面中使用，支持 13 种语言的快速切换
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const _supportedLanguages = [
    _LanguageInfo('en', 'English', '🇺🇸'),
    _LanguageInfo('zh', '中文', '🇨🇳'),
    _LanguageInfo('ja', '日本語', '🇯🇵'),
    _LanguageInfo('ko', '한국어', '🇰🇷'),
    _LanguageInfo('fr', 'Français', '🇫🇷'),
    _LanguageInfo('de', 'Deutsch', '🇩🇪'),
    _LanguageInfo('es', 'Español', '🇪🇸'),
    _LanguageInfo('pt', 'Português', '🇧🇷'),
    _LanguageInfo('ru', 'Русский', '🇷🇺'),
    _LanguageInfo('ar', 'العربية', '🇸🇦'),
    _LanguageInfo('th', 'ไทย', '🇹🇭'),
    _LanguageInfo('vi', 'Tiếng Việt', '🇻🇳'),
    _LanguageInfo('id', 'Bahasa Indonesia', '🇮🇩'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = context.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            '🌐 ${'common_language'.tr()}',
            style: TextStyle(
              color: AppColors.neonCyan,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _supportedLanguages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final lang = _supportedLanguages[index];
              final isSelected = currentLocale.languageCode == lang.code;
              return _LanguageChip(
                info: lang,
                isSelected: isSelected,
                onTap: () {
                  context.setLocale(Locale(lang.code));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LanguageInfo {
  final String code;
  final String nativeName;
  final String flag;
  const _LanguageInfo(this.code, this.nativeName, this.flag);
}

class _LanguageChip extends StatelessWidget {
  final _LanguageInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryNeonGreen.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryNeonGreen.withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryNeonGreen.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(info.flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              info.nativeName,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryNeonGreen
                    : Colors.white.withOpacity(0.8),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.primaryNeonGreen,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
