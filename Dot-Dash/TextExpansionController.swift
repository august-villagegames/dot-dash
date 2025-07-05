import AppKit
import Carbon

class TextExpansionController {
    
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
    // This will be implemented in a future milestone.
    func expand(command: String, replacement: String) {
        print("TextExpansionController: Expanding \(command) to \(replacement)")
        
        // Validate inputs
        guard !command.isEmpty else {
            print("TextExpansionController: Command is empty, skipping expansion")
            return
        }
        
        guard !replacement.isEmpty else {
            print("TextExpansionController: Replacement is empty, skipping expansion")
            return
        }
        
        // TODO: Re-enable AppleScript strategy when automation permissions issue is resolved
        // See AUTOMATION_PERMISSIONS_ISSUE.md for details
        /*
        // Try AppleScript first for better reliability
        if tryAppleScriptStrategy(command: command, replacement: replacement) {
            print("TextExpansionController: AppleScript strategy succeeded")
            return
        }
        */
        
        // Try multiple strategies for text replacement
        if tryStrategy1(command: command, replacement: replacement) {
            print("TextExpansionController: Strategy 1 (backspace + paste) succeeded")
            return
        }
        
        if tryStrategy2(command: command, replacement: replacement) {
            print("TextExpansionController: Strategy 2 (select all + replace) succeeded")
            return
        }
        
        print("TextExpansionController: All strategies failed, falling back to basic paste")
        _ = tryStrategy3(command: command, replacement: replacement)
    }
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    // AppleScript Strategy: Most reliable for supported applications
    private func tryAppleScriptStrategy(command: String, replacement: String) -> Bool {
        // Check if we have Apple Events permission first
        if !checkAppleEventsPermission() {
            print("TextExpansionController: Apple Events permission not granted, skipping AppleScript strategy")
            return false
        }
        
        // Escape special characters in the replacement text
        let escapedReplacement = replacement.replacingOccurrences(of: "\"", with: "\\\"")
        
        let script = """
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
        end tell
        
        tell application "System Events"
            tell process frontApp
                try
                    -- Get the current text selection or cursor position
                    set currentText to value of attribute "AXValue" of (first text field whose focused is true)
                    
                    -- Calculate the position to delete the command
                    set commandLength to \(command.count)
                    set textLength to length of currentText
                    
                    -- Delete the command characters from the end
                    set newText to text 1 thru (textLength - commandLength) of currentText
                    
                    -- Set the new text with replacement
                    set value of attribute "AXValue" of (first text field whose focused is true) to (newText & "\(escapedReplacement)")
                    return true
                on error
                    return false
                end try
            end tell
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        let result = appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            let errorNumber = error[NSAppleScript.errorNumber] as? Int
            if errorNumber == -1743 {
                // Not authorized to send Apple events
                print("TextExpansionController: AppleScript failed with error -1743 (no Automation permission)")
                // Show user alert for Automation permission
                DispatchQueue.main.async {
                    (NSApplication.shared.delegate as? AppDelegate)?.showAppleEventsPermissionAlert()
                }
                return false
            }
            print("TextExpansionController: AppleScript failed with error: \(error)")
            return false
        }
        
        return result?.booleanValue ?? false
    }
    */
    
    // TODO: Re-enable when automation permissions issue is resolved
    // See AUTOMATION_PERMISSIONS_ISSUE.md for details
    /*
    // Helper method to check Apple Events permission
    private func checkAppleEventsPermission() -> Bool {
        let testScript = """
        tell application "System Events"
            return "permission granted"
        end tell
        """
        
        let appleScript = NSAppleScript(source: testScript)
        var error: NSDictionary?
        let result = appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            let errorNumber = error[NSAppleScript.errorNumber] as? Int
            if errorNumber == -1743 { // Not authorized to send Apple events
                return false
            }
        }
        
        return result?.stringValue == "permission granted"
    }
    */
    
    // Strategy 1: Backspace + Paste (original approach, improved)
    private func tryStrategy1(command: String, replacement: String) -> Bool {
        let backspaceCount = command.count - 1  // Subtract 1 because cursor is after the last character
        print("TextExpansionController: Strategy 1 - Command length: \(command.count), will backspace \(backspaceCount) times")
        logToFile("TextExpansionController: Strategy 1 - Command length: \(command.count), will backspace \(backspaceCount) times")
        
        // Use the correct key code for backspace: 0x33 (kVK_Delete)
        let backspaceKeyCode: CGKeyCode = 0x33
        
        // Delete exactly the command length (cursor is after the last character)
        for i in 0..<backspaceCount {
            print("TextExpansionController: Strategy 1 - Backspace \(i + 1)/\(backspaceCount)")
            logToFile("TextExpansionController: Strategy 1 - Backspace \(i + 1)/\(backspaceCount)")
            // Create backspace down event
            let backspaceDown = CGEvent(keyboardEventSource: nil, virtualKey: backspaceKeyCode, keyDown: true)
            backspaceDown?.post(tap: .cgSessionEventTap)
            
            // Small delay to ensure the event is processed
            Thread.sleep(forTimeInterval: 0.01)
            
            // Create backspace up event
            let backspaceUp = CGEvent(keyboardEventSource: nil, virtualKey: backspaceKeyCode, keyDown: false)
            backspaceUp?.post(tap: .cgSessionEventTap)
            
            // Small delay between backspaces
            Thread.sleep(forTimeInterval: 0.01)
        }
        
        // Small delay after all backspaces to ensure they're processed
        Thread.sleep(forTimeInterval: 0.05)
        
        // Set the replacement text on the pasteboard and paste
        return pasteText(replacement)
    }
    
    // Strategy 2: Select All + Replace (alternative approach)
    private func tryStrategy2(command: String, replacement: String) -> Bool {
        // Select all text (Cmd+A)
        let selectAllDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x00, keyDown: true) // kVK_ANSI_A
        selectAllDown?.flags = .maskCommand
        selectAllDown?.post(tap: .cgSessionEventTap)
        
        Thread.sleep(forTimeInterval: 0.01)
        
        let selectAllUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x00, keyDown: false)
        selectAllUp?.flags = .maskCommand
        selectAllUp?.post(tap: .cgSessionEventTap)
        
        Thread.sleep(forTimeInterval: 0.05)
        
        // Paste the replacement text
        return pasteText(replacement)
    }
    
    // Strategy 3: Just paste (fallback)
    private func tryStrategy3(command: String, replacement: String) -> Bool {
        return pasteText(replacement)
    }
    
    // Helper method to paste text
    private func pasteText(_ text: String) -> Bool {
        // Set the replacement text on the pasteboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Small delay to ensure pasteboard is updated
        Thread.sleep(forTimeInterval: 0.01)
        
        // Simulate a paste command (Cmd+V)
        let pasteKeyCode: CGKeyCode = 0x09 // kVK_ANSI_V
        
        let pasteDown = CGEvent(keyboardEventSource: nil, virtualKey: pasteKeyCode, keyDown: true)
        pasteDown?.flags = .maskCommand
        
        let pasteUp = CGEvent(keyboardEventSource: nil, virtualKey: pasteKeyCode, keyDown: false)
        pasteUp?.flags = .maskCommand
        
        pasteDown?.post(tap: .cgSessionEventTap)
        Thread.sleep(forTimeInterval: 0.01)
        pasteUp?.post(tap: .cgSessionEventTap)
        
        return true
    }
}
