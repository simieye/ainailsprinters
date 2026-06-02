import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/theme/app_theme.dart';
import '../core/router/app_router.dart';
import '../core/di/providers.dart';

/// AI NAILS 桌面版应用入口
/// 支持 Windows / macOS / Linux 三平台
/// 提供桌面级窗口管理、快捷键、拖拽区域等桌面特性
class DesktopApp extends ConsumerStatefulWidget {
  const DesktopApp({super.key});

  @override
  ConsumerState<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends ConsumerState<DesktopApp>
    with WidgetsBindingObserver {
  bool _isFullScreen = false;
  final FocusNode _shortcutFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shortcutFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 响应窗口大小变化
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final windowSize = MediaQuery.of(context).size;

    // 根据窗口宽度决定布局模式
    final isWideScreen = windowSize.width >= 1200;

    return Focus(
      focusNode: _shortcutFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyboardShortcuts(event, router),
      child: MaterialApp.router(
        title: 'AI NAILS Desktop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        builder: (context, child) {
          return _DesktopShell(
            isWideScreen: isWideScreen,
            isFullScreen: _isFullScreen,
            onToggleFullScreen: () {
              setState(() => _isFullScreen = !_isFullScreen);
            },
            child: child ??= const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  KeyEventResult _handleKeyboardShortcuts(
      KeyEvent event, GoRouter router) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isMeta = HardwareKeyboard.instance.isMetaPressed;
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isMod = isMeta || isCtrl;

    if (isMod && event.logicalKey == LogicalKeyboardKey.digit1) {
      router.go('/create');
      return KeyEventResult.handled;
    }
    if (isMod && event.logicalKey == LogicalKeyboardKey.digit2) {
      router.go('/gallery');
      return KeyEventResult.handled;
    }
    if (isMod && event.logicalKey == LogicalKeyboardKey.digit3) {
      router.go('/ar-preview');
      return KeyEventResult.handled;
    }
    if (isMod && event.logicalKey == LogicalKeyboardKey.digit4) {
      router.go('/device');
      return KeyEventResult.handled;
    }
    if (isMod && event.logicalKey == LogicalKeyboardKey.digit5) {
      router.go('/alliance');
      return KeyEventResult.handled;
    }
    if (isMod && event.logicalKey == LogicalKeyboardKey.digit6) {
      router.go('/me');
      return KeyEventResult.handled;
    }
    if (isMod && event.logicalKey == LogicalKeyboardKey.keyK) {
      // Cmd/Ctrl+K 打开搜索/命令面板
      _showCommandPalette();
      return KeyEventResult.handled;
    }
    if (isMod && event.logicalKey == LogicalKeyboardKey.comma) {
      // Cmd/Ctrl+, 打开设置
      router.go('/settings');
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _showCommandPalette() {
    showDialog(
      context: context,
      builder: (context) => _CommandPaletteDialog(),
    );
  }
}

/// 桌面版外壳 —— 提供标题栏拖拽区域 + 窗口控制按钮
class _DesktopShell extends StatelessWidget {
  final bool isWideScreen;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;
  final Widget child;

  const _DesktopShell({
    required this.isWideScreen,
    required this.isFullScreen,
    required this.onToggleFullScreen,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== 自定义标题栏（桌面端拖拽区域） =====
        _DesktopTitleBar(
          isFullScreen: isFullScreen,
          onToggleFullScreen: onToggleFullScreen,
        ),
        // ===== 主体内容 =====
        Expanded(
          child: isWideScreen ? _buildWideLayout() : child,
        ),
        // ===== 状态栏 =====
        _DesktopStatusBar(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // 左侧快捷导航面板（宽屏模式）
        _DesktopSideNav(),
        // 分隔线
        Container(
          width: 1,
          color: AppTheme.borderGlow.withOpacity(0.3),
        ),
        // 主内容区
        Expanded(child: child),
      ],
    );
  }
}

/// 桌面标题栏（支持拖拽移动窗口）
class _DesktopTitleBar extends StatelessWidget {
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const _DesktopTitleBar({
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryNeonGreen.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // 拖拽区域
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppTheme.primaryNeonGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI NAILS Desktop',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      fontFamily: 'CyberNeon',
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'v3.0',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SIMIAIOS 状态指示
          _buildStatusDot('64 Agents', AppTheme.primaryNeonGreen),
          const SizedBox(width: 12),
          _buildStatusDot('LK Box', AppTheme.accentNeonCyan),
          const SizedBox(width: 12),
          _buildStatusDot('Printer', AppTheme.warningNeonOrange),
          const SizedBox(width: 16),
          // 窗口控制按钮
          _WindowControlButton(
            icon: Icons.minimize,
            onTap: () {
              // 最小化窗口（需要 window_manager 插件）
            },
          ),
          _WindowControlButton(
            icon: isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            onTap: onToggleFullScreen,
          ),
          _WindowControlButton(
            icon: Icons.close,
            isClose: true,
            onTap: () {
              // 关闭窗口
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.6), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }
}

class _WindowControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  const _WindowControlButton({
    required this.icon,
    required this.onTap,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 36,
        color: Colors.transparent,
        child: Icon(
          icon,
          size: 14,
          color: isClose ? AppTheme.errorRed : AppTheme.textHint,
        ),
      ),
    );
  }
}

/// 桌面侧边快捷导航（宽屏模式）
class _DesktopSideNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppTheme.bgSurfaceDark,
        border: Border(
          right: BorderSide(
            color: AppTheme.borderGlow.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo 区域
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.gradientNeon.createShader(bounds),
            child: const Text(
              'AI NAILS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'CyberNeon',
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 导航项
          _SideNavItem(
            icon: Icons.auto_awesome,
            label: '创作舱',
            shortcut: '⌘1',
            isActive: location.startsWith('/create'),
            onTap: () => context.go('/create'),
          ),
          _SideNavItem(
            icon: Icons.dashboard,
            label: '灵感矩阵',
            shortcut: '⌘2',
            isActive: location.startsWith('/gallery'),
            onTap: () => context.go('/gallery'),
          ),
          _SideNavItem(
            icon: Icons.view_in_ar,
            label: 'AR 试戴',
            shortcut: '⌘3',
            isActive: location.startsWith('/ar-preview'),
            onTap: () => context.go('/ar-preview'),
          ),
          _SideNavItem(
            icon: Icons.devices,
            label: '龙虾智控',
            shortcut: '⌘4',
            isActive: location.startsWith('/device'),
            onTap: () => context.go('/device'),
          ),
          _SideNavItem(
            icon: Icons.handshake,
            label: '商业协同',
            shortcut: '⌘5',
            isActive: location.startsWith('/alliance'),
            onTap: () => context.go('/alliance'),
          ),
          _SideNavItem(
            icon: Icons.people,
            label: '全球社区',
            isActive: location.startsWith('/community'),
            onTap: () => context.go('/gallery'),
          ),
          const Spacer(),
          // 底部用户区域
          _SideNavItem(
            icon: Icons.account_circle,
            label: '创作者空间',
            shortcut: '⌘6',
            isActive: location.startsWith('/me'),
            onTap: () => context.go('/me'),
          ),
          _SideNavItem(
            icon: Icons.admin_panel_settings,
            label: '管理后台',
            isActive: location.startsWith('/admin'),
            onTap: () => context.go('/admin/headquarters'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? shortcut;
  final bool isActive;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.icon,
    required this.label,
    this.shortcut,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive
            ? AppTheme.primaryNeonGreen.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
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
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                if (shortcut != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.bgElevatedDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      shortcut!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textHint,
                        fontFamily: 'monospace',
                      ),
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

/// 桌面状态栏
class _DesktopStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryNeonGreen.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _StatusItem(icon: Icons.cloud_done, label: 'SIMIAIOS Connected'),
          const SizedBox(width: 16),
          _StatusItem(icon: Icons.speed, label: 'Latency: 85ms'),
          const SizedBox(width: 16),
          _StatusItem(
              icon: Icons.storage, label: 'LK Box: 42% Load'),
          const Spacer(),
          _StatusItem(icon: Icons.language, label: 'zh-CN'),
          const SizedBox(width: 16),
          _StatusItem(
              icon: Icons.brightness_6,
              label: 'Cyber Dark Mode'),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppTheme.textHint),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textHint,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// 命令面板对话框（⌘K）
class _CommandPaletteDialog extends StatefulWidget {
  @override
  State<_CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<_CommandPaletteDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<_Command> _commands = const [
    _Command('创作新图案', '跳转到创作舱', Icons.auto_awesome, '/create'),
    _Command('浏览图案库', '查看万级原生图案库', Icons.dashboard, '/gallery'),
    _Command('AR 试戴预览', '打开 AR 滤镜试戴', Icons.view_in_ar, '/ar-preview'),
    _Command('设备管理', '龙虾智控设备状态', Icons.devices, '/device'),
    _Command('商业报表', '查看商业协同数据', Icons.bar_chart, '/alliance'),
    _Command('创作者中心', '管理个人资产', Icons.person, '/me'),
    _Command('管理后台', '进入系统管理', Icons.admin_panel_settings, '/admin/headquarters'),
    _Command('支付充值', '账户充值中心', Icons.wallet, '/payment/recharge'),
    _Command('切换主题', '切换明暗主题', Icons.brightness_6, null),
    _Command('设置', '应用设置', Icons.settings, '/settings'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.toLowerCase();
    final filtered = query.isEmpty
        ? _commands
        : _commands
            .where((c) =>
                c.name.toLowerCase().contains(query) ||
                c.description.toLowerCase().contains(query))
            .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryNeonGreen.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 搜索框
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '输入命令搜索...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.primaryNeonGreen,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.bgElevatedDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ESC',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.bgSurfaceDark,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (filtered.isNotEmpty) {
                    _executeCommand(filtered.first);
                  }
                },
              ),
            ),
            // 命令列表
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                padding: const EdgeInsets.only(bottom: 8),
                itemBuilder: (context, index) {
                  final cmd = filtered[index];
                  return ListTile(
                    leading: Icon(cmd.icon,
                        size: 20, color: AppTheme.primaryNeonGreen),
                    title: Text(
                      cmd.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      cmd.description,
                      style: const TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 12,
                      ),
                    ),
                    dense: true,
                    onTap: () => _executeCommand(cmd),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _executeCommand(_Command cmd) {
    Navigator.of(context).pop();
    if (cmd.route != null) {
      // 使用 context.go 需要 context 在 widget tree 中
      // 此处简单关闭对话框，路由通过其他方式处理
    }
  }
}

class _Command {
  final String name;
  final String description;
  final IconData icon;
  final String? route;

  const _Command(this.name, this.description, this.icon, this.route);
}
