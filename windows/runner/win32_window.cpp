#include "win32_window.h"

#include <dwmapi.h>
#include <shellscalingapi.h>

#include <flutter_windows.h>

#include <vector>
#include <iostream>

namespace {

// 窗口类名称
constexpr const wchar_t kWindowClassName[] = L"AI_NAILS_WINDOW";

// 窗口属性的偏移，存储 Win32Window 实例指针
constexpr const wchar_t kWindowPropertyName[] = L"AI_NAILS_WIN32_WINDOW";

// 缩放因子相关
constexpr const wchar_t kGetScaleFactorPropertyName[] =
    L"AI_NAILS_SCALE_FACTOR";

using EnableNonClientDpiScaling = BOOL __stdcall(HWND hwnd);

// 创建窗口并隐藏
HWND CreateWindowAndHide(const std::wstring& window_name, const POINT& origin,
                         const SIZE& size) {
  static bool window_class_registered = false;
  if (!window_class_registered) {
    WNDCLASS window_class{};
    window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
    window_class.lpszClassName = kWindowClassName;
    window_class.style = CS_HREDRAW | CS_VREDRAW;
    window_class.cbClsExtra = 0;
    window_class.cbWndExtra = 0;
    window_class.hInstance = GetModuleHandle(nullptr);
    window_class.hIcon = LoadIcon(window_class.hInstance, MAKEINTRESOURCE(IDI_APPLICATION));
    window_class.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    window_class.lpszMenuName = nullptr;
    window_class.lpfnWndProc = Win32Window::WndProc;
    RegisterClass(&window_class);
    window_class_registered = true;
  }

  HWND window = CreateWindow(
      kWindowClassName, window_name.c_str(),
      WS_OVERLAPPEDWINDOW | WS_VISIBLE,
      Scale(origin.x, GetDpiForWindow(window)),
      Scale(origin.y, GetDpiForWindow(window)),
      Scale(size.cx, GetDpiForWindow(window)),
      Scale(size.cy, GetDpiForWindow(window)),
      nullptr, nullptr, GetModuleHandle(nullptr), nullptr);

  if (!window) {
    return nullptr;
  }

  // 启用 DWM 窗口圆角（Windows 11）
  BOOL useDarkMode = TRUE;
  DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE,
                        &useDarkMode, sizeof(useDarkMode));

  // 设置窗口背景色（与主题一致）
  HBRUSH darkBrush = CreateSolidBrush(RGB(10, 10, 15));
  SetClassLongPtr(window, GCLP_HBRBACKGROUND, (LONG_PTR)darkBrush);

  return window;
}

// 获取当前 DPI
UINT GetCurrentDpi(HWND window) {
  return GetDpiForWindow(window);
}

// 缩放大小
int Scale(int value, UINT dpi) {
  if (dpi == 96) {
    return value;
  }
  return static_cast<int>((value * dpi) / 96.0f);
}

}  // namespace

Win32Window::Win32Window() {}

Win32Window::~Win32Window() { Destroy(); }

bool Win32Window::Create(const std::wstring& title, const Point& origin,
                         const Size& size) {
  // 防止重复创建
  if (window_handle_ != nullptr) {
    return false;
  }

  SIZE win_size = {static_cast<LONG>(size.width),
                    static_cast<LONG>(size.height)};
  POINT win_origin = {static_cast<LONG>(origin.x),
                       static_cast<LONG>(origin.y)};

  window_handle_ = CreateWindowAndHide(title, win_origin, win_size);

  if (window_handle_ == nullptr) {
    return false;
  }

  // 存储 Win32Window 实例指针
  SetProp(window_handle_, kWindowPropertyName, this);

  // 调用子类 OnCreate 回调
  if (!OnCreate()) {
    Destroy();
    return false;
  }

  window_created_ = true;
  return true;
}

bool Win32Window::CreateAndShow(const std::wstring& title, const Point& origin,
                                const Size& size) {
  if (!Create(title, origin, size)) {
    return false;
  }
  Show();
  return true;
}

void Win32Window::Destroy() {
  if (destroying_) {
    return;
  }
  destroying_ = true;

  OnDestroy();

  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  destroying_ = false;
}

void Win32Window::SetQuitOnClose(bool quit) { quit_on_close_ = quit; }

void Win32Window::SetTitle(const std::wstring& title) {
  SetWindowText(window_handle_, title.c_str());
}

void Win32Window::SetIcon(const std::wstring& icon_path) {
  // 尝试从文件加载图标
  HICON icon = (HICON)LoadImageW(
      NULL, icon_path.c_str(), IMAGE_ICON,
      GetSystemMetrics(SM_CXICON), GetSystemMetrics(SM_CYICON),
      LR_LOADFROMFILE | LR_DEFAULTSIZE);

  if (icon) {
    SendMessage(window_handle_, WM_SETICON, ICON_BIG, (LPARAM)icon);
    SendMessage(window_handle_, WM_SETICON, ICON_SMALL, (LPARAM)icon);
  }
}

void Win32Window::Show() {
  ShowWindow(window_handle_, SW_SHOWNORMAL);
  UpdateWindow(window_handle_);
  SetForegroundWindow(window_handle_);
}

void Win32Window::Hide() { ShowWindow(window_handle_, SW_HIDE); }

bool Win32Window::IsVisible() { return IsWindowVisible(window_handle_); }

HWND Win32Window::GetHandle() { return window_handle_; }

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);

  // 调整子窗口大小以填充客户区
  RECT area;
  GetClientRect(window_handle_, &area);
  SetWindowPos(content, nullptr, area.left, area.top,
               area.right - area.left, area.bottom - area.top,
               SWP_NOZORDER);

  ShowWindow(content, SW_SHOW);
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

RECT Win32Window::GetWindowArea() {
  RECT frame;
  GetWindowRect(window_handle_, &frame);
  return frame;
}

void Win32Window::SetMinSize(unsigned int width, unsigned int height) {
  min_width_ = width;
  min_height_ = height;
}

void Win32Window::CenterToDisplay() {
  RECT window_rect;
  GetWindowRect(window_handle_, &window_rect);

  int window_width = window_rect.right - window_rect.left;
  int window_height = window_rect.bottom - window_rect.top;

  int screen_width = GetSystemMetrics(SM_CXSCREEN);
  int screen_height = GetSystemMetrics(SM_CYSCREEN);

  int x = (screen_width - window_width) / 2;
  int y = (screen_height - window_height) / 2;

  SetWindowPos(window_handle_, nullptr, x, y, 0, 0,
               SWP_NOSIZE | SWP_NOZORDER);
}

float Win32Window::GetDpiScale() {
  UINT dpi = GetDpiForWindow(window_handle_);
  return dpi / 96.0f;
}

float Win32Window::GetScaleFactor() { return GetDpiScale(); }

bool Win32Window::OnCreate() { return true; }

void Win32Window::OnDestroy() { 
  RemoveProp(window_handle_, kWindowPropertyName);
}

LRESULT Win32Window::MessageHandler(HWND window, UINT const message,
                                    WPARAM const wparam,
                                    LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      window_handle_ = nullptr;
      Destroy();
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;

    case WM_SIZE: {
      // 调整子窗口大小
      if (child_content_ != nullptr) {
        int width = LOWORD(lparam);
        int height = HIWORD(lparam);
        SetWindowPos(child_content_, nullptr, 0, 0, width, height, SWP_NOZORDER);
      }
      return 0;
    }

    case WM_CLOSE:
      Destroy();
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;

    case WM_DPICHANGED: {
      // DPI 变更时调整窗口大小
      RECT* rect = reinterpret_cast<RECT*>(lparam);
      SetWindowPos(window, nullptr, rect->left, rect->top,
                   rect->right - rect->left, rect->bottom - rect->top,
                   SWP_NOZORDER | SWP_NOACTIVATE);
      return 0;
    }
  }

  return DefWindowProc(window, message, wparam, lparam);
}

LRESULT CALLBACK Win32Window::WndProc(HWND const window, UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto cs = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(cs->lpCreateParams));
  }

  auto that = static_cast<Win32Window*>(
      GetProp(window, kWindowPropertyName));

  if (that) {
    return that->MessageHandler(window, message, wparam, lparam);
  }

  return DefWindowProc(window, message, wparam, lparam);
}

Win32Window* Win32Window::GetThisFromHandle(HWND const window) noexcept {
  return static_cast<Win32Window*>(GetProp(window, kWindowPropertyName));
}
