import CoreGraphics
import Foundation

@MainActor
enum KeyboardFormatter {
    static func keyLabel(for keyCode: CGKeyCode) -> String? {
        keyLabels[keyCode]
    }

    static func characterLabel(for character: String) -> String? {
        guard let scalar = character.unicodeScalars.first else { return nil }
        let value = scalar.value

        if value >= 0xF704, value <= 0xF726 {
            return "F\(value - 0xF703)"
        }
        if let label = specialCharacters[value] {
            return label
        }
        switch Character(scalar) {
        case "\t": return "⇥"
        case "\r", "\n": return "↩"
        case " ": return "Space"
        default: break
        }

        let category = scalar.properties.generalCategory
        guard category != .control, category != .privateUse else { return nil }

        let trimmed = character.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed.uppercased()
    }

    private static let specialCharacters: [UInt32: String] = [
        0x1B: "Esc",
        0x7F: "⌫",
        0xF700: "↑", 0xF701: "↓", 0xF702: "←", 0xF703: "→",
        0xF727: "Insert", 0xF728: "⌦", 0xF729: "Home", 0xF72B: "End",
        0xF72C: "Page Up", 0xF72D: "Page Down", 0xF735: "Menu", 0xF746: "Help",
    ]

    private static let keyLabels: [CGKeyCode: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
        8: "C", 9: "V", 10: "§", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5",
        24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0", 30: "]", 31: "O",
        32: "U", 33: "[", 34: "I", 35: "P", 36: "↩", 37: "L", 38: "J", 39: "'",
        40: "K", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "N", 46: "M", 47: ".",
        48: "⇥", 49: "Space", 50: "`",
        51: "⌫", 53: "Esc",
        64: "F17", 65: "KP .", 67: "KP *", 69: "KP +", 71: "Clear", 75: "KP /",
        76: "Enter", 78: "KP -", 79: "F18", 80: "F19", 81: "KP =",
        82: "KP 0", 83: "KP 1", 84: "KP 2", 85: "KP 3", 86: "KP 4", 87: "KP 5",
        88: "KP 6", 89: "KP 7", 90: "F20", 91: "KP 8", 92: "KP 9",
        96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8", 101: "F9",
        103: "F11", 105: "F13", 106: "F16", 107: "F14", 109: "F10", 110: "Menu",
        111: "F12", 113: "F15", 114: "Help", 115: "Home", 116: "Page Up",
        117: "⌦", 118: "F4", 119: "End", 120: "F2", 121: "Page Down",
        122: "F1", 123: "←", 124: "→", 125: "↓", 126: "↑",
    ]
}
