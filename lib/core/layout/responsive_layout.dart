import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 屏幕断点枚举
enum ScreenBreakpoint {
  mobile,   // < 600px
  tablet,   // 600 - 1024px
  desktop,  // >= 1024px
}

/// 响应式布局 Provider
final screenBreakpointProvider = StateProvider<ScreenBreakpoint>((ref) {
  return ScreenBreakpoint.desktop;
});

/// 当前是否为桌面端布局
final isDesktopLayoutProvider = Provider<bool>((ref) {
  return ref.watch(screenBreakpointProvider) == ScreenBreakpoint.desktop;
});

/// 是否为平板布局
final isTabletLayoutProvider = Provider<bool>((ref) {
  return ref.watch(screenBreakpointProvider) == ScreenBreakpoint.tablet;
});

/// 是否为移动端布局
final isMobileLayoutProvider = Provider<bool>((ref) {
  return ref.watch(screenBreakpointProvider) == ScreenBreakpoint.mobile;
});

/// 响应式布局构建器
/// 根据屏幕宽度自动切换移动端/平板/桌面端布局
class ResponsiveLayoutBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = _getBreakpoint(constraints.maxWidth);
        ref.read(screenBreakpointProvider.notifier).state = breakpoint;

        switch (breakpoint) {
          case ScreenBreakpoint.desktop:
            return desktop?.call(context) ?? tablet?.call(context) ?? mobile(context);
          case ScreenBreakpoint.tablet:
            return tablet?.call(context) ?? mobile(context);
          case ScreenBreakpoint.mobile:
            return mobile(context);
        }
      },
    );
  }

  ScreenBreakpoint _getBreakpoint(double width) {
    if (width >= 1024) return ScreenBreakpoint.desktop;
    if (width >= 600) return ScreenBreakpoint.tablet;
    return ScreenBreakpoint.mobile;
  }
}

/// 桌面端侧边栏布局
/// 左侧固定导航 + 右侧内容区域
class DesktopSidebarLayout extends ConsumerWidget {
  final Widget sidebar;
  final Widget content;
  final double sidebarWidth;

  const DesktopSidebarLayout({
    super.key,
    required this.sidebar,
    required this.content,
    this.sidebarWidth = 240,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ref.watch(isDesktopLayoutProvider);

    if (!isDesktop) {
      return content;
    }

    return Row(
      children: [
        // 左侧导航栏
        SizedBox(
          width: sidebarWidth,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: sidebar,
          ),
        ),
        // 分割线
        Container(
          width: 1,
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        // 右侧内容区域
        Expanded(child: content),
      ],
    );
  }
}

/// 桌面端分栏布局
/// 支持可调整大小的左右分栏
class DesktopSplitView extends ConsumerStatefulWidget {
  final Widget leftPanel;
  final Widget rightPanel;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;

  const DesktopSplitView({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
    this.initialRatio = 0.4,
    this.minRatio = 0.25,
    this.maxRatio = 0.6,
  });

  @override
  ConsumerState<DesktopSplitView> createState() => _DesktopSplitViewState();
}

class _DesktopSplitViewState extends ConsumerState<DesktopSplitView> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ref.watch(isDesktopLayoutProvider);

    if (!isDesktop) {
      // 移动端/平板：上下排列
      return Column(
        children: [
          Expanded(child: widget.leftPanel),
          const Divider(height: 1),
          Expanded(child: widget.rightPanel),
        ],
      );
    }

    // 桌面端：左右分栏
    return LayoutBuilder(
      builder: (context, constraints) {
        final leftWidth = constraints.maxWidth * _ratio;
        final rightWidth = constraints.maxWidth - leftWidth - 4;

        return Row(
          children: [
            SizedBox(
              width: leftWidth,
              child: widget.leftPanel,
            ),
            // 可拖拽分割条
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _ratio += details.delta.dx / constraints.maxWidth;
                  _ratio = _ratio.clamp(widget.minRatio, widget.maxRatio);
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Container(
                  width: 4,
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
            ),
            SizedBox(
              width: rightWidth,
              child: widget.rightPanel,
            ),
          ],
        );
      },
    );
  }
}

/// 桌面端最大宽度约束
/// 在大屏幕上限制内容最大宽度，保持可读性
class DesktopConstrainedBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const DesktopConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// 桌面端卡片网格布局
/// 根据屏幕宽度自动调整列数
class DesktopAdaptiveGrid extends ConsumerWidget {
  final List<Widget> children;
  final double itemMinWidth;
  final double spacing;
  final double runSpacing;

  const DesktopAdaptiveGrid({
    super.key,
    required this.children,
    this.itemMinWidth = 280,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint = ref.watch(screenBreakpointProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / itemMinWidth).floor().clamp(1, 6);

        if (breakpoint == ScreenBreakpoint.mobile && crossAxisCount > 1) {
          // 移动端单列
          return ListView.separated(
            itemCount: children.length,
            separatorBuilder: (_, __) => SizedBox(height: runSpacing),
            itemBuilder: (_, i) => children[i],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: runSpacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 0.85,
          ),
          itemCount: children.length,
          itemBuilder: (_, i) => children[i],
        );
      },
    );
  }
}

/// 快捷键回调包装器
class DesktopShortcutWrapper extends StatelessWidget {
  final Widget child;
  final Map<ShortcutActivator, VoidCallback> shortcuts;

  const DesktopShortcutWrapper({
    super.key,
    required this.child,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    final intentMap = <ShortcutActivator, Intent>{
      for (final entry in shortcuts.entries)
        entry.key: VoidCallbackIntent(entry.value),
    };

    return Shortcuts(
      shortcuts: intentMap,
      child: Actions(
        actions: {
          VoidCallbackIntent: CallbackAction<VoidCallbackIntent>(
            onInvoke: (intent) {
              intent.callback();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class VoidCallbackIntent extends Intent {
  final VoidCallback callback;
  const VoidCallbackIntent(this.callback);
}
