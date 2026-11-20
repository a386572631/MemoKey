import AppKit

@main
struct MemoKeyApp {
    @MainActor private static let appDelegate = AppDelegate()

    @MainActor
    static func main() {
        let app = NSApplication.shared
        app.delegate = appDelegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
