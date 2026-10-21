import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../"
import "../reusables"
import "../reusables/buttons"

Item {
    id: contentArea
    required property var popup
    property alias searchInput: searchField
    property alias searchResults: resultsList

    readonly property real headerHeight: popup.s(64)
    readonly property real bodyMaxWidth: popup.s(960)

    Item {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: contentArea.headerHeight

        RowLayout {
            layoutDirection: I18n.layoutDirection
            anchors.fill: parent
            anchors.leftMargin: popup.s(20)
            anchors.rightMargin: popup.s(20)
            spacing: popup.s(16)

            Text {
                visible: !popup.searchActive
                text: popup.currentTitle
                font.family: ThemeBackend.fontFamily
                font.pixelSize: popup.s(20)
                font.weight: Font.DemiBold
                color: ThemeBackend.text
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: popup.compact ? popup.s(160) : popup.s(300)
            }

            Item { Layout.fillWidth: true; visible: !popup.searchActive }

            Input {
                id: searchField
                visible: popup.searchActive
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.preferredHeight: popup.s(38)
                implicitHeight: popup.s(38)
                placeholderText: I18n.t("guide.search.placeholder", "Search settings...")
                showClearButton: true
                fontPixelSize: popup.s(12)
                baseColor: Qt.alpha(ThemeBackend.surface0, 0.6)
                accentColor: ThemeBackend.mauve
                textColor: ThemeBackend.text
                subTextColor: ThemeBackend.subtext0
                borderColor: Qt.alpha(ThemeBackend.surface2, 0.4)
                cornerRadius: ThemeBackend.borderRadius

                onHasFocusChanged: {
                    if (hasFocus && !popup.searchActive) popup.openSearch();
                }
                onTextEdited: (txt) => {
                    if (!popup.searchActive) popup.openSearch();
                    popup.searchQuery = txt;
                    popup.searchSelectedIndex = 0;
                }
                onCleared: {
                    popup.searchQuery = "";
                    popup.searchSelectedIndex = 0;
                }

                Keys.onEscapePressed: (event) => {
                    if (popup.searchQuery !== "") {
                        searchField.text = "";
                        popup.searchQuery = "";
                    } else {
                        popup.closeSearch();
                    }
                    event.accepted = true;
                }
                Keys.onDownPressed: (event) => { popup.navigateSearch(1); event.accepted = true; }
                Keys.onUpPressed: (event) => { popup.navigateSearch(-1); event.accepted = true; }
                Keys.onReturnPressed: (event) => { popup.activateSelectedSearch(); event.accepted = true; }
                Keys.onEnterPressed: (event) => { popup.activateSelectedSearch(); event.accepted = true; }
            }
        }
    }

    Item {
        id: body
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width, contentArea.bodyMaxWidth)

        Rectangle {
            anchors.fill: parent
            color: ThemeBackend.base
            visible: popup.searchActive
            z: 2

            GuideSearchResults {
                id: resultsList
                popup: contentArea.popup
                anchors.fill: parent
                anchors.leftMargin: popup.s(16)
                anchors.rightMargin: popup.s(16)
                anchors.bottomMargin: popup.s(8)
            }
        }

    Repeater {
        id: contentRepeater
        model: popup.tabsModel
        delegate: Item {
            id: tabContentWrapper
            anchors.fill: parent

            property int parentTabIndex: index
            property int tabIndex: parentTabIndex
            property var tabData: modelData
            property bool hasSubtabs: Boolean(tabData.subtabs && tabData.subtabs.length > 0)
            property alias singleLoader: singleTabLoader
            property alias subLoadersRepeater: subRepeat

            property bool isCurrent: popup.currentTab === parentTabIndex
            visible: isCurrent || opacity > 0.001
            opacity: isCurrent ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }

            Loader {
                id: singleTabLoader
                anchors.fill: parent
                asynchronous: false
                active: !tabContentWrapper.hasSubtabs
                visible: !tabContentWrapper.hasSubtabs && tabContentWrapper.visible
                property int tabIndex: tabContentWrapper.parentTabIndex
                property int subTabIndex: -1

                function ensureLoaded() {
                    if (status === Loader.Null && tabData.file) {
                        setSource(tabData.file, {
                            "rootObj": popup,
                            "tabIndex": tabContentWrapper.parentTabIndex
                        });
                    }
                }

                onStatusChanged: {
                    if (status === Loader.Error) {
                        console.warn("Guide tab failed to load:", source);
                    }
                }

                onLoaded: {
                    popup.registerTabSearchItems(item);
                    Qt.callLater(function() {
                        popup.registerTabSearchItems(singleTabLoader.item);
                    });
                }

                Component.onCompleted: {
                    if (popup.standalone || popup.currentTab === tabContentWrapper.parentTabIndex) ensureLoaded();
                }

                Connections {
                    target: popup
                    function onCurrentTabChanged() {
                        if (popup.currentTab === tabContentWrapper.parentTabIndex && !tabContentWrapper.hasSubtabs) singleTabLoader.ensureLoaded();
                    }
                    function onRequestLoad(order) {
                        if (order === popup.tabLoadOrder(tabContentWrapper.parentTabIndex, -1)) singleTabLoader.ensureLoaded();
                    }
                }

                Connections {
                    target: singleTabLoader.item
                    ignoreUnknownSignals: true
                    function onSearchItemsChanged() {
                        popup.registerTabSearchItems(singleTabLoader.item);
                    }
                    function onSearchEntriesChanged() {
                        popup.registerTabSearchItems(singleTabLoader.item);
                    }
                }
            }

            Repeater {
                id: subRepeat
                model: tabContentWrapper.hasSubtabs ? tabData.subtabs : []

                delegate: Loader {
                    id: subTabLoader
                    anchors.fill: parent
                    asynchronous: false
                    property int subIndex: index
                    property int tabIndex: tabContentWrapper.parentTabIndex
                    property int subTabIndex: subIndex
                    property var subData: modelData

                    property bool isSubCurrent: popup.currentTab === tabContentWrapper.parentTabIndex && popup.currentSubTab === subIndex
                    visible: isSubCurrent || opacity > 0.001
                    opacity: isSubCurrent ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                    }

                    function ensureLoaded() {
                        if (status === Loader.Null && subData.file) {
                            setSource(subData.file, {
                                "rootObj": popup,
                                "tabIndex": tabContentWrapper.parentTabIndex
                            });
                            if (item && item.subTabIndex !== undefined) {
                                item.subTabIndex = subIndex;
                            }
                        }
                    }

                    onStatusChanged: {
                        if (status === Loader.Error) {
                            console.warn("Guide tab failed to load:", source);
                        }
                    }

                    onLoaded: {
                        if (item && item.subTabIndex !== undefined) {
                            item.subTabIndex = subIndex;
                        }
                        popup.registerTabSearchItems(item);
                        Qt.callLater(function() {
                            popup.registerTabSearchItems(subTabLoader.item);
                        });
                    }

                    Component.onCompleted: {
                        if (popup.standalone || isSubCurrent) ensureLoaded();
                    }

                    Connections {
                        target: popup
                        function onCurrentTabChanged() {
                            if (popup.currentTab === tabContentWrapper.parentTabIndex && popup.currentSubTab === subIndex) subTabLoader.ensureLoaded();
                        }
                        function onCurrentSubTabChanged() {
                            if (popup.currentTab === tabContentWrapper.parentTabIndex && popup.currentSubTab === subIndex) subTabLoader.ensureLoaded();
                        }
                        function onRequestLoad(order) {
                            if (order === popup.tabLoadOrder(tabContentWrapper.parentTabIndex, subIndex)) subTabLoader.ensureLoaded();
                        }
                    }

                    Connections {
                        target: subTabLoader.item
                        ignoreUnknownSignals: true
                        function onSearchItemsChanged() {
                            popup.registerTabSearchItems(subTabLoader.item);
                        }
                        function onSearchEntriesChanged() {
                            popup.registerTabSearchItems(subTabLoader.item);
                        }
                    }
                }
            }
        }
    }
    }
}
