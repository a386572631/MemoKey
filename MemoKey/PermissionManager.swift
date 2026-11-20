import AppKit
import ApplicationServices

@MainActor
enum PermissionManager {
    enum PrivacyPane {
        case inputMonitoring
        case accessibility
    }

    static var inputMonitoringGranted: Bool {
        CGPreflightListenEventAccess()
    }

    static var accessibilityGranted: Bool {
        AXIsProcessTrusted()
    }

    static func requestInputMonitoring() {
        guard !inputMonitoringGranted else { return }
        CGRequestListenEventAccess()
    }

    static func requestAccessibility() {
        guard !accessibilityGranted else { return }
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    static func openPrivacySettings(_ pane: PrivacyPane) {
        let anchor: String
        switch pane {
        case .inputMonitoring: anchor = "Privacy_ListenEvent"
        case .accessibility: anchor = "Privacy_Accessibility"
        }
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(anchor)") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
