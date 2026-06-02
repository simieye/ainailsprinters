import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/alliance/presentation/widgets/business_mode_toggle.dart';
import '../theme/app_theme.dart';
import '../layout/responsive_layout.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final isDesktop = ref.watch(isDesktopLayoutProvider);

    // 桌面端：侧边栏导航
    if (isDesktop) {
      return _DesktopShell(
        child: child,
        currentLocation: location,
      );
    }

    // 移动端/平板：底部导航
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

/// 桌面端布局
class _DesktopShell extends ConsumerWidget {
  final Widget child;
  final String currentLocation;

  const _DesktopShell({
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: Row(
        children: [
          // 左侧导航栏
          SizedBox(
            width: 240,
            child: Container(
              color: AppTheme.bgCardDark,
              child: Column(
                children: [
                  // Logo 区域
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.primaryNeonGreen.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: AppTheme.gradientNeon,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppTheme.bgDeepDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'AI NAILS',
                          style: TextStyle(
                            fontFamily: 'CyberNeon',
                            fontSize: 18,
                            color: AppTheme.primaryNeonGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 导航菜单
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        _DesktopNavItem(
                          icon: Icons.auto_awesome,
                          label: '创作舱',
                          isActive: currentLocation.startsWith('/create'),
                          onTap: () => context.go('/create'),
                        ),
                        _DesktopNavItem(
                          icon: Icons.dashboard_outlined,
                          activeIcon: Icons.dashboard,
                          label: '灵感矩阵',
                          isActive: currentLocation.startsWith('/gallery'),
                          onTap: () => context.go('/gallery'),
                        ),
                        _DesktopNavItem(
                          icon: Icons.devices_outlined,
                          activeIcon: Icons.devices,
                          label: '龙虾智控',
                          isActive: currentLocation.startsWith('/device'),
                          onTap: () => context.go('/device'),
                        ),
                        _DesktopNavItem(
                          icon: Icons.business_outlined,
                          activeIcon: Icons.business,
                          label: '商业协同',
                          isActive: currentLocation.startsWith('/alliance'),
                          onTap: () => context.go('/alliance'),
                        ),
                        const Divider(
                          color: AppTheme.borderGlow,
                          height: 32,
                          indent: 16,
                          endIndent: 16,
                        ),
                        _DesktopNavItem(
                          icon: Icons.view_in_ar_outlined,
                          activeIcon: Icons.view_in_ar,
                          label: 'AR 预览',
                          isActive: currentLocation.startsWith('/ar-preview'),
                          onTap: () => context.go('/ar-preview'),
                        ),
                        _DesktopNavItem(
                          icon: Icons.print_outlined,
                          activeIcon: Icons.print,
                          label: '打印任务',
                          isActive: currentLocation.startsWith('/print-confirm'),
                          onTap: () => context.go('/print-confirm'),
                        ),
                        _DesktopNavItem(
                          icon: Icons.assessment_outlined,
                          activeIcon: Icons.assessment,
                          label: '数据报表',
                          isActive: currentLocation.startsWith('/report'),
                          onTap: () => context.go('/report'),
                        ),
                      ],
                    ),
                  ),

                  // 底部用户信息
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.primaryNeonGreen.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.secondaryNeonPurple.withOpacity(0.3),
                          child: Text(
                            user?.displayName?.isNotEmpty == true
                                ? user!.displayName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppTheme.secondaryNeonPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user?.displayName ?? '创作者',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(
                                  color: AppTheme.textHint,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, size: 18),
                          color: AppTheme.textHint,
                          onPressed: () => context.go('/me'),
                          tooltip: '设置',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 分割线
          Container(
            width: 1,
            color: AppTheme.primaryNeonGreen.withOpacity(0.1),
          ),

          // 右侧内容区
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DesktopNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isActive
            ? AppTheme.primaryNeonGreen.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isActive ? (activeIcon ?? icon) : icon,
                  size: 20,
                  color: isActive
                      ? AppTheme.primaryNeonGreen
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? AppTheme.primaryNeonGreen
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryNeonGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
