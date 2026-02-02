# Explorer application for DevDash Gauges library

qt_add_executable(qml-gauges-explorer
    main.cpp
    stateserver.cpp
    stateserver.h
)

# Mark Theme.qml as singleton BEFORE adding to module
set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

# Add QML module for the explorer UI
qt_add_qml_module(qml-gauges-explorer
    URI Explorer
    VERSION 1.0
    QML_FILES
        qml/Theme.qml
        qml/Main.qml
        qml/components/ComponentSidebar.qml
        qml/components/PropertyPanel.qml
        qml/components/PreviewArea.qml
        qml/components/DocumentationPanel.qml
        qml/editors/RealEditor.qml
        qml/editors/IntEditor.qml
        qml/editors/ColorEditor.qml
        qml/editors/BoolEditor.qml
        qml/editors/StringEditor.qml
        qml/editors/EnumEditor.qml
        qml/pages/WelcomePage.qml
        qml/pages/GaugeArcPage.qml
        qml/pages/GaugeBezelPage.qml
        qml/pages/GaugeCenterCapPage.qml
        qml/pages/GaugeFacePage.qml
        qml/pages/GaugeNeedlePage.qml
        qml/pages/GaugeTickPage.qml
        qml/pages/GaugeTickLabelPage.qml
        qml/pages/DigitalReadoutPage.qml
        qml/pages/GaugeTickRingPage.qml
        qml/pages/GaugeValueArcPage.qml
        qml/pages/GaugeZoneArcPage.qml
        qml/pages/RollingDigitReadoutPage.qml
        qml/pages/RadialGaugePage.qml
        qml/pages/RadialGauge3DPage.qml
        qml/pages/Bezel3DPage.qml
        qml/pages/CenterCap3DPage.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/Explorer
)

# Link against Qt (including WebSockets for state server)
target_link_libraries(qml-gauges-explorer PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    Qt6::WebSockets
)

# Set QML import paths so the explorer can find DevDash.Gauges modules
set_target_properties(qml-gauges-explorer PROPERTIES
    QML_IMPORT_PATH "${CMAKE_BINARY_DIR}/qml"
)

# Ensure the gauge modules are built before the explorer
add_dependencies(qml-gauges-explorer
    devdash_gauges
    devdash_gauges_primitives
    devdash_gauges_compounds
)
