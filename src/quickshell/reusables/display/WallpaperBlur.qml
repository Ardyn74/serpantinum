import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "../../"

Item {
    id: root

    property real radius: ThemeBackend.borderRadius
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius
    property real blurStrength: 1.0
    property real tint: 0.0

    readonly property var hostWindow: QsWindow.window
    readonly property var hostScreen: hostWindow ? hostWindow.screen : null
    readonly property string screenName: hostScreen && hostScreen.name ? hostScreen.name : ""
    readonly property bool active: ThemeBackend.blurBackground && ThemeBackend.elementOpacity < 0.999 && width > 0 && height > 0 && hostScreen !== null

    readonly property var engine: Wallpaper.engines[screenName] || null

    property real imageX: 0
    property real imageY: 0
    property real imageWidth: 0
    property real imageHeight: 0
    property int revision: 0

    readonly property string snapshotDir: Caching.getCacheDir("wallpaper")
    readonly property string snapshotPath: snapshotDir + (screenName !== "" ? "/current_wallpaper_" + screenName + ".png" : "/current_wallpaper.png")
    readonly property string snapshotUrl: "file://" + snapshotPath + "?rev=" + revision

    function layerSource(slot) {
        if (!root.active) return "";
        if (!root.engine) return slot === 0 ? root.snapshotUrl : "";
        const e = root.engine;
        if (slot === 0) {
            if (e.isVideoA) return e.snapReadyA ? "file://" + e.layerSnapshotPathA + "?rev=" + e.snapRevA : "";
            return e.pathA !== "" ? "file://" + e.pathA : "";
        }
        if (e.isVideoB) return e.snapReadyB ? "file://" + e.layerSnapshotPathB + "?rev=" + e.snapRevB : "";
        return e.pathB !== "" ? "file://" + e.pathB : "";
    }

    readonly property int incomingSlot: engine ? engine.activeLayer : 0
    readonly property string newSource: layerSource(incomingSlot)
    readonly property string oldSource: engine ? layerSource(incomingSlot === 0 ? 1 : 0) : ""
    readonly property size textureSize: hostScreen ? Qt.size(Math.max(1, hostScreen.width / 2), Math.max(1, hostScreen.height / 2)) : Qt.size(1, 1)

    visible: active
    clip: false

    function refreshGeometry() {
        const w = root.hostWindow;
        const scr = root.hostScreen;
        if (!w || !scr) return;
        const a = w.anchors;
        const m = w.margins;
        let wx;
        let wy;
        if (a.left) wx = m.left;
        else if (a.right) wx = scr.width - w.width - m.right;
        else wx = (scr.width - w.width) / 2;
        if (a.top) wy = m.top;
        else if (a.bottom) wy = scr.height - w.height - m.bottom;
        else wy = (scr.height - w.height) / 2;
        const p0 = root.mapFromItem(null, -wx, -wy);
        const p1 = root.mapFromItem(null, scr.width - wx, scr.height - wy);
        root.imageX = p0.x;
        root.imageY = p0.y;
        root.imageWidth = p1.x - p0.x;
        root.imageHeight = p1.y - p0.y;
    }

    FrameAnimation {
        running: root.active
        onTriggered: root.refreshGeometry()
    }

    onActiveChanged: {
        if (active) {
            refreshGeometry();
        } else {
            imageWidth = 0;
            imageHeight = 0;
        }
    }

    FileView {
        path: root.active ? root.snapshotPath : ""
        watchChanges: true
        onFileChanged: root.revision++
    }

    Item {
        id: oldLayer
        x: root.imageX
        y: root.imageY
        width: root.imageWidth
        height: root.imageHeight
        visible: false
        layer.enabled: true

        Image {
            anchors.fill: parent
            source: root.oldSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            sourceSize: root.textureSize
        }
    }

    Item {
        id: newLayer
        x: root.imageX
        y: root.imageY
        width: root.imageWidth
        height: root.imageHeight
        visible: false
        layer.enabled: true

        Image {
            anchors.fill: parent
            source: root.newSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            sourceSize: root.textureSize
        }
    }

    Item {
        id: mask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            topLeftRadius: root.topLeftRadius
            topRightRadius: root.topRightRadius
            bottomLeftRadius: root.bottomLeftRadius
            bottomRightRadius: root.bottomRightRadius
            color: "black"
        }
    }

    Item {
        id: content
        anchors.fill: parent
        visible: false
        layer.enabled: true

        ShaderEffect {
            id: blend
            x: root.imageX
            y: root.imageY
            width: root.imageWidth
            height: root.imageHeight

            property variant oldTex: oldLayer
            property variant newTex: newLayer
            property vector2d itemSize: Qt.vector2d(width, height)
            property real progress: root.engine ? (root.engine.isPreloading ? -1.0 : root.engine.transitionProgress) : 1.0
            property real transitionType: root.engine ? root.engine.activeTransitionType : 0
            property vector2d origin: Qt.vector2d(root.engine ? root.engine.transitionOriginX : 0.5, root.engine ? root.engine.transitionOriginY : 0.5)
            property vector4d params: Qt.vector4d(root.engine && root.engine.wipeIsVertical ? 1.0 : 0.0, root.engine ? root.engine.swipeDirection : 0, 0.0, 0.0)

            fragmentShader: "file://" + Caching.serpantinumDir + "/assets/shaders/transitions/wallpaper_blend.frag.qsb"
        }

        Rectangle {
            anchors.fill: parent
            visible: root.tint > 0
            color: Qt.alpha(ThemeBackend.base, root.tint)
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: content
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: 64
        blur: Math.min(1.0, root.blurStrength)
        maskEnabled: true
        maskSource: mask
    }
}
