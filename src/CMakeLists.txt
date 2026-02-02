# Main DevDash.Gauges module
qt_add_qml_module(devdash_gauges
    URI DevDash.Gauges
    VERSION 1.0
    QML_FILES
        radial/RadialGauge.qml
        radial/RadialGauge3D.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash/Gauges
)

# Install library
install(TARGETS devdash_gauges
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install QML module files
install(DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml
)

# Add sub-modules
add_subdirectory(primitives)
add_subdirectory(compounds)

# QML linting with qmllint
if(EXISTS /usr/lib/qt6/bin/qmllint)
    set(QMLLINT_EXECUTABLE /usr/lib/qt6/bin/qmllint)
else()
    find_program(QMLLINT_EXECUTABLE NAMES qmllint6 HINTS ${Qt6_DIR}/../../../bin)
endif()

if(QMLLINT_EXECUTABLE)
    set(QML_FILES_TO_LINT
        ${CMAKE_CURRENT_SOURCE_DIR}/radial/RadialGauge.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/radial/RadialGauge3D.qml
    )

    add_custom_target(qmllint-gauges
        COMMAND ${QMLLINT_EXECUTABLE} ${QML_FILES_TO_LINT}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on DevDash.Gauges module"
        VERBATIM
    )

    message(STATUS "qmllint found: ${QMLLINT_EXECUTABLE}")
    message(STATUS "Run 'cmake --build build --target qmllint-gauges' to lint QML files")
else()
    message(WARNING "qmllint not found - QML linting disabled")
endif()
