# AI NAILS APP (V3.0)

🌍 全球首款基于 **OpenClaw 原生技术** 构建的智能美业客户端。

**多端支持**: macOS | Windows | iOS | Android

[![Build Status](https://github.com/simieye/ainailsprinters/actions/workflows/build_and_release.yml/badge.svg)](https://github.com/simieye/ainailsprinters/actions/workflows/build_and_release.yml)
[![Test Status](https://github.com/simieye/ainailsprinters/actions/workflows/test.yml/badge.svg)](https://github.com/simieye/ainailsprinters/actions/workflows/test.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.22-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## 🏗️ 项目架构

```
ai_nails_app/
├── lib/
│   ├── main.dart                          # 应用入口
│   ├── core/
│   │   ├── theme/app_theme.dart           # 赛博暗色主题
│   │   ├── router/
│   │   │   ├── app_router.dart            # GoRouter 路由
│   │   │   └── app_shell.dart             # 底部导航 Shell
│   │   ├── di/providers.dart              # Riverpod 全局状态
│   │   └── services/
│   │       ├── simiai_service.dart        # SIMIAIOS 64智能体集群
│   │       ├── openclaw_service.dart      # OpenClaw 会话管理
│   │       ├── nanobanana_service.dart    # NanoBanana 3.0 引擎
│   │       ├── lkbox_service.dart         # LK Box 龙虾云盒
│   │       ├── mcp_protocol_service.dart  # MCP 协议层
│   │       ├── http_client.dart           # HTTP 客户端
│   │       ├── api_config.dart            # API 配置
│   │       ├── camera_service.dart        # 相机服务
│   │       ├── bluetooth_print_service.dart # 蓝牙打印
│   │       ├── translation_service.dart   # 翻译服务
│   │       ├── voice_input_service.dart   # 语音输入
│   │       └── image_upload_service.dart  # 图片上传
│   └── features/
│       ├── auth/                          # 🔐 用户认证
│       │   ├── domain/
│       │   │   ├── models/user.dart
│       │   │   └── services/auth_service.dart
│       │   └── presentation/pages/
│       │       ├── login_page.dart
│       │       └── register_page.dart
│       ├── create/                        # 🎨 创作舱
│       ├── gallery/                       # 🖼️ 灵感矩阵
│       ├── device/                        # 🖨️ 龙虾智控
│       ├── alliance/                      # 📊 商业协同
│       ├── me/                            # 👤 创作者空间
│       ├── community/                     # 🌐 全球社区
│       └── ar/                            # 📱 AR 预览
├── android/                               # Android 平台
├── ios/                                   # iOS 平台
├── macos/                                 # macOS 平台
├── windows/                               # Windows 平台
├── assets/
│   └── i18n/                              # 13语言国际化
├── .github/workflows/                     # CI/CD
│   ├── build_and_release.yml              # 多平台构建+发布
│   └── test.yml                           # 自动化测试
├── Dockerfile                             # Docker 构建环境
├── Makefile                               # 自动化命令
└── pubspec.yaml
```

## 🚀 核心技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| **大脑层** | OpenClaw Master | 自然语言解析、多模态上下文会话管理、MCP 状态反馈 |
| **创意层** | NanoBanana 3.0 Engine | 亚秒级 AIGC 图像生成、甲型自适应拓扑变形算法 |
| **物联网层** | LK Box Cloud & Local | 私有化算力、边缘网关、硬件状态监控 |
| **前端** | Flutter + Riverpod | 跨平台 UI、赛博暗色主题 |
| **路由** | GoRouter | 声明式导航 + 认证路由守卫 |
| **国际化** | Easy Localization | 13+ 语言支持 |
| **认证** | Flutter Secure Storage + Hive | JWT Token 管理 + 本地缓存 |
| **网络** | Dio + WebSocket | HTTP/2 + MCP 双向通信 |
| **CI/CD** | GitHub Actions | 自动构建 Android/iOS/macOS/Windows |

## 🎨 七大核心看板

1. **🔐 Auth - 认证中心**：邮箱登录/注册、JWT Token 管理、游客模式
2. **🎨 Create - 创作舱**：语音/文本 AI 创作，OpenClaw 智能大脑气泡
3. **🖼️ Gallery - 灵感矩阵**：10000+ 工业级图案库，太极64卦偏好推荐
4. **🖨️ Device - 龙虾智控**：3D 设备建模透视图，CMYK 墨盒实时监控
5. **📊 Alliance - 商业协同**：45天 ROI 回本进度，多店并联营收管理
6. **👤 Me - 创作者空间**：提示词资产管理，全球创作者社区
7. **📱 AR - AR 预览**：真实相机 + V-ALIGN 3D 视觉定位

## 📦 用户工作流

```
打开APP → 登录/游客模式 → 点击微标喊出创意 
→ nanobanana 生成4张候选图 → 3D甲面AR试戴 
→ 确认发送至彩绘机 → 10秒完成打印
```

## 🔧 本地运行

### 环境要求
- Flutter SDK >= 3.2.0
- Xcode 15+ (macOS/iOS)
- Android Studio (Android)
- Visual Studio 2022 (Windows)

### 快速开始
```bash
# 克隆仓库
git clone https://github.com/simieye/ainailsprinters.git
cd ainailsprinters

# 安装依赖
flutter pub get

# 运行代码生成
dart run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run

# 或使用 Makefile
make deps
make run
```

### 平台特定运行
```bash
# macOS
flutter run -d macos

# iOS (需要 macOS + Xcode)
flutter run -d ios

# Android
flutter run -d android

# Windows
flutter run -d windows
```

## 🏗️ 构建发布包

```bash
# 使用 Makefile
make build-android    # Android APK + AAB
make build-ios        # iOS (无签名)
make build-macos      # macOS 应用
make build-windows    # Windows 应用
make build-all        # 所有平台
make release          # 打包所有发布文件
```

## 🤖 CI/CD 自动构建

项目配置了 GitHub Actions 自动化流水线：

- **Push 到 main/master**: 自动运行测试 + 代码分析
- **推送 tag (v*)**: 触发全平台构建并自动创建 GitHub Release
- **Pull Request**: 运行 lint + test 检查

### 安装包下载

每次 Release 会自动构建并上传以下平台的安装包：

| 平台 | 文件类型 | 说明 |
|------|----------|------|
| 🤖 Android | APK (arm64/armv7/x86_64) + AAB | 直接安装或上传 Google Play |
| 🍎 iOS | IPA | 需通过 Xcode 或 AltStore 侧载 |
| 💻 macOS | ZIP (app bundle) | 解压后拖入 Applications |
| 🪟 Windows | ZIP (exe) | 解压后运行 |

## 🌍 国际化

支持 13 种语言：

| 代码 | 语言 | 覆盖率 |
|------|------|--------|
| zh | 中文 | ✅ 100% |
| en | English | ✅ 100% |
| ja | 日本語 | ✅ 100% |
| ko | 한국어 | ✅ 100% |
| fr | Français | ⬜ 待翻译 |
| de | Deutsch | ⬜ 待翻译 |
| es | Español | ⬜ 待翻译 |
| pt | Português | ⬜ 待翻译 |
| ru | Русский | ⬜ 待翻译 |
| ar | العربية | ⬜ 待翻译 |
| th | ไทย | ⬜ 待翻译 |
| vi | Tiếng Việt | ⬜ 待翻译 |
| id | Bahasa Indonesia | ⬜ 待翻译 |

## 📋 API 服务

| 服务 | 端点 | 状态 |
|------|------|------|
| SIMIAIOS 集群 | `api.ai-nails.com/v3` | 🟢 Mock Ready |
| NanoBanana 3.0 | `api.ai-nails.com/nanobanana` | 🟢 Mock Ready |
| OpenClaw | `api.ai-nails.com/openclaw` | 🟢 Mock Ready |
| LK Box IoT | `api.ai-nails.com/lkbox` | 🟢 Mock Ready |
| MCP WebSocket | `ws.ai-nails.com/ws/simiai` | 🟢 Mock Ready |
| CDN | `cdn.ai-nails.com` | 🟢 Mock Ready |

> 所有服务均支持 API 优先调用 + Mock 回退模式，确保离线开发可用。

## 🗺️ 开发路线图

- [x] 跨平台项目框架 (macOS/Windows/iOS/Android)
- [x] 用户认证系统 (登录/注册/Token管理)
- [x] AIGC 引擎集成 (NanoBanana + OpenClaw)
- [x] AR 真实预览 + 蓝牙打印
- [x] 社区翻译 + 图片上传 + 语音输入
- [x] CI/CD 自动构建 + GitHub Release
- [ ] 接入真实后端 API
- [ ] 补充 9 种语言翻译文件
- [ ] 集成测试
- [ ] App Store / Google Play 发布
- [ ] 推送通知
- [ ] 暗色/浅色主题切换

## 📄 License

MIT License - 详见 [LICENSE](LICENSE)
