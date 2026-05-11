import QtQuick
import QtQuick3D

/**
 * @brief 3D bezel ring using Qt Quick 3D with PBR chrome material.
 *
 * Bezel3D renders a realistic 3D torus bezel ring using Qt Quick 3D's
 * PBR (Physically Based Rendering) system with IBL (Image Based Lighting)
 * for realistic chrome reflections.
 *
 * This is a showcase component demonstrating Qt Quick 3D capabilities.
 * For production use on resource-constrained devices, consider the 2D
 * GaugeBezel component with style: "chrome3d".
 *
 * @example
 * @code
 * Bezel3D {
 *     width: 400
 *     height: 400
 *     outerRadius: 200
 *     color: "#555555"
 *     metalness: 1.0
 *     roughness: 0.08
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry ===

    /**
     * @brief Outer radius of the bezel ring.
     * @default 200
     */
    property real outerRadius: 200

    /**
     * @brief Inner radius of the bezel ring (determines ring thickness).
     * @default 185
     */
    property real innerRadius: 185

    // === Material Properties ===

    /**
     * @brief Base color of the chrome material.
     * @default "#555555"
     */
    property color color: "#555555"

    /**
     * @brief Metalness of the material (0.0-1.0).
     *
     * 1.0 = fully metallic (chrome), 0.0 = dielectric (plastic).
     *
     * @default 1.0
     */
    property real metalness: 1.0

    /**
     * @brief Roughness of the material (0.0-1.0).
     *
     * 0.0 = mirror-smooth, 1.0 = completely rough/matte.
     * For polished chrome, use 0.05-0.15.
     *
     * @default 0.08
     */
    property real roughness: 0.08

    /**
     * @brief Specular reflection amount (0.0-1.0).
     * @default 1.0
     */
    property real specularAmount: 1.0

    // === Lighting ===

    /**
     * @brief IBL (environment map) exposure.
     *
     * Higher values brighten reflections.
     *
     * @default 1.0
     */
    property real iblExposure: 1.0

    /**
     * @brief Directional light brightness.
     * @default 1.5
     */
    property real lightBrightness: 1.5

    /**
     * @brief Light angle in degrees (rotation around Y axis).
     * @default 45
     */
    property real lightAngle: 45

    // === Implementation ===

    implicitWidth: outerRadius * 2
    implicitHeight: outerRadius * 2

    // Computed scale factor
    // The torus was created with major radius 1.0, minor radius 0.075
    // We want major radius = (outerRadius + innerRadius) / 2
    // And minor radius = (outerRadius - innerRadius) / 2
    readonly property real _torusMajorRadius: (outerRadius + innerRadius) / 2
    readonly property real _torusMinorRadius: (outerRadius - innerRadius) / 2

    // Scale factor: original major radius was 1.0
    readonly property real _scaleFactor: _torusMajorRadius

    View3D {
        id: view3d
        anchors.fill: parent

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High

            // IBL for realistic chrome reflections
            lightProbe: Texture {
                source: "qrc:/DevDash/Gauges/Primitives/assets/studio.ktx"
            }
            probeExposure: root.iblExposure
        }

        // Orthographic camera for consistent sizing
        OrthographicCamera {
            id: camera
            position: Qt.vector3d(0, 200, 0)
            eulerRotation.x: -90  // Look down
        }

        // Key light for highlights
        DirectionalLight {
            eulerRotation: Qt.vector3d(-30, root.lightAngle, 0)
            brightness: root.lightBrightness
            color: "#ffffff"
        }

        // Fill light (softer, from opposite side)
        DirectionalLight {
            eulerRotation: Qt.vector3d(-20, root.lightAngle + 180, 0)
            brightness: root.lightBrightness * 0.4
            color: "#e8e8ff"
        }

        // Rim light for edge definition
        DirectionalLight {
            eulerRotation: Qt.vector3d(10, root.lightAngle + 90, 0)
            brightness: root.lightBrightness * 0.2
            color: "#ffe8e8"
        }

        // 3D torus model
        Model {
            id: torusModel
            source: "qrc:/DevDash/Gauges/Primitives/assets/meshes/torus_mesh.mesh"

            // Scale to match desired dimensions
            // Original torus: major radius 1.0, minor radius 0.075
            // We scale uniformly by major radius factor, then adjust minor radius with Y scale
            property real minorScale: root._torusMinorRadius / 0.075

            scale: Qt.vector3d(
                root._scaleFactor,
                root._scaleFactor * (minorScale / root._scaleFactor),
                root._scaleFactor
            )

            materials: PrincipledMaterial {
                baseColor: root.color
                metalness: root.metalness
                roughness: root.roughness
                specularAmount: root.specularAmount
            }
        }
    }
}
