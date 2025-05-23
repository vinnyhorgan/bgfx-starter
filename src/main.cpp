#include <stdio.h>

#include <bgfx/bgfx.h>
#include <bgfx/platform.h>
#include <bx/bx.h>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#if BX_PLATFORM_WINDOWS
#define GLFW_EXPOSE_NATIVE_WIN32
#elif BX_PLATFORM_LINUX

#ifdef _GLFW_X11
#define GLFW_EXPOSE_NATIVE_X11
#endif

#ifdef _GLFW_WAYLAND
#define GLFW_EXPOSE_NATIVE_WAYLAND
#endif

#endif

#include <GLFW/glfw3native.h>

// dark title bar
#if BX_PLATFORM_WINDOWS
#include <dwmapi.h>

#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif
#endif

#include "logo.h"

static void error_cb(int error, const char* description) {
  fprintf(stderr, "glfw error %d: %s\n", error, description);
}

int main(int argc, char** argv) {
  glfwSetErrorCallback(error_cb);

  glfwInitHint(GLFW_WIN32_MESSAGES_IN_FIBER, GLFW_TRUE);

  if (!glfwInit()) {
    return 1;
  }

  glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
  glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);

  GLFWwindow* window = glfwCreateWindow(640, 480, "hello bgfx", NULL, NULL);
  if (!window) {
    glfwTerminate();
    return 1;
  }

#if BX_PLATFORM_WINDOWS
  HWND hwnd = glfwGetWin32Window(window);
  BOOL dark = TRUE;
  DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark, sizeof(dark));
#endif

  bgfx::renderFrame();

  bgfx::Init init;
  init.type = bgfx::RendererType::Count;
  init.vendorId = BGFX_PCI_ID_NONE;

#if BX_PLATFORM_WINDOWS
  init.platformData.nwh = glfwGetWin32Window(window);
#elif BX_PLATFORM_LINUX

#ifdef _GLFW_X11
  init.platformData.nwh = (void*)uintptr_t(glfwGetX11Window(window));
  init.platformData.ndt = glfwGetX11Display();
#endif

#ifdef _GLFW_WAYLAND
  init.platformData.nwh = glfwGetWaylandWindow(window);
  init.platformData.ndt = glfwGetWaylandDisplay();
  init.platformData.type = bgfx::NativeWindowHandleType::Wayland;
#endif

#endif

  int width, height;
  glfwGetFramebufferSize(window, &width, &height);

  init.resolution.width = width;
  init.resolution.height = height;
  init.resolution.reset = BGFX_RESET_VSYNC;

  if (!bgfx::init(init)) {
    glfwDestroyWindow(window);
    glfwTerminate();
    return 1;
  }

  const bgfx::ViewId view = 0;

  bgfx::setViewClear(view, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0x303030ff);
  bgfx::setViewRect(view, 0, 0, width, height);

  bgfx::setDebug(BGFX_DEBUG_TEXT);

  printf("renderer: %s\n", bgfx::getRendererName(bgfx::getRendererType()));

  glfwShowWindow(window);

  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();

    int old_width = width;
    int old_height = height;
    glfwGetFramebufferSize(window, &width, &height);

    if (width != old_width || height != old_height) {
      bgfx::reset(width, height, BGFX_RESET_VSYNC);
      bgfx::setViewRect(view, 0, 0, width, height);
    }

    bgfx::touch(view);

    bgfx::dbgTextClear();

    const bgfx::Stats* stats = bgfx::getStats();

    bgfx::dbgTextImage(bx::max<uint16_t>(uint16_t(stats->textWidth / 2), 20) - 20,
                       bx::max<uint16_t>(uint16_t(stats->textHeight / 2), 6) - 6, 40, 12, s_logo, 160);
    bgfx::dbgTextPrintf(
        0, 1, 0x0f,
        "Color can be changed with ANSI \x1b[9;me\x1b[10;ms\x1b[11;mc\x1b[12;ma\x1b[13;mp\x1b[14;me\x1b[0m code too.");

    bgfx::dbgTextPrintf(80, 1, 0x0f,
                        "\x1b[;0m    \x1b[;1m    \x1b[; 2m    \x1b[; 3m    \x1b[; 4m    \x1b[; 5m    \x1b[; 6m    "
                        "\x1b[; 7m    \x1b[0m");
    bgfx::dbgTextPrintf(80, 2, 0x0f,
                        "\x1b[;8m    \x1b[;9m    \x1b[;10m    \x1b[;11m    \x1b[;12m    \x1b[;13m    \x1b[;14m    "
                        "\x1b[;15m    \x1b[0m");

    bgfx::dbgTextPrintf(0, 2, 0x0f, "Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters.", stats->width,
                        stats->height, stats->textWidth, stats->textHeight);

    bgfx::frame();
  }

  bgfx::shutdown();

  glfwDestroyWindow(window);
  glfwTerminate();

  return 0;
}
