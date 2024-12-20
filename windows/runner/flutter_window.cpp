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
#include <gdiplus.h>
#pragma comment(lib, "Gdiplus.lib")

#include <thread>

#include <sstream>
#include <string>

#define LOG_ERROR(msg) std::cerr << "[ERROR] in " << __FUNCTION__ << " at line " << __LINE__ << ": " << msg << std::endl;
#define LOG_INFO(msg) std::clog << "[INFO] " << msg << std::endl;

ULONG_PTR gdiplusToken;
bool gdiInitialized = false;

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

void InitializeGDIPlus()
{
  if (!gdiInitialized)
  {
    Gdiplus::GdiplusStartupInput gdiplusStartupInput;
    Gdiplus::Status status = Gdiplus::GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);
    if (status == Gdiplus::Ok)
    {
      gdiInitialized = true;
      LOG_INFO("GDI+ initialized successfully.");
    }
    else
    {
      LOG_ERROR("GDI+ initialization failed.");
    }
  }
}

void ShutdownGDIPlus()
{
  if (gdiInitialized)
  {
    Gdiplus::GdiplusShutdown(gdiplusToken);
    gdiInitialized = false;
    LOG_INFO("GDI+ shutdown successfully.");
  }
}

std::string ConvertToUTF8(const std::wstring &wstr)
{
  if (wstr.empty())
    return std::string();
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
  std::string strTo(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
  return strTo;
}

std::wstring ConvertToWString(const std::string &str)
{
  int len;
  int strLength = (int)str.length() + 1;
  len = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), strLength, 0, 0);
  std::wstring wstr(len, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, str.c_str(), strLength, &wstr[0], len);
  return wstr;
}

static std::vector<std::string> GetOpenWindows()
{
  std::vector<std::string> windowList;

  // Hàm EnumWindows để liệt kê các cửa sổ mở
  EnumWindows([](HWND hwnd, LPARAM lParam) -> BOOL
              {
                auto &windowList = *reinterpret_cast<std::vector<std::string> *>(lParam);

                wchar_t windowTitle[256];
                GetWindowTextW(hwnd, windowTitle, sizeof(windowTitle) / sizeof(wchar_t));

                if (IsWindowVisible(hwnd) && wcslen(windowTitle) > 0)
                {
                  std::wstring titleW(windowTitle);
                  std::string title = ConvertToUTF8(titleW);

                  // Thêm cửa sổ vào danh sách với định dạng "title - hwnd"
                  windowList.push_back(title + " - " + std::to_string(reinterpret_cast<intptr_t>(hwnd)));
                }
                return TRUE; // Tiếp tục liệt kê
              },
              reinterpret_cast<LPARAM>(&windowList)); // Truyền địa chỉ của windowList

  return windowList;
}

int GetEncoderClsid(const WCHAR *format, CLSID *pClsid)
{
  try
  {
    UINT num = 0;
    UINT size = 0;
    Gdiplus::ImageCodecInfo *pImageCodecInfo = NULL;

    Gdiplus::GetImageEncodersSize(&num, &size);
    if (size == 0)
      return -1;

    pImageCodecInfo = (Gdiplus::ImageCodecInfo *)(malloc(size));
    if (!pImageCodecInfo)
    {
      LOG_ERROR("Failed to allocate memory for image codecs");
      return -1;
    }

    Gdiplus::GetImageEncoders(num, size, pImageCodecInfo);
    for (UINT j = 0; j < num; ++j)
    {
      if (wcscmp(pImageCodecInfo[j].MimeType, format) == 0)
      {
        *pClsid = pImageCodecInfo[j].Clsid;
        free(pImageCodecInfo);
        return j;
      }
    }
    free(pImageCodecInfo);
    LOG_ERROR("Could not find image encoder for format");
    return -1;
  }
  catch (const std::exception &e)
  {
    LOG_ERROR(e.what());
  }
  catch (...)
  {
    LOG_ERROR("Unknown error in GetEncoderClsid");
  }
  return -1;
}

void SaveBitmapToFile(HBITMAP hBitmap, const std::string &filePath, const std::string &format)
{
  try
  {
    if (!gdiInitialized)
    {
      LOG_ERROR("GDI+ not initialized.");
      return;
    }

    Gdiplus::Bitmap bitmap(hBitmap, NULL);
    CLSID clsid;

    if (format == "png")
    {
      if (GetEncoderClsid(L"image/png", &clsid) == -1)
      {
        LOG_ERROR("PNG encoder not found.");
        return;
      }
    }
    else if (format == "jpeg")
    {
      if (GetEncoderClsid(L"image/jpeg", &clsid) == -1)
      {
        LOG_ERROR("JPEG encoder not found.");
        return;
      }
    }
    else
    {
      if (GetEncoderClsid(L"image/bmp", &clsid) == -1)
      {
        LOG_ERROR("BMP encoder not found.");
        return;
      }
    }

    std::string fullPath = "D:/hoctap/auto_tele/images/" + filePath;
    std::wstring wFullPath = ConvertToWString(fullPath);
    Gdiplus::Status status = bitmap.Save(wFullPath.c_str(), &clsid, NULL);

    if (status != Gdiplus::Ok)
    {
      LOG_ERROR("Failed to save bitmap to file.");
    }
    else
    {
      LOG_INFO("Bitmap saved successfully to " + fullPath);
    }
  }
  catch (const std::exception &e)
  {
    LOG_ERROR(e.what());
  }
  catch (...)
  {
    LOG_ERROR("Unknown error in SaveBitmapToFile.");
  }
}

BOOL CaptureWindowContent(HWND hwnd, HBITMAP &hBitmap)
{
  try
  {
    if (!IsWindow(hwnd))
    {
      LOG_ERROR("Invalid window handle");
      return false;
    }

    RECT rect;
    GetWindowRect(hwnd, &rect);

    int width = rect.right - rect.left;
    int height = rect.bottom - rect.top;

    HDC hdcWindow = GetWindowDC(hwnd);
    if (!hdcWindow)
    {
      LOG_ERROR("Failed to get window DC");
      return false;
    }

    HDC hdcMemDC = CreateCompatibleDC(hdcWindow);
    if (!hdcMemDC)
    {
      LOG_ERROR("Failed to create compatible DC");
      ReleaseDC(hwnd, hdcWindow);
      return false;
    }

    hBitmap = CreateCompatibleBitmap(hdcWindow, width, height);
    if (!hBitmap)
    {
      LOG_ERROR("Failed to create compatible bitmap");
      DeleteDC(hdcMemDC);
      ReleaseDC(hwnd, hdcWindow);
      return false;
    }

    SelectObject(hdcMemDC, hBitmap);
    BOOL result = PrintWindow(hwnd, hdcMemDC, PW_RENDERFULLCONTENT);

    SelectObject(hdcMemDC, hBitmap);
    DeleteDC(hdcMemDC);
    ReleaseDC(hwnd, hdcWindow);

    return result != 0;
  }
  catch (const std::exception &e)
  {
    LOG_ERROR(e.what());
  }
  catch (...)
  {
    LOG_ERROR("Unknown error in CaptureWindowContent");
  }
  return FALSE;
}

void CaptureWindowScreenshot(HWND hwnd, const std::string &format = "bmp")
{
  try
  {
    HBITMAP hBitmap;
    if (!CaptureWindowContent(hwnd, hBitmap))
    {
      LOG_ERROR("Unable to capture window content");
      return;
    }

    std::ostringstream filePathStream;
    filePathStream << reinterpret_cast<intptr_t>(hwnd) << "." << format;
    std::string filePath = filePathStream.str();
    SaveBitmapToFile(hBitmap, filePath, format);
    DeleteObject(hBitmap);
  }
  catch (const std::exception &e)
  {
    LOG_ERROR(e.what());
  }
  catch (...)
  {
    LOG_ERROR("Unknown error in CaptureWindowScreenshot");
  }
}

// mouse event
RECT GetWindowRectByHandle(HWND hwnd)
{
  RECT rect;
  if (GetWindowRect(hwnd, &rect))
  {
    return rect;
  }
  return RECT{0, 0, 0, 0};
}

void PerformMouseClick(int x, int y, HWND hwnd)
{
  // Lấy tọa độ và kích thước của cửa sổ
  RECT windowRect = GetWindowRectByHandle(hwnd);

  // Tính toán tọa độ màn hình từ tọa độ cửa sổ
  int screenX = windowRect.left + x;
  int screenY = windowRect.top + y;

  // Giả lập click chuột tại toạ độ màn hình
  mouse_event(MOUSEEVENTF_LEFTDOWN, screenX, screenY, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, screenX, screenY, 0, 0);
}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  InitializeGDIPlus();

  RECT frame = GetClientArea();
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);

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
          }
          result->Success(flutter::EncodableValue(flutter_windows));
        }
        else if (call.method_name().compare("captureScreenshot") == 0)
        {
          const int *windowHandle = std::get_if<int>(call.arguments());
          const std::string format = "png"; // Hoặc "jpeg" nếu bạn muốn
          if (windowHandle)
          {
            HWND hwnd = reinterpret_cast<HWND>(static_cast<intptr_t>(*windowHandle));

            std::thread([result = std::move(result), hwnd, format]() mutable
                        {
            try 
            {
              if (hwnd == NULL)
              {
                result->Error("InvalidHandle", "Handle is not valid");
              }
                CaptureWindowScreenshot(hwnd, format);
                result->Success(flutter::EncodableValue("Success"));
            } 
            catch (const std::exception& e) {
                // Xử lý lỗi ngoại lệ tiêu chuẩn
                result->Error("Exception", e.what());
            } 
            catch (...) {
                // Xử lý các lỗi không xác định
                result->Error("UnknownError", "An unknown error occurred.");
            } })
                .detach();
          }
          else
          {
            result->Error("InvalidArgument", "Expected an integer argument");
          }
        }
        else if (call.method_name().compare("performClick") == 0)
        {
          auto arguments = call.arguments();
          if (arguments && arguments->IsMap())
          {
            auto map = std::get<flutter::EncodableMap>(*arguments);

            auto x_it = map.find(flutter::EncodableValue("x"));
            auto y_it = map.find(flutter::EncodableValue("y"));
            auto hwnd_it = map.find(flutter::EncodableValue("hwnd"));

            if (x_it != map.end() && y_it != map.end() && hwnd_it != map.end())
            {
              auto x_value = std::get_if<int>(&(x_it->second));
              auto y_value = std::get_if<int>(&(y_it->second));
              auto hwnd_value = std::get_if<int>(&(hwnd_it->second));
              if (x_value && y_value && hwnd_value)
              {
                int x = *x_value;
                int y = *y_value;
                HWND hwnd = reinterpret_cast<HWND>(static_cast<intptr_t>(*hwnd_value));

                PerformMouseClick(x, y, hwnd);
                result->Success();
              }
            }
          }
          else
          {
            std::cerr << "Key 'x' or 'y' not found in arguments." << std::endl;
          }
        }
        else
        {
          result->NotImplemented();
        }

        else
        {
          result->NotImplemented();
        }
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]()
                                                      { this->Show(); });
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy()
{
  ShutdownGDIPlus();
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }
  Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message, WPARAM const wparam, LPARAM const lparam) noexcept
{
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam, lparam);
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
