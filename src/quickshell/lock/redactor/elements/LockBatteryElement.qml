import QtQuick
import "../../../"
import "../../../reusables"

Item {
    id: el

    property string variant: "filled"
    property var ctx: null

    readonly property bool plain: el.variant === "plain"

    visible: !el.ctx || !el.ctx.root.isDesktop

    ClickButton {
        anchors.fill: parent
        cornerRadius: ThemeBackend.borderRadius
        horizontalPadding: Scaler.s(12)
        buttonIcon: el.ctx ? el.ctx.root.batIcon : "󰁹"
        iconFontSize: Scaler.s(14)
        buttonText: el.ctx ? el.ctx.root.batPercent : "87%"
        textFontSize: Scaler.s(12)
        accentColor: el.plain ? "transparent" : Qt.lighter(ThemeBackend.surface0, 1.28)
        textColor: el.ctx ? el.ctx.root.batDynamicColor : ThemeBackend.text
    }
}
