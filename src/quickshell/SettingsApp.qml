//@ pragma AppId serpantinum-settings
//@ pragma Env SERPANTINUM_STANDALONE=1
import QtQuick
import Quickshell
import Quickshell.Io
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

    FloatingWindow {
        id: window

        title: I18n.t("widgets.guide.name", "Settings")
        color: ThemeBackend.base
        implicitWidth: Math.round(1200 * app.uiScale)
        implicitHeight: Math.round(750 * app.uiScale)
        minimumSize: Qt.size(Math.round(480 * app.uiScale), Math.round(400 * app.uiScale))
        visible: true

        onVisibleChanged: if (!visible) Qt.quit()

        GuidePopup {
            id: popup
            anchors.fill: parent
            standalone: true
            visible: window.visible
            onExitRequested: Qt.quit()
        }
    }
}
