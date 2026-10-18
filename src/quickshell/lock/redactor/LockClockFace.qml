import QtQuick
import QtQuick.Layouts
import "../../"

Item {
    id: face

    property string variant: "classic"
    property var currentTime: (typeof DateTime !== "undefined" && DateTime.now) ? DateTime.now : new Date()
    property string timeFormat: {
        if (typeof Config !== "undefined" && Config.rawSettings && Config.rawSettings.bar && Config.rawSettings.bar.time && Config.rawSettings.bar.time.format !== undefined) {
            return Config.rawSettings.bar.time.format;
        }
        return "HH:mm:ss";
    }
    readonly property bool is12h: face.timeFormat.includes("h") || face.timeFormat.toLowerCase().includes("ap")
    readonly property string hourFmt: face.is12h ? (face.timeFormat.includes("hh") ? "hh" : "h") : (face.timeFormat.includes("H") && !face.timeFormat.includes("HH") ? "H" : "HH")
    readonly property string hoursText: Qt.formatDateTime(face.currentTime, face.hourFmt)
    readonly property string minutesText: Qt.formatDateTime(face.currentTime, "mm")
    readonly property string meridiemText: face.is12h ? Qt.formatDateTime(face.currentTime, "AP") : ""
    readonly property string dateText: Qt.formatDateTime(face.currentTime, "dddd, d MMMM").toUpperCase()

    implicitWidth: loader.implicitWidth
    implicitHeight: loader.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Connections {
        target: typeof DateTime !== "undefined" ? DateTime : null
        function onNowChanged() {
            face.currentTime = DateTime.now;
        }
    }

    component ShadowText: Text {
        font.family: ThemeBackend.fontFamily
        color: "#ffffff"

        Text {
            anchors.fill: parent
            anchors.topMargin: Scaler.s(1.5)
            anchors.bottomMargin: -Scaler.s(1.5)
            font.family: parent.font.family
            font.pixelSize: parent.font.pixelSize
            font.weight: parent.font.weight
            font.letterSpacing: parent.font.letterSpacing
            color: Qt.rgba(0, 0, 0, 0.16)
            text: parent.text
            z: -1
        }
    }

    Loader {
        id: loader
        sourceComponent: {
            switch (face.variant) {
            case "stacked": return stackedComponent;
            case "compact": return compactComponent;
            case "analog": return analogComponent;
            default: return classicComponent;
            }
        }
    }

    Component {
        id: classicComponent

        ColumnLayout {
            spacing: Scaler.s(8)

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Scaler.s(4)

                ShadowText {
                    text: face.hoursText
                    font.pixelSize: Scaler.s(120)
                }

                ShadowText {
                    Layout.alignment: Qt.AlignVCenter
                    text: ":"
                    font.pixelSize: Scaler.s(80)
                    font.weight: Font.Light
                    opacity: 0.75
                }

                ShadowText {
                    text: face.minutesText
                    font.pixelSize: Scaler.s(120)
                }

                ShadowText {
                    visible: text !== ""
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: Scaler.s(24)
                    text: face.meridiemText
                    font.pixelSize: Scaler.s(28)
                    font.weight: Font.Bold
                    opacity: 0.8
                }
            }

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                text: face.dateText
                font.pixelSize: Scaler.s(14)
                font.weight: Font.Bold
                font.letterSpacing: 1.4
                opacity: 0.85
            }
        }
    }

    Component {
        id: stackedComponent

        ColumnLayout {
            spacing: Scaler.s(-16)

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                text: face.hoursText
                font.pixelSize: Scaler.s(150)
                font.weight: Font.DemiBold
            }

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                text: face.minutesText
                font.pixelSize: Scaler.s(150)
                font.weight: Font.Light
                color: ThemeBackend.mauve
            }

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Scaler.s(20)
                text: face.dateText
                font.pixelSize: Scaler.s(14)
                font.weight: Font.Bold
                font.letterSpacing: 1.4
                opacity: 0.85
            }
        }
    }

    Component {
        id: compactComponent

        ColumnLayout {
            spacing: Scaler.s(4)

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Scaler.s(8)

                ShadowText {
                    text: face.hoursText + ":" + face.minutesText
                    font.pixelSize: Scaler.s(64)
                    font.weight: Font.Medium
                }

                ShadowText {
                    visible: text !== ""
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: Scaler.s(10)
                    text: face.meridiemText
                    font.pixelSize: Scaler.s(18)
                    font.weight: Font.Bold
                    opacity: 0.8
                }
            }

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                text: face.dateText
                font.pixelSize: Scaler.s(12)
                font.weight: Font.Bold
                font.letterSpacing: 1.2
                opacity: 0.85
            }
        }
    }

    Component {
        id: analogComponent

        ColumnLayout {
            id: analogRoot
            spacing: Scaler.s(14)

            readonly property real dial: Scaler.s(240)
            readonly property real hoursAngle: ((face.currentTime.getHours() % 12) + face.currentTime.getMinutes() / 60) * 30
            readonly property real minutesAngle: (face.currentTime.getMinutes() + face.currentTime.getSeconds() / 60) * 6
            readonly property real secondsAngle: face.currentTime.getSeconds() * 6

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: analogRoot.dial
                Layout.preferredHeight: analogRoot.dial

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(0, 0, 0, 0.22)
                    border.width: Scaler.s(2)
                    border.color: Qt.rgba(1, 1, 1, 0.55)
                }

                Repeater {
                    model: 12

                    Rectangle {
                        width: Scaler.s(index % 3 === 0 ? 4 : 2)
                        height: Scaler.s(index % 3 === 0 ? 14 : 8)
                        radius: width / 2
                        color: "#ffffff"
                        opacity: index % 3 === 0 ? 0.9 : 0.55
                        x: analogRoot.dial / 2 - width / 2
                        y: Scaler.s(10)
                        transform: Rotation {
                            origin.x: width / 2
                            origin.y: analogRoot.dial / 2 - Scaler.s(10)
                            angle: index * 30
                        }
                    }
                }

                Rectangle {
                    width: Scaler.s(6)
                    height: analogRoot.dial * 0.26
                    radius: width / 2
                    color: "#ffffff"
                    x: analogRoot.dial / 2 - width / 2
                    y: analogRoot.dial / 2 - height
                    transformOrigin: Item.Bottom
                    rotation: analogRoot.hoursAngle
                }

                Rectangle {
                    width: Scaler.s(4)
                    height: analogRoot.dial * 0.38
                    radius: width / 2
                    color: "#ffffff"
                    x: analogRoot.dial / 2 - width / 2
                    y: analogRoot.dial / 2 - height
                    transformOrigin: Item.Bottom
                    rotation: analogRoot.minutesAngle
                }

                Rectangle {
                    width: Scaler.s(2)
                    height: analogRoot.dial * 0.42
                    radius: width / 2
                    color: ThemeBackend.mauve
                    x: analogRoot.dial / 2 - width / 2
                    y: analogRoot.dial / 2 - height
                    transformOrigin: Item.Bottom
                    rotation: analogRoot.secondsAngle
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: Scaler.s(12)
                    height: width
                    radius: width / 2
                    color: ThemeBackend.mauve
                }
            }

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                text: face.dateText
                font.pixelSize: Scaler.s(14)
                font.weight: Font.Bold
                font.letterSpacing: 1.4
                opacity: 0.85
            }
        }
    }
}
