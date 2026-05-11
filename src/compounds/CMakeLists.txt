# DevDash.Gauges.Compounds sub-module
qt_add_qml_module(devdash_gauges_compounds
    URI DevDash.Gauges.Compounds
    VERSION 1.0
    QML_FILES
        readout/DigitalReadout.qml
        readout/RollingDigitReadout.qml
        needle/GaugeNeedle.qml
        needle/NeedleFrontBody.qml
        needle/NeedleHeadTip.qml
        needle/NeedleRearBody.qml
        needle/NeedleTailTip.qml
        tick/GaugeTickRing.qml
        arc/GaugeValueArc.qml
        arc/GaugeZoneArc.qml
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
        ${CMAKE_CURRENT_SOURCE_DIR}/readout/DigitalReadout.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/readout/RollingDigitReadout.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/needle/GaugeNeedle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/needle/NeedleFrontBody.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/needle/NeedleHeadTip.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/needle/NeedleRearBody.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/needle/NeedleTailTip.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/tick/GaugeTickRing.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/arc/GaugeValueArc.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/arc/GaugeZoneArc.qml
    )

    add_custom_target(qmllint-compounds
        COMMAND ${QMLLINT_EXECUTABLE} ${COMPOUNDS_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on Compounds module"
        VERBATIM
    )
endif()
