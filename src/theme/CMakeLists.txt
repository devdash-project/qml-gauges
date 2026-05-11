# DevDash.Gauges.Theme sub-module
#
# Holds GaugeTheme — the singleton that carries the currently-active aesthetic
# state for every gauge in the dashboard (active preset + light/dark mode).
#
# Preset files live under presets/ and are an implementation detail of
# GaugeTheme: they are not exported as public QML types (no qmldir entry), so
# downstream code only ever imports GaugeTheme.

# GaugeTheme must be registered as a QML singleton (before qt_add_qml_module).
set_source_files_properties(GaugeTheme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(devdash_gauges_theme
    URI DevDash.Gauges.Theme
    VERSION 1.0
    QML_FILES
        GaugeTheme.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash/Gauges/Theme
)

# Install library
install(TARGETS devdash_gauges_theme
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# QML linting
if(QMLLINT_EXECUTABLE)
    set(THEME_QML_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeTheme.qml
    )

    add_custom_target(qmllint-theme
        COMMAND ${QMLLINT_EXECUTABLE} ${THEME_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on Theme module"
        VERBATIM
    )
endif()
