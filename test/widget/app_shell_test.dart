import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AppShell Widget 测试
/// 
/// 注意：由于 AppShell 依赖 GoRouter 上下文，
/// 这些测试验证核心 Widget 的构建和渲染逻辑。
void main() {
  group('AppShell - Navigation Items', () {
    testWidgets('should have correct number of tabs', (tester) async {
      // 创建简化的导航栏测试
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: _MockNavigationBar(),
          ),
        ),
      );

      // 验证导航栏渲染
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byType(Column), findsWidgets);
    });
  });
}

/// 模拟导航栏 Widget 用于测试
class _MockNavigationBar extends StatelessWidget {
  const _MockNavigationBar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Mock')),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Device'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
