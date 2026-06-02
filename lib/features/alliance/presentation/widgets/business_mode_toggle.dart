import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';

class BusinessModeToggle extends ConsumerWidget {
  const BusinessModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(businessModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.bgSurfaceDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildModeButton(
              label: 'B2C 家庭版',
              icon: Icons.home,
              isSelected: mode == BusinessMode.b2c,
              onTap: () => ref.read(businessModeProvider.notifier).state = BusinessMode.b2c,
            ),
            _buildModeButton(
              label: 'B2B 店中店',
              icon: Icons.store,
              isSelected: mode == BusinessMode.b2b,
              onTap: () => ref.read(businessModeProvider.notifier).state = BusinessMode.b2b,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryNeonGreen.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(
                    color: AppTheme.primaryNeonGreen.withOpacity(0.3),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppTheme.primaryNeonGreen
                    : AppTheme.textHint,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primaryNeonGreen
                      : AppTheme.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum BusinessMode { b2c, b2b }
