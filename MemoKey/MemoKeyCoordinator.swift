import AppKit
import os

@MainActor
final class MemoKeyCoordinator {
    private let logger = Logger(subsystem: "cn.jay.MemoKey", category: "MemoKey")
    private let overlay = OverlayWindowController()
    private let eventTap = EventTapService()
    private var actionMonitor: ActionMonitor?
    private var statusBar: StatusBarController?

    private var lastShownAt = Date.distantPast
    private var lastShownText = ""
    private var didShowPermissionAlert = false

    func start() {
        logger.info("Launch: inputMonitoring=\(PermissionManager.inputMonitoringGranted, privacy: .public) accessibility=\(PermissionManager.accessibilityGranted, privacy: .public)")

        actionMonitor = ActionMonitor { [weak self] item in
            self?.show(item)
        }

        eventTap.onMenuClick = { [weak self] point in
            self?.actionMonitor?.handleClick(at: point)
        }

        statusBar = StatusBarController(actions: .init(
            restartTap: { [weak self] in self?.startEventTap(reportFailure: true) },
            testShortcut: { [weak self] in self?.overlay.show(.shortcut(keys: ["⌘", "C"])) },
            quit: { NSApp.terminate(nil) }
        ))

        promptForPermissionsIfNeeded()
        startEventTap(reportFailure: false)
    }

    func stop() {
        eventTap.stop()
    }

    private func startEventTap(reportFailure: Bool) {
        let granted = PermissionManager.inputMonitoringGranted
        let started = eventTap.start()
        logger.info("Event tap started: \(started, privacy: .public), inputMonitoring: \(granted, privacy: .public)")
        if !granted || (reportFailure && !started) {
            showPermissionAlert()
        }
    }

    private func show(_ item: DisplayItem) {
        let now = Date()
        if item.displayText == lastShownText, now.timeIntervalSince(lastShownAt) < 0.25 {
            return
        }
        lastShownText = item.displayText
        lastShownAt = now
        overlay.show(item)
    }

    private func promptForPermissionsIfNeeded() {
        if !PermissionManager.accessibilityGranted {
            PermissionManager.requestAccessibility()
        }
        if !PermissionManager.inputMonitoringGranted {
            PermissionManager.requestInputMonitoring()
        }
    }

    private func showPermissionAlert() {
        guard !didShowPermissionAlert else { return }
        didShowPermissionAlert = true

        Task { @MainActor in
            if #available(macOS 14.0, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }

            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "MemoKey 需要授权才能提示快捷键"
            alert.informativeText = """
            请在“系统设置 > 隐私与安全性”中为 MemoKey 开启：
            • 输入监控：捕获鼠标点击事件
            • 辅助功能：读取被点击菜单项绑定的快捷键

            授权后，请在菜单栏图标中选择“重新启动监听”；若仍无效，请重启应用。
            """
            alert.addButton(withTitle: "打开输入监控设置")
            alert.addButton(withTitle: "稍后")

            if alert.runModal() == .alertFirstButtonReturn {
                PermissionManager.openPrivacySettings(.inputMonitoring)
            }
        }
    }
}
