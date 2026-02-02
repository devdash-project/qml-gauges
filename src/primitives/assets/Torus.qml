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
        id: torus_obj
        objectName: "torus.obj"
        Model {
            id: torus
            objectName: "Torus"
            source: "qrc:/DevDash/Gauges/Primitives/assets/meshes/torus_mesh.mesh"
            materials: [
                defaultMaterial_material
            ]
        }
    }

    // Animations:
}
