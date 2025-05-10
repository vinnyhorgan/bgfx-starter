workspace "bgfx-starter"
  configurations { "debug", "release" }
  architecture "x64"
  location "build"

project "bgfx-starter"
  kind "ConsoleApp"
  language "C++"
  staticruntime "on"

  targetdir "%{wks.location}/bin/%{cfg.buildcfg}"
  objdir "%{wks.location}/obj/%{cfg.buildcfg}"

  files {
    "src/**.h",
    "src/**.cpp",

    "vendor/glfw/src/*.h",
    "vendor/glfw/src/*.c",
  }

  includedirs {
    "vendor/glfw/include",
  }

  filter "system:windows"
    defines {
      "_CRT_SECURE_NO_WARNINGS",
      "_GLFW_WIN32",
    }

    links { "dwmapi" }

  filter { "system:windows", "configurations:release" }
    kind "WindowedApp"

    linkoptions { "/ENTRY:mainCRTStartup" }

  filter "configurations:debug"
    defines { "DEBUG" }
    symbols "on"

  filter "configurations:release"
    defines { "NDEBUG" }
    optimize "on"
