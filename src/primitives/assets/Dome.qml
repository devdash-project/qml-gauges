import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    PrincipledMaterial {
        id: defaultMaterial_material
        objectName: "DefaultMaterial"
        baseColor: "#ff999999"
        indexOfRefraction: 1
    }

    // Nodes:
    Node {
        id: dome_obj
        objectName: "dome.obj"
        Model {
            id: dome
            objectName: "Dome"
            source: "qrc:/DevDash/Gauges/Primitives/assets/meshes/dome_mesh.mesh"
            materials: [
                defaultMaterial_material
            ]
        }
    }

    // Animations:
}
