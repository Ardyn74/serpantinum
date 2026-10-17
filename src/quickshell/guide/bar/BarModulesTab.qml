import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import "../"
import "../../"
import "../../bar"
import "../../reusables"
import "../../reusables/guide"
import "modules"

GuideTab {
    id: barModulesRoot
    subTabIndex: 1

    property real cardRadius: ThemeBackend.clampedBorderRadius

    property bool isDesktop: (typeof UPower !== "undefined" && UPower.displayDevice && UPower.displayDevice.ready) ? !UPower.displayDevice.isLaptopBattery : (typeof SystemInfo !== "undefined" ? SystemInfo.isDesktop : false)

    property string barPosition: {
        let bs = Config.getSetting("bar", {});
        return bs && bs.position !== undefined ? bs.position : "top";
    }
    readonly property bool isSideBar: barPosition === "left" || barPosition === "right"

    property string workspacesStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.workspacesStyle) return bs.workspacesStyle;
        return "pills";
    }

    property int workspaceCount: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.workspaceCount !== undefined) return bs.workspaceCount;
        return 8;
    }

    property bool hideEmptyWorkspaces: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.hideEmptyWorkspaces !== undefined) return Boolean(bs.hideEmptyWorkspaces);
        return false;
    }

    property string timeStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.timeStyle) return bs.timeStyle;
        return "classic";
    }

    property bool timeShowDate: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.timeShowDate !== undefined) return bs.timeShowDate;
        if (bs && bs.showDate !== undefined) return bs.showDate;
        return true;
    }

    property string timeFormat: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.time && bs.time.format !== undefined) return bs.time.format;
        return "HH:mm:ss";
    }

    property int visBarCount: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.visBarCount !== undefined) return bs.visBarCount;
        return 16;
    }

    property string visAlignment: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.visAlignment) return bs.visAlignment;
        return "center";
    }

    property bool visContinuous: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.visContinuous !== undefined) return Boolean(bs.visContinuous);
        return false;
    }

    property string sysmonStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.sysmonStyle) return bs.sysmonStyle;
        if (bs && bs.sysmon && bs.sysmon.style) return bs.sysmon.style;
        return "wave";
    }

    property var sysmonStats: {
        let bs = Config.getSetting("bar", {});
        if (bs && Array.isArray(bs.sysmonStats)) return bs.sysmonStats;
        if (bs && bs.sysmon && Array.isArray(bs.sysmon.stats)) return bs.sysmon.stats;
        if (bs && (bs.sysmonShowCpu !== undefined || bs.sysmonShowRam !== undefined || bs.sysmonShowTemp !== undefined || bs.sysmonShowDisk !== undefined)) {
            let stats = [];
            if (bs.sysmonShowCpu !== false) stats.push("cpu");
            if (bs.sysmonShowRam !== false) stats.push("ram");
            if (bs.sysmonShowTemp !== false) stats.push("temp");
            if (bs.sysmonShowDisk === true) stats.push("disk");
            return stats;
        }
        return ["cpu", "ram", "temp"];
    }

    readonly property var menuStyles: BarModuleRegistry.variantList("left")
    readonly property var workspaceStyles: BarModuleRegistry.variantList("workspaces")
    readonly property var timeStyles: BarModuleRegistry.variantList("timedate")
    readonly property var batStyles: BarModuleRegistry.variantList("bat")
    readonly property var wifiStyles: BarModuleRegistry.variantList("wifi")
    readonly property var btStyles: BarModuleRegistry.variantList("bt")
    readonly property var volStyles: BarModuleRegistry.variantList("vol")
    readonly property var kbStyles: BarModuleRegistry.variantList("kb")

    property string menuStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.menuStyle) return bs.menuStyle;
        return "button";
    }

    property bool menuShowSettings: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.menuShowSettings !== undefined) return Boolean(bs.menuShowSettings);
        return true;
    }

    property bool menuShowLauncher: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.menuShowLauncher !== undefined) return Boolean(bs.menuShowLauncher);
        return true;
    }

    property string wifiStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.wifiStyle) return bs.wifiStyle;
        return "button";
    }

    property bool wifiShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.wifiShowIcon !== undefined) return Boolean(bs.wifiShowIcon);
        return true;
    }

    property bool wifiShowName: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.wifiShowName !== undefined) return Boolean(bs.wifiShowName);
        return true;
    }

    property string btStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btStyle) return bs.btStyle;
        return "button";
    }

    property bool btShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btShowIcon !== undefined) return Boolean(bs.btShowIcon);
        return true;
    }

    property bool btShowName: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.btShowName !== undefined) return Boolean(bs.btShowName);
        return true;
    }

    property string volStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.volStyle) return bs.volStyle;
        return "button";
    }

    property bool volShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.volShowIcon !== undefined) return Boolean(bs.volShowIcon);
        return true;
    }

    property bool volShowPercent: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.volShowPercent !== undefined) return Boolean(bs.volShowPercent);
        return true;
    }

    property string kbStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.kbStyle) return bs.kbStyle;
        return "button";
    }

    property bool kbShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.kbShowIcon !== undefined) return Boolean(bs.kbShowIcon);
        return true;
    }

    property string mediaInfoMode: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.mediaInfoMode) return bs.mediaInfoMode;
        return "duration";
    }

    property int mediaWidth: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.mediaWidth !== undefined) return Math.round(Number(bs.mediaWidth));
        return 120;
    }

    property bool mediaShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.mediaShowIcon !== undefined) return Boolean(bs.mediaShowIcon);
        return true;
    }

    property bool mediaShowControls: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.mediaShowControls !== undefined) return Boolean(bs.mediaShowControls);
        return true;
    }

    property string batStyle: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.batStyle) return bs.batStyle;
        return "classic";
    }

    property bool batShowPercent: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.batShowPercent !== undefined) return Boolean(bs.batShowPercent);
        return true;
    }

    property bool batShowIcon: {
        let bs = Config.getSetting("bar", {});
        if (bs && bs.batShowIcon !== undefined) return Boolean(bs.batShowIcon);
        return true;
    }

    property real barOpacity: ThemeBackend.elementOpacity

    function syncSettings() {
        let bs = Config.getSetting("bar", {});
        barModulesRoot.barPosition = (bs && bs.position !== undefined) ? bs.position : "top";

        if (bs && bs.workspacesStyle) {
            barModulesRoot.workspacesStyle = bs.workspacesStyle;
        } else {
            barModulesRoot.workspacesStyle = "pills";
        }

        if (bs && bs.workspaceCount !== undefined) {
            barModulesRoot.workspaceCount = bs.workspaceCount;
        } else {
            barModulesRoot.workspaceCount = 8;
        }

        if (bs && bs.hideEmptyWorkspaces !== undefined) {
            barModulesRoot.hideEmptyWorkspaces = Boolean(bs.hideEmptyWorkspaces);
        } else {
            barModulesRoot.hideEmptyWorkspaces = false;
        }

        if (bs && bs.timeStyle) {
            barModulesRoot.timeStyle = bs.timeStyle;
        } else {
            barModulesRoot.timeStyle = "classic";
        }

        if (bs && bs.timeShowDate !== undefined) {
            barModulesRoot.timeShowDate = bs.timeShowDate;
        } else if (bs && bs.showDate !== undefined) {
            barModulesRoot.timeShowDate = bs.showDate;
        } else {
            barModulesRoot.timeShowDate = true;
        }

        if (bs && bs.time && bs.time.format !== undefined) {
            barModulesRoot.timeFormat = bs.time.format;
        } else {
            barModulesRoot.timeFormat = "HH:mm:ss";
        }

        if (bs && bs.visBarCount !== undefined) {
            barModulesRoot.visBarCount = bs.visBarCount;
        } else {
            barModulesRoot.visBarCount = 16;
        }

        if (bs && bs.visAlignment) {
            barModulesRoot.visAlignment = bs.visAlignment;
        } else {
            barModulesRoot.visAlignment = "center";
        }

        if (bs && bs.visContinuous !== undefined) {
            barModulesRoot.visContinuous = Boolean(bs.visContinuous);
        } else {
            barModulesRoot.visContinuous = false;
        }

        if (bs && bs.sysmonStyle) {
            barModulesRoot.sysmonStyle = bs.sysmonStyle;
        } else {
            barModulesRoot.sysmonStyle = "wave";
        }

        if (bs && Array.isArray(bs.sysmonStats)) {
            barModulesRoot.sysmonStats = bs.sysmonStats;
        } else if (bs && (bs.sysmonShowCpu !== undefined || bs.sysmonShowRam !== undefined || bs.sysmonShowTemp !== undefined || bs.sysmonShowDisk !== undefined)) {
            let stats = [];
            if (bs.sysmonShowCpu !== false) stats.push("cpu");
            if (bs.sysmonShowRam !== false) stats.push("ram");
            if (bs.sysmonShowTemp !== false) stats.push("temp");
            if (bs.sysmonShowDisk === true) stats.push("disk");
            barModulesRoot.sysmonStats = stats;
        } else {
            barModulesRoot.sysmonStats = ["cpu", "ram", "temp"];
        }

        if (bs && bs.batStyle) {
            barModulesRoot.batStyle = bs.batStyle;
        } else {
            barModulesRoot.batStyle = "classic";
        }

        if (bs && bs.batShowPercent !== undefined) {
            barModulesRoot.batShowPercent = Boolean(bs.batShowPercent);
        } else {
            barModulesRoot.batShowPercent = true;
        }

        if (bs && bs.batShowIcon !== undefined) {
            barModulesRoot.batShowIcon = Boolean(bs.batShowIcon);
        } else {
            barModulesRoot.batShowIcon = true;
        }

        barModulesRoot.menuStyle = (bs && bs.menuStyle) ? bs.menuStyle : "button";
        barModulesRoot.menuShowSettings = (bs && bs.menuShowSettings !== undefined) ? Boolean(bs.menuShowSettings) : true;
        barModulesRoot.menuShowLauncher = (bs && bs.menuShowLauncher !== undefined) ? Boolean(bs.menuShowLauncher) : true;
        if (!barModulesRoot.menuShowSettings && !barModulesRoot.menuShowLauncher) {
            barModulesRoot.menuShowSettings = true;
        }

        if (bs && bs.wifiStyle) {
            barModulesRoot.wifiStyle = bs.wifiStyle;
        } else {
            barModulesRoot.wifiStyle = "button";
        }

        if (bs && bs.wifiShowIcon !== undefined) {
            barModulesRoot.wifiShowIcon = Boolean(bs.wifiShowIcon);
        } else {
            barModulesRoot.wifiShowIcon = true;
        }

        if (bs && bs.wifiShowName !== undefined) {
            barModulesRoot.wifiShowName = Boolean(bs.wifiShowName);
        } else {
            barModulesRoot.wifiShowName = true;
        }

        if (bs && bs.btStyle) {
            barModulesRoot.btStyle = bs.btStyle;
        } else {
            barModulesRoot.btStyle = "button";
        }

        if (bs && bs.btShowIcon !== undefined) {
            barModulesRoot.btShowIcon = Boolean(bs.btShowIcon);
        } else {
            barModulesRoot.btShowIcon = true;
        }

        if (bs && bs.btShowName !== undefined) {
            barModulesRoot.btShowName = Boolean(bs.btShowName);
        } else {
            barModulesRoot.btShowName = true;
        }

        if (bs && bs.volStyle) {
            barModulesRoot.volStyle = bs.volStyle;
        } else {
            barModulesRoot.volStyle = "button";
        }

        if (bs && bs.volShowIcon !== undefined) {
            barModulesRoot.volShowIcon = Boolean(bs.volShowIcon);
        } else {
            barModulesRoot.volShowIcon = true;
        }

        if (bs && bs.volShowPercent !== undefined) {
            barModulesRoot.volShowPercent = Boolean(bs.volShowPercent);
        } else {
            barModulesRoot.volShowPercent = true;
        }

        if (bs && bs.kbStyle) {
            barModulesRoot.kbStyle = bs.kbStyle;
        } else {
            barModulesRoot.kbStyle = "button";
        }

        if (bs && bs.kbShowIcon !== undefined) {
            barModulesRoot.kbShowIcon = Boolean(bs.kbShowIcon);
        } else {
            barModulesRoot.kbShowIcon = true;
        }

        barModulesRoot.mediaInfoMode = (bs && bs.mediaInfoMode) ? bs.mediaInfoMode : "duration";
        barModulesRoot.mediaWidth = (bs && bs.mediaWidth !== undefined) ? Math.round(Number(bs.mediaWidth)) : 120;

        if (bs && bs.mediaShowIcon !== undefined) {
            barModulesRoot.mediaShowIcon = Boolean(bs.mediaShowIcon);
        } else {
            barModulesRoot.mediaShowIcon = true;
        }

        if (bs && bs.mediaShowControls !== undefined) {
            barModulesRoot.mediaShowControls = Boolean(bs.mediaShowControls);
        } else {
            barModulesRoot.mediaShowControls = true;
        }

        if (!barModulesRoot.batShowPercent && !barModulesRoot.batShowIcon) {
            barModulesRoot.batShowIcon = true;
        }
        if (!barModulesRoot.wifiShowIcon && !barModulesRoot.wifiShowName) {
            barModulesRoot.wifiShowIcon = true;
        }
        if (!barModulesRoot.btShowIcon && !barModulesRoot.btShowName) {
            barModulesRoot.btShowIcon = true;
        }
        if (!barModulesRoot.volShowIcon && !barModulesRoot.volShowPercent) {
            barModulesRoot.volShowIcon = true;
        }
    }

    function setWorkspacesStyle(styleName) {
        barModulesRoot.workspacesStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.workspacesStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setWorkspaceCount(count) {
        barModulesRoot.workspaceCount = count;
        let current = Config.getSetting("bar", {});
        current.workspaceCount = count;
        Config.setSetting("bar", current);
    }

    function setHideEmptyWorkspaces(val) {
        barModulesRoot.hideEmptyWorkspaces = val;
        let current = Config.getSetting("bar", {});
        current.hideEmptyWorkspaces = val;
        Config.setSetting("bar", current);
    }

    function setTimeStyle(styleName) {
        barModulesRoot.timeStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.timeStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setTimeShowDate(show) {
        barModulesRoot.timeShowDate = show;
        let current = Config.getSetting("bar", {});
        current.timeShowDate = show;
        if (current.showDate !== undefined) delete current.showDate;
        Config.setSetting("bar", current);
    }

    function setTimeFormat(fmt) {
        barModulesRoot.timeFormat = fmt;
        let current = Config.getSetting("bar", {});
        if (!current.time) current.time = {};
        current.time.format = fmt;
        Config.setSetting("bar", current);
    }

    function setVisBarCount(count) {
        barModulesRoot.visBarCount = count;
        let current = Config.getSetting("bar", {});
        current.visBarCount = count;
        Config.setSetting("bar", current);
    }

    function setVisAlignment(align) {
        barModulesRoot.visAlignment = align;
        let current = Config.getSetting("bar", {});
        current.visAlignment = align;
        Config.setSetting("bar", current);
    }

    function setVisContinuous(val) {
        barModulesRoot.visContinuous = val;
        let current = Config.getSetting("bar", {});
        current.visContinuous = val;
        Config.setSetting("bar", current);
    }

    function setSysmonStyle(styleName) {
        barModulesRoot.sysmonStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.sysmonStyle = styleName;
        Config.setSetting("bar", current);
    }

    function isSysmonStatEnabled(stat) {
        return barModulesRoot.sysmonStats && barModulesRoot.sysmonStats.indexOf(stat) !== -1;
    }

    function toggleSysmonStat(stat, enabled) {
        let list = barModulesRoot.sysmonStats ? barModulesRoot.sysmonStats.slice() : ["cpu", "ram", "temp"];
        let allStats = ["cpu", "ram", "temp", "disk"];
        let set = {};
        for (let i = 0; i < list.length; i++) set[list[i]] = true;
        if (enabled) {
            set[stat] = true;
        } else {
            delete set[stat];
        }
        let res = [];
        for (let i = 0; i < allStats.length; i++) {
            if (set[allStats[i]]) res.push(allStats[i]);
        }
        barModulesRoot.sysmonStats = res;
        let current = Config.getSetting("bar", {});
        current.sysmonStats = res;
        Config.setSetting("bar", current);
    }

    function setBatStyle(styleName) {
        barModulesRoot.batStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.batStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setBatShowPercent(val) {
        if (!val && !barModulesRoot.batShowIcon) return;
        barModulesRoot.batShowPercent = val;
        let current = Config.getSetting("bar", {});
        current.batShowPercent = val;
        Config.setSetting("bar", current);
    }

    function setBatShowIcon(val) {
        if (!val && !barModulesRoot.batShowPercent) return;
        barModulesRoot.batShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.batShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setMenuStyle(styleName) {
        barModulesRoot.menuStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.menuStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setMenuShowSettings(val) {
        if (!val && !barModulesRoot.menuShowLauncher) return;
        barModulesRoot.menuShowSettings = val;
        let current = Config.getSetting("bar", {});
        current.menuShowSettings = val;
        Config.setSetting("bar", current);
    }

    function setMenuShowLauncher(val) {
        if (!val && !barModulesRoot.menuShowSettings) return;
        barModulesRoot.menuShowLauncher = val;
        let current = Config.getSetting("bar", {});
        current.menuShowLauncher = val;
        Config.setSetting("bar", current);
    }

    function setWifiStyle(styleName) {
        barModulesRoot.wifiStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.wifiStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setWifiShowIcon(val) {
        if (!val && !barModulesRoot.wifiShowName) return;
        barModulesRoot.wifiShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.wifiShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setWifiShowName(val) {
        if (!val && !barModulesRoot.wifiShowIcon) return;
        barModulesRoot.wifiShowName = val;
        let current = Config.getSetting("bar", {});
        current.wifiShowName = val;
        Config.setSetting("bar", current);
    }

    function setBtStyle(styleName) {
        barModulesRoot.btStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.btStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setBtShowIcon(val) {
        if (!val && !barModulesRoot.btShowName) return;
        barModulesRoot.btShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.btShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setBtShowName(val) {
        if (!val && !barModulesRoot.btShowIcon) return;
        barModulesRoot.btShowName = val;
        let current = Config.getSetting("bar", {});
        current.btShowName = val;
        Config.setSetting("bar", current);
    }

    function setVolStyle(styleName) {
        barModulesRoot.volStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.volStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setVolShowIcon(val) {
        if (!val && !barModulesRoot.volShowPercent) return;
        barModulesRoot.volShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.volShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setVolShowPercent(val) {
        if (!val && !barModulesRoot.volShowIcon) return;
        barModulesRoot.volShowPercent = val;
        let current = Config.getSetting("bar", {});
        current.volShowPercent = val;
        Config.setSetting("bar", current);
    }

    function setKbStyle(styleName) {
        barModulesRoot.kbStyle = styleName;
        let current = Config.getSetting("bar", {});
        current.kbStyle = styleName;
        Config.setSetting("bar", current);
    }

    function setKbShowIcon(val) {
        barModulesRoot.kbShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.kbShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setMediaInfoMode(val) {
        barModulesRoot.mediaInfoMode = val;
        let current = Config.getSetting("bar", {});
        current.mediaInfoMode = val;
        Config.setSetting("bar", current);
    }

    function setMediaWidth(val) {
        let current = Config.getSetting("bar", {});
        current.mediaWidth = val;
        Config.setSetting("bar", current);
    }

    function setMediaShowIcon(val) {
        barModulesRoot.mediaShowIcon = val;
        let current = Config.getSetting("bar", {});
        current.mediaShowIcon = val;
        Config.setSetting("bar", current);
    }

    function setMediaShowControls(val) {
        barModulesRoot.mediaShowControls = val;
        let current = Config.getSetting("bar", {});
        current.mediaShowControls = val;
        Config.setSetting("bar", current);
    }

    onVisAlignmentChanged: {
        let a = barModulesRoot.visAlignment;
        if (visAlignSwitch) {
            if (barModulesRoot.isSideBar) {
                visAlignSwitch.currentIndex = (a === "left" || a === "top") ? 0 : ((a === "right" || a === "bottom") ? 2 : 1);
            } else {
                visAlignSwitch.currentIndex = (a === "top" || a === "left") ? 0 : ((a === "bottom" || a === "right") ? 2 : 1);
            }
        }
    }

    onIsSideBarChanged: {
        let a = barModulesRoot.visAlignment;
        if (visAlignSwitch) {
            if (barModulesRoot.isSideBar) {
                visAlignSwitch.currentIndex = (a === "left" || a === "top") ? 0 : ((a === "right" || a === "bottom") ? 2 : 1);
            } else {
                visAlignSwitch.currentIndex = (a === "top" || a === "left") ? 0 : ((a === "bottom" || a === "right") ? 2 : 1);
            }
        }
    }

    function inView(item) {
        if (!item || !visible) return false;
        void modulesFlick.contentY;
        void modulesFlick.contentHeight;
        void modulesFlick.height;
        void item.y;
        void item.height;
        const top = item.mapToItem(modulesFlick.contentItem, 0, 0).y;
        const margin = modulesFlick.height * 0.5;
        return top + item.height > modulesFlick.contentY - margin && top < modulesFlick.contentY + modulesFlick.height + margin;
    }

    onVisibleChanged: {
        if (visible) {
            syncSettings();
        }
    }

    Component.onCompleted: {
        syncSettings();
    }

    Connections {
        target: Config
        function onSettingsLoaded() {
            barModulesRoot.syncSettings();
        }
        function onRawSettingsChanged() {
            barModulesRoot.syncSettings();
        }
    }

    Flickable {
        id: modulesFlick
        anchors.fill: parent
        anchors.topMargin: rootObj.s(4)
        anchors.leftMargin: rootObj.s(8)
        anchors.rightMargin: rootObj.s(8)
        anchors.bottomMargin: rootObj.s(4)
        contentHeight: modulesCol.implicitHeight + rootObj.s(16)
        contentWidth: width
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            active: parent.moving || parent.movingVertically
            width: rootObj.s(4)
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle {
                implicitWidth: rootObj.s(4)
                radius: rootObj.s(2)
                color: ThemeBackend.surface2
            }
        }

        ColumnLayout {
            id: modulesCol
            width: parent.width - (parent.contentHeight > parent.height ? rootObj.s(6) : 0)
            spacing: rootObj.s(12)

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.actions", "Menu")
                moduleId: "left"
                styles: barModulesRoot.menuStyles
                currentStyle: barModulesRoot.menuStyle
                styleSettingId: "bar_menu_style"
                styleKeywords: "menu style look button icon layout"
                styleIcon: "󰒓"
                styleTitle: I18n.t("guide.bar.menu.style.title", "Style")
                styleDescription: I18n.t("guide.bar.menu.style.desc", "Choose the visual appearance of the menu module")
                onStyleSelected: id => barModulesRoot.setMenuStyle(id)

                widgetComponent: Component {
                    BarPreviewWidget {
                        property string menuStyle: variantId !== "" ? variantId : tab.menuStyle
                        property bool menuShowSettings: tab.menuShowSettings
                        property bool menuShowLauncher: tab.menuShowLauncher
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_menu_show_settings"
                    searchKeywords: "menu settings gear guide icon button"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰒓"
                    title: I18n.t("guide.bar.menu.show_settings.title", "Show settings icon")
                    description: I18n.t("guide.bar.menu.show_settings.desc", "Display the button that opens settings")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.menuShowSettings
                        enabled: !checked || barModulesRoot.menuShowLauncher
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setMenuShowSettings(c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_menu_show_launcher"
                    searchKeywords: "menu launcher search apps icon button"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰍉"
                    title: I18n.t("guide.bar.menu.show_launcher.title", "Show launcher icon")
                    description: I18n.t("guide.bar.menu.show_launcher.desc", "Display the search button that opens the launcher")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.menuShowLauncher
                        enabled: !checked || barModulesRoot.menuShowSettings
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setMenuShowLauncher(c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.workspaces.name", "Workspaces")
                moduleId: "workspaces"
                showPreview: false
                variantPreviewSideHeight: 160
                styles: barModulesRoot.workspaceStyles
                currentStyle: barModulesRoot.workspacesStyle
                styleSettingId: "bar_workspaces_style"
                styleKeywords: "pills numbers pacman workspaces style"
                styleIcon: "󰮯"
                styleTitle: I18n.t("guide.bar.workspaces.style.title", "Workspaces style")
                styleDescription: I18n.t("guide.bar.workspaces.style.desc", "Choose the visual style for workspace indicators")
                onStyleSelected: id => barModulesRoot.setWorkspacesStyle(id)

                widgetComponent: Component {
                    BarPreviewWidget {
                        isPreview: false
                        moduleActive: true
                        property int workspaceCount: 5
                        property int activeIndex: 1
                        property var isOccupied: function(idx) { return idx === 0 || idx === 1 || idx === 2; }
                        property var focusWorkspace: function(idx) {}
                    }
                }

                variantFallback: Component {
                    Item {
                        property string variantId

                        RowLayout {
                            anchors.centerIn: parent
                            visible: !barModulesRoot.isSideBar
                            spacing: rootObj.s(6)

                            Repeater {
                                model: 5
                                delegate: Rectangle {
                                    required property int index
                                    readonly property bool isActive: index === 1
                                    width: variantId === "pills"
                                        ? (isActive ? rootObj.s(22) : rootObj.s(8))
                                        : rootObj.s(18)
                                    height: variantId === "pills" ? rootObj.s(8) : rootObj.s(18)
                                    Layout.preferredWidth: width
                                    Layout.preferredHeight: height
                                    radius: variantId === "pills" ? height / 2 : rootObj.s(4)
                                    color: isActive ? ThemeBackend.mauve : Qt.alpha(ThemeBackend.surface2, 0.7)

                                    Text {
                                        anchors.centerIn: parent
                                        visible: variantId === "numbers"
                                        text: String(index + 1)
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: rootObj.s(10)
                                        font.bold: isActive
                                        color: isActive ? ThemeBackend.crust : ThemeBackend.text
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: variantId === "pacman"
                                        text: isActive ? "󰮯" : "•"
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: rootObj.s(14)
                                        font.bold: false
                                        color: isActive ? ThemeBackend.yellow : ThemeBackend.subtext0
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: barModulesRoot.isSideBar
                            spacing: rootObj.s(6)

                            Repeater {
                                model: 5
                                delegate: Rectangle {
                                    required property int index
                                    readonly property bool isActive: index === 1
                                    width: rootObj.s(18)
                                    height: variantId === "pills"
                                        ? (isActive ? rootObj.s(36) : rootObj.s(18))
                                        : rootObj.s(18)
                                    Layout.preferredWidth: width
                                    Layout.preferredHeight: height
                                    radius: variantId === "pills" ? width / 2 : rootObj.s(4)
                                    color: isActive ? ThemeBackend.mauve : Qt.alpha(ThemeBackend.surface2, 0.7)

                                    Text {
                                        anchors.centerIn: parent
                                        visible: variantId === "numbers"
                                        text: String(index + 1)
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: rootObj.s(10)
                                        font.bold: isActive
                                        color: isActive ? ThemeBackend.crust : ThemeBackend.text
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: variantId === "pacman"
                                        text: isActive ? "󰮯" : "•"
                                        font.family: ThemeBackend.fontFamily
                                        font.pixelSize: rootObj.s(14)
                                        font.bold: false
                                        color: isActive ? ThemeBackend.yellow : ThemeBackend.subtext0
                                    }
                                }
                            }
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰮯"
                    title: I18n.t("guide.bar.workspaces.title")
                    description: I18n.t("guide.bar.workspaces.desc")

                    NumberSelector {
                        id: workspaceCountSelector
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        implicitWidth: rootObj.s(140)
                        implicitHeight: rootObj.s(32)
                        from: 2
                        to: 10
                        stepSize: 1
                        decimals: 0
                        value: barModulesRoot.workspaceCount
                        baseColor: ThemeBackend.surface0
                        accentColor: ThemeBackend.mauve
                        buttonColor: ThemeBackend.surface1
                        buttonTextColor: ThemeBackend.text
                        textColor: ThemeBackend.text
                        subTextColor: ThemeBackend.subtext0
                        borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
                        cornerRadius: ThemeBackend.borderRadius
                        fontFamily: ThemeBackend.fontFamily
                        fontPixelSize: rootObj.s(12)
                        onValueChanged: {
                            let rounded = Math.round(workspaceCountSelector.value);
                            if (barModulesRoot.workspaceCount !== rounded) {
                                barModulesRoot.setWorkspaceCount(rounded);
                            }
                        }
                        onTriggered: {
                            barModulesRoot.setWorkspaceCount(Math.round(workspaceCountSelector.value));
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰈈"
                    title: I18n.t("guide.bar.workspaces.hide_empty.title", "Hide empty workspaces")
                    description: I18n.t("guide.bar.workspaces.hide_empty.desc", "Show only occupied workspaces and the active one")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.hideEmptyWorkspaces
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setHideEmptyWorkspaces(c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.timedate.name", "Time & date")
                moduleId: "timedate"
                showPreview: false
                styles: barModulesRoot.timeStyles
                currentStyle: barModulesRoot.timeStyle
                styleSettingId: "bar_timedate_style"
                styleKeywords: "classic material badge time date clock style"
                styleIcon: "󰥔"
                styleTitle: I18n.t("guide.bar.timedate.style.title", "Time & date style")
                styleDescription: I18n.t("guide.bar.timedate.style.desc", "Choose the visual style for the clock and date display")
                onStyleSelected: id => barModulesRoot.setTimeStyle(id)

                widgetComponent: Component {
                    BarPreviewWidget {
                        isPreview: false
                        property bool showDate: tab.timeShowDate
                        property string timeStr: (typeof DateTime !== "undefined" && DateTime.time) ? DateTime.time : "14:28"
                        property string hourStr: (typeof DateTime !== "undefined" && DateTime.hour) ? DateTime.hour : "14"
                        property string minuteStr: (typeof DateTime !== "undefined" && DateTime.minute) ? DateTime.minute : "28"
                        property string secondStr: (typeof DateTime !== "undefined" && DateTime.second) ? DateTime.second : "00"
                        property string dayStr: (typeof DateTime !== "undefined" && DateTime.day) ? DateTime.day : "18"
                        property string monthStr: (typeof DateTime !== "undefined" && DateTime.monthShort) ? DateTime.monthShort : "Sep"
                        property string fullDateStr: (typeof DateTime !== "undefined" && DateTime.fullDate) ? DateTime.fullDate : "Fri, Sep 18"
                        property string dateStr: (typeof DateTime !== "undefined" && DateTime.fullDate) ? DateTime.fullDate : "Fri, Sep 18"
                    }
                }

                variantFallback: Component {
                    Item {
                        property string variantId

                        RowLayout {
                            anchors.centerIn: parent
                            visible: !barModulesRoot.isSideBar
                            spacing: rootObj.s(6)

                            Text {
                                text: "14:28:00"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: rootObj.s(13)
                                font.bold: true
                                color: ThemeBackend.text
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: barModulesRoot.isSideBar
                            spacing: rootObj.s(3)

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "14"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: rootObj.s(13)
                                font.bold: true
                                color: ThemeBackend.blue
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "28"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: rootObj.s(13)
                                font.bold: true
                                color: ThemeBackend.sapphire
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: rootObj.s(14)
                                height: 2
                                radius: 1
                                color: ThemeBackend.surface1
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "18"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: rootObj.s(10)
                                font.bold: true
                                color: ThemeBackend.text
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Sep"
                                font.family: ThemeBackend.fontFamily
                                font.pixelSize: rootObj.s(8)
                                font.bold: true
                                color: ThemeBackend.subtext0
                            }
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰃭"
                    title: I18n.t("guide.bar.timedate.show_date.title", "Show date")
                    description: I18n.t("guide.bar.timedate.show_date.desc", "Display the date text alongside the clock")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.timeShowDate
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setTimeShowDate(c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰅐"
                    title: I18n.t("guide.bar.time.title", "Time format")
                    description: I18n.t("guide.bar.time.desc", "Format pattern (e.g. HH:mm:ss)")

                    Input {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        implicitWidth: rootObj.s(140)
                        implicitHeight: rootObj.s(32)
                        text: barModulesRoot.timeFormat
                        placeholderText: "HH:mm:ss"
                        baseColor: ThemeBackend.surface0
                        accentColor: ThemeBackend.mauve
                        textColor: ThemeBackend.text
                        subTextColor: ThemeBackend.subtext0
                        borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
                        cornerRadius: ThemeBackend.borderRadius
                        fontPixelSize: rootObj.s(11)
                        onTextEdited: function(newText) {
                            barModulesRoot.setTimeFormat(newText);
                        }
                        onAccepted: function(finalText) {
                            barModulesRoot.setTimeFormat(finalText);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.vis", "Visualizer")
                moduleId: "vis"

                widgetComponent: Component {
                    BarPreviewWidget {
                        property int barCount: tab.visBarCount
                        property string visAlignment: tab.visAlignment
                        property bool visContinuous: tab.visContinuous
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_vis_bar_count"
                    searchKeywords: "visualizer bars count amount cava"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰝚"
                    title: I18n.t("guide.bar.vis.bars.title", "Amount of bars")
                    description: I18n.t("guide.bar.vis.bars.desc", "Number of frequency bars to display")

                    NumberSelector {
                        id: visBarCountSelector
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        implicitWidth: rootObj.s(140)
                        implicitHeight: rootObj.s(32)
                        from: 4
                        to: 64
                        stepSize: 1
                        decimals: 0
                        value: barModulesRoot.visBarCount
                        baseColor: ThemeBackend.surface0
                        accentColor: ThemeBackend.mauve
                        buttonColor: ThemeBackend.surface1
                        buttonTextColor: ThemeBackend.text
                        textColor: ThemeBackend.text
                        subTextColor: ThemeBackend.subtext0
                        borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
                        cornerRadius: ThemeBackend.borderRadius
                        fontFamily: ThemeBackend.fontFamily
                        fontPixelSize: rootObj.s(12)
                        onValueChanged: {
                            let rounded = Math.round(visBarCountSelector.value);
                            if (barModulesRoot.visBarCount !== rounded) {
                                barModulesRoot.setVisBarCount(rounded);
                            }
                        }
                        onTriggered: {
                            barModulesRoot.setVisBarCount(Math.round(visBarCountSelector.value));
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_vis_alignment"
                    searchKeywords: "visualizer alignment center top bottom align"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰆑"
                    title: I18n.t("guide.bar.vis.alignment.title", "Alignment")
                    description: I18n.t("guide.bar.vis.alignment.desc", "Center the visualizer or align to top or bottom")

                    Switch {
                        id: visAlignSwitch
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        implicitWidth: rootObj.s(220)
                        implicitHeight: rootObj.s(32)
                        cornerRadius: ThemeBackend.borderRadius
                        fontPixelSize: rootObj.s(11)
                        options: barModulesRoot.isSideBar
                            ? [
                                I18n.t("guide.bar.vis.align.left", "Left"),
                                I18n.t("guide.bar.vis.align.center", "Center"),
                                I18n.t("guide.bar.vis.align.right", "Right")
                            ]
                            : [
                                I18n.t("guide.bar.vis.align.top", "Top"),
                                I18n.t("guide.bar.vis.align.center", "Center"),
                                I18n.t("guide.bar.vis.align.bottom", "Bottom")
                            ]
                        currentIndex: {
                            let a = barModulesRoot.visAlignment;
                            if (barModulesRoot.isSideBar) {
                                if (a === "left" || a === "top") return 0;
                                if (a === "right" || a === "bottom") return 2;
                                return 1;
                            } else {
                                if (a === "top" || a === "left") return 0;
                                if (a === "bottom" || a === "right") return 2;
                                return 1;
                            }
                        }
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface0
                        textColor: ThemeBackend.text
                        activeTextColor: ThemeBackend.crust
                        onValueChanged: function(index, value) {
                            let align = "center";
                            if (barModulesRoot.isSideBar) {
                                align = index === 0 ? "left" : (index === 2 ? "right" : "center");
                            } else {
                                align = index === 0 ? "top" : (index === 2 ? "bottom" : "center");
                            }
                            barModulesRoot.setVisAlignment(align);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_vis_continuous"
                    searchKeywords: "visualizer continuous wave smooth fluid"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰓃"
                    title: I18n.t("guide.bar.vis.continuous.title", "Continuous wave")
                    description: I18n.t("guide.bar.vis.continuous.desc", "Render a smooth fluid wave instead of discrete bars")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.visContinuous
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setVisContinuous(c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.sysmon", "System monitor")
                moduleId: "sysmon"
                previewSideHeight: 150

                widgetComponent: Component {
                    BarPreviewWidget {
                        property string sysmonStyle: tab.sysmonStyle
                        property var sysmonStats: tab.sysmonStats
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_sysmon_style"
                    searchKeywords: "sysmon system monitor circle style wave ring"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󱐋"
                    title: I18n.t("guide.bar.sysmon.style.title", "Circle style")
                    description: I18n.t("guide.bar.sysmon.style.desc", "Visual appearance of the progress rings")

                    Switch {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        implicitWidth: rootObj.s(200)
                        implicitHeight: rootObj.s(32)
                        cornerRadius: ThemeBackend.borderRadius
                        fontPixelSize: rootObj.s(11)
                        options: [
                            I18n.t("guide.bar.sysmon.style.wave", "Wave"),
                            I18n.t("guide.bar.sysmon.style.circle", "Circle")
                        ]
                        currentIndex: barModulesRoot.sysmonStyle === "circle" ? 1 : 0
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface0
                        textColor: ThemeBackend.text
                        activeTextColor: ThemeBackend.crust
                        onValueChanged: function(index, value) {
                            barModulesRoot.setSysmonStyle(index === 1 ? "circle" : "wave");
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_sysmon_cpu"
                    searchKeywords: "sysmon cpu processor load usage"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰍛"
                    title: I18n.t("guide.bar.sysmon.cpu.title", "CPU usage")
                    description: I18n.t("guide.bar.sysmon.cpu.desc", "Display processor utilization ring")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.isSysmonStatEnabled("cpu")
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.toggleSysmonStat("cpu", c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_sysmon_ram"
                    searchKeywords: "sysmon ram memory usage"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰘚"
                    title: I18n.t("guide.bar.sysmon.ram.title", "Memory usage")
                    description: I18n.t("guide.bar.sysmon.ram.desc", "Display memory (RAM) utilization ring")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.isSysmonStatEnabled("ram")
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.toggleSysmonStat("ram", c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_sysmon_temp"
                    searchKeywords: "sysmon temperature temp degrees"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰔏"
                    title: I18n.t("guide.bar.sysmon.temp.title", "Temperature")
                    description: I18n.t("guide.bar.sysmon.temp.desc", "Display system temperature ring")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.isSysmonStatEnabled("temp")
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.toggleSysmonStat("temp", c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_sysmon_disk"
                    searchKeywords: "sysmon disk storage usage space drive"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰋊"
                    title: I18n.t("guide.bar.sysmon.disk.title", "Disk usage")
                    description: I18n.t("guide.bar.sysmon.disk.desc", "Display storage disk utilization ring")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.isSysmonStatEnabled("disk")
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.toggleSysmonStat("disk", c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.battery", "Battery")
                moduleId: "bat"
                styles: barModulesRoot.batStyles
                currentStyle: barModulesRoot.batStyle
                styleSettingId: "bar_bat_style"
                styleKeywords: "battery style look visual classic minimal text ios android capsule"
                styleIcon: "󰂄"
                styleTitle: I18n.t("guide.bar.bat.style.title", "Battery style")
                styleDescription: I18n.t("guide.bar.bat.style.desc", "Choose the visual appearance of the battery indicator")
                onStyleSelected: id => barModulesRoot.setBatStyle(id)

                widgetComponent: Component {
                    BarPreviewWidget {
                        property string batStyle: variantId !== "" ? variantId : tab.batStyle
                        property bool batShowPercent: tab.batShowPercent
                        property bool batShowIcon: tab.batShowIcon
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_bat_show_percent"
                    searchKeywords: "battery charge percentage percent number"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰚥"
                    title: I18n.t("guide.bar.bat.show_percent.title", "Show percentage")
                    description: I18n.t("guide.bar.bat.show_percent.desc", "Display the numeric battery charge percentage")
                    visible: !barModulesRoot.isSideBar
                    searchable: !barModulesRoot.isSideBar
                    hiddenByConfig: barModulesRoot.isSideBar

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.batShowPercent
                        enabled: !checked || barModulesRoot.batShowIcon
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setBatShowPercent(c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_bat_show_icon"
                    searchKeywords: "battery icon symbol indicator"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰁹"
                    title: I18n.t("guide.bar.bat.show_icon.title", "Show icon")
                    description: I18n.t("guide.bar.bat.show_icon.desc", "Display the battery icon or graphic indicator")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.batShowIcon
                        enabled: !checked || barModulesRoot.batShowPercent
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setBatShowIcon(c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.network", "Network")
                moduleId: "wifi"
                styles: barModulesRoot.wifiStyles
                currentStyle: barModulesRoot.wifiStyle
                styleSettingId: "bar_wifi_style"
                styleKeywords: "network wifi style look button text layout"
                styleIcon: "󰤨"
                styleTitle: I18n.t("guide.bar.wifi.style.title", "Style")
                styleDescription: I18n.t("guide.bar.wifi.style.desc", "Choose the visual appearance of the network module")
                onStyleSelected: id => barModulesRoot.setWifiStyle(id)

                widgetComponent: Component {
                    BarPreviewWidget {
                        property string wifiStyle: variantId !== "" ? variantId : tab.wifiStyle
                        property bool wifiShowIcon: tab.wifiShowIcon
                        property bool wifiShowName: tab.wifiShowName
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_wifi_show_icon"
                    searchKeywords: "network wifi ethernet icon symbol indicator"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰤨"
                    title: I18n.t("guide.bar.wifi.show_icon.title", "Show icon")
                    description: I18n.t("guide.bar.wifi.show_icon.desc", "Display the network icon or signal indicator")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.wifiShowIcon
                        enabled: !checked || barModulesRoot.wifiShowName
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setWifiShowIcon(c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_wifi_show_name"
                    searchKeywords: "network wifi ethernet ssid name title"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰤥"
                    title: I18n.t("guide.bar.wifi.show_name.title", "Show name")
                    description: I18n.t("guide.bar.wifi.show_name.desc", "Display the network SSID or connection status text")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.wifiShowName
                        enabled: !checked || barModulesRoot.wifiShowIcon
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setWifiShowName(c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.bluetooth", "Bluetooth")
                moduleId: "bt"
                styles: barModulesRoot.btStyles
                currentStyle: barModulesRoot.btStyle
                styleSettingId: "bar_bt_style"
                styleKeywords: "bluetooth style look button text layout"
                styleIcon: "󰂲"
                styleTitle: I18n.t("guide.bar.bt.style.title", "Style")
                styleDescription: I18n.t("guide.bar.bt.style.desc", "Choose the visual appearance of the bluetooth module")
                onStyleSelected: id => barModulesRoot.setBtStyle(id)

                widgetComponent: Component {
                    BarPreviewWidget {
                        property string btStyle: variantId !== "" ? variantId : tab.btStyle
                        property bool btShowIcon: tab.btShowIcon
                        property bool btShowName: tab.btShowName
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_bt_show_icon"
                    searchKeywords: "bluetooth icon symbol indicator"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰂲"
                    title: I18n.t("guide.bar.bt.show_icon.title", "Show icon")
                    description: I18n.t("guide.bar.bt.show_icon.desc", "Display the bluetooth status icon")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.btShowIcon
                        enabled: !checked || barModulesRoot.btShowName
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setBtShowIcon(c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_bt_show_name"
                    searchKeywords: "bluetooth device name title connected"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰂯"
                    title: I18n.t("guide.bar.bt.show_name.title", "Show name")
                    description: I18n.t("guide.bar.bt.show_name.desc", "Display the connected bluetooth device name")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.btShowName
                        enabled: !checked || barModulesRoot.btShowIcon
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setBtShowName(c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.volume", "Volume")
                moduleId: "vol"
                styles: barModulesRoot.volStyles
                currentStyle: barModulesRoot.volStyle
                styleSettingId: "bar_vol_style"
                styleKeywords: "volume audio style look button text layout"
                styleIcon: "󰕾"
                styleTitle: I18n.t("guide.bar.vol.style.title", "Style")
                styleDescription: I18n.t("guide.bar.vol.style.desc", "Choose the visual appearance of the volume module")
                onStyleSelected: id => barModulesRoot.setVolStyle(id)

                widgetComponent: Component {
                    BarPreviewWidget {
                        property string volStyle: variantId !== "" ? variantId : tab.volStyle
                        property bool volShowIcon: tab.volShowIcon
                        property bool volShowPercent: tab.volShowPercent
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_vol_show_icon"
                    searchKeywords: "volume audio sound icon symbol indicator"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰕾"
                    title: I18n.t("guide.bar.vol.show_icon.title", "Show icon")
                    description: I18n.t("guide.bar.vol.show_icon.desc", "Display the volume speaker icon")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.volShowIcon
                        enabled: !checked || barModulesRoot.volShowPercent
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setVolShowIcon(c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_vol_show_percent"
                    searchKeywords: "volume percentage percent level audio sound"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰚥"
                    title: I18n.t("guide.bar.vol.show_percent.title", "Show percentage")
                    description: I18n.t("guide.bar.vol.show_percent.desc", "Display the numeric audio volume percentage")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.volShowPercent
                        enabled: !checked || barModulesRoot.volShowIcon
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setVolShowPercent(c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.keyboard", "Keyboard")
                moduleId: "kb"
                styles: barModulesRoot.kbStyles
                currentStyle: barModulesRoot.kbStyle
                styleSettingId: "bar_kb_style"
                styleKeywords: "keyboard layout style look button text layout"
                styleIcon: "󰌌"
                styleTitle: I18n.t("guide.bar.kb.style.title", "Style")
                styleDescription: I18n.t("guide.bar.kb.style.desc", "Choose the visual appearance of the keyboard module")
                onStyleSelected: id => barModulesRoot.setKbStyle(id)

                widgetComponent: Component {
                    BarPreviewWidget {
                        property string kbStyle: variantId !== "" ? variantId : tab.kbStyle
                        property bool kbShowIcon: tab.kbShowIcon
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_kb_show_icon"
                    searchKeywords: "keyboard layout icon symbol indicator"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰌌"
                    title: I18n.t("guide.bar.kb.show_icon.title", "Show icon")
                    description: I18n.t("guide.bar.kb.show_icon.desc", "Display the keyboard layout icon")
                    visible: !barModulesRoot.isSideBar
                    searchable: !barModulesRoot.isSideBar
                    hiddenByConfig: barModulesRoot.isSideBar

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.kbShowIcon
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setKbShowIcon(c);
                        }
                    }
                }
            }

            BarModuleCard {
                tab: barModulesRoot
                title: I18n.t("guide.bar.modules.media", "Media")
                moduleId: "media"
                previewSideHeight: 160

                widgetComponent: Component {
                    BarPreviewWidget {
                        property string mediaInfoMode: tab.mediaInfoMode
                        property int mediaWidth: tab.mediaWidth
                        property bool mediaShowIcon: tab.mediaShowIcon
                        property bool mediaShowControls: tab.mediaShowControls
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_media_info_mode"
                    searchKeywords: "media song track duration time position length author artist"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰥔"
                    title: I18n.t("guide.bar.media.info_mode.title", "Secondary info")
                    description: I18n.t("guide.bar.media.info_mode.desc", "Choose whether to show the song duration or its author")
                    visible: !barModulesRoot.isSideBar
                    searchable: !barModulesRoot.isSideBar
                    hiddenByConfig: barModulesRoot.isSideBar

                    Switch {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        implicitWidth: rootObj.s(200)
                        implicitHeight: rootObj.s(32)
                        cornerRadius: ThemeBackend.borderRadius
                        fontPixelSize: rootObj.s(11)
                        options: [
                            I18n.t("guide.bar.media.info_mode.duration", "Duration"),
                            I18n.t("guide.bar.media.info_mode.author", "Author")
                        ]
                        currentIndex: barModulesRoot.mediaInfoMode === "author" ? 1 : 0
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface0
                        textColor: ThemeBackend.text
                        activeTextColor: ThemeBackend.crust
                        onToggled: function(idx) {
                            barModulesRoot.setMediaInfoMode(idx === 1 ? "author" : "duration");
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_media_width"
                    searchKeywords: "media song track size width length resize"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰩨"
                    title: I18n.t("guide.bar.media.width.title", "Width")
                    description: I18n.t("guide.bar.media.width.desc", "Width of the song title area")
                    visible: !barModulesRoot.isSideBar
                    searchable: !barModulesRoot.isSideBar
                    hiddenByConfig: barModulesRoot.isSideBar

                    Draggable {
                        id: mediaSizeSlider
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.rightMargin: rootObj.s(8)
                        implicitWidth: rootObj.s(220)
                        implicitHeight: rootObj.s(18)
                        from: 80
                        to: 300
                        stepSize: 1
                        defaultValue: 120
                        showValueBubble: true
                        valueFormatter: function(v) { return Math.round(v) + "px" }
                        value: barModulesRoot.mediaWidth
                        backgroundColor: ThemeBackend.surface0
                        accentColor: ThemeBackend.mauve
                        handleColor: ThemeBackend.text
                        handleBorderColor: ThemeBackend.mantle
                        onMoved: function(val) {
                            barModulesRoot.mediaWidth = Math.round(val);
                        }
                        onDragFinished: {
                            barModulesRoot.setMediaWidth(barModulesRoot.mediaWidth);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_media_show_icon"
                    searchKeywords: "media song track icon album art cover thumbnail"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰎈"
                    title: I18n.t("guide.bar.media.show_icon.title", "Show icon")
                    description: I18n.t("guide.bar.media.show_icon.desc", "Display the album art or music icon")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.mediaShowIcon
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setMediaShowIcon(c);
                        }
                    }
                }

                SettingsRow {
                    rootObj: barModulesRoot.rootObj
                    settingId: "bar_media_show_controls"
                    searchKeywords: "media song track controls buttons play pause previous next"
                    baseColor: Qt.alpha(ThemeBackend.surface1, 0.35)
                    icon: "󰐊"
                    title: I18n.t("guide.bar.media.show_controls.title", "Show controls")
                    description: I18n.t("guide.bar.media.show_controls.desc", "Display the previous, play and next buttons")

                    Toggle {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        checked: barModulesRoot.mediaShowControls
                        accentColor: ThemeBackend.mauve
                        baseColor: ThemeBackend.surface1
                        handleColor: ThemeBackend.crust
                        handleOffColor: ThemeBackend.text
                        onToggled: function(c) {
                            barModulesRoot.setMediaShowControls(c);
                        }
                    }
                }
            }
        }
    }
}
