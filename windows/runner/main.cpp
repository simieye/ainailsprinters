#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <memory>
#include <string>
#include <vector>
#include <iostream>

#include "flutter_window.h"

// 控制台输出（调试模式）
#ifdef _DEBUG
#pragma comment(linker, "/subsystem:console")
#endif

// 程序入口点
int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // 附加到父进程控制台（如果有）
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // 初始化 COM 库（用于拖放、剪贴板等功能）
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // 创建 Flutter 项目
  flutter::DartProject project(L"data");

  // 设置命令行参数
  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  // 窗口配置
  FlutterWindow window(project);
  
  // 设置窗口属性
  Win32Window::Point origin(100, 100);
  Win32Window::Size size(1280, 800);
  
  // 根据 DPI 缩放调整大小
  if (!window.Create(L"AI NAILS", origin, size)) {
    return EXIT_FAILURE;
  }

  // 设置最小窗口大小
  window.SetMinSize(900, 600);

  // 居中窗口
  window.CenterToDisplay();

  // 设置窗口图标
  window.SetIcon(L"resources/app_icon.ico");

  // 运行消息循环
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

