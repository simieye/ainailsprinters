#include "flutter_window.h"

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <optional>
#include <string>

#include <windows.h>
#include <shellapi.h>
#include <shlobj.h>
#include <commdlg.h>

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // Flutter 项目创建，大小匹配窗口
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);

  // 确保基本设置已初始化
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }

  // ===== 注册 Method Channels =====
  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "com.ainails.app/desktop",
      &flutter::StandardMethodCodec::GetInstance());

  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        // 处理桌面特有功能
        if (call.method_name() == "getPlatform") {
          result->Success(flutter::EncodableValue("windows"));
        } else if (call.method_name() == "getAppDataPath") {
          wchar_t path[MAX_PATH];
          if (SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_APPDATA, NULL, 0, path))) {
            std::wstring ws(path);
            std::string spath(ws.begin(), ws.end());
            result->Success(flutter::EncodableValue(spath + "\\AI_NAILS\\"));
          } else {
            result->Error("PATH_ERROR", "Failed to get app data path");
          }
        } else if (call.method_name() == "openFileDialog") {
          // 文件选择对话框
          OPENFILENAMEW ofn = {0};
          wchar_t szFile[260] = {0};
          ofn.lStructSize = sizeof(ofn);
          ofn.hwndOwner = ::GetActiveWindow();
          ofn.lpstrFile = szFile;
          ofn.nMaxFile = sizeof(szFile) / sizeof(wchar_t);
          ofn.lpstrFilter = L"Images\0*.png;*.jpg;*.jpeg;*.bmp;*.webp\0All Files\0*.*\0";
          ofn.nFilterIndex = 1;
          ofn.lpstrFileTitle = NULL;
          ofn.nMaxFileTitle = 0;
          ofn.lpstrInitialDir = NULL;
          ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

          if (GetOpenFileNameW(&ofn)) {
            std::wstring ws(szFile);
            std::string filePath(ws.begin(), ws.end());
            result->Success(flutter::EncodableValue(filePath));
          } else {
            result->Success(flutter::EncodableValue());
          }
        } else if (call.method_name() == "saveFileDialog") {
          // 文件保存对话框
          OPENFILENAMEW ofn = {0};
          wchar_t szFile[260] = L"nail_design.png";
          ofn.lStructSize = sizeof(ofn);
          ofn.hwndOwner = ::GetActiveWindow();
          ofn.lpstrFile = szFile;
          ofn.nMaxFile = sizeof(szFile) / sizeof(wchar_t);
          ofn.lpstrFilter = L"PNG Image\0*.png\0JPEG Image\0*.jpg\0All Files\0*.*\0";
          ofn.nFilterIndex = 1;
          ofn.lpstrDefExt = L"png";
          ofn.Flags = OFN_OVERWRITEPROMPT;

          if (GetSaveFileNameW(&ofn)) {
            std::wstring ws(szFile);
            std::string filePath(ws.begin(), ws.end());
            result->Success(flutter::EncodableValue(filePath));
          } else {
            result->Success(flutter::EncodableValue());
          }
        } else if (call.method_name() == "pickDirectory") {
          // 文件夹选择对话框
          BROWSEINFOW bi = {0};
          bi.lpszTitle = L"Select a folder";
          bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE;
          
          LPITEMIDLIST pidl = SHBrowseForFolderW(&bi);
          if (pidl != nullptr) {
            wchar_t path[MAX_PATH];
            if (SHGetPathFromIDListW(pidl, path)) {
              std::wstring ws(path);
              std::string folderPath(ws.begin(), ws.end());
              CoTaskMemFree(pidl);
              result->Success(flutter::EncodableValue(folderPath));
            } else {
              CoTaskMemFree(pidl);
              result->Success(flutter::EncodableValue());
            }
          } else {
            result->Success(flutter::EncodableValue());
          }
        } else if (call.method_name() == "minimizeWindow") {
          ::ShowWindow(::GetActiveWindow(), SW_MINIMIZE);
          result->Success();
        } else if (call.method_name() == "maximizeWindow") {
          ::ShowWindow(::GetActiveWindow(), SW_MAXIMIZE);
          result->Success();
        } else if (call.method_name() == "restoreWindow") {
          ::ShowWindow(::GetActiveWindow(), SW_RESTORE);
          result->Success();
        } else if (call.method_name() == "closeWindow") {
          ::PostMessage(::GetActiveWindow(), WM_CLOSE, 0, 0);
          result->Success();
        } else if (call.method_name() == "setAlwaysOnTop") {
          if (const auto* args = std::get_if<flutter::EncodableMap>(call.arguments())) {
            auto it = args->find(flutter::EncodableValue("enable"));
            if (it != args->end()) {
              bool enable = std::get<bool>(it->second);
              HWND hwnd = ::GetActiveWindow();
              if (enable) {
                ::SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, 
                              SWP_NOMOVE | SWP_NOSIZE);
              } else {
                ::SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0,
                              SWP_NOMOVE | SWP_NOSIZE);
              }
            }
          }
          result->Success();
        } else {
          result->NotImplemented();
        }
      });

  // 注册拖放支持
  ::DragAcceptFiles(GetHandle(), TRUE);

  // 注册插件
  RegisterPlugins(flutter_controller_->engine());

  // 设置窗口内容
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // 确保 Flutter 第一帧可见
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // 让 Flutter 处理消息
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_DROPFILES: {
      // 处理拖放文件
      HDROP hDrop = (HDROP)wparam;
      UINT fileCount = ::DragQueryFileW(hDrop, 0xFFFFFFFF, NULL, 0);
      
      flutter::MethodChannel<> dropChannel(
          flutter_controller_->engine()->messenger(),
          "com.ainails.app/drop",
          &flutter::StandardMethodCodec::GetInstance());

      flutter::EncodableList files;
      for (UINT i = 0; i < fileCount; i++) {
        wchar_t filePath[MAX_PATH];
        if (::DragQueryFileW(hDrop, i, filePath, MAX_PATH) > 0) {
          std::wstring ws(filePath);
          std::string path(ws.begin(), ws.end());
          files.push_back(flutter::EncodableValue(path));
        }
      }
      
      ::DragFinish(hDrop);
      dropChannel.InvokeMethod("onFilesDropped",
                               std::make_unique<flutter::EncodableValue>(files));
      return 0;
    }

    case WM_FONTCHANGE:
      // 字体变更通知 Flutter
      if (flutter_controller_) {
        flutter_controller_->engine()->ReloadSystemFonts();
      }
      break;

    case WM_DPICHANGED: {
      // DPI 变更处理
      if (flutter_controller_) {
        flutter_controller_->engine()->UpdateWindowMetrics();
      }
      break;
    }

    case WM_GETMINMAXINFO: {
      // 最小窗口大小限制
      MINMAXINFO* mmi = reinterpret_cast<MINMAXINFO*>(lparam);
      mmi->ptMinTrackSize.x = 900;
      mmi->ptMinTrackSize.y = 600;
      return 0;
    }
  }

  // 默认处理
  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
