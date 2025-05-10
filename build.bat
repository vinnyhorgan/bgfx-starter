@echo off

if not exist ".\build" (
  echo project not configured yet, use premake
  exit /b 1
)

if not "%~1"=="debug" if not "%~1"=="release" (
  echo usage: .\build.bat ^<debug^|release^>
  exit /b 1
)

msbuild .\build\bgfx-starter.sln /p:Configuration=%~1
