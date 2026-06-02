import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../domain/models/admin_models.dart';
import '../domain/services/admin_providers.dart';

/// 后台管理系统主框架 - 左侧导航 + 右侧内容区
class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _isSidebarCollapsed = false;

  static const _systems = [
    _SystemInfo(
      index: 0,
      icon: Icons.diamond,
      label: '品牌总部',
      route: '/admin/headquarters',
      color: Color(0xFF00FF88),
    ),
    _SystemInfo(
      index: 1,
      icon: Icons.engineering,
      label: '技术维护Tim',
      route: '/admin/tech-support',
      color: Color(0xFF00E5FF),
    ),
    _SystemInfo(
      index: 2,
      icon: Icons.language,
      label: '经销商渠道',
      route: '/admin/dealers',
      color: Color(0xFFB44CFF),
    ),
    _SystemInfo(
      index: 3,
      icon: Icons.store,
      label: '门店系统',
      route: '/admin/stores',
      color: Color(0xFFFF8C00),
    ),
    _SystemInfo(
      index: 4,
      icon: Icons.people,
      label: '用户系统',
      route: '/admin/users',
      color: Color(0xFFFF2D95),
    ),
    _SystemInfo(
      index: 5,
      icon: Icons.public,
      label: '品牌社区',
      route: '/admin/community',
      color: Color(0xFF00FF88),
    ),
    _SystemInfo(
      index: 6,
      icon: Icons.payments,
      label: '支付中枢',
      route: '/admin/payments',
      color: Color(0xFFFFD700),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(adminSelectedSystemProvider);
    final adminUser = ref.watch(adminUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeepDark,
      body: Row(
        children: [
          // 左侧导航
          _buildSidebar(selectedIndex),
          // 右侧内容区
          Expanded(
            child: Column(
              children: [
                _buildTopBar(adminUser, selectedIndex),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(int selectedIndex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSidebarCollapsed ? 72 : 240,
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        border: Border(
          right: BorderSide(
            color: AppTheme.borderGlow.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo区域
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderGlow.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientCyber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.diamond, color: Colors.white, size: 22),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AINails Admin',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'CyberNeon',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 系统菜单
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _systems.map((sys) {
                final isSelected = selectedIndex == sys.index;
                return _buildNavItem(
                  sys: sys,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(adminSelectedSystemProvider.notifier).state = sys.index;
                    context.go(sys.route);
                  },
                );
              }).toList(),
            ),
          ),
          // 折叠按钮
          _buildCollapseButton(),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required _SystemInfo sys,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? sys.color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(
              horizontal: _isSidebarCollapsed ? 0 : 14,
            ),
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? sys.color.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    sys.icon,
                    color: isSelected ? sys.color : AppTheme.textHint,
                    size: 20,
                  ),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    sys.label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (isSelected) ...[
                    const Spacer(),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: sys.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: sys.color.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.bgSurfaceDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AdminUser? adminUser, int selectedIndex) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGlow.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // 面包屑
          Text(
            _systems[selectedIndex].label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // 搜索
          SizedBox(
            width: 240,
            height: 36,
            child: TextField(
              onChanged: (v) =>
                  ref.read(adminSearchQueryProvider.notifier).state = v,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: '搜索...',
                hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textHint, size: 18),
                filled: true,
                fillColor: AppTheme.bgSurfaceDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 通知
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            color: AppTheme.textSecondary,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          // 用户头像
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientCyber,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            adminUser?.name ?? '管理员',
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SystemInfo {
  final int index;
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _SystemInfo({
    required this.index,
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}
