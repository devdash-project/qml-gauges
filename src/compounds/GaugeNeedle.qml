import QtQuick
import DevDash.Gauges.Primitives

/**
 * @brief Unified gauge needle compound component.
 *
 * GaugeNeedle composes four sub-primitives (NeedleFrontBody, NeedleHeadTip,
 * NeedleRearBody, NeedleTailTip) into a complete, configurable needle.
 *
 * Architecture:
 * @code
 *          [HeadTip]         ← Decorative tip (pointed, arrow, rounded, flat, diamond)
 *              │
 *          [FrontBody]       ← Main shaft extending forward from pivot
 *              │
 *         ═══════════        ← PIVOT POINT (center)
 *              │
 *          [RearBody]        ← Main shaft extending backward from pivot
 *              │
 *          [TailTip]         ← Decorative tip (crescent, counterweight, wedge)
 * @endcode
 *
 * Each section can have independent colors, gradients, and styling.
 * All parts rotate together as one unit around the pivot point.
 *
 * @example
 * @code
 * GaugeNeedle {
 *     angle: 45
 *     frontLength: 100
 *     frontColor: "#ff6600"
 *     headTipShape: "pointed"
 *     rearRatio: 0.25
 *     rearColor: "#333333"
 *     tailTipShape: "crescent"
 * }
 * @endcode
 */
Item {
    id: root

    // === Rotation ===

    /**
     * @brief Current needle rotation angle in degrees.
     * 0 degrees = 12 o'clock position (pointing up).
     * @default 0
     */
    property real angle: 0

    // === Front Body Configuration ===

    /**
     * @brief Front body shape style.
     * Supported: "tapered", "straight", "convex", "concave"
     * @default "tapered"
     */
    property string frontShape: "tapered"

    /**
     * @brief Length of front body from pivot to head tip (pixels).
     * @default 100
     */
    property real frontLength: 100

    /**
     * @brief Width of needle at pivot point (pixels).
     * This is where front and rear bodies meet.
     * @default 10
     */
    property real pivotWidth: 10

    /**
     * @brief Width of front body at tip end (pixels).
     * This is where NeedleHeadTip attaches.
     * @default 4
     */
    property real frontTipWidth: 4

    /**
     * @brief Front body fill color.
     * @default "#ff6600" (orange)
     */
    property color frontColor: "#ff6600"

    /**
     * @brief Enable gradient shading on front body.
     * @default false
     */
    property bool frontGradient: false

    /**
     * @brief Front body border width (pixels).
     * @default 0
     */
    property real frontBorderWidth: 0

    /**
     * @brief Front body border color.
     * @default "transparent"
     */
    property color frontBorderColor: "transparent"

    // === Head Tip Configuration ===

    /**
     * @brief Head tip shape style.
     * Supported: "none", "pointed", "arrow", "rounded", "flat", "diamond"
     * @default "pointed"
     */
    property string headTipShape: "pointed"

    /**
     * @brief Head tip length (pixels).
     * Set to 0 for auto-calculation based on frontTipWidth.
     * @default 0 (auto)
     */
    property real headTipLength: 0

    /**
     * @brief Head tip fill color.
     * @default frontColor
     */
    property color headTipColor: frontColor

    /**
     * @brief Enable gradient shading on head tip.
     * @default false
     */
    property bool headTipGradient: false

    /**
     * @brief Head tip border width (pixels).
     * @default 0
     */
    property real headTipBorderWidth: 0

    /**
     * @brief Head tip border color.
     * @default "transparent"
     */
    property color headTipBorderColor: "transparent"

    /**
     * @brief Auto-align head tip base width to match front body's end width.
     * When true, the tip baseWidth matches the body's actual end width based on shape.
     * When false, uses frontTipWidth regardless of body shape.
     * @default false
     */
    property bool headTipAutoAlign: false

    // === Rear Body Configuration ===

    /**
     * @brief Rear body shape style.
     * Supported: "tapered", "straight", "convex", "concave"
     * @default "tapered"
     */
    property string rearShape: "tapered"

    /**
     * @brief Rear body length as ratio of front body length (0.0-1.0).
     * Set to 0 for no rear body.
     * @default 0.0
     */
    property real rearRatio: 0.0

    /**
     * @brief Width of rear body at tail end (pixels).
     * This is where NeedleTailTip attaches.
     * @default 4
     */
    property real rearTipWidth: 4

    /**
     * @brief Rear body fill color.
     * Can be different from frontColor.
     * @default frontColor
     */
    property color rearColor: frontColor

    /**
     * @brief Enable gradient shading on rear body.
     * @default false
     */
    property bool rearGradient: false

    /**
     * @brief Rear body border width (pixels).
     * @default 0
     */
    property real rearBorderWidth: 0

    /**
     * @brief Rear body border color.
     * @default "transparent"
     */
    property color rearBorderColor: "transparent"

    // === Tail Tip Configuration ===

    /**
     * @brief Tail tip shape style.
     * Supported: "none", "tapered", "crescent", "counterweight", "wedge", "flat"
     * @default "none"
     */
    property string tailTipShape: "none"

    /**
     * @brief Tail tip length (pixels).
     * Set to 0 for auto-calculation based on rearTipWidth.
     * @default 0 (auto)
     */
    property real tailTipLength: 0

    /**
     * @brief Tail tip fill color.
     * @default rearColor
     */
    property color tailTipColor: rearColor

    /**
     * @brief Enable gradient shading on tail tip.
     * @default false
     */
    property bool tailTipGradient: false

    /**
     * @brief Curve amount for crescent tail tip (0.0-1.0).
     * @default 0.5
     */
    property real tailTipCurveAmount: 0.5

    /**
     * @brief Tail tip border width (pixels).
     * @default 0
     */
    property real tailTipBorderWidth: 0

    /**
     * @brief Tail tip border color.
     * @default "transparent"
     */
    property color tailTipBorderColor: "transparent"

    /**
     * @brief Auto-align tail tip base width to match rear body's end width.
     * When true, the tip baseWidth matches the body's actual end width based on shape.
     * When false, uses rearTipWidth regardless of body shape.
     * @default false
     */
    property bool tailTipAutoAlign: false

    // === Shadow Effect ===

    /**
     * @brief Enable drop shadow effect.
     * @default false
     */
    property bool hasShadow: false

    /**
     * @brief Shadow color.
     * @default Qt.rgba(0, 0, 0, 0.5)
     */
    property color shadowColor: Qt.rgba(0, 0, 0, 0.5)

    /**
     * @brief Shadow offset in pixels.
     * @default 2
     */
    property real shadowOffset: 2

    // === Animation ===

    /**
     * @brief Enable spring animation for needle movement.
     * @default true
     */
    property bool animated: true

    /**
     * @brief Spring stiffness (higher = faster response).
     * @default 3.5
     */
    property real spring: 3.5

    /**
     * @brief Spring damping (higher = less oscillation).
     * @default 0.25
     */
    property real damping: 0.25

    /**
     * @brief Spring mass (affects momentum).
     * @default 1.0
     */
    property real mass: 1.0

    /**
     * @brief Animation epsilon (minimum movement threshold).
     * @default 0.25
     */
    property real epsilon: 0.25

    // === Advanced ===

    /**
     * @brief Enable antialiasing on all shapes.
     * @default true
     */
    property bool antialiasing: true

    /**
     * @brief Overall needle opacity.
     * @default 1.0
     */
    property real needleOpacity: 1.0

    // === Internal Computed Properties ===

    // Actual rear length computed from ratio
    readonly property real rearLength: frontLength * rearRatio

    // Computed body end widths based on shape type
    // "straight" bodies maintain pivotWidth throughout, all others taper to tipWidth
    readonly property real frontBodyEndWidth: frontShape === "straight" ? pivotWidth : frontTipWidth
    readonly property real rearBodyEndWidth: rearShape === "straight" ? pivotWidth : rearTipWidth

    // Total needle length (for sizing)
    readonly property real totalLength: frontLength + headTip.actualLength + rearLength + tailTip.actualLength

    // Pivot point coordinates
    readonly property real pivotX: width / 2
    readonly property real pivotY: height / 2

    // === Size ===

    implicitWidth: Math.max(pivotWidth, rearTipWidth, headTip.implicitWidth, tailTip.implicitWidth) + (hasShadow ? shadowOffset * 2 : 0)
    implicitHeight: totalLength + (hasShadow ? shadowOffset * 2 : 0)

    // === Shadow Layer ===

    Loader {
        active: root.hasShadow
        anchors.fill: parent

        sourceComponent: Item {
            opacity: 0.5

            transform: [
                Translate {
                    x: root.shadowOffset
                    y: root.shadowOffset
                },
                Rotation {
                    origin.x: root.pivotX
                    origin.y: root.pivotY
                    angle: rotationTransform.angle
                }
            ]

            // Shadow copies of each component
            NeedleFrontBody {
                x: root.pivotX - implicitWidth / 2
                y: root.pivotY - root.frontLength
                length: root.frontLength
                pivotWidth: root.pivotWidth
                tipWidth: root.frontTipWidth
                shape: root.frontShape
                color: root.shadowColor
                hasGradient: false
                antialiasing: root.antialiasing
            }

            NeedleHeadTip {
                x: root.pivotX - implicitWidth / 2
                y: root.pivotY - root.frontLength - actualLength
                shape: root.headTipShape
                baseWidth: root.headTipAutoAlign ? root.frontBodyEndWidth : root.frontTipWidth
                length: root.headTipLength
                color: root.shadowColor
                hasGradient: false
                antialiasing: root.antialiasing
            }

            NeedleRearBody {
                visible: root.rearRatio > 0
                x: root.pivotX - implicitWidth / 2
                y: root.pivotY - 1
                length: root.rearLength + 1
                pivotWidth: root.pivotWidth
                tipWidth: root.rearTipWidth
                shape: root.rearShape
                color: root.shadowColor
                hasGradient: false
                antialiasing: root.antialiasing
            }

            NeedleTailTip {
                visible: root.rearRatio > 0 && root.tailTipShape !== "none"
                x: root.pivotX - implicitWidth / 2
                y: root.pivotY + root.rearLength
                shape: root.tailTipShape
                baseWidth: root.tailTipAutoAlign ? root.rearBodyEndWidth : root.rearTipWidth
                length: root.tailTipLength
                curveAmount: root.tailTipCurveAmount
                color: root.shadowColor
                hasGradient: false
                antialiasing: root.antialiasing
            }
        }
    }

    // === Main Needle Container ===

    Item {
        id: needleContainer
        anchors.fill: parent
        opacity: root.needleOpacity

        transform: Rotation {
            id: rotationTransform
            origin.x: root.pivotX
            origin.y: root.pivotY
            angle: root.angle

            Behavior on angle {
                enabled: root.animated
                SpringAnimation {
                    spring: root.spring
                    damping: root.damping
                    mass: root.mass
                    epsilon: root.epsilon
                }
            }
        }

        // Front Body (extends upward from pivot)
        NeedleFrontBody {
            id: frontBody
            x: root.pivotX - implicitWidth / 2
            y: root.pivotY - root.frontLength
            length: root.frontLength
            pivotWidth: root.pivotWidth
            tipWidth: root.frontTipWidth
            shape: root.frontShape
            color: root.frontColor
            hasGradient: root.frontGradient
            gradientHighlight: Qt.lighter(root.frontColor, 1.3)
            gradientShadow: Qt.darker(root.frontColor, 1.3)
            borderWidth: root.frontBorderWidth
            borderColor: root.frontBorderColor
            antialiasing: root.antialiasing
        }

        // Head Tip (at end of front body)
        NeedleHeadTip {
            id: headTip
            x: root.pivotX - implicitWidth / 2
            y: root.pivotY - root.frontLength - actualLength
            shape: root.headTipShape
            baseWidth: root.headTipAutoAlign ? root.frontBodyEndWidth : root.frontTipWidth
            length: root.headTipLength
            color: root.headTipColor
            hasGradient: root.headTipGradient
            gradientHighlight: Qt.lighter(root.headTipColor, 1.3)
            gradientShadow: Qt.darker(root.headTipColor, 1.3)
            borderWidth: root.headTipBorderWidth
            borderColor: root.headTipBorderColor
            antialiasing: root.antialiasing
        }

        // Rear Body (extends downward from pivot)
        // Overlap by 1px to eliminate seam between front and rear bodies
        NeedleRearBody {
            id: rearBody
            visible: root.rearRatio > 0
            x: root.pivotX - implicitWidth / 2
            y: root.pivotY - 1
            length: root.rearLength + 1
            pivotWidth: root.pivotWidth
            tipWidth: root.rearTipWidth
            shape: root.rearShape
            color: root.rearColor
            hasGradient: root.rearGradient
            gradientHighlight: Qt.lighter(root.rearColor, 1.3)
            gradientShadow: Qt.darker(root.rearColor, 1.3)
            borderWidth: root.rearBorderWidth
            borderColor: root.rearBorderColor
            antialiasing: root.antialiasing
        }

        // Tail Tip (at end of rear body)
        NeedleTailTip {
            id: tailTip
            visible: root.rearRatio > 0 && root.tailTipShape !== "none"
            x: root.pivotX - implicitWidth / 2
            y: root.pivotY + root.rearLength
            shape: root.tailTipShape
            baseWidth: root.tailTipAutoAlign ? root.rearBodyEndWidth : root.rearTipWidth
            length: root.tailTipLength
            curveAmount: root.tailTipCurveAmount
            color: root.tailTipColor
            hasGradient: root.tailTipGradient
            gradientHighlight: Qt.lighter(root.tailTipColor, 1.3)
            gradientShadow: Qt.darker(root.tailTipColor, 1.3)
            borderWidth: root.tailTipBorderWidth
            borderColor: root.tailTipBorderColor
            antialiasing: root.antialiasing
        }
    }
}
