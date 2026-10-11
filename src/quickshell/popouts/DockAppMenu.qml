import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../reusables"
import "../singletons/widgetcontrols"
import "../"

PanelWindow {
    id: dockAppMenuWindow

    screen: DockAppMenuController.screen

    WlrLayershell.namespace: "dockappmenu"
    WlrLayershell.layer: WlrLayer.Overlay
    focusable: dockAppMenuWindow.isVisible
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    onIsVisibleChanged: {
        if (isVisible) {
            rootContainer.forceActiveFocus();
        } else {
            openAnim.stop();
            closeAnim.restart();
        }
    }

    mask: Region {
        item: (dockAppMenuWindow.isVisible || menuContainer.animProgress > 0.001) ? maskTarget : null
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function s(val) { return (typeof Scaler !== "undefined") ? Scaler.s(val) : val; }

    property bool isVisible: DockAppMenuController.isVisible
    property real targetX: DockAppMenuController.targetX
    property real targetY: DockAppMenuController.targetY
    property string dockPosition: DockAppMenuController.dockPosition
    property var windowsList: DockAppMenuController.windows

    Connections {
        target: DockAppMenuController
        function onMenuTriggered() {
            rootContainer.forceActiveFocus();
            closeAnim.stop();
            openAnim.stop();
            menuContainer.animProgress = 0.0;
            openAnim.restart();
        }
    }

    property real cornerRadius: {
        return (typeof ThemeBackend !== "undefined" && ThemeBackend.borderRadius !== undefined && ThemeBackend.borderRadius !== null)
            ? ThemeBackend.borderRadius
            : s(12);
    }

    property color menuBackgroundColor: {
        if (typeof ThemeBackend !== "undefined" && ThemeBackend.base) {
            return ThemeBackend.base;
        }
        return "#1e1e2e";
    }

    property color buttonColor: {
        if (typeof ThemeBackend !== "undefined" && ThemeBackend.surface0) {
            return ThemeBackend.surface0;
        }
        return "#313244";
    }

    property color primaryButtonColor: {
        if (typeof ThemeBackend !== "undefined" && ThemeBackend.primary) {
            return ThemeBackend.primary;
        }
        if (typeof ThemeBackend !== "undefined" && ThemeBackend.mauve) {
            return ThemeBackend.mauve;
        }
        return "#cba6f7";
    }

    property real menuWidth: s(240)
    property real menuHeight: contentCol.implicitHeight
    property real menuOffset: s(10)

    property real dockButtonSize: {
        if (typeof Config !== "undefined" && Config.rawSettings && Config.rawSettings.dock && Config.rawSettings.dock.elementSize) {
            return s(Config.rawSettings.dock.elementSize);
        }
        return s(44);
    }

    property real computedTargetX: {
        let w = menuWidth;
        let halfBtn = dockButtonSize / 2;
        if (dockPosition === "left") {
            return targetX + halfBtn + menuOffset;
        } else if (dockPosition === "right") {
            return targetX - halfBtn - w - menuOffset;
        } else {
            return targetX - (w / 2);
        }
    }

    property real computedTargetY: {
        let h = menuHeight;
        let halfBtn = dockButtonSize / 2;
        if (dockPosition === "top") {
            return targetY + halfBtn + menuOffset;
        } else if (dockPosition === "bottom") {
            return targetY - halfBtn - h - menuOffset;
        } else {
            return targetY - (h / 2);
        }
    }

    property real clampedX: {
        let margin = s(8);
        return Math.max(margin, Math.min(dockAppMenuWindow.width - menuWidth - margin, computedTargetX));
    }

    property real clampedY: {
        let margin = s(8);
        return Math.max(margin, Math.min(dockAppMenuWindow.height - menuHeight - margin, computedTargetY));
    }

    visible: isVisible || menuContainer.animProgress > 0.001

    Item {
        id: rootContainer
        anchors.fill: parent
        focus: dockAppMenuWindow.isVisible
        Keys.onEscapePressed: DockAppMenuController.hide()

        onActiveFocusChanged: {
            if (!activeFocus && dockAppMenuWindow.isVisible && menuContainer.animProgress > 0.5) {
                DockAppMenuController.hide();
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: DockAppMenuController.hide()
        }

        Item {
            id: maskTarget
            x: dockAppMenuWindow.clampedX
            y: dockAppMenuWindow.clampedY
            width: dockAppMenuWindow.menuWidth
            height: dockAppMenuWindow.menuHeight
        }

        Item {
            id: menuContainer

            property real animProgress: 0.0

            NumberAnimation {
                id: openAnim
                target: menuContainer
                property: "animProgress"
                from: 0.0
                to: 1.0
                duration: 90
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                id: closeAnim
                target: menuContainer
                property: "animProgress"
                from: 1.0
                to: 0.0
                duration: 60
                easing.type: Easing.InQuad
                onFinished: {
                    if (!dockAppMenuWindow.isVisible) {
                        menuContainer.animProgress = 0.0;
                    }
                }
            }

            x: dockAppMenuWindow.clampedX
            y: dockAppMenuWindow.clampedY
            width: dockAppMenuWindow.menuWidth
            height: dockAppMenuWindow.menuHeight

            opacity: 0.75 + (0.25 * animProgress)

            transform: Scale {
                origin.x: Math.max(0, Math.min(menuContainer.width, dockAppMenuWindow.targetX - dockAppMenuWindow.clampedX))
                origin.y: Math.max(0, Math.min(menuContainer.height, dockAppMenuWindow.targetY - dockAppMenuWindow.clampedY))
                xScale: 0.92 + (0.08 * menuContainer.animProgress)
                yScale: 0.92 + (0.08 * menuContainer.animProgress)
            }

            Column {
                id: contentCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: dockAppMenuWindow.s(4)

                Rectangle {
                    id: headerBox
                    width: parent.width
                    height: headerRow.implicitHeight + dockAppMenuWindow.s(10)
                    color: dockAppMenuWindow.menuBackgroundColor
                    radius: dockAppMenuWindow.cornerRadius
                    clip: true

                    RowLayout {
                        id: headerRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: dockAppMenuWindow.s(10)
                        anchors.rightMargin: dockAppMenuWindow.s(10)
                        spacing: dockAppMenuWindow.s(8)

                        Image {
                            Layout.preferredWidth: dockAppMenuWindow.s(22)
                            Layout.preferredHeight: dockAppMenuWindow.s(22)
                            source: DockAppMenuController.appIcon ? (DockAppMenuController.appIcon.indexOf("/") !== -1 || DockAppMenuController.appIcon.startsWith("image://") ? DockAppMenuController.appIcon : ("image://icon/" + DockAppMenuController.appIcon)) : ""
                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                            visible: status === Image.Ready
                        }

                        Text {
                            Layout.fillWidth: true
                            text: DockAppMenuController.appName || DockAppMenuController.desktopId
                            color: ThemeBackend.text
                            font.pixelSize: dockAppMenuWindow.s(13)
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            visible: dockAppMenuWindow.windowsList && dockAppMenuWindow.windowsList.length > 0
                            Layout.preferredWidth: badgeText.implicitWidth + dockAppMenuWindow.s(10)
                            Layout.preferredHeight: dockAppMenuWindow.s(18)
                            radius: height / 2
                            color: dockAppMenuWindow.buttonColor

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: String(dockAppMenuWindow.windowsList ? dockAppMenuWindow.windowsList.length : 0)
                                color: ThemeBackend.subtext0
                                font.pixelSize: dockAppMenuWindow.s(10)
                                font.weight: Font.Bold
                            }
                        }
                    }
                }

                Rectangle {
                    id: windowsBox
                    visible: dockAppMenuWindow.windowsList && dockAppMenuWindow.windowsList.length > 0
                    width: parent.width
                    height: windowsCol.implicitHeight + dockAppMenuWindow.s(8)
                    color: dockAppMenuWindow.menuBackgroundColor
                    radius: dockAppMenuWindow.cornerRadius
                    clip: true

                    Column {
                        id: windowsCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: dockAppMenuWindow.s(4)
                        spacing: dockAppMenuWindow.s(2)

                        Repeater {
                            model: dockAppMenuWindow.windowsList

                            delegate: Item {
                                width: parent.width
                                height: dockAppMenuWindow.s(30)

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: dockAppMenuWindow.s(2)

                                    ClickButton {
                                        Layout.fillWidth: true
                                        height: parent.height
                                        cornerRadius: dockAppMenuWindow.s(7)
                                        contentAlignment: Qt.AlignLeft
                                        horizontalPadding: dockAppMenuWindow.s(8)
                                        buttonIcon: "󰖲"
                                        iconFontSize: dockAppMenuWindow.s(13)
                                        textFontSize: dockAppMenuWindow.s(11)
                                        buttonText: {
                                            let t = modelData.title || I18n.t("guide.dock.window_menu.untitled", "Untitled");
                                            let ws = (modelData.workspaceLabel !== undefined && modelData.workspaceLabel !== "") ? (" [" + modelData.workspaceLabel + "]") : "";
                                            return (t.length > 22 ? (t.substring(0, 20) + "…") : t) + ws;
                                        }
                                        accentColor: modelData.focused ? dockAppMenuWindow.primaryButtonColor : dockAppMenuWindow.buttonColor
                                        textColor: modelData.focused ? ThemeBackend.crust : ThemeBackend.text
                                        onClicked: {
                                            WindowTracker.focus(modelData);
                                            DockAppMenuController.hide();
                                        }
                                    }

                                    IconButton {
                                        width: dockAppMenuWindow.s(28)
                                        height: parent.height
                                        size: height
                                        cornerRadius: dockAppMenuWindow.s(7)
                                        accentColor: dockAppMenuWindow.buttonColor
                                        textColor: ThemeBackend.red
                                        buttonIcon: "󰅖"
                                        iconFontSize: dockAppMenuWindow.s(13)
                                        onClicked: {
                                            WindowTracker.close(modelData);
                                            DockAppMenuController.hide();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: actionsBox
                    width: parent.width
                    height: actionsCol.implicitHeight + dockAppMenuWindow.s(8)
                    color: dockAppMenuWindow.menuBackgroundColor
                    radius: dockAppMenuWindow.cornerRadius
                    clip: true

                    Column {
                        id: actionsCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: dockAppMenuWindow.s(4)
                        spacing: dockAppMenuWindow.s(2)

                        ClickButton {
                            width: parent.width
                            height: dockAppMenuWindow.s(29)
                            cornerRadius: dockAppMenuWindow.s(8)
                            contentAlignment: Qt.AlignLeft
                            horizontalPadding: dockAppMenuWindow.s(8)
                            buttonIcon: "󰐕"
                            iconFontSize: dockAppMenuWindow.s(14)
                            textFontSize: dockAppMenuWindow.s(11)
                            buttonText: I18n.t("guide.dock.window_menu.new_window", "New window")
                            accentColor: dockAppMenuWindow.buttonColor
                            textColor: ThemeBackend.text
                            onClicked: {
                                if (typeof DesktopEntries !== "undefined" && DockAppMenuController.desktopId) {
                                    let entry = DesktopEntries.byId(DockAppMenuController.desktopId);
                                    if (entry) entry.execute();
                                }
                                DockAppMenuController.hide();
                            }
                        }

                        ClickButton {
                            width: parent.width
                            height: dockAppMenuWindow.s(29)
                            cornerRadius: dockAppMenuWindow.s(8)
                            contentAlignment: Qt.AlignLeft
                            horizontalPadding: dockAppMenuWindow.s(8)
                            buttonIcon: DockAppMenuController.isPinned ? "󰤰" : "󰤱"
                            iconFontSize: dockAppMenuWindow.s(14)
                            textFontSize: dockAppMenuWindow.s(11)
                            buttonText: DockAppMenuController.isPinned ? I18n.t("guide.dock.window_menu.unpin", "Unpin from dock") : I18n.t("guide.dock.window_menu.pin", "Pin to dock")
                            accentColor: dockAppMenuWindow.buttonColor
                            textColor: ThemeBackend.text
                            onClicked: {
                                if (DockAppMenuController.isPinned) {
                                    DockAppMenuController.unpinApp(DockAppMenuController.desktopId);
                                } else {
                                    DockAppMenuController.pinApp(DockAppMenuController.desktopId, DockAppMenuController.appName, DockAppMenuController.appIcon);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
