# QML Gauges Test Suite
#
# Uses Qt Quick Test for QML component testing
# Reference: https://doc.qt.io/qt-6/qtquicktest-index.html

cmake_minimum_required(VERSION 3.16)

find_package(Qt6 REQUIRED COMPONENTS QuickTest Qml Quick)

# Enable testing
enable_testing()

# QML Test executable
qt_add_executable(qml-gauges-tests
    tst_gauges.cpp
)

# Link against Qt Quick Test
target_link_libraries(qml-gauges-tests PRIVATE
    Qt6::QuickTest
    Qt6::Qml
    Qt6::Quick
)

# Add QML test files as resources
qt_add_qml_module(qml-gauges-tests
    URI "GaugeTests"
    VERSION 1.0
    QML_FILES
        tst_GaugeArc.qml
        tst_GaugeNeedle.qml
        tst_RadialGauge.qml
    IMPORT_PATH ${CMAKE_SOURCE_DIR}/build/qml
)

# Make the gauge library available to tests
target_include_directories(qml-gauges-tests PRIVATE
    ${CMAKE_SOURCE_DIR}/src
)

# Register test with CTest
add_test(NAME qml-gauges-tests
    COMMAND qml-gauges-tests
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Set QML import path for tests
set_tests_properties(qml-gauges-tests PROPERTIES
    ENVIRONMENT "QML2_IMPORT_PATH=${CMAKE_SOURCE_DIR}/build/qml"
)
