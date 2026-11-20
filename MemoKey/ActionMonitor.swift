import AppKit
import ApplicationServices
import Foundation

@MainActor
final class ActionMonitor {
    private let show: (DisplayItem) -> Void
    private var lastQueryAt = Date.distantPast

    init(show: @escaping (DisplayItem) -> Void) {
        self.show = show
    }

    func handleClick(at point: CGPoint) {
        let now = Date()
        guard now.timeIntervalSince(lastQueryAt) >= 0.08 else { return }
        lastQueryAt = now

        Task { @MainActor [weak self] in
            guard let self, let item = MenuResolver.displayItem(at: point) else { return }
            self.show(item)
        }
    }
}

@MainActor
private enum MenuResolver {
    static func displayItem(at point: CGPoint) -> DisplayItem? {
        let systemWide = AXUIElementCreateSystemWide()
        var element: AXUIElement?
        guard AXUIElementCopyElementAtPosition(systemWide, Float(point.x), Float(point.y), &element) == .success,
              var current = element else {
            return nil
        }

        var appElement: AXUIElement?
        for _ in 0..<12 {
            let role = attribute(current, "AXRole") as? String
            if role == "AXMenuItem" {
                if let keys = shortcutKeys(for: current) {
                    return .shortcut(keys: keys)
                }
                guard let title = normalizedTitle(of: current),
                      let app = appElement ?? frontmostAppElement(),
                      let keys = menuBarShortcutKeys(titled: title, in: app) else {
                    return nil
                }
                return .shortcut(keys: keys)
            }
            if role == "AXApplication" {
                appElement = current
            }
            guard let parentValue = attribute(current, "AXParent"),
                  CFGetTypeID(parentValue) == AXUIElementGetTypeID() else {
                break
            }
            current = parentValue as! AXUIElement
        }
        return nil
    }

    private static func shortcutKeys(for element: AXUIElement) -> [String]? {
        var keys: [String] = []
        let modifiers = (attribute(element, "AXMenuItemCmdModifiers") as? NSNumber)?.intValue ?? 0
        if modifiers & 0b100 != 0 { keys.append("⌃") }
        if modifiers & 0b010 != 0 { keys.append("⌥") }
        if modifiers & 0b001 != 0 { keys.append("⇧") }
        if modifiers & 0b1000 == 0 { keys.append("⌘") }

        var keyLabel: String?
        if let char = attribute(element, "AXMenuItemCmdChar") as? String,
           let label = KeyboardFormatter.characterLabel(for: char) {
            keyLabel = label
        } else if let virtualKey = (attribute(element, "AXMenuItemCmdVirtualKey") as? NSNumber)?.intValue,
                  virtualKey >= 0,
                  let label = KeyboardFormatter.keyLabel(for: CGKeyCode(virtualKey)) {
            keyLabel = label
        }

        guard let keyLabel else { return nil }
        keys.append(keyLabel)
        return keys
    }

    private static func menuBarShortcutKeys(titled title: String, in app: AXUIElement) -> [String]? {
        guard let barValue = attribute(app, "AXMenuBar"),
              CFGetTypeID(barValue) == AXUIElementGetTypeID() else {
            return nil
        }
        let bar = barValue as! AXUIElement

        for barItem in children(of: bar) {
            for topMenu in children(of: barItem) where attribute(topMenu, "AXRole") as? String == "AXMenu" {
                for item in children(of: topMenu) where attribute(item, "AXRole") as? String == "AXMenuItem" {
                    guard normalizedTitle(of: item) == title,
                          let keys = shortcutKeys(for: item) else {
                        continue
                    }
                    return keys
                }
            }
        }
        return nil
    }

    private static func normalizedTitle(of element: AXUIElement) -> String? {
        guard var title = attribute(element, "AXTitle") as? String else { return nil }
        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        while title.hasSuffix("…") || title.hasSuffix("...") {
            title.removeLast()
            title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return title.isEmpty ? nil : title
    }

    private static func children(of element: AXUIElement) -> [AXUIElement] {
        (attribute(element, "AXChildren") as? [AXUIElement]) ?? []
    }

    private static func frontmostAppElement() -> AXUIElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        return AXUIElementCreateApplication(app.processIdentifier)
    }

    private static func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else {
            return nil
        }
        return value
    }
}
