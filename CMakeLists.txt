cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

set(VERSION_MAJOR 3)
set(VERSION_MINOR 0)
set(VERSION_PATCH 0)

set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

set(ARCHES aarch64;arm;i686;x86_64)
set(APIS 21;24)

project(elf-cleaner
  LANGUAGES C CXX
  VERSION ${VERSION}
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(PACKAGE_NAME "termux-elf-cleaner" CACHE STRING "Name of the package")

add_executable("${PACKAGE_NAME}"
  elf-cleaner.cpp
  arghandling.c
)

target_compile_definitions("${PACKAGE_NAME}"
  PRIVATE "COPYRIGHT=\"Copyright (C) 2022-2024 Termux and contributors.\""
  PRIVATE "PACKAGE_VERSION=\"${VERSION}\""
  PRIVATE "PACKAGE_NAME=\"${PACKAGE_NAME}\""
)

enable_testing()
add_test(
  NAME "tests"
  COMMAND bash -c "${CMAKE_CURRENT_SOURCE_DIR}/tests/test.sh ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME} ${CMAKE_CURRENT_SOURCE_DIR}"
  )
