# AI NAILS APP - Makefile
# 跨平台构建、测试、发布自动化

.PHONY: help clean deps analyze test build-all build-android build-ios build-macos build-windows release

# 默认目标
help:
	@echo "AI NAILS APP - Build Commands"
	@echo "============================="
	@echo "make deps           - Install dependencies"
	@echo "make analyze        - Static code analysis"
	@echo "make test           - Run tests"
	@echo "make clean          - Clean build artifacts"
	@echo "make build-android  - Build Android APK + AAB"
	@echo "make build-ios      - Build iOS (no code sign)"
	@echo "make build-macos    - Build macOS app"
	@echo "make build-windows  - Build Windows app"
	@echo "make build-all      - Build all platforms"
	@echo "make release        - Build and prepare release artifacts"
	@echo "make lint           - Check code formatting"

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

# ===== 平台构建 =====

build-android:
	flutter build apk --release --split-per-abi
	flutter build appbundle --release
	@echo "Android build complete: build/app/outputs/"

build-ios:
	cd ios && pod install || true
	flutter build ios --release --no-codesign
	@echo "iOS build complete: build/ios/"

build-macos:
	flutter build macos --release
	@echo "macOS build complete: build/macos/"

build-windows:
	flutter build windows --release
	@echo "Windows build complete: build/windows/"

# 构建所有平台
build-all: build-android build-ios build-macos build-windows
	@echo "All platform builds complete!"

# ===== 发布准备 =====

# 打包发布文件
release: clean deps build-all
	@echo "Creating release packages..."
	@mkdir -p release

	# Android
	@cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk release/ai_nails_android_armv7.apk 2>/dev/null || true
	@cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk release/ai_nails_android_arm64.apk 2>/dev/null || true
	@cp build/app/outputs/flutter-apk/app-x86_64-release.apk release/ai_nails_android_x86_64.apk 2>/dev/null || true
	@cp build/app/outputs/bundle/release/app-release.aab release/ai_nails_android.aab 2>/dev/null || true

	# macOS
	@cd build/macos/Build/Products/Release && zip -r ../../../../../release/ai_nails_macos.zip "AI NAILS.app" 2>/dev/null || true

	# Windows
	@cd build/windows/x64/runner/Release && zip -r ../../../../../release/ai_nails_windows.zip . 2>/dev/null || true

	@echo ""
	@echo "Release packages created in ./release/"
	@ls -la release/ 2>/dev/null || echo "No packages created"

# Docker 构建
docker-build:
	docker build -t ai-nails-builder .
	docker run --rm -v $(PWD):/app ai-nails-builder sh -c "flutter pub get && flutter analyze"

# 版本标签
tag:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make tag VERSION=3.0.1"; \
		exit 1; \
	fi
	git tag -a "v$(VERSION)" -m "Release v$(VERSION)"
	@echo "Tagged v$(VERSION). Run 'git push --tags' to push."
