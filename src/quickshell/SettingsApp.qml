//@ pragma AppId serpantinum-settings
//@ pragma Env SERPANTINUM_STANDALONE=1
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "."
import "guide"

ShellRoot {
    id: app

    readonly property real uiScale: {
        let general = Config.getSetting("general", {});
        let v = general ? Number(general.uiScale) : NaN;
        return (isNaN(v) || v <= 0) ? 1.0 : v;
    }

    Connections {
        target: Quickshell
        function onReloadCompleted() { Quickshell.inhibitReloadPopup() }
        function onReloadFailed(errorString) { Quickshell.inhibitReloadPopup() }
    }

    IpcHandler {
        target: "settings"

        function goto(tab: string, subtab: string): void {
            popup.gotoTab(tab, subtab);
        }

        function close(): void {
            popup.closePopup();
        }

        function ping(): string {
            return "ok";
        }
    }

    property point windowOffset: Qt.point(NaN, NaN)

    function syncWindowOffset() {
        let toplevels = Hyprland.toplevels.values;
        for (let i = 0; i < toplevels.length; i++) {
            let o = toplevels[i].lastIpcObject;
            if (!o || o["class"] !== "serpantinum-settings" || !o.at) continue;
            let monitors = Hyprland.monitors.values;
            for (let j = 0; j < monitors.length; j++) {
                if (monitors[j].id === o.monitor) {
                    app.windowOffset = Qt.point(o.at[0] - monitors[j].x, o.at[1] - monitors[j].y);
                    return;
                }
            }
        }
    }

    Timer {
        interval: 33
        repeat: true
        running: window.visible && ThemeBackend.glassActive && Boolean(Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
        onTriggered: {
            app.syncWindowOffset();
            Hyprland.refreshToplevels();
            Hyprland.refreshMonitors();
        }
    }

    FloatingWindow {
        id: window

        title: I18n.t("widgets.guide.name", "Settings")
        color: "transparent"
        implicitWidth: Math.round(1200 * app.uiScale)
        implicitHeight: Math.round(750 * app.uiScale)
        minimumSize: Qt.size(Math.round(480 * app.uiScale), Math.round(400 * app.uiScale))
        visible: true

        onVisibleChanged: if (!visible) Qt.quit()

        GuidePopup {
            id: popup
            anchors.fill: parent
            standalone: true
            windowOffset: app.windowOffset
            visible: window.visible
            onExitRequested: Qt.quit()
        }
    }
}
