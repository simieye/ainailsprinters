#!/bin/bash
# ================================================================
# AI NAILS Desktop — GitHub 推送脚本
# 将全部代码推送到 https://github.com/simieye/ainailsprinters
# ================================================================
set -e

REPO_URL="https://github.com/simieye/ainailsprinters.git"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 AI NAILS — GitHub 推送脚本"
echo "================================================================"

cd "$PROJECT_DIR"

# 检查是否已初始化 git
if [ ! -d ".git" ]; then
  echo "📦 初始化 Git 仓库..."
  git init
  git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"
  echo "✅ Git 仓库已初始化"
else
  echo "✅ Git 仓库已存在"
fi

# 检查远程仓库
REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ "$REMOTE" != "$REPO_URL" ]; then
  echo "🔗 设置远程仓库..."
  git remote set-url origin "$REPO_URL" 2>/dev/null || git remote add origin "$REPO_URL"
fi

# 拉取远程更改（如果有）
echo "📥 拉取远程更新..."
git fetch origin 2>/dev/null || echo "⚠️  无法连接远程仓库（首次推送或网络问题）"

# 添加 .gitignore
cat > .gitignore << 'GITIGNORE'
# Flutter
.dart_tool/
.packages
build/
*.iml
*.ipr
*.iws
.idea/

# Android
android/.gradle/
android/app/build/
android/local.properties

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec

# macOS
macos/Pods/
macos/.symlinks/
macos/Flutter/Flutter.framework
macos/Flutter/Flutter.podspec

# Windows
windows/flutter/

# Electron
desktop/electron/node_modules/
desktop/electron/assets/icon.iconset/

# Release
release/

# IDE
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Dependencies
node_modules/
.pub-cache/

# Environment
.env
.env.local
*.jks
*.keystore
GITIGNORE

echo "📝 .gitignore 已更新"

# 添加所有文件
echo "📦 添加文件..."
git add -A

# 检查是否有更改
if git diff --cached --quiet 2>/dev/null; then
  echo "ℹ️  没有新的更改需要提交"
else
  # 提交
  COMMIT_MSG="feat: AI NAILS Desktop v4.0 — 6大系统完善 + AI模型提供商 + 智能体集群 + OpenClaw控制台 + macOS DMG封装

- ✨ 完善6大系统全部功能（创作舱/设备/社区/支付/后台/设置）
- 🔌 新增AI大模型提供商设置界面（OpenAI/Anthropic/Gemini/DeepSeek/通义千问/自定义）
- 🧠 新增智能体集群Skill管理（已安装/Hub市场/自定义添加/对话添加）
- 🦞 新增一键跳转OpenClaw控制台（http://127.0.0.1:18789/chat?session=main）
- 📦 新增Electron封装 + macOS DMG打包脚本
- 🎨 新增风格选择器、图片上传、AI对话创作助手
- 🏪 新增ClawSkill Hub官方市场集成
- 🔧 增强设备仪表盘（测试打印/清洁喷头/校准功能）
- 🌍 增强社区（排行榜/交易市场/动态Feed切换）
- 🛡 增强后台管理（订单操作/风控释放/详情查看）"

  git commit -m "$COMMIT_MSG"
  echo "✅ 代码已提交"
fi

# 推送到 GitHub
echo ""
echo "🚀 推送到 GitHub..."
echo "   仓库: $REPO_URL"

# 尝试推送到 main 分支
if git push -u origin main 2>/dev/null; then
  echo "✅ 推送成功 (main 分支)"
elif git push -u origin master 2>/dev/null; then
  echo "✅ 推送成功 (master 分支)"
else
  # 如果推送失败，尝试使用 --force（谨慎）
  echo "⚠️  常规推送失败，可能是远程仓库有冲突"
  echo ""
  echo "请手动处理："
  echo "  cd $PROJECT_DIR"
  echo "  git pull origin main --allow-unrelated-histories"
  echo "  git push -u origin main"
  echo ""
  echo "或者创建新分支推送："
  echo "  git checkout -b feat/v4.0-desktop"
  echo "  git push -u origin feat/v4.0-desktop"
fi

echo ""
echo "================================================================"
echo "✅ 推送完成！"
echo "================================================================"
echo ""
echo "GitHub 仓库: $REPO_URL"
echo ""
