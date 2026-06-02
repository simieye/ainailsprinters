import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/simiai_service.dart';
import '../services/lkbox_service.dart';
import '../services/nanobanana_service.dart';
import '../services/openclaw_service.dart';
import '../services/mcp_protocol_service.dart';
import '../services/camera_service.dart';
import '../services/bluetooth_print_service.dart';
import '../services/translation_service.dart';
import '../services/voice_input_service.dart';
import '../services/image_upload_service.dart';
import '../../features/create/domain/models/design_prompt.dart';
import '../../features/device/domain/models/device_status.dart';
import '../../features/gallery/domain/models/nail_design.dart';
import '../../features/alliance/domain/models/business_metrics.dart';
import '../../features/me/domain/models/creator_profile.dart';
import '../../features/community/domain/models/community_post.dart';
import '../../features/community/domain/services/community_service.dart';
import '../../features/alliance/domain/services/report_service.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/auth/domain/models/user.dart';

// ===== 主题状态 =====
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// ===== 服务层 Provider =====
final simiaiServiceProvider = Provider<SimiaiService>((ref) => SimiaiService.instance);
final openclawServiceProvider = Provider<OpenClawService>((ref) => OpenClawService.instance);
final nanobananaServiceProvider = Provider<NanoBananaService>((ref) => NanoBananaService.instance);
final lkboxServiceProvider = Provider<LKBoxService>((ref) => LKBoxService.instance);
final mcpProtocolServiceProvider = Provider<McpProtocolService>((ref) => McpProtocolService.instance);
final communityServiceProvider = Provider<CommunityService>((ref) => CommunityService.instance);
final reportServiceProvider = Provider<ReportService>((ref) => ReportService.instance);
final authServiceProvider = Provider<AuthService>((ref) => AuthService.instance);
final cameraServiceProvider = Provider<CameraService>((ref) => CameraService.instance);
final bluetoothPrintServiceProvider = Provider<BluetoothPrintService>((ref) => BluetoothPrintService.instance);
final translationServiceProvider = Provider<TranslationService>((ref) => TranslationService.instance);
final voiceInputServiceProvider = Provider<VoiceInputService>((ref) => VoiceInputService.instance);
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) => ImageUploadService.instance);

// ===== 认证状态 =====
final authStateProvider = StateProvider<AuthState>((ref) {
  // 监听 AuthService 的状态流
  final authService = ref.watch(authServiceProvider);
  authService.authState.listen((state) {
    ref.read(_authStateInternalProvider.notifier).state = state;
  });
  return AuthState.initial();
});

final _authStateInternalProvider = StateProvider<AuthState>((ref) => AuthState.initial());

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider).isAuthenticated;
});

// ===== 商业模式切换 (B2C / B2B) =====
final businessModeProvider = StateProvider<BusinessMode>((ref) => BusinessMode.b2c);

// ===== 创作舱状态 =====
final currentPromptProvider = StateProvider<String>((ref) => '');
final generatedDesignsProvider = StateProvider<List<NailDesign>>((ref) => []);
final isGeneratingProvider = StateProvider<bool>((ref) => false);
final selectedDesignProvider = StateProvider<NailDesign?>((ref) => null);

// ===== 图案库状态 =====
final galleryDesignsProvider = StateProvider<List<NailDesign>>((ref) => []);
final galleryCategoryProvider = StateProvider<String>((ref) => 'all');
final gallerySearchProvider = StateProvider<String>((ref) => '');

// ===== 设备状态 =====
final deviceStatusProvider = StateProvider<DeviceStatus>((ref) => DeviceStatus.initial());
final isDeviceConnectedProvider = StateProvider<bool>((ref) => false);
final cartridgeLevelsProvider = StateProvider<Map<String, double>>((ref) => {
  'C': 0.85, 'M': 0.62, 'Y': 0.91, 'K': 0.45,
});

// ===== B端商业指标 =====
final businessMetricsProvider = StateProvider<BusinessMetrics>((ref) => BusinessMetrics.initial());
final multiStoreDataProvider = StateProvider<List<StoreMetrics>>((ref) => []);

// ===== 创作者空间 =====
final creatorProfileProvider = StateProvider<CreatorProfile>((ref) => CreatorProfile.initial());
final creatorAssetsProvider = StateProvider<List<PromptAsset>>((ref) => []);

// ===== 语音输入状态 =====
final isListeningProvider = StateProvider<bool>((ref) => false);
final voiceTextProvider = StateProvider<String>((ref) => '');

// ===== AR 预览状态 =====
final isArPreviewActiveProvider = StateProvider<bool>((ref) => false);

// ===== 用户偏好推荐 =====
final userPreferencesProvider = StateProvider<Map<String, double>>((ref) => {
  'cyberpunk': 0.8,
  'minimalist': 0.6,
  'floral': 0.3,
  'geometric': 0.5,
  'gradient': 0.7,
});

// ===== 社区模块 =====
final communityPostsProvider = StateProvider<List<CommunityPost>>((ref) => []);
final communityCurrentPageProvider = StateProvider<int>((ref) => 1);

// ===== MCP 连接状态 =====
final mcpConnectionStateProvider = StateProvider<McpConnectionState>(
  (ref) => McpConnectionState.disconnected,
);
