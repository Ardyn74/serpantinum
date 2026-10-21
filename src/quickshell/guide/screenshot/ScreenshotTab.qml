import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"
import "../../"
import "../../reusables"
import "../../reusables/guide"
import "OcrLanguages.js" as OcrLanguages

GuideTab {
    id: screenshotTabRoot

    readonly property string scriptPath: Caching.serpantinumDir + "/scripts/ocr_langs.sh"

    property bool captureOnRelease: false
    property var languages: []
    property bool online: true
    property bool loaded: false
    property bool failed: false
    property string busyCode: ""
    property string busyAction: ""
    property string search: ""

    readonly property var rows: {
        let dummy = I18n.currentLang;
        let q = screenshotTabRoot.search.trim().toLowerCase();
        let list = screenshotTabRoot.languages.map(l => ({
            code: l.code,
            size: l.size,
            installed: l.installed,
            name: OcrLanguages.name(l.code)
        })).filter(l => q === "" || l.name.toLowerCase().indexOf(q) !== -1 || l.code.indexOf(q) !== -1);
        list.sort((a, b) => {
            if (a.installed !== b.installed) return a.installed ? -1 : 1;
            return a.name.localeCompare(b.name);
        });
        return list;
    }

    function syncSettings() {
        let gs = (typeof Config !== "undefined" && typeof Config.getSetting === "function") ? Config.getSetting("general", {}) : {};
        screenshotTabRoot.captureOnRelease = gs && gs.screenshotCaptureOnRelease === true;
    }

    function updateCaptureOnRelease(value) {
        if (typeof Config !== "undefined" && !Config.dataReady) return;
        let current = Object.assign({}, Config.getSetting("general", {}));
        current.screenshotCaptureOnRelease = value;
        Config.setSetting("general", current);
        screenshotTabRoot.captureOnRelease = value;
    }

    function loadLanguages() {
        if (listProc.running) return;
        listProc.running = true;
    }

    function runAction(action, code) {
        if (opProc.running) return;
        screenshotTabRoot.failed = false;
        screenshotTabRoot.busyCode = code;
        screenshotTabRoot.busyAction = action;
        opProc.command = ["bash", screenshotTabRoot.scriptPath, action, code];
        opProc.running = true;
    }

    function formatSize(bytes) {
        return (bytes / 1048576).toFixed(1) + " MB";
    }

    Process {
        id: listProc
        command: ["bash", screenshotTabRoot.scriptPath, "list"]
        stdout: StdioCollector {
            id: listOut
            onStreamFinished: {
                try {
                    let data = JSON.parse(listOut.text);
                    screenshotTabRoot.languages = data.languages || [];
                    screenshotTabRoot.online = data.online === true;
                } catch (e) {
                    screenshotTabRoot.languages = [];
                    screenshotTabRoot.online = false;
                }
                screenshotTabRoot.loaded = true;
            }
        }
    }

    Process {
        id: opProc
        onExited: function(exitCode) {
            screenshotTabRoot.failed = exitCode !== 0;
            screenshotTabRoot.busyCode = "";
            screenshotTabRoot.busyAction = "";
            screenshotTabRoot.loadLanguages();
        }
    }

    onVisibleChanged: {
        if (visible) {
            syncSettings();
            loadLanguages();
        }
    }

    Component.onCompleted: syncSettings()

    Connections {
        target: typeof Config !== "undefined" ? Config : null
        function onSettingsLoaded() {
            screenshotTabRoot.syncSettings();
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.topMargin: rootObj.s(8)
        anchors.leftMargin: rootObj.s(8)
        anchors.rightMargin: rootObj.s(8)
        anchors.bottomMargin: rootObj.s(8)
        contentHeight: settingsCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: settingsCol
            width: parent.width
            spacing: rootObj.s(6)

            SettingsBlob {
                SettingsRow {
                    rootObj: screenshotTabRoot.rootObj
                    settingId: "screenshot_capture_on_release"
                    searchKeywords: "screenshot capture release mouse region shutter"
                    icon: "󰹑"
                    title: I18n.t("guide.general.screenshot_on_release.title", "Capture region on mouse release")
                    description: I18n.t("guide.general.screenshot_on_release.desc", "Take the screenshot as soon as you finish dragging, without clicking the shutter")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: screenshotTabRoot.captureOnRelease
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) { screenshotTabRoot.updateCaptureOnRelease(c); }
                    }
                }
            }

            SettingsBlob {
                SettingsRow {
                    rootObj: screenshotTabRoot.rootObj
                    settingId: "screenshot_ocr_languages"
                    searchKeywords: "ocr text recognition language tesseract download install"
                    icon: "󱄽"
                    title: I18n.t("guide.screenshot.ocr.title", "OCR languages")
                    description: I18n.t("guide.screenshot.ocr.desc", "Text recognition detects the language automatically from the ones you install")

                    Input {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        implicitWidth: rootObj.s(220)
                        implicitHeight: rootObj.s(32)
                        text: screenshotTabRoot.search
                        placeholderText: I18n.t("guide.screenshot.ocr.search", "Search languages...")
                        showClearButton: true
                        baseColor: ThemeBackend.surface0
                        accentColor: ThemeBackend.mauve
                        textColor: ThemeBackend.text
                        subTextColor: ThemeBackend.subtext0
                        borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
                        cornerRadius: ThemeBackend.borderRadius
                        fontPixelSize: rootObj.s(11)
                        onTextEdited: function(newText) { screenshotTabRoot.search = newText; }
                        onCleared: screenshotTabRoot.search = ""
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.margins: rootObj.s(12)
                    visible: !screenshotTabRoot.loaded || !screenshotTabRoot.online || screenshotTabRoot.failed
                    wrapMode: Text.WordWrap
                    color: (screenshotTabRoot.failed || (screenshotTabRoot.loaded && !screenshotTabRoot.online)) ? ThemeBackend.red : ThemeBackend.subtext0
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: rootObj.s(11)
                    text: screenshotTabRoot.failed
                        ? I18n.t("guide.screenshot.ocr.failed", "Download failed. Check your connection.")
                        : (screenshotTabRoot.loaded
                            ? I18n.t("guide.screenshot.ocr.offline", "Can't reach the language list. Showing installed languages only.")
                            : I18n.t("guide.screenshot.ocr.loading", "Loading languages..."))
                }

                Repeater {
                    model: screenshotTabRoot.rows

                    delegate: SettingsRow {
                        required property var modelData

                        rootObj: screenshotTabRoot.rootObj
                        searchable: false
                        baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                        icon: "󰗊"
                        iconSize: 28
                        iconFontSize: 14
                        title: modelData.name
                        description: modelData.code + " · " + screenshotTabRoot.formatSize(modelData.size)
                        titlePixelSize: 12
                        descriptionPixelSize: 10
                        verticalPadding: rootObj.s(10)

                        Text {
                            visible: modelData.code === "eng" && modelData.installed
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            text: I18n.t("guide.screenshot.ocr.installed", "Installed")
                            color: ThemeBackend.subtext0
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: rootObj.s(11)
                        }

                        ClickButton {
                            visible: !(modelData.code === "eng" && modelData.installed)
                            enabled: screenshotTabRoot.busyCode === ""
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            implicitHeight: rootObj.s(30)
                            implicitWidth: rootObj.s(120)
                            cornerRadius: ThemeBackend.borderRadius
                            textFontSize: rootObj.s(11)
                            iconFontSize: rootObj.s(13)
                            opacity: enabled || screenshotTabRoot.busyCode === modelData.code ? 1.0 : 0.5
                            buttonIcon: screenshotTabRoot.busyCode === modelData.code ? "󰦖" : (modelData.installed ? "󰆴" : "󰇚")
                            buttonText: screenshotTabRoot.busyCode === modelData.code
                                ? (screenshotTabRoot.busyAction === "install" ? I18n.t("guide.screenshot.ocr.installing", "Installing...") : I18n.t("guide.screenshot.ocr.removing", "Removing..."))
                                : (modelData.installed ? I18n.t("guide.screenshot.ocr.remove", "Remove") : I18n.t("guide.screenshot.ocr.install", "Install"))
                            accentColor: modelData.installed ? ThemeBackend.surface0 : ThemeBackend.mauve
                            textColor: modelData.installed ? ThemeBackend.text : ThemeBackend.crust
                            onClicked: screenshotTabRoot.runAction(modelData.installed ? "remove" : "install", modelData.code)
                        }
                    }
                }
            }
        }
    }
}
