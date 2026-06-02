import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/providers.dart';
import 'core/services/simiai_service.dart';
import 'features/auth/domain/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地化
  await EasyLocalization.ensureInitialized();

  // 初始化 Hive 本地存储
  await Hive.initFlutter();

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
