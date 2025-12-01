# DevDash.Gauges.Compounds sub-module
qt_add_qml_module(devdash_gauges_compounds
    URI DevDash.Gauges.Compounds
    VERSION 1.0
    QML_FILES
        DigitalReadout.qml
        GaugeNeedle.qml
        GaugeTickRing.qml
        GaugeValueArc.qml
        GaugeZoneArc.qml
        RollingDigitReadout.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash/Gauges/Compounds
)

# Install library
install(TARGETS devdash_gauges_compounds
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# QML linting
if(QMLLINT_EXECUTABLE)
    set(COMPOUNDS_QML_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/DigitalReadout.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeNeedle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeTickRing.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeValueArc.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeZoneArc.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/RollingDigitReadout.qml
    )

    add_custom_target(qmllint-compounds
        COMMAND ${QMLLINT_EXECUTABLE} ${COMPOUNDS_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on Compounds module"
        VERBATIM
    )
endif()
