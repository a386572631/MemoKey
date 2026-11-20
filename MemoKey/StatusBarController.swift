import AppKit

@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {
    struct Actions {
        let restartTap: () -> Void
        let testShortcut: () -> Void
        let quit: () -> Void
    }

    private let statusItem: NSStatusItem
    private let menu = NSMenu()
    private let actions: Actions
    private let inputStatusItem = NSMenuItem()
    private let accessibilityStatusItem = NSMenuItem()
    private let restartItem = NSMenuItem()

    init(actions: Actions) {
        self.actions = actions
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "MemoKey")
            button.image?.isTemplate = true
            button.toolTip = "MemoKey"
        }

        menu.autoenablesItems = false
        menu.delegate = self

        let header = NSMenuItem(title: "MemoKey", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        inputStatusItem.target = self
        inputStatusItem.action = #selector(openInputMonitoringSettings)
        menu.addItem(inputStatusItem)

        accessibilityStatusItem.target = self
        accessibilityStatusItem.action = #selector(openAccessibilitySettings)
        menu.addItem(accessibilityStatusItem)

        menu.addItem(.separator())

        restartItem.title = "重新启动监听"
        restartItem.action = #selector(restartListening)
        restartItem.target = self
        menu.addItem(restartItem)

        let previewItem = NSMenuItem(title: "预览提示样式", action: #selector(testShortcut), keyEquivalent: "")
        previewItem.target = self
        menu.addItem(previewItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出 MemoKey", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        updateStatusTitles()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        updateStatusTitles()
    }

    private func updateStatusTitles() {
        inputStatusItem.title = "输入监控：\(PermissionManager.inputMonitoringGranted ? "已授权" : "未授权（点击去设置）")"
        accessibilityStatusItem.title = "辅助功能：\(PermissionManager.accessibilityGranted ? "已授权" : "未授权（点击去设置）")"
        restartItem.isEnabled = PermissionManager.inputMonitoringGranted
    }

    @objc private func openInputMonitoringSettings() {
        PermissionManager.openPrivacySettings(.inputMonitoring)
    }

    @objc private func openAccessibilitySettings() {
        PermissionManager.openPrivacySettings(.accessibility)
    }

    @objc private func restartListening() {
        actions.restartTap()
    }

    @objc private func testShortcut() {
        actions.testShortcut()
    }

    @objc private func quit() {
        actions.quit()
    }
}
