import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/create/presentation/pages/create_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/device/presentation/pages/device_page.dart';
import '../../features/alliance/presentation/pages/alliance_page.dart';
import '../../features/me/presentation/pages/me_page.dart';
import '../../features/ar/presentation/pages/ar_preview_page.dart';
import '../../features/create/presentation/pages/print_confirm_page.dart';
import '../../features/alliance/presentation/pages/report_page.dart';
import '../../features/community/presentation/pages/community_detail_page.dart';
import '../../features/community/presentation/pages/publish_post_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../di/providers.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/create',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isAuthenticated = authState.isAuthenticated;

      // 未登录且不是认证页面 → 重定向到登录页
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // 已登录但访问认证页面 → 重定向到主页
      if (isAuthenticated && isAuthRoute) {
        return '/create';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/create',
            name: 'create',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CreatePage(),
            ),
          ),
          GoRoute(
            path: '/gallery',
            name: 'gallery',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GalleryPage(),
            ),
          ),
          GoRoute(
            path: '/device',
            name: 'device',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DevicePage(),
            ),
          ),
          GoRoute(
            path: '/alliance',
            name: 'alliance',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AlliancePage(),
            ),
          ),
          GoRoute(
            path: '/me',
            name: 'me',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MePage(),
            ),
          ),
        ],
      ),
      // 认证页面（独立路由，不使用 Shell）
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/ar-preview',
        name: 'ar-preview',
        builder: (context, state) => const ArPreviewPage(),
      ),
      GoRoute(
        path: '/print-confirm',
        name: 'print-confirm',
        builder: (context, state) => const PrintConfirmPage(),
      ),
      GoRoute(
        path: '/report',
        name: 'report',
        builder: (context, state) => const ReportPage(),
      ),
      GoRoute(
        path: '/community/post/:postId',
        name: 'community-post',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return CommunityDetailPage(
              post: extra['post'] as dynamic,
            );
          }
          return const SizedBox();
        },
      ),
      GoRoute(
        path: '/community/publish',
        name: 'community-publish',
        builder: (context, state) => const PublishPostPage(),
      ),
    ],
  );
});
