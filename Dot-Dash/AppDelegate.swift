import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var keyboardMonitor: KeyboardMonitorService?
    var permissionsTimer: Timer?
    var waitingAlert: NSAlert?
    
    // Add logging functionality
    private func logToFile(_ message: String) {
        let logMessage = "\(Date()): \(message)\n"
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFileURL = documentsPath.appendingPathComponent("Dot-Dash.log")
            if let data = logMessage.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: logFileURL.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } else {
                    try? data.write(to: logFileURL)
                }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("=== APPDELEGATE: Application did finish launching ===")
        logToFile("=== APPDELEGATE: Application did finish launching ===")
        
        // Log app information for debugging
        logAppInfo()
        
        // Check for permissions and start the monitor first
        checkPermissionsAndStart()
        
        // TODO: Re-enable Apple Events permission check when automation permissions issue is resolved
        // See AUTOMATION_PERMISSIONS_ISSUE.md for details
        /*
        // Delay Apple Events permission check to ensure app is fully initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.forceAppleEventsPermissionCheck()
        }
        
        // Check TCC database after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.checkTCCDatabase()
        }
        */
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
            
            // TODO: Re-enable Apple Events permission check when automation permissions issue is resolved
            // See AUTOMATION_PERMISSIONS_ISSUE.md for details
            /*
            // Check Apple Events permission after accessibility is granted
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.checkAppleEventsPermission()
            }
            */
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
                // Show a waiting alert while polling for permissions
                showWaitingForPermissionsAlert()
                // Start polling for permissions
                permissionsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    self?.pollForPermissions()
                }
            } else {
                print("=== APPDELEGATE: User chose to quit ===")
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    private func checkAppleEventsPermission() {
        print("=== APPDELEGATE: Checking Apple Events permission ===")
        
        // Try to get the frontmost application - this will trigger the permission request
        let testScript = """
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
            return frontApp
        end tell
        """
        
        let appleScript = NSAppleScript(source: testScript)
        var error: NSDictionary?
        let result = appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            let errorNumber = error[NSAppleScript.errorNumber] as? Int
            print("=== APPDELEGATE: AppleScript error: \(error) ===")
            if errorNumber == -1743 { // Not authorized to send Apple events
                print("=== APPDELEGATE: Apple Events permission not granted (error -1743) ===")
                showAppleEventsPermissionAlert()
            } else {
                print("=== APPDELEGATE: AppleScript failed with different error: \(errorNumber ?? -1) ===")
            }
        } else {
            let frontApp = result?.stringValue ?? "unknown"
            print("=== APPDELEGATE: Apple Events permission granted, frontmost app: \(frontApp) ===")
        }
    }
    */
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    private func forceAppleEventsPermissionCheck() {
        print("=== APPDELEGATE: Force checking Apple Events permission ===")
        logToFile("=== APPDELEGATE: Force checking Apple Events permission ===")
        
        // First, try a simple permission check that should trigger the system dialog
        let simpleScript = """
        tell application "System Events"
            return "permission test"
        end tell
        """
        
        let simpleAppleScript = NSAppleScript(source: simpleScript)
        var simpleError: NSDictionary?
        let simpleResult = simpleAppleScript?.executeAndReturnError(&simpleError)
        
        if let simpleError = simpleError {
            let errorNumber = simpleError[NSAppleScript.errorNumber] as? Int
            print("=== APPDELEGATE: Simple AppleScript error: \(simpleError) ===")
            logToFile("=== APPDELEGATE: Simple AppleScript error: \(simpleError) ===")
            
            if errorNumber == -1743 { // Not authorized to send Apple events
                print("=== APPDELEGATE: Apple Events permission not granted (error -1743) ===")
                logToFile("=== APPDELEGATE: Apple Events permission not granted (error -1743) ===")
                
                // Try a more specific approach to trigger the permission dialog
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.triggerAppleEventsPermissionDialog()
                }
            } else {
                print("=== APPDELEGATE: AppleScript failed with different error: \(errorNumber ?? -1) ===")
                logToFile("=== APPDELEGATE: AppleScript failed with different error: \(errorNumber ?? -1) ===")
            }
        } else {
            let result = simpleResult?.stringValue ?? "unknown"
            print("=== APPDELEGATE: Apple Events permission granted, result: \(result) ===")
            logToFile("=== APPDELEGATE: Apple Events permission granted, result: \(result) ===")
        }
    }
    */
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    private func triggerAppleEventsPermissionDialog() {
        print("=== APPDELEGATE: Triggering Apple Events permission dialog ===")
        logToFile("=== APPDELEGATE: Triggering Apple Events permission dialog ===")
        
        // Try to get the frontmost application - this should trigger the permission request
        let testScript = """
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
            return frontApp
        end tell
        """
        
        let appleScript = NSAppleScript(source: testScript)
        var error: NSDictionary?
        let result = appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            let errorNumber = error[NSAppleScript.errorNumber] as? Int
            print("=== APPDELEGATE: AppleScript error: \(error) ===")
            logToFile("=== APPDELEGATE: AppleScript error: \(error) ===")
            
            if errorNumber == -1743 { // Not authorized to send Apple events
                print("=== APPDELEGATE: Apple Events permission still not granted after dialog trigger ===")
                logToFile("=== APPDELEGATE: Apple Events permission still not granted after dialog trigger ===")
                
                // Show a more specific alert with troubleshooting steps
                DispatchQueue.main.async {
                    self.showForceAppleEventsPermissionAlert()
                }
            }
        } else {
            let frontApp = result?.stringValue ?? "unknown"
            print("=== APPDELEGATE: Apple Events permission granted after dialog trigger, frontmost app: \(frontApp) ===")
            logToFile("=== APPDELEGATE: Apple Events permission granted after dialog trigger, frontmost app: \(frontApp) ===")
        }
    }
    */
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    private func showForceAppleEventsPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Apple Events Permission Required"
        alert.informativeText = "Dot-Dash needs Apple Events permission to work properly. If you haven't seen a permission request dialog, please follow these steps:\n\n1. Go to System Settings > Privacy & Security > Automation\n2. Look for 'Dot-Dash' in the list\n3. If it's not there, try restarting the app\n4. If still not appearing, check that the app is properly signed and notarized\n\nYou can continue without this permission, but some text replacement features may be less reliable."
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Restart App")
        alert.addButton(withTitle: "Continue Without")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
            NSWorkspace.shared.open(url)
        } else if response == .alertSecondButtonReturn {
            // Restart the app
            let url = URL(fileURLWithPath: Bundle.main.bundlePath)
            NSWorkspace.shared.open(url)
            NSApplication.shared.terminate(nil)
        }
    }
    */
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    func showAppleEventsPermissionAlert() {
        let alert = NSAlert()
        
        // Check if running from Xcode/development
        let isRunningFromXcode = Bundle.main.executablePath?.contains("DerivedData") ?? false
        
        if isRunningFromXcode {
            alert.messageText = "Development Build - Apple Events Permission"
            alert.informativeText = "You're running Dot-Dash from Xcode. For Apple Events permission to work properly, you need to install the app to Applications folder first. The app will still work without this permission, but some text replacement features may be less reliable."
            alert.addButton(withTitle: "Install to Applications")
            alert.addButton(withTitle: "Continue Without")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // Install the app
                installAppToApplications()
            }
        } else {
            alert.messageText = "Apple Events Permission Recommended"
            alert.informativeText = "Dot-Dash can work better with Apple Events permission. This allows for more reliable text replacement in some applications. You can grant this permission in System Settings > Privacy & Security > Automation."
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Continue Without")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
                NSWorkspace.shared.open(url)
            }
        }
    }
    */
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    private func installAppToApplications() {
        let sourcePath = Bundle.main.bundlePath
        let destinationPath = "/Applications/Dot-Dash.app"
        
        do {
            // Remove existing app if it exists
            if FileManager.default.fileExists(atPath: destinationPath) {
                try FileManager.default.removeItem(atPath: destinationPath)
            }
            
            // Copy the app
            try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
            
            let alert = NSAlert()
            alert.messageText = "App Installed"
            alert.informativeText = "Dot-Dash has been installed to Applications. The installed version will now launch and attempt to trigger Apple Events permission. You should see a permission request dialog."
            alert.addButton(withTitle: "Open Installed App")
            alert.addButton(withTitle: "OK")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // Launch the installed app with a special flag to trigger permission check immediately
                let process = Process()
                process.executableURL = URL(fileURLWithPath: destinationPath + "/Contents/MacOS/Dot-Dash")
                process.arguments = ["--trigger-apple-events-permission"]
                try process.run()
                
                // Also open the app normally
                NSWorkspace.shared.open(URL(fileURLWithPath: destinationPath))
                NSApplication.shared.terminate(nil)
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Installation Failed"
            alert.informativeText = "Failed to install app: \(error.localizedDescription)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    */

    private func showWaitingForPermissionsAlert() {
        let alert = NSAlert()
        alert.messageText = "Waiting for Accessibility Permissions"
        alert.informativeText = "Please grant Accessibility permissions for Dot-Dash in System Settings. This app will detect when permissions are granted."
        alert.addButton(withTitle: "Quit")
        // Show the alert as a non-blocking sheet on the main window if possible
        if let window = NSApplication.shared.windows.first {
            alert.beginSheetModal(for: window) { [weak self] response in
                if response == .alertFirstButtonReturn {
                    print("=== APPDELEGATE: User chose to quit from waiting alert ===")
                    self?.permissionsTimer?.invalidate()
                    self?.permissionsTimer = nil
                    NSApplication.shared.terminate(nil)
                }
            }
            waitingAlert = alert
        } else {
            // Fallback: run modal if no window
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                print("=== APPDELEGATE: User chose to quit from waiting alert (modal) ===")
                permissionsTimer?.invalidate()
                permissionsTimer = nil
                NSApplication.shared.terminate(nil)
            }
            waitingAlert = nil
        }
    }

    private func pollForPermissions() {
        if AXIsProcessTrusted() {
            print("=== APPDELEGATE: Permissions granted during polling ===")
            permissionsTimer?.invalidate()
            permissionsTimer = nil
            // Dismiss the waiting alert if present
            if let window = NSApplication.shared.windows.first, let alert = waitingAlert {
                window.endSheet(alert.window)
                waitingAlert = nil
            }
            // Start the keyboard monitor
            keyboardMonitor = KeyboardMonitorService()
            keyboardMonitor?.start()
            print("=== APPDELEGATE: Keyboard monitor started after permissions granted ===")
            
            // TODO: Re-enable Apple Events permission check when automation permissions issue is resolved
            // See AUTOMATION_PERMISSIONS_ISSUE.md for details
            /*
            // Check Apple Events permission after accessibility is granted
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.checkAppleEventsPermission()
            }
            */
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("=== APPDELEGATE: Application will terminate ===")
        logToFile("=== APPDELEGATE: Application will terminate ===")
        // Clean up the event tap when the app closes.
        keyboardMonitor?.stop()
        permissionsTimer?.invalidate()
    }
    
    // MARK: - Debugging Helpers
    
    func logAppInfo() {
        let bundleID = Bundle.main.bundleIdentifier ?? "nil"
        let execPath = Bundle.main.executablePath ?? "nil"
        let bundlePath = Bundle.main.bundlePath
        let isRunningFromXcode = bundlePath.contains("DerivedData")
        
        let info = """
        === APP INFO ===
        Bundle ID: \(bundleID)
        Executable Path: \(execPath)
        Bundle Path: \(bundlePath)
        Running from Xcode: \(isRunningFromXcode)
        === END APP INFO ===
        """
        
        print(info)
        logToFile(info)
    }
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    func checkTCCDatabase() {
        // This is a helper to check if the app appears in TCC database
        let task = Process()
        task.launchPath = "/usr/bin/sqlite3"
        task.arguments = [
            "\(NSHomeDirectory())/Library/Application Support/com.apple.TCC/TCC.db",
            "SELECT client, service, auth_value FROM access WHERE client LIKE '%Dot-Dash%' OR client LIKE '%augustcomstock.Dot-Dash%';"
        ]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "No output"
            
            print("=== TCC Database Check ===")
            print(output)
            logToFile("=== TCC Database Check ===\n\(output)")
        } catch {
            print("=== TCC Database Check Failed ===")
            print("Error: \(error)")
            logToFile("=== TCC Database Check Failed ===\nError: \(error)")
        }
    }
    */
}
