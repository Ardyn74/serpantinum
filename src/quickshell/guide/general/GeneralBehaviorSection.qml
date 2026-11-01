import QtQuick
import "../../"
import "../../reusables"
import "../../reusables/guide"

SettingsBlob {
    id: section
    required property var tab
    readonly property var rootObj: tab.rootObj

    SettingsRow {
        rootObj: section.tab.rootObj
        icon: "󱓞"
        title: I18n.t("guide.general.quickactions.title") || "Quickactions"
        description: I18n.t("guide.general.quickactions.desc") || "Enable floating quickactions overlay"

        Toggle {
            checked: section.tab.quickactions
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                section.tab.quickactions = c;
                section.tab.updateGeneralSettings();
            }
        }
    }

    SettingsRow {
        rootObj: section.tab.rootObj
        icon: "󰍜"
        title: I18n.t("guide.general.quickactions_edge.title") || "Screen Edge Triggers"
        description: I18n.t("guide.general.quickactions_edge.desc") || "Open quickactions menu when cursor hits screen edges"

        Toggle {
            checked: section.tab.quickactionsEdgeTrigger
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                section.tab.quickactionsEdgeTrigger = c;
                section.tab.updateGeneralSettings();
            }
        }
    }

    SettingsRow {
        rootObj: section.tab.rootObj
        icon: "󰖲"
        title: I18n.t("guide.general.separatewindow.title") || "Make settings a separate window"
        description: I18n.t("guide.general.separatewindow.desc") || "Open settings as a regular resizable app window instead of a panel inside the shell"

        Toggle {
            checked: section.tab.settingsSeparateWindow
            accentColor: ThemeBackend.mauve
            baseColor: ThemeBackend.surface1
            handleColor: ThemeBackend.crust
            handleOffColor: ThemeBackend.text
            onToggled: function(c) {
                section.tab.settingsSeparateWindow = c;
                section.tab.updateGeneralSettings();
            }
        }
    }
}
