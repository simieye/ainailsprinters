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
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/pages/headquarters_page.dart';
import '../../features/admin/presentation/pages/tech_support_page.dart';
import '../../features/admin/presentation/pages/dealers_page.dart';
import '../../features/admin/presentation/pages/stores_page.dart';
import '../../features/admin/presentation/pages/users_page.dart';
import '../../features/admin/presentation/pages/community_page.dart';
import '../../features/admin/presentation/pages/payment_hub_page.dart';
import '../../features/admin/presentation/pages/production_page.dart';
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
      // ===== 管理后台路由 =====
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/headquarters',
            name: 'admin-headquarters',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HeadquartersPage(),
            ),
          ),
          GoRoute(
            path: '/admin/tech-support',
            name: 'admin-tech-support',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TechSupportPage(),
            ),
          ),
          GoRoute(
            path: '/admin/dealers',
            name: 'admin-dealers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DealersPage(),
            ),
          ),
          GoRoute(
            path: '/admin/stores',
            name: 'admin-stores',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StoresPage(),
            ),
          ),
          GoRoute(
            path: '/admin/users',
            name: 'admin-users',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UsersPage(),
            ),
          ),
          GoRoute(
            path: '/admin/community',
            name: 'admin-community',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommunityPage(),
            ),
          ),
          GoRoute(
            path: '/admin/payments',
            name: 'admin-payments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PaymentHubPage(),
            ),
          ),
          GoRoute(
            path: '/admin/production',
            name: 'admin-production',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductionPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
