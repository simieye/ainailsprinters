#!/bin/bash
# ================================================================
# AI NAILS Desktop — macOS DMG 打包脚本
# 封装为原生 macOS .dmg 安装包
# ================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ELECTRON_DIR="$SCRIPT_DIR/electron"
RELEASE_DIR="$PROJECT_DIR/release"
APP_NAME="AI NAILS"
DMG_NAME="AI_NAILS_Desktop_v4.0.0"
ICON_DIR="$ELECTRON_DIR/assets"

echo "🔨 AI NAILS Desktop — DMG 打包工具"
echo "================================================================"

# 检查依赖
check_deps() {
  if ! command -v node &> /dev/null; then
    echo "❌ 需要 Node.js，请先安装: brew install node"
    exit 1
  fi
  if ! command -v npm &> /dev/null; then
    echo "❌ 需要 npm"
    exit 1
  fi
  echo "✅ Node.js $(node --version)"
  echo "✅ npm $(npm --version)"
}

# 安装 Electron 依赖
install_deps() {
  echo ""
  echo "📦 安装 Electron 依赖..."
  cd "$ELECTRON_DIR"
  npm install --no-audit --no-fund
  cd "$SCRIPT_DIR"
}

# 生成图标（如果没有 icns 文件，生成一个占位图标）
generate_icon() {
  mkdir -p "$ICON_DIR"
  
  if [ -f "$ICON_DIR/icon.icns" ]; then
    echo "✅ 图标文件已存在: $ICON_DIR/icon.icns"
    return
  fi

  echo "🎨 生成应用图标..."

  # 创建临时 iconset 目录
  ICONSET="$ICON_DIR/icon.iconset"
  mkdir -p "$ICONSET"

  # 使用 Python 生成占位图标（如果 sips 可用）
  if command -v python3 &> /dev/null; then
    python3 -c "
from PIL import Image, ImageDraw, ImageFont
import os

size = 1024
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# 背景圆角矩形
draw.rounded_rectangle([40, 40, size-40, size-40], radius=120, fill=(8, 8, 15, 255))

# 渐变效果 - 简单双色
for i in range(size-80):
    r = int(0 + (180-0) * i / (size-80))
    g = int(240 - (240-76) * i / (size-80))
    b = int(255 - (255-255) * i / (size-80))
    draw.line([(40, 40+i), (size-40, 40+i)], fill=(r, g, b, 30))

# 文字
try:
    font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 200)
except:
    font = ImageFont.load_default()
draw.text((size/2, size/2-40), 'AI', fill=(0, 240, 255, 255), font=font, anchor='mm')
draw.text((size/2, size/2+120), 'NAILS', fill=(180, 76, 255, 255), font=ImageFont.load_default(), anchor='mm')

img.save('$ICONSET/icon_512x512@2x.png')
print('Icon generated')
" 2>/dev/null || {
      echo "⚠️  PIL 不可用，使用 sips 生成简单图标"
      # 创建纯色图标
      convert -size 1024x1024 xc:'#08080f' -fill '#00f0ff' -draw "text 300,550 'AI NAILS'" "$ICONSET/icon_512x512@2x.png" 2>/dev/null || {
        echo "⚠️  无法生成图标，将跳过图标打包"
        return
      }
    }
  fi

  # 生成各种尺寸
  if [ -f "$ICONSET/icon_512x512@2x.png" ]; then
    sips -z 16 16 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_16x16.png" 2>/dev/null || true
    sips -z 32 32 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_16x16@2x.png" 2>/dev/null || true
    sips -z 32 32 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_32x32.png" 2>/dev/null || true
    sips -z 64 64 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_32x32@2x.png" 2>/dev/null || true
    sips -z 128 128 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_128x128.png" 2>/dev/null || true
    sips -z 256 256 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_128x128@2x.png" 2>/dev/null || true
    sips -z 256 256 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_256x256.png" 2>/dev/null || true
    sips -z 512 512 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_256x256@2x.png" 2>/dev/null || true
    sips -z 512 512 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_512x512.png" 2>/dev/null || true

    iconutil -c icns "$ICONSET" -o "$ICON_DIR/icon.icns" 2>/dev/null || {
      echo "⚠️  iconutil 不可用，将使用 PNG 图标"
      cp "$ICONSET/icon_512x512@2x.png" "$ICON_DIR/icon.png"
    }
    echo "✅ 图标生成完成"
  fi
}

# DMG 背景图
generate_dmg_bg() {
  if [ -f "$ICON_DIR/dmg-background.png" ]; then
    return
  fi
  echo "🎨 生成 DMG 背景图..."
  if command -v python3 &> /dev/null; then
    python3 -c "
from PIL import Image, ImageDraw
img = Image.new('RGBA', (540, 380), (14, 14, 24, 255))
draw = ImageDraw.Draw(img)
# 简单的装饰线
for i in range(0, 540, 20):
    draw.line([(i, 0), (i, 380)], fill=(20, 20, 40, 50))
img.save('$ICON_DIR/dmg-background.png')
" 2>/dev/null || echo "⚠️  无法生成 DMG 背景"
    echo "✅ DMG 背景图生成完成"
  fi
}

# 构建 Electron 应用
build_electron() {
  echo ""
  echo "🔨 构建 Electron 应用..."
  cd "$ELECTRON_DIR"
  
  # 使用 electron-builder 打包
  npx electron-builder --mac --config \
'{
  "appId": "com.ainails.desktop",
  "productName": "AI NAILS",
  "mac": {
    "category": "public.app-category.graphics-design",
    "icon": "assets/icon.icns",
    "target": ["dmg", "zip"],
    "hardenedRuntime": true
  },
  "dmg": {
    "title": "AI NAILS Installer",
    "icon": "assets/icon.icns",
    "contents": [
      {"x": 130, "y": 220},
      {"x": 410, "y": 220, "type": "link", "path": "/Applications"}
    ]
  },
  "directories": {
    "output": "'$RELEASE_DIR'"
  },
  "files": [
    "main.js",
    "preload.js",
    "../../preview/index.html",
    "../../preview/**/*",
    "assets/**/*"
  ]
}'

  cd "$SCRIPT_DIR"
  echo "✅ Electron 应用构建完成"
}

# 使用 hdiutil 手动创建 DMG（备用方案）
create_dmg_manual() {
  echo ""
  echo "📀 手动创建 DMG 安装包..."
  
  mkdir -p "$RELEASE_DIR/dmg_temp"
  
  # 如果 Electron 构建已产生 .app
  APP_PATH=""
  if [ -d "$RELEASE_DIR/mac-arm64/AI NAILS.app" ]; then
    APP_PATH="$RELEASE_DIR/mac-arm64/AI NAILS.app"
  elif [ -d "$RELEASE_DIR/mac/AI NAILS.app" ]; then
    APP_PATH="$RELEASE_DIR/mac/AI NAILS.app"
  elif [ -d "$RELEASE_DIR/AI NAILS.app" ]; then
    APP_PATH="$RELEASE_DIR/AI NAILS.app"
  fi

  if [ -z "$APP_PATH" ]; then
    echo "⚠️  未找到 .app bundle，跳过 DMG 创建"
    echo "   请先运行: npm run dist:mac (在 desktop/electron 目录)"
    return
  fi

  cp -R "$APP_PATH" "$RELEASE_DIR/dmg_temp/"
  ln -s /Applications "$RELEASE_DIR/dmg_temp/Applications" 2>/dev/null || true

  DMG_PATH="$RELEASE_DIR/${DMG_NAME}.dmg"
  rm -f "$DMG_PATH"

  hdiutil create -volname "$APP_NAME" -srcfolder "$RELEASE_DIR/dmg_temp" -ov -format UDZO "$DMG_PATH" 2>/dev/null

  rm -rf "$RELEASE_DIR/dmg_temp"

  if [ -f "$DMG_PATH" ]; then
    echo "✅ DMG 创建成功: $DMG_PATH"
    ls -lh "$DMG_PATH"
  else
    echo "⚠️  DMG 创建失败"
  fi
}

# 主流程
main() {
  check_deps
  install_deps
  generate_icon
  generate_dmg_bg

  echo ""
  echo "================================================================"
  echo "🚀 开始构建..."
  echo "================================================================"

  # 尝试使用 electron-builder
  if build_electron 2>&1; then
    echo ""
    echo "✅ Electron 打包成功！"
  else
    echo ""
    echo "⚠️  Electron 打包出现问题，尝试手动创建 DMG..."
    create_dmg_manual
  fi

  # 查找产物
  echo ""
  echo "📦 构建产物:"
  find "$RELEASE_DIR" -maxdepth 3 -name "*.dmg" -o -name "*.zip" 2>/dev/null | while read f; do
    echo "   📄 $(basename "$f") — $(ls -lh "$f" | awk '{print $5}')"
  done

  echo ""
  echo "================================================================"
  echo "✅ AI NAILS Desktop 打包完成！"
  echo "================================================================"
  echo ""
  echo "安装方式："
  echo "  1. 双击 DMG 文件挂载"
  echo "  2. 将 AI NAILS.app 拖入 Applications 文件夹"
  echo "  3. 首次打开如提示安全，前往 系统设置 → 隐私与安全性 → 仍要打开"
  echo ""
}

main "$@"
