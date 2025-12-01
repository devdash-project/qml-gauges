# QML Gauges Test Suite
#
# Two complementary test approaches:
# 1. Qt Quick Test (tst_*.qml) - Behavioral tests for QML property/signal validation
# 2. Catch2 (tst_qml_loading.cpp) - C++ level load-time validation
#
# References:
# - Qt Quick Test: https://doc.qt.io/qt-6/qtquicktest-index.html
# - Catch2: https://github.com/catchorg/Catch2

cmake_minimum_required(VERSION 3.16)

find_package(Qt6 REQUIRED COMPONENTS QuickTest Qml Quick)

# Enable testing
enable_testing()

# =============================================================================
# Qt Quick Tests (QML behavioral tests)
# =============================================================================

qt_add_executable(qml-gauges-tests
    tst_gauges.cpp
)

target_link_libraries(qml-gauges-tests PRIVATE
    Qt6::QuickTest
    Qt6::Qml
    Qt6::Quick
)

qt_add_qml_module(qml-gauges-tests
    URI "GaugeTests"
    VERSION 1.0
    QML_FILES
        tst_GaugeArc.qml
        tst_GaugeNeedle.qml
        tst_RadialGauge.qml
    IMPORT_PATH ${CMAKE_BINARY_DIR}/qml
)

target_include_directories(qml-gauges-tests PRIVATE
    ${CMAKE_SOURCE_DIR}/src
)

add_test(NAME qml-gauges-tests
    COMMAND qml-gauges-tests
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

set_tests_properties(qml-gauges-tests PROPERTIES
    ENVIRONMENT "QML2_IMPORT_PATH=${CMAKE_BINARY_DIR}/qml"
)

# =============================================================================
# Catch2 Tests (C++ QML loading validation)
# =============================================================================

# Try to find Catch2 - if not found, skip these tests
find_package(Catch2 3 QUIET)

if(Catch2_FOUND)
    message(STATUS "Catch2 found - building QML loading tests")

    qt_add_executable(qml-loading-tests
        tst_qml_loading.cpp
    )

    target_link_libraries(qml-loading-tests PRIVATE
        Qt6::Qml
        Qt6::Quick
        Qt6::Gui
        Catch2::Catch2  # Use Catch2 without main (we provide custom main for QGuiApplication)
    )

    # Set QML import path at compile time
    target_compile_definitions(qml-loading-tests PRIVATE
        QML_IMPORT_PATH="${CMAKE_BINARY_DIR}/qml"
    )

    add_test(NAME qml-loading-tests
        COMMAND qml-loading-tests
    )

    set_tests_properties(qml-loading-tests PROPERTIES
        ENVIRONMENT "QML2_IMPORT_PATH=${CMAKE_BINARY_DIR}/qml"
    )

    # Include Catch2's CMake integration for test discovery
    include(Catch)
    catch_discover_tests(qml-loading-tests)
else()
    message(STATUS "Catch2 not found - skipping QML loading tests")
    message(STATUS "  Install with: sudo apt install catch2 (Ubuntu 24.04+)")
    message(STATUS "  Or: vcpkg install catch2")
endif()
