pragma Singleton
import QtQuick
import "../../"
import "../../widgets"

QtObject {
    id: registry

    readonly property var lockTypeIds: ["clock", "avatar", "user", "lockstatus", "password", "fingerprint", "keyboard", "battery", "notifications"]

    readonly property var types: ({
        "clock": {
            icon: String.fromCodePoint(0xF0954),
            file: "LockClockFace.qml",
            scopes: ["screen"],
            scaled: true,
            deletable: false,
            variants: ["classic", "stacked", "compact", "analog"]
        },
        "avatar": {
            icon: String.fromCodePoint(0xF0009),
            file: "elements/LockAvatarElement.qml",
            scopes: ["panel"],
            w: 200, h: 200, minW: 60, minH: 60, maxW: 400, maxH: 400,
            aspect: 1,
            variants: ["round", "rounded"]
        },
        "user": {
            icon: String.fromCodePoint(0xF0004),
            file: "elements/LockUserElement.qml",
            scopes: ["panel"],
            w: 380, h: 44, minW: 100, minH: 32, maxW: 1000, maxH: 80,
            variants: ["filled", "plain"]
        },
        "lockstatus": {
            icon: String.fromCodePoint(0xF033E),
            file: "elements/LockLockStatusElement.qml",
            scopes: ["panel"],
            w: 190, h: 44, minW: 80, minH: 32, maxW: 1000, maxH: 80,
            variants: ["filled", "plain"]
        },
        "password": {
            icon: String.fromCodePoint(0xF0306),
            file: "elements/LockPasswordElement.qml",
            scopes: ["panel"],
            deletable: false,
            w: 380, h: 44, minW: 160, minH: 32, maxW: 1000, maxH: 80,
            variants: ["filled", "glass"]
        },
        "fingerprint": {
            icon: String.fromCodePoint(0xF0237),
            file: "elements/LockFingerprintElement.qml",
            scopes: ["screen", "panel"],
            scaled: true,
            variants: ["labeled", "icon"]
        },
        "keyboard": {
            icon: String.fromCodePoint(0xF030C),
            file: "elements/LockKeyboardElement.qml",
            scopes: ["panel"],
            w: 185, h: 44, minW: 80, minH: 32, maxW: 1000, maxH: 80,
            variants: ["filled", "plain"]
        },
        "battery": {
            icon: String.fromCodePoint(0xF0079),
            file: "elements/LockBatteryElement.qml",
            scopes: ["panel"],
            w: 185, h: 44, minW: 80, minH: 32, maxW: 1000, maxH: 80,
            variants: ["filled", "plain"]
        },
        "notifications": {
            icon: String.fromCodePoint(0xF009A),
            file: "elements/LockNotificationsElement.qml",
            scopes: ["screen", "panel"],
            w: 400, h: 440, minW: 220, minH: 140, maxW: 800, maxH: 1000,
            variants: ["card", "plain"]
        },
    })

    function isWidget(type) {
        return String(type).indexOf("widget:") === 0;
    }

    function widgetKey(type) {
        return String(type).substring(7);
    }

    function hasType(type) {
        if (registry.isWidget(type)) return WidgetRegistry.types[registry.widgetKey(type)] !== undefined;
        return registry.types[type] !== undefined;
    }

    function allowedIn(type, scope) {
        if (registry.isWidget(type)) return true;
        let t = registry.types[type];
        return !!t && t.scopes.indexOf(scope) >= 0;
    }

    function isScaled(type) {
        if (registry.isWidget(type)) return false;
        let t = registry.types[type];
        return !!t && t.scaled === true;
    }

    function isDeletable(type) {
        if (registry.isWidget(type)) return true;
        let t = registry.types[type];
        return !!t && t.deletable !== false;
    }

    function typeName(type) {
        if (registry.isWidget(type)) {
            let w = WidgetRegistry.types[registry.widgetKey(type)];
            return w ? w.name : "";
        }
        return I18n.t("lock.redactor.element." + type);
    }

    function typeIcon(type) {
        if (registry.isWidget(type)) {
            let w = WidgetRegistry.types[registry.widgetKey(type)];
            return w ? w.icon : "";
        }
        return registry.types[type] ? registry.types[type].icon : "";
    }

    function variantList(type) {
        if (registry.isWidget(type)) {
            return WidgetRegistry.variantList(registry.widgetKey(type)).map(v => ({ id: v.id, name: v.label || v.id }));
        }
        let t = registry.types[type];
        if (!t) return [];
        return t.variants.map(id => ({ id: id, name: I18n.t("lock.redactor.variant." + type + "." + id) }));
    }

    function hasVariant(type, variantId) {
        return registry.variantList(type).some(v => v.id === variantId);
    }

    function defaultVariant(type) {
        if (registry.isWidget(type)) return WidgetRegistry.defaultVariant(registry.widgetKey(type));
        let t = registry.types[type];
        return t ? t.variants[0] : "";
    }

    function defaultSize(type) {
        if (registry.isWidget(type)) return WidgetRegistry.defaultSize(registry.widgetKey(type));
        let t = registry.types[type];
        if (!t || t.scaled) return { w: 0, h: 0 };
        return { w: t.w, h: t.h };
    }

    function limits(type) {
        let t = registry.isWidget(type) ? null : registry.types[type];
        if (!t || t.scaled) return null;
        return { minW: t.minW, minH: t.minH, maxW: t.maxW, maxH: t.maxH, aspect: t.aspect || 0 };
    }

    function faceSource(type, variant) {
        if (registry.isWidget(type)) return WidgetRegistry.faceFile(registry.widgetKey(type), variant);
        let t = registry.types[type];
        return t ? t.file : "";
    }

    function lockTypeList(scope) {
        return registry.lockTypeIds
            .filter(id => registry.allowedIn(id, scope) && registry.isDeletable(id))
            .map(id => ({ id: id, icon: registry.typeIcon(id), name: registry.typeName(id) }));
    }
}
