pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../"
import "../../widgets"

QtObject {
    id: root

    readonly property real screenW: Quickshell.screens.length > 0 ? Quickshell.screens[0].width : 1920
    readonly property real screenH: Quickshell.screens.length > 0 ? Quickshell.screens[0].height : 1080

    property real panelW: 1280
    property real panelH: 580
    property real panelX: -1
    property real panelOpacity: 1.0
    property real refW: 1920
    property real refH: 1080
    property real panelY: -1
    property ListModel screenItems: ListModel { dynamicRoles: true }
    property ListModel panelItems: ListModel { dynamicRoles: true }

    property int revision: 0
    property bool applying: false
    property bool loaded: false
    property string lastWrittenText: ""

    readonly property string stateDir: Caching.getStateDir("lockscreen")
    readonly property string filePath: root.stateDir + "/layout.json"

    readonly property var standardKeys: ["iid", "itype", "ivariant", "ix", "iy", "iw", "ih", "iopacity", "irotation", "iimage"]

    function modelFor(scope) {
        return scope === "panel" ? root.panelItems : root.screenItems;
    }

    function newId() {
        return "i_" + Date.now() + "_" + Math.floor(Math.random() * 100000);
    }

    function makeEntry(type, variant, x, y, w, h) {
        return {
            iid: root.newId(),
            itype: type,
            ivariant: variant || LockElementRegistry.defaultVariant(type),
            ix: x,
            iy: y,
            iw: w,
            ih: h,
            iopacity: 1.0,
            irotation: 0,
            iimage: ""
        };
    }

    function defaultScreenItems() {
        return [
            root.makeEntry("clock", "classic", root.screenW * 0.5, root.screenH * 0.36, 0, 0),
            root.makeEntry("fingerprint", "labeled", root.screenW * 0.5, root.screenH * 0.92, 0, 0)
        ];
    }

    function defaultPanelItems() {
        return [
            root.makeEntry("widget:weather", "full", 20, 20, 380, 182),
            root.makeEntry("widget:cpu", "default", 20, 210, 186, 170),
            root.makeEntry("widget:ram", "default", 214, 210, 186, 170),
            root.makeEntry("widget:temp", "default", 20, 388, 186, 170),
            root.makeEntry("widget:disk", "default", 214, 388, 186, 170),
            root.makeEntry("avatar", "round", 540, 20, 200, 200),
            root.makeEntry("user", "filled", 450, 236, 185, 44),
            root.makeEntry("lockstatus", "filled", 645, 236, 185, 44),
            root.makeEntry("password", "filled", 450, 288, 380, 44),
            root.makeEntry("keyboard", "filled", 450, 340, 185, 44),
            root.makeEntry("battery", "filled", 645, 340, 185, 44),
            root.makeEntry("fingerprint", "labeled", 640, 450, 0, 0),
            root.makeEntry("notifications", "card", 860, 20, 400, 440),
            root.makeEntry("widget:music", "full", 860, 468, 400, 92)
        ];
    }

    function setPanelOpacity(value) {
        root.panelOpacity = Math.max(0, Math.min(1, value));
        root.touch();
    }

    function setReference(w, h) {
        if (w <= 0 || h <= 0 || (w === root.refW && h === root.refH)) return;
        let fx = w / root.refW;
        let fy = h / root.refH;
        let f = Math.min(fx, fy);
        let m = root.screenItems;
        for (let i = 0; i < m.count; i++) {
            let e = m.get(i);
            m.setProperty(i, "ix", e.ix * fx);
            m.setProperty(i, "iy", e.iy * fy);
            if (e.iw > 0 && e.ih > 0) {
                m.setProperty(i, "iw", e.iw * f);
                m.setProperty(i, "ih", e.ih * f);
            }
        }
        root.refW = w;
        root.refH = h;
        root.touch();
    }

    function ensurePassword() {
        for (let i = 0; i < root.panelItems.count; i++) {
            if (root.panelItems.get(i).itype === "password") return;
        }
        root.panelItems.append(root.makeEntry("password", "filled", Math.max(0, (root.panelW - 380) / 2), Math.max(0, root.panelH - 64), 380, 44));
    }

    function fill(model, list) {
        model.clear();
        for (let i = 0; i < list.length; i++) model.append(list[i]);
    }

    function touch() {
        root.revision++;
        if (!root.applying) saveTimer.restart();
    }

    function findItem(id) {
        let scopes = ["screen", "panel"];
        for (let s = 0; s < scopes.length; s++) {
            let m = root.modelFor(scopes[s]);
            for (let i = 0; i < m.count; i++) {
                if (m.get(i).iid === id) return { scope: scopes[s], index: i };
            }
        }
        return null;
    }

    function addItem(scope, entry) {
        root.modelFor(scope).append(entry);
        root.touch();
        return entry.iid;
    }

    function removeItem(id) {
        let f = root.findItem(id);
        if (!f) return;
        root.modelFor(f.scope).remove(f.index, 1);
        root.touch();
    }

    function setItemProperty(id, prop, value) {
        let f = root.findItem(id);
        if (!f) return;
        root.modelFor(f.scope).setProperty(f.index, prop, value);
        root.touch();
    }

    function clearScope(scope) {
        let m = root.modelFor(scope);
        for (let i = m.count - 1; i >= 0; i--) {
            if (LockElementRegistry.isDeletable(m.get(i).itype)) m.remove(i, 1);
        }
        root.touch();
    }

    function resetScope(scope) {
        root.applying = true;
        if (scope === "panel") {
            root.panelW = 1280;
            root.panelH = 580;
            root.panelX = -1;
            root.panelY = -1;
            root.panelOpacity = 1.0;
            root.fill(root.panelItems, root.defaultPanelItems());
        } else {
            root.fill(root.screenItems, root.defaultScreenItems());
        }
        root.applying = false;
        root.touch();
    }

    function setPanelRect(x, y, w, h) {
        root.panelX = x;
        root.panelY = y;
        root.panelW = w;
        root.panelH = h;
        root.touch();
    }

    function applyDefaults() {
        root.applying = true;
        root.panelW = 1280;
        root.panelH = 580;
        root.panelX = -1;
        root.panelY = -1;
        root.panelOpacity = 1.0;
        root.refW = root.screenW;
        root.refH = root.screenH;
        root.fill(root.screenItems, root.defaultScreenItems());
        root.fill(root.panelItems, root.defaultPanelItems());
        root.applying = false;
        root.revision++;
    }

    function rowToJson(row) {
        let o = {};
        for (let k in row) {
            if (!k || typeof k !== "string") continue;
            if (k.endsWith("Changed") || k.startsWith("on") || typeof row[k] === "function" || row[k] === undefined) continue;
            o[k] = row[k];
        }
        return o;
    }

    function modelToJson(model) {
        let out = [];
        for (let i = 0; i < model.count; i++) out.push(root.rowToJson(model.get(i)));
        return out;
    }

    function serialize() {
        return JSON.stringify({
            version: 3,
            ref: { w: root.refW, h: root.refH },
            panel: { x: root.panelX, y: root.panelY, w: root.panelW, h: root.panelH, opacity: root.panelOpacity },
            screen: root.modelToJson(root.screenItems),
            items: root.modelToJson(root.panelItems)
        }, null, 2);
    }

    function sanitize(raw, scope) {
        if (!raw || !LockElementRegistry.hasType(raw.itype) || !LockElementRegistry.allowedIn(raw.itype, scope)) return null;
        let n = function(v, d) { let x = Number(v); return isNaN(x) ? d : x; };
        let e = {};
        for (let k in raw) e[k] = raw[k];
        e.iid = raw.iid ? String(raw.iid) : root.newId();
        e.ivariant = LockElementRegistry.hasVariant(raw.itype, raw.ivariant) ? raw.ivariant : LockElementRegistry.defaultVariant(raw.itype);
        e.ix = n(raw.ix, 0);
        e.iy = n(raw.iy, 0);
        e.iw = Math.max(0, n(raw.iw, 0));
        e.ih = Math.max(0, n(raw.ih, 0));
        if (scope === "panel") {
            e.iw = Math.min(e.iw, root.panelW);
            e.ih = Math.min(e.ih, root.panelH);
            e.ix = Math.max(0, Math.min(e.ix, Math.max(0, root.panelW - e.iw)));
            e.iy = Math.max(0, Math.min(e.iy, Math.max(0, root.panelH - e.ih)));
        }
        e.iopacity = Math.max(0, Math.min(1, n(raw.iopacity, 1)));
        e.irotation = ((Math.round(n(raw.irotation, 0)) % 360) + 360) % 360;
        e.iimage = raw.iimage ? String(raw.iimage) : "";
        return e;
    }

    function loadList(scope, list) {
        let m = root.modelFor(scope);
        m.clear();
        let seen = {};
        for (let i = 0; i < list.length; i++) {
            let e = root.sanitize(list[i], scope);
            if (!e || seen[e.iid]) continue;
            seen[e.iid] = true;
            m.append(e);
        }
    }

    function applyText(text) {
        let data = null;
        try {
            data = JSON.parse(text);
        } catch (e) {
            return false;
        }
        if (!data || typeof data !== "object" || data.version !== 3) return false;

        root.applying = true;
        let p = data.panel || {};
        root.panelW = Math.max(240, Number(p.w) || 1280);
        root.panelH = Math.max(160, Number(p.h) || 580);
        root.panelOpacity = p.opacity !== undefined ? Math.max(0, Math.min(1, Number(p.opacity))) : 1.0;
        let r = data.ref || {};
        root.refW = Number(r.w) > 0 ? Number(r.w) : root.screenW;
        root.refH = Number(r.h) > 0 ? Number(r.h) : root.screenH;
        root.panelX = p.x !== undefined && Number(p.x) >= 0 ? Number(p.x) : -1;
        root.panelY = p.y !== undefined && Number(p.y) >= 0 ? Number(p.y) : -1;
        root.loadList("screen", Array.isArray(data.screen) ? data.screen : []);
        root.loadList("panel", Array.isArray(data.items) ? data.items : []);
        root.ensurePassword();
        root.applying = false;
        root.revision++;
        return true;
    }

    function saveNow() {
        saveTimer.stop();
        let text = root.serialize();
        root.lastWrittenText = text;
        Quickshell.execDetached([
            "bash", "-c",
            "mkdir -p \"$1\" && printf '%s' \"$2\" > \"$1/layout.json.tmp\" && mv \"$1/layout.json.tmp\" \"$1/layout.json\"",
            "bash", root.stateDir, text
        ]);
    }

    function flush() {
        if (saveTimer.running) root.saveNow();
    }

    function reloadFromDisk(text) {
        let trimmed = String(text || "").trim();
        if (trimmed === "") {
            if (!root.loaded) root.applyDefaults();
            return;
        }
        if (trimmed === root.lastWrittenText.trim()) return;
        if (!root.applyText(trimmed) && !root.loaded) root.applyDefaults();
    }

    property Timer saveTimer: Timer {
        interval: 250
        repeat: false
        onTriggered: root.saveNow()
    }

    property FileView fileView: FileView {
        path: root.filePath
        watchChanges: true
        onLoaded: {
            root.reloadFromDisk(fileView.text());
            root.loaded = true;
        }
        onFileChanged: fileView.reload()
        onLoadFailed: {
            if (!root.loaded) root.applyDefaults();
            root.loaded = true;
        }
    }

    Component.onCompleted: root.applyDefaults()
}
