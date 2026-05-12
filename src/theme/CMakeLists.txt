# DevDash.Gauges.Theme sub-module
#
# Holds GaugeTheme — the singleton that carries the currently-active aesthetic
# state for every gauge in the dashboard (active preset + light/dark mode).
#
# The presets (`industrial`, `modernOEM`) are defined inline as nested QtObjects
# inside GaugeTheme.qml rather than as separate preset .qml files: a QML
# singleton that references same-module types is not reliably loadable at
# runtime from a compiled qt_add_qml_module resource (the auto-generated
# qmldir's `prefer :/...` line breaks relative resolution of the referenced
# types). See PLAN.md decisions log.

# Singletons must be registered before qt_add_qml_module.
#   GaugeTheme   — active aesthetic preset + light/dark mode.
#   GaugeQuality — active graphics-quality profile (2D vs 3D rendering paths).
set_source_files_properties(GaugeTheme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(GaugeQuality.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

# Bundled fonts. Loaded at runtime by FontLoader in GaugeTheme.qml. We place
# them in src/assets/fonts/ on disk and bundle them into the theme module's
# resource bundle via RESOURCES (with explicit aliases so the qrc path is
# stable regardless of the file's relative location on disk). The qrc URL
# pattern with qt_add_qml_module's RESOURCE_PREFIX `/` + URI `DevDash.Gauges.Theme`
# is: qrc:/DevDash/Gauges/Theme/<alias>.
set(THEME_FONT_FILES
    ${CMAKE_SOURCE_DIR}/src/assets/fonts/BarlowCondensed-Regular.ttf
    ${CMAKE_SOURCE_DIR}/src/assets/fonts/BarlowCondensed-SemiBold.ttf
    ${CMAKE_SOURCE_DIR}/src/assets/fonts/BarlowCondensed-Bold.ttf
    ${CMAKE_SOURCE_DIR}/src/assets/fonts/BarlowCondensed-ExtraBold.ttf
    ${CMAKE_SOURCE_DIR}/src/assets/fonts/Caveat.ttf
)
foreach(font_file IN LISTS THEME_FONT_FILES)
    get_filename_component(font_name "${font_file}" NAME)
    set_source_files_properties("${font_file}"
        PROPERTIES QT_RESOURCE_ALIAS "fonts/${font_name}")
endforeach()

qt_add_qml_module(devdash_gauges_theme
    URI DevDash.Gauges.Theme
    VERSION 1.0
    QML_FILES
        GaugeTheme.qml
        GaugeQuality.qml
    RESOURCES
        ${THEME_FONT_FILES}
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
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeQuality.qml
    )

    add_custom_target(qmllint-theme
        COMMAND ${QMLLINT_EXECUTABLE} ${THEME_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on Theme module"
        VERBATIM
    )
endif()
