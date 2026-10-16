import QtQuick
import "../../"
import "../"
import "glassNesting.js" as Nesting

Item {
    id: root

    property real radius: 0
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius
    property color tintColor: ThemeBackend.base
    property real tintAmount: 0.35
    property real frost: 1.5
    property real rim: 0.45
    property real saturation: 1.2
    property real thickness: -1
    property real tintStrength: 0.5
    property real shadow: 0
    property real press: 0
    property real pulse: 0
    readonly property real pad: shadow > 0 ? 12 : 0

    readonly property bool isGlassFill: true
    property bool allowed: true
    property bool forceClear: false
    property int nestLevel: 0
    readonly property real nest: Math.min(1, nestLevel * 0.5)
    property Item backdrop: null
    property Item registeredBackdrop: null

    readonly property bool active: allowed && tintColor.a > 0.02 && root.visible && ThemeBackend.liquidGlass && backdrop !== null && backdrop.active && width > 0 && height > 0

    function findBackdrop() {
        let e = root.parent;
        let d = 0;
        while (e && d < 48) {
            if (e.glassBackdropItem !== undefined) {
                root.explicitOwner = e;
                return e.glassBackdropItem;
            }
            e = e.parent;
            d++;
        }
        root.explicitOwner = null;
        let a = root.parent;
        let depth = 0;
        while (a && depth < 32) {
            const kids = a.children;
            if (kids) {
                for (let i = 0; i < kids.length; i++) {
                    if (kids[i] && kids[i].isGlassBackdrop === true && kids[i].surfaceEnabled !== false) return kids[i];
                }
            }
            a = a.parent;
            depth++;
        }
        a = root.parent;
        depth = 0;
        while (a && depth < 32) {
            const kids = a.children;
            if (kids) {
                for (let i = 0; i < kids.length; i++) {
                    const sub = kids[i] ? kids[i].children : null;
                    if (!sub) continue;
                    for (let j = 0; j < sub.length; j++) {
                        if (sub[j] && sub[j].isGlassBackdrop === true && sub[j].surfaceEnabled !== false) return sub[j];
                    }
                }
            }
            a = a.parent;
            depth++;
        }
        return null;
    }

    function resolve() {
        root.backdrop = root.findBackdrop();
        root.nestLevel = Nesting.nestLevel(root, root.backdrop ? root.backdrop.parent : null, false);
    }

    function register() {
        unregister();
        if (root.active) {
            root.backdrop.consumers++;
            root.registeredBackdrop = root.backdrop;
        }
    }

    function unregister() {
        if (root.registeredBackdrop) {
            root.registeredBackdrop.consumers--;
            root.registeredBackdrop = null;
        }
    }

    property int resolveAttempts: 0
    property Item explicitOwner: null

    Connections {
        target: root.explicitOwner
        ignoreUnknownSignals: true
        function onGlassBackdropItemChanged() { root.resolve(); }
    }

    Timer {
        interval: 450
        repeat: true
        running: (root.backdrop === null || !root.backdrop.active) && root.allowed && ThemeBackend.liquidGlass && root.visible && root.resolveAttempts < 24
        onTriggered: {
            root.resolveAttempts++;
            root.resolve();
        }
    }

    onActiveChanged: register()
    onBackdropChanged: register()
    onParentChanged: resolve()
    Component.onCompleted: resolve()
    Component.onDestruction: unregister()

    Connections {
        target: ThemeBackend
        function onLiquidGlassChanged() { root.resolve(); }
    }

    property point origin: {
        if (!root.backdrop) return Qt.point(0, 0);
        void root.backdrop.frame;
        return root.backdrop.mapFromItem(root, 0, 0);
    }

    LiquidGlass {
        anchors.fill: parent
        anchors.margins: -root.pad
        glassPad: root.pad
        shadowAmt: root.shadow * (1 - 0.6 * root.nest)
        nest: root.nest
        morph: 1
        clear: (root.forceClear || root.nestLevel >= 1) ? 1 : 0
        energy: Math.min(1, root.press + root.pulse)
        visible: root.active
        src: root.backdrop ? root.backdrop.texture : null
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
        tintColor: root.tintColor
        tintAmount: root.tintAmount * root.tintStrength * (1 - 0.5 * root.nest)
        frost: root.nestLevel >= 1 ? Math.min(root.frost, 1.0) : root.frost
        rim: root.rim * (1 - 0.35 * root.nest)
        saturation: 1 + (root.saturation - 1) * (1 - root.nest)
        bezel: Math.max(3, Math.min(14, Math.min(root.width, root.height) * 0.28))
        thickness: root.thickness >= 0 ? root.thickness : bezel * 0.8
        sourceRect: root.backdrop ? Qt.rect((root.origin.x - root.pad) / Math.max(1, root.backdrop.width), (root.origin.y - root.pad) / Math.max(1, root.backdrop.height), (root.width + 2 * root.pad) / Math.max(1, root.backdrop.width), (root.height + 2 * root.pad) / Math.max(1, root.backdrop.height)) : Qt.rect(0, 0, 1, 1)
        cursorPos: root.backdrop ? Qt.point(root.backdrop.cursorX - root.origin.x + root.pad, root.backdrop.cursorY - root.origin.y + root.pad) : Qt.point(0, 0)
        hover: root.backdrop ? root.backdrop.hoverAmount : 0
    }
}
