import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../"
import "../reusables"

Rectangle {
    id: resultsRoot
    required property var popup
    property alias list: resultsView
    color: ThemeBackend.base
    visible: opacity > 0.001
    opacity: popup.searchActive ? 1.0 : 0.0
    enabled: popup.searchActive

    Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    Connections {
        target: popup
        function onSearchSelectedIndexChanged() {
            if (popup.searchSelectedIndex >= 0) resultsView.positionViewAtIndex(popup.searchSelectedIndex, ListView.Contain);
        }
    }

    ListView {
        id: resultsView
        anchors.fill: parent
        anchors.leftMargin: popup.s(20)
        anchors.rightMargin: popup.s(20)
        anchors.bottomMargin: popup.s(12)
        spacing: popup.s(4)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: popup.flatSearchResults
        reuseItems: false

        ScrollBar.vertical: ScrollBar {
            width: popup.s(4)
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle {
                implicitWidth: popup.s(4)
                radius: popup.s(2)
                color: ThemeBackend.surface2
            }
        }

        delegate: Rectangle {
            id: row
            required property var modelData
            required property int index
            readonly property bool selected: popup.searchSelectedIndex === index
            readonly property string desc: popup.resolveI18nText(modelData.desc || modelData.description || "")

            width: resultsView.width
            height: popup.s(desc !== "" ? 58 : 46)
            radius: ThemeBackend.borderRadius
            color: selected ? Qt.alpha(ThemeBackend.mauve, 0.16) : (rowMa.containsMouse ? Qt.alpha(ThemeBackend.surface1, 0.4) : "transparent")
            Behavior on color { ColorAnimation { duration: 100 } }

            MouseArea {
                id: rowMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: popup.selectSearchResult(row.modelData)
                onPositionChanged: popup.searchSelectedIndex = row.index
            }

            RowLayout {
                layoutDirection: I18n.layoutDirection
                anchors.fill: parent
                anchors.leftMargin: popup.s(14)
                anchors.rightMargin: popup.s(14)
                spacing: popup.s(14)

                Text {
                    text: row.modelData.icon || "󰒓"
                    font.family: ThemeBackend.iconFont
                    font.pixelSize: popup.s(18)
                    color: row.selected ? ThemeBackend.mauve : ThemeBackend.subtext0
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: popup.s(1)

                    Text {
                        Layout.fillWidth: true
                        text: popup.resolveI18nText(row.modelData.title)
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: popup.s(13)
                        font.weight: Font.DemiBold
                        color: ThemeBackend.text
                        horizontalAlignment: I18n.textAlignment
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: row.desc
                        font.family: ThemeBackend.fontFamily
                        font.pixelSize: popup.s(11)
                        color: ThemeBackend.subtext0
                        horizontalAlignment: I18n.textAlignment
                        elide: Text.ElideRight
                    }
                }

                Text {
                    text: popup.breadcrumb(row.modelData)
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: popup.s(11)
                    color: ThemeBackend.subtext0
                    opacity: 0.8
                    elide: Text.ElideRight
                    Layout.maximumWidth: resultsView.width * 0.35
                    Layout.alignment: Qt.AlignVCenter
                    visible: !popup.compact
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: popup.s(40)
            visible: popup.searchActive && resultsView.count === 0
            text: popup.searchQuery.trim() === "" ? I18n.t("guide.search.prompt", "Type to search settings...") : I18n.t("guide.search.no_results", "No settings found")
            font.family: ThemeBackend.fontFamily
            font.pixelSize: popup.s(13)
            color: ThemeBackend.subtext0
        }
    }
}
