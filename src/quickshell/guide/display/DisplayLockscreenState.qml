import QtQuick
import Quickshell.Io
import "../"
import "../../"

GuideTab {
    id: displayLockscreenRoot
    subTabIndex: 2

    property var defaultLockscreenSettings: ({
        "fingerprintEnabled": true,
        "attemptLimitEnabled": false,
        "passwordMaxAttempts": 5,
        "fingerprintMaxAttempts": 5
    })

    property var lockscreenSettings: {
        if (typeof Config !== "undefined" && typeof Config.getSetting === "function") {
            return Config.getSetting("lockscreen", displayLockscreenRoot.defaultLockscreenSettings);
        }
        return displayLockscreenRoot.defaultLockscreenSettings;
    }

    property bool fingerprintSupported: false
    property bool currentFingerprintEnabled: lockscreenSettings.fingerprintEnabled !== false
    property bool currentAttemptLimitEnabled: lockscreenSettings.attemptLimitEnabled === true
    property int currentPasswordMaxAttempts: lockscreenSettings.passwordMaxAttempts !== undefined ? lockscreenSettings.passwordMaxAttempts : 5
    property int currentFingerprintMaxAttempts: lockscreenSettings.fingerprintMaxAttempts !== undefined ? lockscreenSettings.fingerprintMaxAttempts : 5

    Process {
        id: fingerprintProbe
        command: ["bash", (Caching.serpantinumDir ? Caching.serpantinumDir : "") + "/scripts/system/fingerprint_available.sh"]
        onExited: (exitCode) => displayLockscreenRoot.fingerprintSupported = exitCode === 0
    }

    Component.onCompleted: fingerprintProbe.running = true

    function updateLockscreenSetting(key, value) {
        let current = JSON.parse(JSON.stringify((typeof Config !== "undefined" && typeof Config.getSetting === "function") ? (Config.getSetting("lockscreen", defaultLockscreenSettings) || defaultLockscreenSettings) : defaultLockscreenSettings));
        current[key] = value;
        if (typeof Config !== "undefined" && typeof Config.setSetting === "function") {
            Config.setSetting("lockscreen", current);
        }
        displayLockscreenRoot.lockscreenSettings = current;
    }
}
