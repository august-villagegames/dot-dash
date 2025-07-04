import AppKit
import CoreGraphics

class KeyboardMonitorService {
    private var eventTap: CFMachPort?
    private var currentInput = ""

    private var rules: [ExpansionRule] = []
    private let persistenceManager = PersistenceManager()

    private var recentKeyTimestamps: [TimeInterval] = [] // For loop control

    func start() {
        print("KeyboardMonitorService: start() called")
        // First, check for accessibility permissions.
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let isAccessibilityEnabled = AXIsProcessTrustedWithOptions(options)

        print("KeyboardMonitorService: isAccessibilityEnabled = \(isAccessibilityEnabled)")
        if !isAccessibilityEnabled {
            print("KeyboardMonitorService: Accessibility permissions not enabled")
            return
        }

        // Load rules from persistence
        self.rules = persistenceManager.getRules()
        print("KeyboardMonitorService: Loaded rules: \(rules.map { $0.command })")

        // The event tap callback function
        let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
            print("KeyboardMonitorService: Event tap callback triggered, type: \(type.rawValue)")
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
            print("KeyboardMonitorService: Failed to create event tap")
            return
        } else {
            print("KeyboardMonitorService: Event tap created successfully")
        }

        // Add the event tap to the run loop.
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap!, enable: true)

        print("KeyboardMonitorService: Event tap added to run loop and enabled")
    }

    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        print("Keyboard monitor stopped.")
    }

    private func handle(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        print("KeyboardMonitorService: handle() called, type: \(type.rawValue)")
        guard type == .keyDown else { return Unmanaged.passRetained(event) }

        // Only count real user events for runaway protection
        let sourceStateID = event.getIntegerValueField(.eventSourceStateID)
        let sourcePID = event.getIntegerValueField(.eventSourceUnixProcessID)
        let userData = event.getIntegerValueField(.eventSourceUserData)
        print("[DEBUG] Event sourceStateID: \(sourceStateID), sourcePID: \(sourcePID), userData: \(userData)")
        // 1 = .hidSystemState (real hardware), 0 = .privateState (synthetic), others possible
        let isRealUserEvent = (sourcePID == 0)

        if isRealUserEvent {
            // Loop control: track timestamps
            let now = Date().timeIntervalSince1970
            recentKeyTimestamps.append(now)
            // Keep only the last 20 timestamps
            if recentKeyTimestamps.count > 20 {
                recentKeyTimestamps.removeFirst(recentKeyTimestamps.count - 20)
            }
            // If 20 key events in less than 1 second, stop monitor
            if recentKeyTimestamps.count == 20 && (now - recentKeyTimestamps.first!) < 1.0 {
                print("[WARNING] Too many key events in 1 second. Stopping keyboard monitor to prevent runaway loop.")
                stop()
                return Unmanaged.passRetained(event)
            }
        }

        guard let keyEvent = event.copy() else { return Unmanaged.passRetained(event) }

        var unicodeString = ""
        var actualLength: Int = 0
        var chars: [UniChar] = [0] // Buffer for one character

        keyEvent.keyboardGetUnicodeString(maxStringLength: 1, actualStringLength: &actualLength, unicodeString: &chars)

        if actualLength > 0 {
            unicodeString = String(utf16CodeUnits: chars, count: actualLength)
        }

        // Only process real user events for currentInput building
        if isRealUserEvent {
            // Handle space or return - clear currentInput
            if unicodeString == " " || unicodeString == "\r" {
                print("KeyboardMonitorService: Detected space or return. Clearing currentInput.")
                currentInput = ""
            } else {
                // Check for backspace key (key code 0x33)
                let keyCode = keyEvent.getIntegerValueField(.keyboardEventKeycode)
                if keyCode == 0x33 { // kVK_Delete (backspace)
                    if !currentInput.isEmpty {
                        currentInput.removeLast()
                        print("KeyboardMonitorService: Backspace detected. Removed last character. currentInput = \(currentInput)")
                    }
                } else {
                    // Only append printable characters to currentInput (excluding spaces and returns)
                    if let scalar = unicodeString.unicodeScalars.first, scalar.isASCII, scalar.value >= 32 && scalar.value <= 126 {
                        currentInput.append(unicodeString)
                    }
                }
            }
            // TODO: In the future, ensure that synthetic backspaces and other control characters do not interfere with shortcut typing.

            print("KeyboardMonitorService: currentInput after = \(currentInput)")
            // Check for immediate match after every key
            if let rule = rules.first(where: { $0.command == currentInput }) {
                print("KeyboardMonitorService: Command recognized: \(currentInput)")
                let expansionController = TextExpansionController()
                print("KeyboardMonitorService: Calling TextExpansionController.expand with command: \(currentInput), replacement: \(rule.replacementText)")
                expansionController.expand(command: self.currentInput, replacement: rule.replacementText)
                currentInput = "" // Reset after expansion
            }
        }
        return Unmanaged.passRetained(event)
    }
}