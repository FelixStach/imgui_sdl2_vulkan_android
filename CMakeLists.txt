cmake_minimum_required(VERSION 3.14.7 FATAL_ERROR)
cmake_policy(VERSION 3.14.7...3.28.1)

set(PROJECT_NAME imgui_sdl2_vulkan_android)
project(${PROJECT_NAME})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Vulkan REQUIRED)

# Disable SDL tests
set(SDL_TEST_ENABLED_BY_DEFAULT OFF)

# Prevent SDL from redefining main() (skip on android)
if(NOT ANDROID)
  add_definitions(-DSDL_MAIN_HANDLED)
endif()

# Make sure debug libs have the same name as release ones
set(SDL_CMAKE_DEBUG_POSTFIX "" CACHE STRING "" FORCE)

add_subdirectory(libraries/SDL)

# Force copy of SDL2 Java files to happen before target build
set(SDL_ACTIVITY_FOLDER app/src/main/java/org/libsdl/app)
set(SDL_SRC_DIR ${CMAKE_SOURCE_DIR}/libraries/SDL/android-project/${SDL_ACTIVITY_FOLDER})
set(SDL_DST_DIR ${CMAKE_SOURCE_DIR}/android/${SDL_ACTIVITY_FOLDER})

add_custom_target(copy_sdl_java_files ALL
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${SDL_DST_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SDL_SRC_DIR} ${SDL_DST_DIR}
    COMMENT "Force-copying SDL2 Java activity files every time"
    VERBATIM
)

include_directories(
  libraries/imgui
  libraries/imgui/backends
)

set(SOURCE_FILES
  libraries/imgui/imgui.cpp
  libraries/imgui/imgui_demo.cpp
  libraries/imgui/imgui_draw.cpp
  libraries/imgui/imgui_tables.cpp
  libraries/imgui/imgui_widgets.cpp
  libraries/imgui/backends/imgui_impl_sdl2.cpp
  libraries/imgui/backends/imgui_impl_vulkan.cpp
  libraries/imgui/examples/example_sdl2_vulkan/main.cpp
)

# build a shared library for Android, or an executable for other platforms
if(ANDROID)
    add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES})
else()
    add_executable(${PROJECT_NAME} ${SOURCE_FILES})
endif()

target_link_libraries( ${PROJECT_NAME}
  SDL2
  Vulkan::Vulkan
)

add_dependencies(${PROJECT_NAME} copy_sdl_java_files)