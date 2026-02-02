import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DevDash.Gauges.Primitives 1.0
import "../components"

Item {
    id: root

    // Component metadata
    property string title: "Bezel3D"
    property string description: "True 3D bezel ring using Qt Quick 3D with PBR chrome material and IBL reflections. Renders a realistic torus with metallic lighting."

    // State server for MCP integration (passed to PropertyPanel)
    property var stateServer: null

    // Expose property panel for external access
    property alias propertyPanel: propertyPanel

    // Property definitions for the editor (with descriptions for documentation panel)
    property var properties: [
        // Geometry
        {name: "outerRadius", type: "real", min: 50, max: 250, default: 200, category: "Geometry",
         description: "Outer radius of the bezel ring in pixels."},
        {name: "innerRadius", type: "real", min: 40, max: 240, default: 185, category: "Geometry",
         description: "Inner radius of the bezel ring. Difference from outerRadius determines ring thickness."},

        // Material
        {name: "color", type: "color", default: "#555555", category: "Material",
         description: "Base color of the chrome material. Affects reflected tint."},
        {name: "metalness", type: "real", min: 0, max: 1, default: 1.0, category: "Material",
         description: "Metalness of the PBR material. 1.0 = chrome, 0.0 = plastic/dielectric."},
        {name: "roughness", type: "real", min: 0, max: 1, default: 0.08, category: "Material",
         description: "Surface roughness. 0.0 = mirror polish, 1.0 = matte finish."},
        {name: "specularAmount", type: "real", min: 0, max: 1, default: 1.0, category: "Material",
         description: "Specular reflection intensity."},

        // Lighting
        {name: "iblExposure", type: "real", min: 0.1, max: 3, default: 1.0, category: "Lighting",
         description: "IBL (environment map) exposure. Higher = brighter reflections."},
        {name: "lightBrightness", type: "real", min: 0, max: 3, default: 1.5, category: "Lighting",
         description: "Directional light brightness for highlights."},
        {name: "lightAngle", type: "real", min: 0, max: 360, default: 45, category: "Lighting",
         description: "Light rotation angle in degrees around Y axis."}
    ]

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Preview area (60% width)
        PreviewArea {
            id: previewArea
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width * 0.6
            properties: root.properties

            // Dark background to show chrome reflections better
            Rectangle {
                anchors.centerIn: parent
                width: 420
                height: 420
                radius: 210
                color: "#1a1a1a"

                Bezel3D {
                    id: bezel3D
                    anchors.centerIn: parent
                    width: 400
                    height: 400
                }
            }

            // Performance overlay for 3D components
            PerformanceOverlay {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
            }
        }

        // Property panel (40% width)
        PropertyPanel {
            id: propertyPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 300

            target: bezel3D
            properties: root.properties
            stateServer: root.stateServer
        }
    }
}
