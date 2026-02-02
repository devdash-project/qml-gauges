# DevDash.Gauges.Primitives sub-module
qt_add_qml_module(devdash_gauges_primitives
    URI DevDash.Gauges.Primitives
    VERSION 1.0
    QML_FILES
        GaugeArc.qml
        GaugeBezel.qml
        GaugeCenterCap.qml
        GaugeFace.qml
        GaugeTick.qml
        GaugeTickLabel.qml
        GlassOverlay.qml
        NeedleFrontBody.qml
        NeedleHeadTip.qml
        NeedleRearBody.qml
        NeedleTailTip.qml
        PerformanceOverlay.qml
    RESOURCE_PREFIX /
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/DevDash/Gauges/Primitives
)

# Qt Quick 3D components (optional - only built if Qt6::Quick3D is available)
if(HAVE_QUICK3D)
    # Add 3D QML components to the module
    qt_target_qml_sources(devdash_gauges_primitives
        QML_FILES
            CenterCap3D.qml
            Bezel3D.qml
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
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeArc.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeBezel.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeCenterCap.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeFace.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeTick.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GaugeTickLabel.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/GlassOverlay.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/NeedleFrontBody.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/NeedleHeadTip.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/NeedleRearBody.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/NeedleTailTip.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/PerformanceOverlay.qml
    )

    add_custom_target(qmllint-primitives
        COMMAND ${QMLLINT_EXECUTABLE} ${PRIMITIVES_QML_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running qmllint on Primitives module"
        VERBATIM
    )
endif()
