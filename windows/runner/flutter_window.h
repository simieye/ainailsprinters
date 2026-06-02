#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"

// 实现 Flutter 内容的窗口
class FlutterWindow : public Win32Window {
 public:
  // 使用项目创建新窗口
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

  // 防止复制
  FlutterWindow(const FlutterWindow&) = delete;
  FlutterWindow& operator=(const FlutterWindow&) = delete;

 protected:
  // Win32Window 回调
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message,
                         WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // 此窗口的 Flutter 控制器实例
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
