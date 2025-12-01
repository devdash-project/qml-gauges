# DevDash.Gauges.Primitives sub-module
qt_add_qml_module(devdash_gauges_primitives
    URI DevDash.Gauges.Primitives
    VERSION 1.0
    QML_FILES
        GaugeArc.qml
        GaugeBezel.qml
        GaugeCenterCap.qml
        GaugeFace.qml
        GaugeNeedleClassic.qml
        GaugeNeedleTapered.qml
        GaugeNeedleVelocity.qml
        GaugeTick.qml
        GaugeTickLabel.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash/Gauges/Primitives
)

# Install library
install(TARGETS devdash_gauges_primitives
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# QML linting
if(QMLLINT_EXECUTABLE)
    set(PRIMITIVES_QML_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeArc.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeBezel.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeCenterCap.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeFace.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeNeedleClassic.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeNeedleTapered.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeNeedleVelocity.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeTick.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeTickLabel.qml
    )

    add_custom_target(qmllint-primitives
        COMMAND ${QMLLINT_EXECUTABLE} ${PRIMITIVES_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on Primitives module"
        VERBATIM
    )
endif()
