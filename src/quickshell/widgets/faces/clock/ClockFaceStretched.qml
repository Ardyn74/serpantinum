import QtQuick
import QtQuick.Effects
import "../../../reusables"
import "../../../"

Item {
    id: root
    anchors.fill: parent
    clip: true

    property real minWidth: 100
    property real minHeight: 120
    property real maxWidth: 900
    property real maxHeight: 1200
    property real minAspect: 0.3
    property real maxAspect: 2.5
    property bool isRound: false

    readonly property real digitSize: 200
    readonly property real dateHeight: Math.max(14, Math.min(width * 0.09, height * 0.08))
    readonly property real areaTop: dateHeight * 1.9
    readonly property real areaWidth: width * 0.94
    readonly property real areaHeight: Math.max(1, height - areaTop - height * 0.03)
    readonly property real colonRatio: 0.4
    readonly property real maxCondense: 0.62
    readonly property real yScale: areaHeight / Math.max(1, glyphMetrics.tightBoundingRect.height)
    readonly property real digitsWidth: hoursText.implicitWidth + minutesText.implicitWidth
    readonly property real xScale: Math.max(0.01, Math.min(yScale * maxCondense, areaWidth / Math.max(1, digitsWidth + colonRatio * hoursText.implicitWidth)))
    readonly property real colonWidth: colonRatio * hoursText.implicitWidth * xScale
    readonly property real contentWidth: digitsWidth * xScale + colonWidth
    readonly property color digitColor: Qt.alpha(ThemeBackend.text, 0.82)

    FontMetrics {
        id: fontMetrics
        font.family: ThemeBackend.fontFamily
        font.pixelSize: root.digitSize
        font.weight: Font.Black
    }

    TextMetrics {
        id: glyphMetrics
        font: fontMetrics.font
        text: "0"
    }

    component StretchText: Text {
        font: fontMetrics.font
        color: root.digitColor
        y: -(fontMetrics.ascent + glyphMetrics.tightBoundingRect.y) * root.yScale
        transform: Scale {
            xScale: root.xScale
            yScale: root.yScale
        }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: root.dateHeight * 0.4
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(DateTime.now, "ddd d MMM")
        font.family: ThemeBackend.fontFamily
        font.pixelSize: root.dateHeight
        font.weight: Font.DemiBold
        color: ThemeBackend.subtext0
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowVerticalOffset: Scaler.s(1.5)
            shadowBlur: 0.35
            shadowOpacity: 0.45
        }
    }

    Item {
        id: digits
        x: (root.width - root.contentWidth) / 2
        y: root.areaTop
        width: root.contentWidth
        height: root.areaHeight

        layer.enabled: true
        layer.smooth: true
        layer.textureSize: Qt.size(width * 2, height * 2)
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowVerticalOffset: Scaler.s(3)
            shadowBlur: 0.6
            shadowOpacity: 0.55
        }

        StretchText {
            id: hoursText
            x: 0
            text: DateTime.hour
        }

        Item {
            x: hoursText.implicitWidth * root.xScale
            width: root.colonWidth
            height: parent.height

            Repeater {
                model: 2

                Rectangle {
                    width: root.colonWidth * 0.5
                    height: width
                    radius: width / 2
                    color: root.digitColor
                    x: (parent.width - width) / 2
                    y: parent.height * (index === 0 ? 0.34 : 0.66) - height / 2
                }
            }
        }

        StretchText {
            id: minutesText
            x: hoursText.implicitWidth * root.xScale + root.colonWidth
            text: DateTime.minute
        }
    }
}
