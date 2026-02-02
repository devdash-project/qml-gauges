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

# Qt Quick 3D is optional - enables Bezel3D, CenterCap3D components
find_package(Qt6 COMPONENTS Quick3D QUIET)
if(Qt6Quick3D_FOUND)
    message(STATUS "Qt6::Quick3D found - 3D gauge components enabled")
    set(HAVE_QUICK3D TRUE)
else()
    message(STATUS "Qt6::Quick3D not found - 3D gauge components disabled")
    set(HAVE_QUICK3D FALSE)
endif()

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

    # QML Loader cross-module verification
    # Catches runtime failures from Loader source paths crossing QML module boundaries
    find_package(Python3 REQUIRED)
    add_custom_target(verify-qml-loaders
        COMMAND ${Python3_EXECUTABLE} "${CMAKE_SOURCE_DIR}/scripts/verify-qml-loaders.py" "${CMAKE_BINARY_DIR}"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Verifying QML Loader source paths..."
        VERBATIM
    )

    # Make explorer depend on both lint check AND loader verification when LINT_ON_BUILD is enabled
    if(LINT_ON_BUILD AND BUILD_EXPLORER)
        add_dependencies(qml-gauges-explorer qmllint-critical verify-qml-loaders)
        message(STATUS "QML lint-on-build enabled - explorer will check for critical QML errors and loader paths")
    endif()

    # Also add as tests so `ctest` can run them
    enable_testing()
    add_test(
        NAME qmllint
        COMMAND ${QMLLINT_EXECUTABLE}
            -I "${CMAKE_BINARY_DIR}/qml"
            ${ALL_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
    add_test(
        NAME verify-qml-loaders
        COMMAND ${Python3_EXECUTABLE} "${CMAKE_SOURCE_DIR}/scripts/verify-qml-loaders.py" "${CMAKE_BINARY_DIR}"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
else()
    message(WARNING "qmllint not found - QML linting disabled")
endif()
