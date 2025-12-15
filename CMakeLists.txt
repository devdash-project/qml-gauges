cmake_minimum_required(VERSION 3.21)
project(qml-gauges VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Export compile commands for clangd language server
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find Qt6
# Minimum 6.10 for latest QtQuick.Effects features and CurveRenderer
find_package(Qt6 6.10 REQUIRED COMPONENTS Quick Qml QuickControls2 QuickEffects WebSockets)

# Build options
option(BUILD_EXPLORER "Build the component explorer application" ON)
option(BUILD_EXAMPLES "Build example applications" OFF)
option(BUILD_TESTS "Build unit tests" OFF)
option(LINT_ON_BUILD "Run qmllint before building (fails on critical errors)" ON)

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

# QML Linting target
# Find qmllint - check Qt bin directory first
find_program(QMLLINT_EXECUTABLE
    NAMES qmllint
    HINTS "${Qt6_DIR}/../../../bin" "${Qt6_DIR}/../../bin"
    PATHS /usr/lib/qt6/bin
)

if(QMLLINT_EXECUTABLE)
    message(STATUS "Found qmllint: ${QMLLINT_EXECUTABLE}")

    # Collect all QML files
    file(GLOB_RECURSE ALL_QML_FILES
        "${CMAKE_SOURCE_DIR}/src/*.qml"
        "${CMAKE_SOURCE_DIR}/explorer/qml/*.qml"
    )

    # Create a custom target for full linting (shows all warnings)
    add_custom_target(qmllint
        COMMAND ${QMLLINT_EXECUTABLE}
            -I "${CMAKE_BINARY_DIR}/qml"
            ${ALL_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running qmllint on all QML files..."
        VERBATIM
    )

    # Create a critical-errors-only lint target using a wrapper script
    # This filters for errors that break runtime (non-existent properties, etc.)
    configure_file(
        "${CMAKE_SOURCE_DIR}/cmake/qmllint-critical.sh.in"
        "${CMAKE_BINARY_DIR}/qmllint-critical.sh"
        @ONLY
    )

    add_custom_target(qmllint-critical
        COMMAND bash "${CMAKE_BINARY_DIR}/qmllint-critical.sh"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Checking QML files for critical errors..."
        VERBATIM
    )

    # Make explorer depend on lint check when LINT_ON_BUILD is enabled
    if(LINT_ON_BUILD AND BUILD_EXPLORER)
        add_dependencies(qml-gauges-explorer qmllint-critical)
        message(STATUS "QML lint-on-build enabled - explorer will check for critical QML errors")
    endif()

    # Also add as a test so `ctest` can run it
    enable_testing()
    add_test(
        NAME qmllint
        COMMAND ${QMLLINT_EXECUTABLE}
            -I "${CMAKE_BINARY_DIR}/qml"
            ${ALL_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
else()
    message(WARNING "qmllint not found - QML linting disabled")
endif()
