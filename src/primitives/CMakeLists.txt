# DevDash.Gauges.Primitives sub-module
qt_add_qml_module(devdash_gauges_primitives
    URI DevDash.Gauges.Primitives
    VERSION 1.0
    QML_FILES
        arc/GaugeArc.qml
        frame/BezelScrews.qml
        frame/GaugeBezel.qml
        center/GaugeCenterCap.qml
        frame/GaugeFace.qml
        tick/GaugeTick.qml
        tick/GaugeTickLabel.qml
        overlays/GlassOverlay.qml
        overlays/PerformanceOverlay.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash/Gauges/Primitives
)

# Qt Quick 3D components (optional - only built if Qt6::Quick3D is available)
if(HAVE_QUICK3D)
    # Add 3D QML components to the module
    qt_target_qml_sources(devdash_gauges_primitives
        QML_FILES
            3d/CenterCap3D.qml
            3d/Bezel3D.qml
    )

    # Add 3D assets as resources
    # PREFIX must match the QML module path so relative paths in QML resolve correctly
    qt_add_resources(devdash_gauges_primitives "quick3d_assets"
        PREFIX "/DevDash/Gauges/Primitives"
        BASE "${CMAKE_CURRENT_SOURCE_DIR}"
        FILES
            assets/studio.ktx
            assets/meshes/dome_mesh.mesh
            assets/meshes/torus_mesh.mesh
    )

    # Link Qt Quick 3D
    target_link_libraries(devdash_gauges_primitives PRIVATE Qt6::Quick3D)
endif()

# Install library
install(TARGETS devdash_gauges_primitives
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# QML linting
if(QMLLINT_EXECUTABLE)
    set(PRIMITIVES_QML_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/arc/GaugeArc.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/frame/BezelScrews.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/frame/GaugeBezel.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/center/GaugeCenterCap.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/frame/GaugeFace.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/tick/GaugeTick.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/tick/GaugeTickLabel.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/overlays/GlassOverlay.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/overlays/PerformanceOverlay.qml
    )

    add_custom_target(qmllint-primitives
        COMMAND ${QMLLINT_EXECUTABLE} ${PRIMITIVES_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on Primitives module"
        VERBATIM
    )
endif()
