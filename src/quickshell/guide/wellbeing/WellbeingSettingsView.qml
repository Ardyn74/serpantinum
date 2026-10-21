import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../"
import "../../reusables"
import "../../reusables/guide"
import "../../reusables/buttons"
import "../../reusables/inputs"

Flickable {
    id: sv
    required property var tab
    readonly property var rootObj: tab.rootObj
    readonly property int defaultAppLimitMinutes: 60

    readonly property var limitedClasses: Object.keys(tab.appLimits)
    readonly property var limitCandidates: tab.allKnownApps.filter(function(a) { return tab.appLimits[a.class] === undefined; })
    readonly property var excludeCandidates: tab.allKnownApps.filter(function(a) { return tab.excludedApps.indexOf(a.class) === -1; })

    anchors.fill: parent
    contentWidth: width
    contentHeight: settingsColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height

    opacity: tab.settingsViewFocus
    visible: opacity > 0
    transform: Translate { y: rootObj.s(40) * (1 - sv.tab.settingsViewFocus) }

    ScrollBar.vertical: ScrollBar {
        active: sv.moving
        width: rootObj.s(4)
        policy: ScrollBar.AsNeeded
        contentItem: Rectangle { implicitWidth: rootObj.s(4); radius: rootObj.s(2); color: ThemeBackend.surface2 }
    }

    component AppLabel: RowLayout {
        required property var view
        id: appLabel
        property string appClass: ""
        readonly property var info: view.tab.appInfo(appClass)
        spacing: view.rootObj.s(10)

        Rectangle {
            Layout.preferredWidth: view.rootObj.s(32)
            Layout.preferredHeight: view.rootObj.s(32)
            radius: Math.round(view.rootObj.s(32) * 0.28)
            color: ThemeBackend.surface0

            Image {
                anchors.fill: parent
                anchors.margins: view.rootObj.s(4)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                mipmap: true
                visible: status === Image.Ready
                source: view.tab.iconSource(appLabel.info.icon)
            }

            Text {
                anchors.centerIn: parent
                visible: !appLabel.info.icon
                text: appLabel.info.name ? appLabel.info.name.charAt(0).toUpperCase() : "?"
                font.family: ThemeBackend.fontFamily
                font.pixelSize: view.rootObj.s(13)
                font.bold: true
                color: view.tab.textMain
            }
        }

        Text {
            Layout.fillWidth: true
            elide: Text.ElideRight
            font.family: ThemeBackend.fontFamily
            font.pixelSize: view.rootObj.s(13)
            color: ThemeBackend.text
            text: appLabel.info.name
        }
    }

    component LimitStepper: NumberSelector {
        required property var view
        implicitWidth: view.rootObj.s(150)
        implicitHeight: view.rootObj.s(32)
        stepSize: 15
        decimals: 0
        suffix: " min"
        baseColor: ThemeBackend.surface0
        accentColor: ThemeBackend.mauve
        buttonColor: ThemeBackend.surface1
        buttonTextColor: ThemeBackend.text
        textColor: ThemeBackend.text
        subTextColor: ThemeBackend.subtext0
        borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
        cornerRadius: ThemeBackend.borderRadius
        fontPixelSize: view.rootObj.s(11)
    }

    component AppPicker: Dropdown {
        required property var view
        id: picker
        property var candidates: []
        signal picked(string appClass)
        implicitWidth: view.rootObj.s(180)
        implicitHeight: view.rootObj.s(32)
        enabled: candidates.length > 0
        options: candidates.map(function(a) { return a.name; })
        currentIndex: -1
        placeholderText: I18n.t("guide.wellbeing.settings.add_app")
        accentColor: ThemeBackend.mauve
        baseColor: ThemeBackend.surface0
        borderColor: Qt.alpha(ThemeBackend.surface2, 0.6)
        fontPixelSize: view.rootObj.s(11)
        onSelected: function(index, value) {
            if (index >= 0 && index < candidates.length) picked(candidates[index].class);
            currentIndex = -1;
        }
    }

    component RemoveButton: CloseButton {
        required property var view
        Layout.preferredWidth: view.rootObj.s(32)
        Layout.preferredHeight: view.rootObj.s(32)
        size: view.rootObj.s(32)
        cornerRadius: ThemeBackend.borderRadius
        iconFontSize: view.rootObj.s(15)
        accentColor: ThemeBackend.surface1
        textColor: isHoveredOrHighlighted ? ThemeBackend.red : ThemeBackend.subtext0
    }

    component EmptyHint: Text {
        required property var view
        Layout.fillWidth: true
        Layout.margins: view.rootObj.s(14)
        Layout.topMargin: view.rootObj.s(2)
        font.family: ThemeBackend.fontFamily
        font.pixelSize: view.rootObj.s(12)
        color: ThemeBackend.subtext0
        wrapMode: Text.WordWrap
    }

    ColumnLayout {
        id: settingsColumn
        width: sv.width
        spacing: rootObj.s(8)

        SettingsBlob {
            SettingsRow {
                rootObj: sv.rootObj
                icon: "󰔛"
                title: I18n.t("guide.wellbeing.settings.overall_limit")
                description: I18n.t("guide.wellbeing.settings.overall_limit_desc")

                LimitStepper {
                    view: sv
                    from: 0
                    to: 1440
                    specialZeroText: I18n.t("guide.wellbeing.settings.off")
                    value: Math.round(sv.tab.overallLimitSeconds / 60)
                    onValueChanged: sv.tab.setOverallLimit(Math.round(value) * 60)
                }
            }
        }

        SettingsBlob {
            SettingsRow {
                rootObj: sv.rootObj
                icon: "󰀻"
                title: I18n.t("guide.wellbeing.settings.app_limits")
                description: I18n.t("guide.wellbeing.settings.app_limits_desc")

                AppPicker {
                    view: sv
                    candidates: sv.limitCandidates
                    onPicked: function(appClass) { sv.tab.setAppLimit(appClass, sv.defaultAppLimitMinutes * 60); }
                }
            }

            EmptyHint {
                view: sv
                visible: sv.limitedClasses.length === 0
                text: I18n.t("guide.wellbeing.settings.no_limits")
            }

            Repeater {
                model: sv.limitedClasses

                delegate: SettingsRow {
                    id: limitRow
                    rootObj: sv.rootObj
                    required property string modelData
                    customLeftContent: Component { AppLabel { view: sv; appClass: limitRow.modelData } }

                    LimitStepper {
                    view: sv
                        from: 5
                        to: 1440
                        value: Math.round((Number(sv.tab.appLimits[limitRow.modelData]) || 0) / 60)
                        onValueChanged: {
                            let secs = Math.round(value) * 60;
                            if (secs >= 300 && secs !== Number(sv.tab.appLimits[limitRow.modelData])) sv.tab.setAppLimit(limitRow.modelData, secs);
                        }
                    }

                    RemoveButton { view: sv; onClicked: sv.tab.setAppLimit(limitRow.modelData, 0) }
                }
            }
        }

        SettingsBlob {
            SettingsRow {
                rootObj: sv.rootObj
                icon: "󰈉"
                title: I18n.t("guide.wellbeing.settings.excluded_apps")
                description: I18n.t("guide.wellbeing.settings.excluded_apps_desc")

                AppPicker {
                    view: sv
                    candidates: sv.excludeCandidates
                    onPicked: function(appClass) { sv.tab.setAppExcluded(appClass, true); }
                }
            }

            EmptyHint {
                view: sv
                visible: sv.tab.excludedApps.length === 0
                text: I18n.t("guide.wellbeing.settings.no_excluded")
            }

            Repeater {
                model: sv.tab.excludedApps

                delegate: SettingsRow {
                    id: excludedRow
                    rootObj: sv.rootObj
                    required property string modelData
                    customLeftContent: Component { AppLabel { view: sv; appClass: excludedRow.modelData } }

                    RemoveButton { view: sv; onClicked: sv.tab.setAppExcluded(excludedRow.modelData, false) }
                }
            }
        }

        Item { Layout.preferredHeight: rootObj.s(4) }
    }
}
