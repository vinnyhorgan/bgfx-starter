include "scripts/premake-export-compile-commands.lua"

workspace "bgfx-starter"
  configurations { "debug", "release" }
  architecture "x64"
  location "build"

newoption {
  trigger = "use-wayland",
  description = "use wayland instead of x11",
}

project "bgfx-starter"
  kind "ConsoleApp"
  language "C++"
  cppdialect "C++17"
  staticruntime "on"
  exceptionhandling "off"
  rtti "off"

  targetdir "%{wks.location}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/obj/%{cfg.buildcfg}"

  files {
    "src/**.h",
    "src/**.cpp",

    -- bx
    "vendor/bx/include/bx/*.h",
    "vendor/bx/include/bx/inline/*.inl",
    "vendor/bx/src/*.cpp",

    -- bimg
    "vendor/bimg/include/bimg/*.h",
    "vendor/bimg/src/image.cpp",
    "vendor/bimg/src/image_gnf.cpp",
    "vendor/bimg/3rdparty/astc-encoder/source/*.cpp",

    -- bgfx
    "vendor/bgfx/include/bgfx/**.h",
    "vendor/bgfx/src/*.h",
    "vendor/bgfx/src/*.cpp",
    "vendor/bgfx/src/*.mm",

    -- glfw
    "vendor/glfw/include/GLFW/*.h",
    "vendor/glfw/src/*.h",
    "vendor/glfw/src/*.c",
    "vendor/glfw/src/*.m",
  }

  excludes {
    -- bx
    "vendor/bx/src/amalgamated.cpp",

    -- bgfx
    "vendor/bgfx/src/amalgamated.cpp",
    "vendor/bgfx/src/amalgamated.mm",
  }

  includedirs {
    -- bx
    "vendor/bx/include",
    "vendor/bx/3rdparty",

    -- bimg
    "vendor/bimg/include",
    "vendor/bimg/3rdparty/astc-encoder/include",

    -- bgfx
    "vendor/bgfx/include",
    "vendor/bgfx/3rdparty",
    "vendor/bgfx/3rdparty/khronos",
    "vendor/bgfx/3rdparty/directx-headers/include/directx",

    -- glfw
    "vendor/glfw/include",

    -- glm
    "vendor/glm",

    -- stb
    "vendor/stb",
  }

  filter "system:windows"
    defines { "_GLFW_WIN32" }
    files { "assets/res.rc" }
    links { "dwmapi" }

  filter { "system:windows", "configurations:release" }
    kind "WindowedApp"

  filter { "toolset:msc*" }
    defines { "_CRT_SECURE_NO_WARNINGS" }
    includedirs { "vendor/bx/include/compat/msvc" }
    buildoptions { "/Zc:__cplusplus", "/Zc:preprocessor", "/MP" }
    disablewarnings { "4244" }

  filter { "toolset:msc*", "configurations:release" }
    linkoptions { "/ENTRY:mainCRTStartup" }

  filter { "system:windows", "toolset:gcc" }
    includedirs { "vendor/bx/include/compat/mingw" }
    links { "gdi32" }

  filter { "system:linux" }
    includedirs {
      "vendor/bx/include/compat/linux",
      "vendor/bgfx/3rdparty/directx-headers/include",
      "vendor/bgfx/3rdparty/directx-headers/include/wsl/stubs",
    }

  filter { "system:linux", "options:use-wayland" }
    defines { "_GLFW_WAYLAND" }
    includedirs { "vendor/wl" }
    excludes { "vendor/glfw/src/xkb_unicode.c" }

  filter { "system:linux", "not options:use-wayland" }
    defines { "_GLFW_X11" }

  filter "system:macosx"
    includedirs { "vendor/bx/include/compat/osx" }
    defines { "_GLFW_COCOA" }
    links { "Cocoa.framework", "QuartzCore.framework", "IOKit.framework", "CoreFoundation.framework", "CoreVideo.framework", "Metal.framework", "AppKit.framework" }
    buildoptions { "-Wno-deprecated-declarations" }

  filter { "system:macosx", "files:**.cpp" }
    compileas "Objective-C++"

  filter { "system:macosx", "files:**.c" }
    compileas "Objective-C"

  filter "configurations:debug"
    defines { "DEBUG", "BX_CONFIG_DEBUG=1" }
    symbols "on"

  filter "configurations:release"
    defines { "NDEBUG", "BX_CONFIG_DEBUG=0" }
    optimize "on"
