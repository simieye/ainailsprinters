import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 桌面端原生功能服务
/// 提供拖拽导入、快捷键、文件系统、窗口管理等桌面特有功能
class DesktopService {
  static final DesktopService instance = DesktopService._();
  DesktopService._();

  static const _channel = MethodChannel('com.ainails.app/desktop');
  static const _dropChannel = MethodChannel('com.ainails.app/drop');

  /// 是否为桌面平台
  bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  /// 是否为 macOS
  bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// 是否为 Windows
  bool get isWindows => !kIsWeb && Platform.isWindows;

  /// 获取平台名称
  Future<String> getPlatform() async {
    if (!isDesktop) return kIsWeb ? 'web' : Platform.operatingSystem;
    try {
      final result = await _channel.invokeMethod<String>('getPlatform');
      return result ?? Platform.operatingSystem;
    } catch (e) {
      return Platform.operatingSystem;
    }
  }

  /// 获取应用数据目录
  Future<String> getAppDataPath() async {
    if (!isDesktop) return '';
    try {
      final path = await _channel.invokeMethod<String>('getAppDataPath');
      if (path != null) {
        final dir = Directory(path);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return path;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// 打开文件选择对话框
  /// [filters] 文件类型过滤器，如 {'Images': '*.png;*.jpg'}
  Future<String?> openFileDialog({Map<String, String>? filters}) async {
    if (!isDesktop) return null;
    try {
      final result = await _channel.invokeMethod<String>('openFileDialog');
      return result;
    } catch (e) {
      debugPrint('DesktopService: openFileDialog error: $e');
      return null;
    }
  }

  /// 打开文件保存对话框
  Future<String?> saveFileDialog({String? defaultFileName}) async {
    if (!isDesktop) return null;
    try {
      final result = await _channel.invokeMethod<String>(
        'saveFileDialog',
        defaultFileName != null ? {'fileName': defaultFileName} : null,
      );
      return result;
    } catch (e) {
      debugPrint('DesktopService: saveFileDialog error: $e');
      return null;
    }
  }

  /// 打开文件夹选择对话框
  Future<String?> pickDirectory() async {
    if (!isDesktop) return null;
    try {
      final result = await _channel.invokeMethod<String>('pickDirectory');
      return result;
    } catch (e) {
      debugPrint('DesktopService: pickDirectory error: $e');
      return null;
    }
  }

  /// 窗口操作
  Future<void> minimizeWindow() async {
    if (!isDesktop) return;
    try {
      await _channel.invokeMethod('minimizeWindow');
    } catch (e) {
      debugPrint('DesktopService: minimizeWindow error: $e');
    }
  }

  Future<void> maximizeWindow() async {
    if (!isDesktop) return;
    try {
      await _channel.invokeMethod('maximizeWindow');
    } catch (e) {
      debugPrint('DesktopService: maximizeWindow error: $e');
    }
  }

  Future<void> restoreWindow() async {
    if (!isDesktop) return;
    try {
      await _channel.invokeMethod('restoreWindow');
    } catch (e) {
      debugPrint('DesktopService: restoreWindow error: $e');
    }
  }

  Future<void> closeWindow() async {
    if (!isDesktop) return;
    try {
      await _channel.invokeMethod('closeWindow');
    } catch (e) {
      debugPrint('DesktopService: closeWindow error: $e');
    }
  }

  /// 设置窗口置顶
  Future<void> setAlwaysOnTop(bool enable) async {
    if (!isDesktop) return;
    try {
      await _channel.invokeMethod('setAlwaysOnTop', {'enable': enable});
    } catch (e) {
      debugPrint('DesktopService: setAlwaysOnTop error: $e');
    }
  }

  /// 拖放文件回调
  final ValueNotifier<List<String>?> droppedFiles =
      ValueNotifier<List<String>?>(null);

  /// 监听拖放事件
  void listenToDropEvents() {
    if (!isDesktop) return;
    _dropChannel.setMethodCallHandler((call) async {
      if (call.method == 'onFilesDropped') {
        final List<dynamic> files = call.arguments as List<dynamic>;
        droppedFiles.value =
            files.map((e) => e.toString()).toList();
      }
    });
  }

  /// 键盘快捷键处理
  final Map<LogicalKeyboardKey, VoidCallback> _shortcuts = {};

  /// 注册快捷键
  void registerShortcut(LogicalKeyboardKey key, VoidCallback callback) {
    _shortcuts[key] = callback;
  }

  /// 注销快捷键
  void unregisterShortcut(LogicalKeyboardKey key) {
    _shortcuts.remove(key);
  }

  /// 处理快捷键
  void handleShortcut(LogicalKeyboardKey key) {
    _shortcuts[key]?.call();
  }

  /// 保存文件到本地
  Future<String?> saveFileToLocal(
    List<int> bytes, {
    required String fileName,
    String? directory,
  }) async {
    if (!isDesktop) return null;
    try {
      final dir = directory ?? await getAppDataPath();
      if (dir.isEmpty) return null;

      final file = File('$dir/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('DesktopService: saveFileToLocal error: $e');
      return null;
    }
  }

  /// 读取本地文件
  Future<List<int>?> readFileFromLocal(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('DesktopService: readFileFromLocal error: $e');
      return null;
    }
  }

  /// 列出目录文件
  Future<List<String>> listDirectoryFiles(
    String path, {
    List<String>? extensions,
  }) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) return [];

      final entities = await dir.list().toList();
      final files = entities
          .whereType<File>()
          .where((f) {
            if (extensions == null || extensions.isEmpty) return true;
            final ext = f.path.split('.').last.toLowerCase();
            return extensions.contains(ext);
          })
          .map((f) => f.path)
          .toList();

      return files;
    } catch (e) {
      debugPrint('DesktopService: listDirectoryFiles error: $e');
      return [];
    }
  }

  /// 清理资源
  void dispose() {
    droppedFiles.dispose();
    _shortcuts.clear();
  }
}
