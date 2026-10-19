import QtQuick
import QtQuick.Layouts
import "../../../"

Item {
    id: root
    anchors.fill: parent

    property real minWidth: 160
    property real minHeight: 80
    property real maxWidth: 1600
    property real maxHeight: 800
    property real minAspect: 1.2
    property real maxAspect: 4.0
    property bool isRound: false

    property var currentTime: (typeof DateTime !== "undefined" && DateTime.now) ? DateTime.now : new Date()
    property string timeFormat: {
        if (typeof Config !== "undefined" && Config.rawSettings && Config.rawSettings.bar && Config.rawSettings.bar.time && Config.rawSettings.bar.time.format !== undefined) {
            return Config.rawSettings.bar.time.format;
        }
        return "HH:mm:ss";
    }
    readonly property bool is12h: root.timeFormat.includes("h") || root.timeFormat.toLowerCase().includes("ap")
    readonly property string hourFmt: root.is12h ? (root.timeFormat.includes("hh") ? "hh" : "h") : (root.timeFormat.includes("H") && !root.timeFormat.includes("HH") ? "H" : "HH")
    readonly property string hoursText: Qt.formatDateTime(root.currentTime, root.hourFmt)
    readonly property string minutesText: Qt.formatDateTime(root.currentTime, "mm")
    readonly property string meridiemText: root.is12h ? Qt.formatDateTime(root.currentTime, "AP") : ""
    readonly property string dateText: Qt.formatDateTime(root.currentTime, "dddd, d MMMM").toUpperCase()

    Connections {
        target: typeof DateTime !== "undefined" ? DateTime : null
        function onNowChanged() {
            root.currentTime = DateTime.now;
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

    ColumnLayout {
        id: content
        anchors.centerIn: parent
        spacing: Scaler.s(8)
        scale: Math.min(root.width / Math.max(1, implicitWidth), root.height / Math.max(1, implicitHeight))

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Scaler.s(4)

            ShadowText {
                text: root.hoursText
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
                text: root.minutesText
                font.pixelSize: Scaler.s(120)
            }

            ShadowText {
                visible: text !== ""
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: Scaler.s(24)
                text: root.meridiemText
                font.pixelSize: Scaler.s(28)
                font.weight: Font.Bold
                opacity: 0.8
            }
        }

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: root.dateText
            font.pixelSize: Scaler.s(14)
            font.weight: Font.Bold
            font.letterSpacing: 1.4
            opacity: 0.85
        }
    }
}
