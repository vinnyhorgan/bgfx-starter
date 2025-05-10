#include <stdio.h>

#include <bgfx/bgfx.h>
#include <bgfx/platform.h>
#include <bx/bx.h>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#if BX_PLATFORM_WINDOWS
#define GLFW_EXPOSE_NATIVE_WIN32
#elif BX_PLATFORM_LINUX
#define GLFW_EXPOSE_NATIVE_X11
#endif

#include <GLFW/glfw3native.h>

// dark title bar
#if BX_PLATFORM_WINDOWS
#include <dwmapi.h>

#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif
#endif

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

#if BX_PLATFORM_WINDOWS
  init.platformData.nwh = glfwGetWin32Window(window);
#elif BX_PLATFORM_LINUX
  init.platformData.ndt = glfwGetX11Display();
  init.platformData.nwh = (void*)glfwGetX11Window(window);
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

  bgfx::setViewClear(view, BGFX_CLEAR_COLOR, 0x303030ff);
  bgfx::setViewRect(view, 0, 0, width, height);

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
    bgfx::frame();
  }

  bgfx::shutdown();

  glfwDestroyWindow(window);
  glfwTerminate();

  return 0;
}
