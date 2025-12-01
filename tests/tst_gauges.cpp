/**
 * @file tst_gauges.cpp
 * @brief Qt Quick Test runner for QML gauge component tests
 *
 * This is the C++ entry point that launches all QML test cases.
 * Individual tests are defined in tst_*.qml files.
 *
 * Usage:
 *   cmake --build build --target qml-gauges-tests
 *   ./build/tests/qml-gauges-tests
 *
 * Or via CTest:
 *   cd build && ctest --verbose
 */

#include <QtQuickTest>

// QUICK_TEST_MAIN runs all tst_*.qml files in the source directory
QUICK_TEST_MAIN(qml_gauges_tests)
