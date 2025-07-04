import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var keyboardMonitor: KeyboardMonitorService?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("=== APPDELEGATE: Application did finish launching ===")
        // Check for permissions and start the monitor.
        checkPermissionsAndStart()
    }

    private func checkPermissionsAndStart() {
        print("=== APPDELEGATE: Checking permissions and starting ===")
        let bundleID = Bundle.main.bundleIdentifier ?? "nil"
        let execPath = Bundle.main.executablePath ?? "nil"
        let currentUser = NSUserName()
        let env = ProcessInfo.processInfo.environment

        print("=== APPDELEGATE: Bundle ID: \(bundleID) ===")
        print("=== APPDELEGATE: Executable Path: \(execPath) ===")
        print("=== APPDELEGATE: Current User: \(currentUser) ===")
        print("=== APPDELEGATE: Environment: \(env) ===")

        let legacyTrusted = AXIsProcessTrusted()
        print("=== APPDELEGATE: AXIsProcessTrusted() = \(legacyTrusted) ===")

        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let isAccessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        print("=== APPDELEGATE: AXIsProcessTrustedWithOptions = \(isAccessibilityEnabled) ===")

        if isAccessibilityEnabled {
            print("=== APPDELEGATE: Permissions granted, starting keyboard monitor ===")
            keyboardMonitor = KeyboardMonitorService()
            keyboardMonitor?.start()
            print("=== APPDELEGATE: Keyboard monitor started ===")
        } else {
            print("=== APPDELEGATE: Permissions not granted, showing alert ===")
            let alert = NSAlert()
            alert.messageText = "Permissions Required"
            alert.informativeText = "Dot-Dash needs Accessibility permissions to work. Please grant permissions in System Settings."
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Quit")

            let response = alert.runModal()
            print("=== APPDELEGATE: Alert response: \(response.rawValue) ===")
            if response == .alertFirstButtonReturn {
                print("=== APPDELEGATE: Opening System Settings ===")
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                NSWorkspace.shared.open(url)
            }
            print("=== APPDELEGATE: Terminating app due to missing permissions ===")
            NSApplication.shared.terminate(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("=== APPDELEGATE: Application will terminate ===")
        // Clean up the event tap when the app closes.
        keyboardMonitor?.stop()
    }
}
