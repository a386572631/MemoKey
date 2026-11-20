import CoreGraphics
import Foundation
import os

private nonisolated func keycastEventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if let userInfo {
        let service = Unmanaged<EventTapService>.fromOpaque(userInfo).takeUnretainedValue()
        service.handle(type: type, event: event)
    }
    return Unmanaged.passUnretained(event)
}

@MainActor
final class EventTapService {
    var onMenuClick: ((CGPoint) -> Void)?

    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    nonisolated private let logger = Logger(subsystem: "cn.jay.MemoKey", category: "Tap")

    var isRunning: Bool { tap != nil }

    @discardableResult
    func start() -> Bool {
        stop()

        let mask: CGEventMask = 1 << CGEventType.leftMouseDown.rawValue

        let userInfo = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: keycastEventTapCallback,
            userInfo: userInfo
        ) else {
            return false
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        logger.info("Tap enabled: \(CGEvent.tapIsEnabled(tap: tap), privacy: .public)")

        self.tap = tap
        self.runLoopSource = source
        return true
    }

    func stop() {
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        runLoopSource = nil
        tap = nil
    }

    nonisolated func handle(type: CGEventType, event: CGEvent) {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            Task { @MainActor [weak self] in
                self?.reenableTap()
            }

        case .leftMouseDown:
            let point = event.location
            Task { @MainActor [weak self] in
                self?.onMenuClick?(point)
            }

        default:
            break
        }
    }

    private func reenableTap() {
        guard let tap else { return }
        CGEvent.tapEnable(tap: tap, enable: true)
    }
}
