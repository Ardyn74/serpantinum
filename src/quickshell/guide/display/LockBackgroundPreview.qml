import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../../"
import "../../lock"
import "../../reusables"

Item {
    id: preview
    required property var tab
    readonly property var rootObj: tab.rootObj
    readonly property bool following: tab.currentBackgroundMode === "follow"
    readonly property string shownPath: tab.effectiveBackgroundPath
    readonly property bool shownIsVideo: tab.effectiveBackgroundIsVideo
    readonly property bool customVideo: !preview.following && tab.customBackgroundActive && preview.shownIsVideo

    Layout.alignment: Qt.AlignHCenter
    Layout.fillWidth: true
    Layout.preferredHeight: rootObj.s(220)
    Layout.topMargin: rootObj.s(6)
    Layout.bottomMargin: rootObj.s(4)

    ImagePicker {
        id: backgroundPicker
        rootObj: preview.rootObj
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg", "*.gif", "*.mp4", "*.mkv", "*.mov", "*.webm"]
        onImageSelected: function(filePath, fileName) {
            preview.tab.setCustomBackground(filePath);
        }
    }

    Rectangle {
        id: cardMask
        anchors.fill: parent
        radius: ThemeBackend.borderRadius
        color: "black"
        visible: false
        layer.enabled: true
    }

    Item {
        id: cardContent
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            color: ThemeBackend.surface0
        }

        Image {
            anchors.fill: parent
            visible: !preview.customVideo && source !== ""
            source: {
                if (preview.shownIsVideo) return "file://" + Caching.getCacheDir("wallpaper") + "/current_wallpaper.png?rev=" + preview.tab.currentBackgroundMode;
                return preview.shownPath !== "" ? "file://" + preview.shownPath : "";
            }
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            mipmap: true
            cache: false
        }

        Loader {
            anchors.fill: parent
            active: preview.customVideo
            sourceComponent: VideoLock {
                wallpaperPath: preview.shownPath
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: rootObj.s(64)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.25; color: Qt.rgba(0, 0, 0, 0.35) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.8) }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(ThemeBackend.crust.r, ThemeBackend.crust.g, ThemeBackend.crust.b, 0.6)
            opacity: preview.following ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: cardContent
        maskEnabled: true
        maskSource: cardMask
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: rootObj.s(6)
        opacity: preview.following ? 1.0 : 0.0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "󰸉"
            font.family: ThemeBackend.iconFont
            font.pixelSize: rootObj.s(28)
            color: ThemeBackend.text
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: I18n.t("guide.display.lockscreen.background.follows_hint", "Follows wallpaper")
            font.family: ThemeBackend.fontFamily
            font.pixelSize: rootObj.s(14)
            font.weight: Font.Bold
            color: ThemeBackend.text
        }
    }

    IconButton {
        visible: preview.shownIsVideo && preview.following
        anchors.centerIn: parent
        anchors.verticalCenterOffset: rootObj.s(44)
        size: rootObj.s(36)
        cornerRadius: rootObj.s(12)
        iconFontSize: rootObj.s(16)
        buttonIcon: "󰐊"
        accentColor: ThemeBackend.surface0
        textColor: ThemeBackend.text
        enabled: false
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: rootObj.s(12)
        spacing: rootObj.s(12)

        ClickButton {
            Layout.preferredHeight: rootObj.s(32)
            cornerRadius: ThemeBackend.borderRadius
            horizontalPadding: rootObj.s(14)
            buttonIcon: "󰸉"
            iconFontSize: rootObj.s(15)
            buttonText: I18n.t("guide.display.lockscreen.background.select", "Select background")
            textFontSize: rootObj.s(11)
            accentColor: ThemeBackend.mauve
            textColor: ThemeBackend.base
            contentAlignment: Qt.AlignHCenter
            enabled: !preview.following
            opacity: preview.following ? 0.45 : 1.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            onClicked: backgroundPicker.openPicker(preview.tab.currentCustomBackground, false)
        }

        Switch {
            Layout.preferredHeight: rootObj.s(32)
            Layout.preferredWidth: rootObj.s(220)
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface0
            textColor: ThemeBackend.text
            activeTextColor: ThemeBackend.crust
            cornerRadius: ThemeBackend.borderRadius
            fontPixelSize: rootObj.s(11)
            options: [
                I18n.t("guide.display.lockscreen.background.follow", "Follow wallpaper"),
                I18n.t("guide.display.lockscreen.background.custom", "Custom")
            ]
            currentIndex: preview.following ? 0 : 1
            onToggled: (idx) => preview.tab.setBackgroundMode(idx === 0 ? "follow" : "custom")
        }

        Item { Layout.fillWidth: true }

        ColumnLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: rootObj.s(1)

            Text {
                text: preview.shownPath === "" ? I18n.t("guide.display.lockscreen.background.none", "No background selected") : (preview.shownPath.split("/").pop() || preview.shownPath)
                font.family: ThemeBackend.fontFamily
                font.pixelSize: rootObj.s(12)
                font.weight: Font.Bold
                color: "#ffffff"
                Layout.alignment: Qt.AlignRight
                elide: Text.ElideLeft
                Layout.maximumWidth: rootObj.s(320)
            }

            Text {
                text: preview.shownPath.replace(Quickshell.env("HOME"), "~")
                font.family: ThemeBackend.fontFamily
                font.pixelSize: rootObj.s(10)
                color: Qt.rgba(1, 1, 1, 0.75)
                Layout.alignment: Qt.AlignRight
                elide: Text.ElideLeft
                Layout.maximumWidth: rootObj.s(320)
                visible: text !== ""
            }
        }
    }
}
