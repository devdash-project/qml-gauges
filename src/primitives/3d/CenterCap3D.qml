import QtQuick
import QtQuick3D

/**
 * @brief 3D center cap using Qt Quick 3D with PBR chrome material.
 *
 * CenterCap3D renders a realistic 3D domed center cap using Qt Quick 3D's
 * PBR (Physically Based Rendering) system with IBL (Image Based Lighting)
 * for realistic chrome reflections.
 *
 * This is a showcase component demonstrating Qt Quick 3D capabilities.
 * For production use on resource-constrained devices, consider the 2D
 * GaugeCenterCap component with domed: true.
 *
 * @example
 * @code
 * CenterCap3D {
 *     width: 50
 *     height: 50
 *     color: "#666666"
 *     metalness: 1.0
 *     roughness: 0.1
 * }
 * @endcode
 */
Item {
    id: root

    // === Geometry ===

    /**
     * @brief Diameter of the center cap in pixels.
     * @default 35
     */
    property real diameter: 35

    // === Material Properties ===

    /**
     * @brief Base color of the chrome material.
     * @default "#666666"
     */
    property color color: "#666666"

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
     * @default 0.1
     */
    property real roughness: 0.1

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
     * @default 1.2
     */
    property real iblExposure: 1.2

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

    implicitWidth: diameter
    implicitHeight: diameter

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
            position: Qt.vector3d(0, 100, 0)
            eulerRotation.x: -90  // Look down
        }

        // Key light for highlights
        DirectionalLight {
            eulerRotation: Qt.vector3d(-45, root.lightAngle, 0)
            brightness: root.lightBrightness
            color: "#ffffff"
        }

        // Fill light (softer, from opposite side)
        DirectionalLight {
            eulerRotation: Qt.vector3d(-30, root.lightAngle + 180, 0)
            brightness: root.lightBrightness * 0.3
            color: "#e8e8ff"
        }

        // 3D dome model
        Model {
            id: domeModel
            source: "qrc:/DevDash/Gauges/Primitives/assets/meshes/dome_mesh.mesh"

            // Scale to match diameter
            // The dome was created with radius 0.5, so diameter 1.0
            // Scale factor = desired diameter / 1.0
            scale: Qt.vector3d(root.diameter, root.diameter, root.diameter)

            materials: PrincipledMaterial {
                baseColor: root.color
                metalness: root.metalness
                roughness: root.roughness
                specularAmount: root.specularAmount
            }
        }
    }
}
