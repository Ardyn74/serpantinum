import QtQuick
import "../../../"
import "../../../reusables"

Item {
    id: el

    property string variant: "filled"
    property var ctx: null

    readonly property bool plain: el.variant === "plain"

    ClickButton {
        anchors.fill: parent
        cornerRadius: ThemeBackend.borderRadius
        horizontalPadding: Scaler.s(12)
        buttonIcon: "󰌌"
        iconFontSize: Scaler.s(14)
        buttonText: el.ctx ? el.ctx.root.kbLayout : "US"
        textFontSize: Scaler.s(12)
        accentColor: el.plain ? "transparent" : Qt.lighter(ThemeBackend.surface0, 1.28)
        textColor: ThemeBackend.text
        onClicked: if (el.ctx) el.ctx.root.switchKbLayout()
    }
}
