#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// Win32 窗口的封装，包含窗口管理、DPI 处理和消息循环
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int const x, unsigned int const y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int const width, unsigned int const height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  // 创建并显示窗口
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  // 创建并显示窗口（带父窗口）
  bool CreateAndShow(const std::wstring& title, const Point& origin,
                     const Size& size);

  // 销毁窗口
  void Destroy();

  // 设置窗口是否在关闭时退出应用
  void SetQuitOnClose(bool quit);

  // 设置窗口标题
  void SetTitle(const std::wstring& title);

  // 设置窗口图标
  void SetIcon(const std::wstring& icon_path);

  // 显示窗口
  void Show();

  // 隐藏窗口
  void Hide();

  // 窗口是否可见
  bool IsVisible();

  // 获取窗口句柄
  HWND GetHandle();

  // 设置窗口内容
  void SetChildContent(HWND content);

  // 获取客户区大小
  RECT GetClientArea();

  // 获取窗口大小
  RECT GetWindowArea();

  // 设置最小窗口大小
  void SetMinSize(unsigned int width, unsigned int height);

  // 居中显示
  void CenterToDisplay();

  // 获取当前 DPI
  float GetDpiScale();

  // 获取屏幕缩放因子
  virtual float GetScaleFactor();

 protected:
  // 子类重写此方法来响应窗口创建
  virtual bool OnCreate();

  // 子类重写此方法来响应窗口销毁
  virtual void OnDestroy();

  // 子类重写此方法来处理窗口消息
  virtual LRESULT MessageHandler(HWND window, UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

 private:
  // 窗口过程
  static LRESULT CALLBACK WndProc(HWND const window, UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  // 获取当前窗口的 Win32Window 实例
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  // 窗口句柄
  HWND window_handle_ = nullptr;

  // 窗口内容句柄
  HWND child_content_ = nullptr;

  // 窗口类名
  std::wstring window_class_name_;

  // 最小窗口大小
  unsigned int min_width_ = 0;
  unsigned int min_height_ = 0;

  // 是否在关闭时退出应用
  bool quit_on_close_ = false;

  // 窗口是否已创建
  bool window_created_ = false;

  // 窗口是否正在销毁
  bool destroying_ = false;
};

#endif  // RUNNER_WIN32_WINDOW_H_
