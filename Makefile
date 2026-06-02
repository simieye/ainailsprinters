# AI NAILS APP - Makefile
# 跨平台构建、测试、发布自动化

.PHONY: help clean deps analyze test build-all build-android build-ios build-macos build-windows build-linux release

# 默认目标
help:
	@echo "AI NAILS APP - Build Commands"
	@echo "============================="
	@echo "make deps              - Install dependencies"
	@echo "make analyze           - Static code analysis"
	@echo "make test              - Run tests"
	@echo "make clean             - Clean build artifacts"
	@echo ""
	@echo "=== Desktop Builds ==="
	@echo "make build-macos       - Build macOS desktop app + DMG"
	@echo "make build-windows     - Build Windows desktop app"
	@echo "make build-linux       - Build Linux desktop app"
	@echo "make desktop-all       - Build all desktop platforms"
	@echo ""
	@echo "=== Mobile Builds ==="
	@echo "make build-android     - Build Android APK + AAB"
	@echo "make build-ios         - Build iOS (no code sign)"
	@echo ""
	@echo "=== Release ==="
	@echo "make release           - Build and prepare release artifacts"
	@echo "make dmg               - Create macOS DMG installer"
	@echo "make msix              - Create Windows MSIX package"
	@echo ""
	@echo "=== Development ==="
	@echo "make run-macos         - Run on macOS desktop"
	@echo "make run-windows       - Run on Windows desktop"
	@echo "make run-linux         - Run on Linux desktop"
	@echo "make lint              - Check code formatting"
	@echo "make format            - Format code"

# 安装依赖
deps:
	flutter pub get

# 静态分析
analyze:
	flutter analyze

# 代码格式化检查
lint:
	dart format --output=none --set-exit-if-changed lib/ test/

# 格式化代码
format:
	dart format lib/ test/

# 运行测试
test:
	flutter test --coverage

# 清理
clean:
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/
	rm -rf release/

# ===== 桌面端运行 =====

run-macos:
	flutter run -d macos

run-windows:
	flutter run -d windows

run-linux:
	flutter run -d linux

# ===== 桌面端构建 =====

build-macos:
	@echo "🔨 Building macOS desktop app..."
	flutter config --enable-macos-desktop
	cd macos && pod install || true
	cd ..
	flutter build macos --release
	@echo "✅ macOS build complete: build/macos/Build/Products/Release/"

build-windows:
	@echo "🔨 Building Windows desktop app..."
	flutter config --enable-windows-desktop
	flutter build windows --release
	@echo "✅ Windows build complete: build/windows/x64/runner/Release/"

build-linux:
	@echo "🔨 Building Linux desktop app..."
	flutter config --enable-linux-desktop
	flutter build linux --release
	@echo "✅ Linux build complete: build/linux/x64/release/"

# 构建所有桌面平台
desktop-all: build-macos build-windows build-linux
	@echo "✅ All desktop platforms built!"

# ===== 打包 =====

# 创建 macOS DMG
dmg:
	@echo "📦 Creating macOS DMG installer..."
	@mkdir -p dmg_contents
	@cp -R "build/macos/Build/Products/Release/AI NAILS.app" dmg_contents/
	@ln -s /Applications dmg_contents/Applications 2>/dev/null || true
	@hdiutil create -volname "AI NAILS" \
		-srcfolder dmg_contents \
		-ov -format UDZO \
		"release/AI_NAILS_macOS.dmg"
	@rm -rf dmg_contents
	@echo "✅ DMG created: release/AI_NAILS_macOS.dmg"

# 创建 Windows 便携版 ZIP
msix:
	@echo "📦 Creating Windows portable ZIP..."
	@mkdir -p release
	@cd build/windows/x64/runner/Release && \
		zip -r "../../../../../release/AI_NAILS_Windows_portable.zip" .
	@echo "✅ Windows ZIP created: release/AI_NAILS_Windows_portable.zip"

# ===== 移动端构建 =====

build-android:
	flutter build apk --release --split-per-abi
	flutter build appbundle --release
	@echo "✅ Android build complete: build/app/outputs/"

build-ios:
	cd ios && pod install || true
	flutter build ios --release --no-codesign
	@echo "✅ iOS build complete: build/ios/"

# 构建所有平台
build-all: build-android build-ios build-macos build-windows build-linux
	@echo "✅ All platform builds complete!"

# ===== 发布准备 =====

release: clean deps build-all
	@echo "📦 Creating release packages..."
	@mkdir -p release

	# Android
	@cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk release/ai_nails_android_armv7.apk 2>/dev/null || true
	@cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk release/ai_nails_android_arm64.apk 2>/dev/null || true
	@cp build/app/outputs/flutter-apk/app-x86_64-release.apk release/ai_nails_android_x86_64.apk 2>/dev/null || true
	@cp build/app/outputs/bundle/release/app-release.aab release/ai_nails_android.aab 2>/dev/null || true

	# macOS DMG
	@mkdir -p dmg_contents
	@cp -R "build/macos/Build/Products/Release/AI NAILS.app" dmg_contents/ 2>/dev/null || true
	@ln -s /Applications dmg_contents/Applications 2>/dev/null || true
	@hdiutil create -volname "AI NAILS" \
		-srcfolder dmg_contents \
		-ov -format UDZO \
		"release/AI_NAILS_macOS.dmg" 2>/dev/null || true
	@rm -rf dmg_contents

	# Windows
	@cd build/windows/x64/runner/Release && \
		zip -r "../../../../../release/AI_NAILS_Windows_portable.zip" . 2>/dev/null || true

	# Linux
	@cd build/linux/x64/release && \
		tar -czf "../../../../release/AI_NAILS_Linux.tar.gz" bundle/ 2>/dev/null || true

	@echo ""
	@echo "🎉 Release packages created in ./release/"
	@ls -la release/ 2>/dev/null || echo "No packages created"

# Docker 构建
docker-build:
	docker build -t ai-nails-builder .
	docker run --rm -v $(PWD):/app ai-nails-builder sh -c "flutter pub get && flutter analyze"

# 版本标签
tag:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make tag VERSION=3.1.0"; \
		exit 1; \
	fi
	git tag -a "v$(VERSION)" -m "Release v$(VERSION)"
	@echo "Tagged v$(VERSION). Run 'git push --tags' to push."
