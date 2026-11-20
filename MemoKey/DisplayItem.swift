import Foundation

struct DisplayItem: Identifiable, Equatable {
    let id = UUID()
    let keys: [String]

    static func shortcut(keys: [String]) -> DisplayItem {
        DisplayItem(keys: keys)
    }

    var displayText: String {
        keys.joined(separator: " + ")
    }
}
