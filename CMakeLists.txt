cmake_minimum_required(VERSION 3.21)
project(qml-gauges VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Export compile commands for clangd language server
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find Qt6
# Minimum 6.2 for Ubuntu 22.04 LTS (JetPack 6 on Jetson Orin Nano)
find_package(Qt6 6.2 REQUIRED COMPONENTS Quick Qml QuickControls2)

# Build options
option(BUILD_EXPLORER "Build the component explorer application" ON)
option(BUILD_EXAMPLES "Build example applications" OFF)
option(BUILD_TESTS "Build unit tests" OFF)

# Add subdirectories
add_subdirectory(src)

if(BUILD_EXPLORER)
    add_subdirectory(explorer)
endif()

if(BUILD_EXAMPLES)
    add_subdirectory(examples/cpp)
endif()

if(BUILD_TESTS)
    add_subdirectory(tests)
endif()
