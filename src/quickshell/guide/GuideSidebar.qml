import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../"
import "../reusables"
import "../reusables/buttons"

Rectangle {
    id: sidebar
    required property var popup
    property alias tabsView: tabsFlickable
    property alias tabsItems: tabsRepeater

    x: I18n.rtl ? (parent.width - width) : 0
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: popup.compact ? popup.s(64) : popup.s(232)
    color: Qt.alpha(ThemeBackend.surface0, 0.35)

    Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: popup.s(12)
        spacing: popup.s(8)

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: popup.s(44)
            Layout.leftMargin: popup.s(10)
            visible: !popup.compact
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: I18n.textAlignment
            text: I18n.t("guide.settings", "Settings")
            font.family: ThemeBackend.fontFamily
            font.pixelSize: popup.s(15)
            font.weight: Font.DemiBold
            color: ThemeBackend.text
        }

        Item {
            visible: popup.compact
            Layout.preferredHeight: popup.s(8)
        }

        Flickable {
            id: tabsFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: tabsCol.implicitHeight
            contentWidth: width
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: tabsCol
                width: tabsFlickable.width
                spacing: popup.s(2)

                Repeater {
                    id: tabsRepeater
                    model: popup.tabsModel
                    delegate: ColumnLayout {
                        id: tabDelegate
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        spacing: popup.s(2)

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: popup.s(6)
                            Layout.bottomMargin: popup.s(6)
                            Layout.leftMargin: popup.s(10)
                            Layout.rightMargin: popup.s(10)
                            Layout.preferredHeight: 1
                            visible: !!tabDelegate.modelData.separatorBefore
                            color: Qt.alpha(ThemeBackend.surface2, 0.4)
                        }

                        Rectangle {
                            id: item
                            Layout.fillWidth: true
                            Layout.preferredHeight: popup.s(38)
                            radius: ThemeBackend.borderRadius

                            readonly property bool active: popup.currentTab === tabDelegate.index
                            color: active ? Qt.alpha(ThemeBackend.mauve, 0.16) : (itemMa.containsMouse ? Qt.alpha(ThemeBackend.surface1, 0.45) : "transparent")
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Rectangle {
                                x: 0
                                anchors.verticalCenter: parent.verticalCenter
                                width: popup.s(3)
                                height: item.active ? popup.s(18) : 0
                                radius: width / 2
                                color: ThemeBackend.mauve
                                Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            }

                            RowLayout {
                                layoutDirection: I18n.layoutDirection
                                anchors.fill: parent
                                anchors.leftMargin: popup.compact ? 0 : popup.s(14)
                                anchors.rightMargin: popup.compact ? 0 : popup.s(10)
                                spacing: popup.s(12)

                                Text {
                                    text: tabDelegate.modelData.icon || "󰒓"
                                    font.family: ThemeBackend.iconFont
                                    font.pixelSize: popup.s(17)
                                    color: item.active ? ThemeBackend.mauve : ThemeBackend.subtext0
                                    Layout.alignment: Qt.AlignVCenter | (popup.compact ? Qt.AlignHCenter : 0)
                                    Layout.fillWidth: popup.compact
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: popup.compact ? -1 : popup.s(20)
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                Text {
                                    visible: !popup.compact
                                    text: I18n.t("guide.tabs." + (tabDelegate.modelData.key || tabDelegate.modelData.id).toLowerCase(), tabDelegate.modelData.name || tabDelegate.modelData.id)
                                    font.family: ThemeBackend.fontFamily
                                    font.pixelSize: popup.s(13)
                                    font.weight: item.active ? Font.DemiBold : Font.Medium
                                    color: item.active ? ThemeBackend.text : ThemeBackend.subtext0
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    horizontalAlignment: I18n.textAlignment
                                    elide: Text.ElideRight
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }
                            }

                            MouseArea {
                                id: itemMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    popup.currentTab = tabDelegate.index;
                                    popup.currentSubTab = 0;
                                    popup.closeSearch();
                                    popup.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }
        }

        ClickButton {
            visible: Updater.updateAvailable
            Layout.fillWidth: true
            implicitHeight: popup.s(38)
            cornerRadius: ThemeBackend.borderRadius
            buttonText: popup.compact ? "" : I18n.t("guide.update_available")
            buttonIcon: "󰚰"
            iconFontSize: popup.s(16)
            textFontSize: popup.s(13)
            accentColor: ThemeBackend.green
            textColor: ThemeBackend.crust
            onClicked: popup.gotoTab("about")
        }
    }
}
