cmake_minimum_required(VERSION 3.15)
project(ai_nails_app LANGUAGES CXX)

set(BINARY_NAME "ai_nails_app")

set(CMAKE_CXX_STANDARD 17)

cmake_policy(SET CMP0063 NEW)

# Windows SDK 配置
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# 链接 Dwmapi（DWM 窗口属性）和 Shcore（DPI）
target_link_libraries(${BINARY_NAME} PRIVATE dwmapi shcore)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/build/windows/x64/flutter")

find_package(flutter REQUIRED CONFIG)

add_executable(${BINARY_NAME}
  "flutter/generated_plugin_registrant.cc"
  "runner/main.cpp"
  "runner/flutter_window.cpp"
  "runner/flutter_window.h"
  "runner/win32_window.cpp"
  "runner/win32_window.h"
  "runner/utils.cpp"
  "runner/utils.h"
)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

target_link_libraries(${BINARY_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
  PkgConfig::GTK
)

target_compile_definitions(${BINARY_NAME} PRIVATE
  FLUTTER_VERSION="${FLUTTER_VERSION}"
  FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}
  FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}
  FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}
  FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}
)

set_target_properties(${BINARY_NAME} PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner"
)

# 复制资源文件
configure_file(
  "${CMAKE_SOURCE_DIR}/runner/resources/app_icon.ico"
  "${CMAKE_BINARY_DIR}/runner/resources/app_icon.ico"
  COPYONLY
)

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${INSTALL_BUNDLE_DATA_DIR}/runner")
install(DIRECTORY "${CMAKE_SOURCE_DIR}/flutter/ephemeral" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}")
install(DIRECTORY "${CMAKE_SOURCE_DIR}/runner/resources/" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}/runner/resources")
