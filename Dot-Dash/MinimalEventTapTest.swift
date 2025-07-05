import Foundation
import Cocoa

func startMinimalEventTapTest() {
    // First, check for accessibility permissions.
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
    let isAccessibilityEnabled = AXIsProcessTrustedWithOptions(options)

    if !isAccessibilityEnabled {
        print("MinimalEventTapTest: Accessibility permissions are required. Please enable them in System Settings.")
        return
    }

    let eventMask = (1 << CGEventType.keyDown.rawValue)

    let eventTap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: CGEventMask(eventMask),
        callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
            if type == .keyDown {
                let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                print("Key down: \(keyCode)")
            }
            return Unmanaged.passRetained(event)
        },
        userInfo: nil
    )

    if let eventTap = eventTap {
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        print("Event tap started. Press keys to see output. Ctrl+C to quit.")
        CFRunLoopRun()
    } else {
        print("Failed to create event tap. Check Accessibility permissions and sandboxing.")
    }
} 