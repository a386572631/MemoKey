import AppKit
import SwiftUI

@MainActor
final class OverlayWindowController {
    private let model = OverlayModel()
    private let panel: OverlayPanel
    private var sequenceTask: Task<Void, Never>?

    init() {
        let contentRect = NSRect(x: 0, y: 0, width: 900, height: 260)
        panel = OverlayPanel(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = true
        panel.isReleasedWhenClosed = false
        panel.animationBehavior = .none
        panel.contentView = NSHostingView(rootView: ContentView(model: model))
    }

    func show(_ item: DisplayItem) {
        sequenceTask?.cancel()
        positionOnActiveScreen()
        panel.orderFrontRegardless()

        withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
            model.item = item
            model.faded = false
        }

        sequenceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(420))
            guard let self, !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.24)) {
                self.model.faded = true
            }

            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            self.panel.orderOut(nil)
        }
    }

    private func positionOnActiveScreen() {
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main
        guard let screen else { return }

        let frame = screen.frame
        let size = panel.frame.size
        panel.setFrameOrigin(NSPoint(x: frame.midX - size.width / 2, y: frame.midY - size.height / 2))
    }
}

private final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
