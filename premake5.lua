workspace "bgfx-starter"
  configurations { "debug", "release" }
  architecture "x64"
  location "build"

project "bgfx-starter"
  kind "ConsoleApp"
  language "C++"
  cppdialect "C++17"
  staticruntime "on"

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

    -- glfw
    "vendor/glfw/src/*.h",
    "vendor/glfw/src/*.c",
  }

  excludes {
    -- bx
    "vendor/bx/src/amalgamated.cpp",

    -- bgfx
    "vendor/bgfx/src/amalgamated.cpp",
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
  }

  filter "system:windows"
    defines { "_GLFW_WIN32" }
    links { "dwmapi" }

  filter { "system:windows", "configurations:release" }
    kind "WindowedApp"

  filter { "toolset:msc*" }
    defines { "_CRT_SECURE_NO_WARNINGS" }
    includedirs { "vendor/bx/include/compat/msvc" }
    buildoptions { "/Zc:__cplusplus", "/Zc:preprocessor" }
    disablewarnings { "4244" }

  filter { "toolset:msc*", "configurations:release" }
    linkoptions { "/ENTRY:mainCRTStartup" }

  filter { "system:windows", "toolset:gcc" }
    includedirs { "vendor/bx/include/compat/mingw" }
    links { "gdi32" }

  filter "configurations:debug"
    defines { "DEBUG", "BX_CONFIG_DEBUG=1" }
    symbols "on"

  filter "configurations:release"
    defines { "NDEBUG", "BX_CONFIG_DEBUG=0" }
    optimize "on"
