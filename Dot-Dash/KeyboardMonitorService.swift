import AppKit
import CoreGraphics

class KeyboardMonitorService {
    private var eventTap: CFMachPort?
    private var currentInput = ""

    private var rules: [ExpansionRule] = []
    private let persistenceManager = PersistenceManager()

    func start() {
        // First, check for accessibility permissions.
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let isAccessibilityEnabled = AXIsProcessTrustedWithOptions(options)

        if !isAccessibilityEnabled {
            print("Accessibility permissions are required. Please enable them in System Settings.")
            // In a real app, you would show a UI to guide the user.
            return
        }

        // Load rules from persistence
        self.rules = persistenceManager.getRules()

        // The event tap callback function
        let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
            guard let refcon = refcon else { return Unmanaged.passRetained(event) }
            let selfPointer = Unmanaged<KeyboardMonitorService>.fromOpaque(refcon).takeUnretainedValue()
            return selfPointer.handle(proxy: proxy, type: type, event: event)
        }

        // Create the event tap.
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, 
                                     place: .headInsertEventTap, 
                                     options: .defaultTap, 
                                     eventsOfInterest: CGEventMask(eventMask), 
                                     callback: eventTapCallback, 
                                     userInfo: Unmanaged.passUnretained(self).toOpaque())

        if eventTap == nil {
            print("Failed to create event tap")
            return
        }

        // Add the event tap to the run loop.
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap!, enable: true)

        print("Keyboard monitor started.")
    }

    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        print("Keyboard monitor stopped.")
    }

    private func handle(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else { return Unmanaged.passRetained(event) }

        guard let keyEvent = event.copy() else { return Unmanaged.passRetained(event) }

        var unicodeString = ""
        var actualLength: Int = 0
        var chars: [UniChar] = [0] // Buffer for one character

        keyEvent.keyboardGetUnicodeString(maxStringLength: 1, actualStringLength: &actualLength, unicodeString: &chars)

        if actualLength > 0 {
            unicodeString = String(utf16CodeUnits: chars, count: actualLength)
        }

        if unicodeString == " " || unicodeString == "\r" { // Space or Return terminates the command
            if let rule = rules.first(where: { $0.command == currentInput }) {
                print("Command recognized: \(currentInput)")
                let expansionController = TextExpansionController()
                expansionController.expand(command: self.currentInput, replacement: rule.replacementText)
            }
            currentInput = ""
        } else {
            currentInput.append(unicodeString)
        }
        return Unmanaged.passRetained(event)
    }
}