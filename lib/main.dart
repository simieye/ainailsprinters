import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/providers.dart';
import 'core/services/simiai_service.dart';
import 'core/services/desktop_service.dart';
import 'features/auth/domain/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===== 桌面端初始化 =====
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    // 窗口管理器
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(900, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'AI NAILS',
      windowButtonVisibility: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setPreventClose(false);
    });
  }

  // 初始化本地化
  await EasyLocalization.ensureInitialized();

  // 初始化 Hive 本地存储
  await Hive.initFlutter();

  // 初始化桌面服务
  DesktopService.instance.listenToDropEvents();

  // 初始化 SIMIAIOS 64智能体集群连接
  await SimiaiService.instance.initialize();

  // 初始化认证服务（从安全存储恢复会话）
  await AuthService.instance.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
        Locale('pt'),
        Locale('ru'),
        Locale('ar'),
        Locale('th'),
        Locale('vi'),
        Locale('id'),
      ],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(
        child: AiNailsApp(),
      ),
    ),
  );
}

class AiNailsApp extends ConsumerWidget {
  const AiNailsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'AI NAILS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
    );
  }
}
