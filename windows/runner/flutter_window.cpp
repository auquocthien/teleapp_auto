#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

std::string ConvertToUTF8(const std::wstring &wstr)
{
  if (wstr.empty())
    return std::string();

  int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
  std::string strTo(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
  return strTo;
}
static std::vector<std::string> GetOpenWindows()
{
  std::vector<std::string> windowList;
  EnumWindows([](HWND hwnd, LPARAM lParam) -> BOOL
              {
                wchar_t windowTitle[256];
                GetWindowTextW(hwnd, windowTitle, sizeof(windowTitle) / sizeof(wchar_t));
                if (IsWindowVisible(hwnd) && wcslen(windowTitle) > 0)
                {
                  std::wstring titleW(windowTitle);
                  std::string title = ConvertToUTF8(titleW); // Chuyển đổi sang UTF-8

                  auto *titles = reinterpret_cast<std::vector<std::string> *>(lParam);
                  std::string windowInfo = title + " - " + std::to_string(reinterpret_cast<intptr_t>(hwnd));
                  titles->push_back(windowInfo);
                }
                return TRUE; // Tiếp tục duyệt các cửa sổ
              },
              reinterpret_cast<LPARAM>(&windowList));
  return windowList;
}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view())
  {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(),
      "com.example.window_control",
      &flutter::StandardMethodCodec::GetInstance());

  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue> &call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
      {
        if (call.method_name().compare("getOpenWindows") == 0)
        {
          std::vector<std::string> windows = GetOpenWindows();
          std::vector<flutter::EncodableValue> flutter_windows;
          for (const auto &window : windows)
          {
            flutter_windows.emplace_back(window);
            // std::cout << window << std::endl;
          }
          result->Success(flutter::EncodableValue(flutter_windows));
        }
        else
        {
          result->NotImplemented();
        }
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]()
                                                      { this->Show(); });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy()
{
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept
{
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result)
    {
      return *result;
    }
  }

  switch (message)
  {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
