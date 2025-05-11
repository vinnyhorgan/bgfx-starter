#!/bin/bash

if [ ! -d "./build" ]; then
  echo "project not configured yet, use premake"
  exit 1
fi

if [ "$1" != "debug" ] && [ "$1" != "release" ]; then
  echo "usage: ./build.sh <debug|release>"
  exit 1
fi

cd build
make config=$1
