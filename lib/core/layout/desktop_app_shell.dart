import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../layout/responsive_layout.dart';
import '../theme/app_theme.dart';
import '../services/desktop_service.dart';

/// 桌面端侧边栏导航 Shell
/// 左侧固定导航 + 右侧内容区
class DesktopAppShell extends ConsumerWidget {
  final Widget child;
  const DesktopAppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ref.watch(isDesktopLayoutProvider);
    final location = GoRouterState.of(context).uri.toString();

    if (!isDesktop) {
      // 移动端/平板：保持原有底部导航
      return child;
    }

    return Row(
      children: [
        // 左侧导航栏
        _DesktopSidebar(
          currentLocation: location,
          onNavigate: (route) => context.go(route),
        ),
        // 右侧内容区
        Expanded(child: child),
      ],
    );
  }
}

class _DesktopSidebar extends ConsumerWidget {
  final String currentLocation;
  final void Function(String route) onNavigate;

  const _DesktopSidebar({
    required this.currentLocation,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Container(
      width: 240,
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
                _SidebarNavItem(
                  icon: Icons.auto_awesome,
                  label: '创作舱',
                  isActive: currentLocation.startsWith('/create'),
                  onTap: () => onNavigate('/create'),
                ),
                _SidebarNavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: '灵感矩阵',
                  isActive: currentLocation.startsWith('/gallery'),
                  onTap: () => onNavigate('/gallery'),
                ),
                _SidebarNavItem(
                  icon: Icons.devices_outlined,
                  activeIcon: Icons.devices,
                  label: '龙虾智控',
                  isActive: currentLocation.startsWith('/device'),
                  onTap: () => onNavigate('/device'),
                ),
                _SidebarNavItem(
                  icon: Icons.business_outlined,
                  activeIcon: Icons.business,
                  label: '商业协同',
                  isActive: currentLocation.startsWith('/alliance'),
                  onTap: () => onNavigate('/alliance'),
                ),
                _SidebarNavItem(
                  icon: Icons.groups_outlined,
                  activeIcon: Icons.groups,
                  label: '灵感社区',
                  isActive: currentLocation.startsWith('/community'),
                  onTap: () => onNavigate('/community'),
                ),
                _SidebarNavItem(
                  icon: Icons.view_in_ar_outlined,
                  activeIcon: Icons.view_in_ar,
                  label: 'AR 预览',
                  isActive: currentLocation.startsWith('/ar-preview'),
                  onTap: () => onNavigate('/ar-preview'),
                ),
                const Divider(
                  color: AppTheme.borderGlow,
                  height: 32,
                  indent: 16,
                  endIndent: 16,
                ),
                _SidebarNavItem(
                  icon: Icons.print_outlined,
                  activeIcon: Icons.print,
                  label: '打印任务',
                  isActive: currentLocation.startsWith('/print-confirm'),
                  onTap: () => onNavigate('/print-confirm'),
                ),
                _SidebarNavItem(
                  icon: Icons.assessment_outlined,
                  activeIcon: Icons.assessment,
                  label: '数据报表',
                  isActive: currentLocation.startsWith('/report'),
                  onTap: () => onNavigate('/report'),
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
                // 设置按钮
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  color: AppTheme.textHint,
                  onPressed: () => onNavigate('/me'),
                  tooltip: '设置',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarNavItem({
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
