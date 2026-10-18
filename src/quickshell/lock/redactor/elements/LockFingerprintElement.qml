import QtQuick
import "../../"
import "../../../"

Item {
    id: el

    property string variant: "labeled"
    property var ctx: null

    visible: !el.ctx || el.ctx.root.fingerprintAvailable
    implicitWidth: Scaler.s(200)
    implicitHeight: Scaler.s(72)

    readonly property bool labeled: el.variant === "labeled"

    FingerprintIndicator {
        anchors.centerIn: parent
        status: el.ctx ? el.ctx.lockUI.fpState : "ready"
        label: el.ctx ? el.ctx.lockUI.fpLabel : I18n.t("lock.fingerprint.ready")
        attempts: el.ctx ? el.ctx.lockUI.fpFailures : 0
        maxAttempts: el.ctx ? el.ctx.root.fingerprintMaxAttempts : 5
        showLabel: el.labeled
        glyphSize: Math.max(Scaler.s(24), Math.min(el.width, el.height - (el.labeled ? Scaler.s(24) : 0)) * 0.9)
        labelPixelSize: Scaler.s(12)
    }
}
