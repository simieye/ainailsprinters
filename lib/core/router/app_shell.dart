import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/alliance/presentation/widgets/business_mode_toggle.dart';
import '../theme/app_theme.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryNeonGreen.withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.auto_awesome,
                  activeIcon: Icons.auto_awesome,
                  label: 'Create',
                  isActive: location.startsWith('/create'),
                  onTap: () => context.go('/create'),
                ),
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Gallery',
                  isActive: location.startsWith('/gallery'),
                  onTap: () => context.go('/gallery'),
                ),
                // 中心打印按钮
                _PrintCenterButton(onTap: () {}),
                _NavItem(
                  icon: Icons.devices_outlined,
                  activeIcon: Icons.devices,
                  label: 'Device',
                  isActive: location.startsWith('/device'),
                  onTap: () => context.go('/device'),
                ),
                _NavItem(
                  icon: Icons.account_circle_outlined,
                  activeIcon: Icons.account_circle,
                  label: 'Me',
                  isActive: location.startsWith('/me'),
                  onTap: () => context.go('/me'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppTheme.primaryNeonGreen : AppTheme.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.primaryNeonGreen : AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrintCenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PrintCenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.gradientNeon,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNeonGreen.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.print,
          color: AppTheme.bgDeepDark,
          size: 26,
        ),
      ),
    );
  }
}
