#!/bin/bash

# Target configuration (default to debug)
CONFIG=${1:-debug}

if [ "$CONFIG" != "debug" ] && [ "$CONFIG" != "release" ]; then
  echo "Usage: ./scripts/build_macos.sh [debug|release]"
  exit 1
fi

# Ensure submodules are initialized
if [ ! -f "vendor/bgfx/include/bgfx/bgfx.h" ]; then
  echo "Initializing submodules..."
  git submodule update --init --recursive
fi

# Generate makefiles using premake5
echo "Generating project files..."
if ! command -v premake5 &> /dev/null; then
    echo "Error: premake5 not found in PATH."
    echo "Please install it via 'brew install premake' or download from https://premake.github.io"
    exit 1
fi

premake5 gmake
premake5 export-compile-commands

# Build the project
echo "Building ($CONFIG)..."
make -C build config=$CONFIG -j$(sysctl -n hw.ncpu)

# Run the application if build was successful
if [ $? -eq 0 ]; then
  echo "Running application..."
  ./build/bin/$CONFIG/bgfx-starter
else
  echo "Build failed."
  exit 1
fi
