/// API 配置
/// 集中管理所有后端服务端点
class ApiConfig {
  ApiConfig._();

  /// SIMIAIOS 64智能体集群基地址
  static const String simiaiBaseUrl = 'https://api.ai-nails.com/v3';

  /// NanoBanana 3.0 AIGC 引擎
  static const String nanobananaBaseUrl = 'https://api.ai-nails.com/nanobanana';

  /// OpenClaw 会话管理
  static const String openclawBaseUrl = 'https://api.ai-nails.com/openclaw';

  /// LK Box IoT 网关
  static const String lkboxBaseUrl = 'https://api.ai-nails.com/lkbox';

  /// MCP WebSocket 网关
  static const String mcpWsUrl = 'wss://ws.ai-nails.com/ws/simiai';

  /// 社区服务
  static const String communityBaseUrl = 'https://api.ai-nails.com/community';

  /// 认证服务
  static const String authBaseUrl = 'https://api.ai-nails.com/auth';

  /// CDN 资源
  static const String cdnBaseUrl = 'https://cdn.ai-nails.com';

  // ===== 端点路径 =====

  /// NanoBanana - 生成图案
  static const String generateDesign = '/generate';

  /// NanoBanana - 甲型自适应
  static const String adaptToNail = '/adapt';

  /// NanoBanana - 风格迁移
  static const String styleTransfer = '/style-transfer';

  /// OpenClaw - 创建会话
  static const String createSession = '/session/create';

  /// OpenClaw - 处理输入
  static const String processInput = '/session/process';

  /// OpenClaw - 结束会话
  static const String endSession = '/session/end';

  /// SIMIAIOS - 分发任务
  static const String dispatchTask = '/cluster/dispatch';

  /// SIMIAIOS - 集群状态
  static const String clusterStatus = '/cluster/status';

  /// LK Box - 设备状态
  static const String deviceStatus = '/device/status';

  /// LK Box - 打印统计
  static const String printStats = '/device/print-stats';

  /// LK Box - ROI 数据
  static const String roiData = '/device/roi';

  /// LK Box - OTA 更新
  static const String otaUpdate = '/device/ota';

  /// 社区 - 帖子列表
  static const String communityPosts = '/posts';

  /// 社区 - 帖子详情
  static const String communityPostDetail = '/posts/{postId}';

  /// 社区 - 发布帖子
  static const String publishPost = '/posts/publish';

  /// 社区 - 评论
  static const String postComments = '/posts/{postId}/comments';

  /// 社区 - 翻译
  static const String translate = '/translate';

  /// 认证 - 注册
  static const String authRegister = '/register';

  /// 认证 - 登录
  static const String authLogin = '/login';

  /// 认证 - 刷新 Token
  static const String authRefresh = '/token/refresh';

  /// 认证 - 用户信息
  static const String authProfile = '/profile';

  // ===== 超时配置 =====
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);

  // ===== 重试配置 =====
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}
