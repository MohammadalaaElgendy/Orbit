#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <shellapi.h>
#include <string>
#include <vector>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {

  // تحقق مما إذا كانت هناك نسخة من التطبيق تعمل بالفعل
  HWND hwnd = FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Orbit");
  if (hwnd) {
    // التطبيق مفتوح، أرسل له الرابط الجديد
    int argc;
    wchar_t** argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (argv && argc > 1) {
      std::wstring link = argv[1];
      COPYDATASTRUCT cds;
      cds.dwData = 0;
      cds.cbData = (DWORD)((link.length() + 1) * sizeof(wchar_t));
      cds.lpData = (PVOID)link.c_str();
      SendMessage(hwnd, WM_COPYDATA, (WPARAM)hwnd, (LPARAM)&cds);
      LocalFree(argv);
    }
    // إحضار النافذة الحالية للمقدمة
    SetForegroundWindow(hwnd);
    if (IsIconic(hwnd)) ShowWindow(hwnd, SW_RESTORE);
    return EXIT_SUCCESS;
  }

  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  std::vector<std::string> command_line_arguments = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Orbit", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
