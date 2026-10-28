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
    property real minAspect: 0.8
    property real maxAspect: 2.8
    property bool isRound: false

    readonly property bool isStacked: (width / height) < 1.25
    readonly property color hourColor: ThemeBackend.mauve
    readonly property color minuteColor: ThemeBackend.text
    readonly property color dateColor: ThemeBackend.subtext0
    readonly property string stackedDateText: root.meridiemText !== "" ? root.meridiemText + "  ·  " + root.dateText : root.dateText

    property var currentTime: (typeof DateTime !== "undefined" && DateTime.now) ? DateTime.now : new Date()
    property string timeFormat: {
        if (typeof DateTime !== "undefined" && DateTime.timeFormat !== undefined && DateTime.timeFormat !== "") {
            return DateTime.timeFormat;
        }
        if (typeof Config !== "undefined" && Config.rawSettings && Config.rawSettings.bar && Config.rawSettings.bar.time && Config.rawSettings.bar.time.format !== undefined) {
            return Config.rawSettings.bar.time.format;
        }
        return "hh:mm AP";
    }
    readonly property bool is12h: {
        if (typeof DateTime !== "undefined" && DateTime.is12Hour !== undefined) {
            return DateTime.is12Hour;
        }
        return root.timeFormat.indexOf("AP") !== -1 || root.timeFormat.indexOf("ap") !== -1 || root.timeFormat.indexOf("a") !== -1 || root.timeFormat.indexOf("A") !== -1 || root.timeFormat.indexOf("h") !== -1;
    }
    readonly property string hourFmt: (root.timeFormat.indexOf("h") !== -1 && root.timeFormat.indexOf("hh") === -1) || root.timeFormat === "H:mm" || root.timeFormat === "H:mm:ss" ? "h" : "hh"
    readonly property string hoursText: {
        let d = root.currentTime;
        let h = d.getHours();
        if (root.is12h) {
            let h12 = h % 12 || 12;
            return (root.hourFmt === "h") ? String(h12) : String(h12).padStart(2, "0");
        } else {
            return (root.hourFmt === "h") ? String(h) : String(h).padStart(2, "0");
        }
    }
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
        font.weight: Font.Bold

        Text {
            anchors.fill: parent
            anchors.topMargin: Scaler.s(3)
            anchors.bottomMargin: -Scaler.s(3)
            font.family: parent.font.family
            font.pixelSize: parent.font.pixelSize
            font.weight: parent.font.weight
            font.letterSpacing: parent.font.letterSpacing
            color: Qt.rgba(0, 0, 0, 0.32)
            text: parent.text
            z: -1
        }
    }

    ColumnLayout {
        visible: root.isStacked
        anchors.centerIn: parent
        spacing: Scaler.s(8)
        scale: Math.min(root.width / Math.max(1, implicitWidth), root.height / Math.max(1, implicitHeight))

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: -Scaler.s(28)
            text: root.hoursText
            color: root.hourColor
            font.pixelSize: Scaler.s(150)
        }

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: root.minutesText
            color: root.minuteColor
            font.pixelSize: Scaler.s(150)
        }

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: root.stackedDateText
            color: root.dateColor
            font.pixelSize: Scaler.s(16)
            font.weight: Font.Medium
            font.letterSpacing: 1.4
        }
    }

    ColumnLayout {
        visible: !root.isStacked
        anchors.centerIn: parent
        spacing: Scaler.s(8)
        scale: Math.min(root.width / Math.max(1, implicitWidth), root.height / Math.max(1, implicitHeight))

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Scaler.s(4)

            ShadowText {
                text: root.hoursText
                color: root.hourColor
                font.pixelSize: Scaler.s(120)
            }

            ShadowText {
                Layout.alignment: Qt.AlignVCenter
                text: ":"
                color: root.dateColor
                font.pixelSize: Scaler.s(80)
            }

            ShadowText {
                text: root.minutesText
                color: root.minuteColor
                font.pixelSize: Scaler.s(120)
            }

            ShadowText {
                visible: text !== ""
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: Scaler.s(24)
                text: root.meridiemText
                color: root.dateColor
                font.pixelSize: Scaler.s(28)
            }
        }

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: root.dateText
            color: root.dateColor
            font.pixelSize: Scaler.s(16)
            font.weight: Font.Medium
            font.letterSpacing: 1.4
        }
    }
}
