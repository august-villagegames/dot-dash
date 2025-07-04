import SwiftUI

@main
struct DotDashApp: App {
    // Use AppDelegate to manage app lifecycle and setup the event tap
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        print("=== DOTDASHAPP: App initializing ===")
    }

    var body: some Scene {
        // This WindowGroup is not shown by default because a MenuBarExtra is present.
        // It can be opened programmatically from the menu bar.
        WindowGroup("main") {
            ContentView()
        }

        MenuBarExtra("Dot-Dash", systemImage: "keyboard.fill") {
            MenuCommands()
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuCommands: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Edit Commands") {
            print("=== MENU COMMANDS: Edit Commands button clicked ===")
            print("Attempting to open window with ID: main")
            openWindow(id: "main")
            print("openWindow() call completed")
            
            // Fallback: Try to force window to front
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("=== MENU COMMANDS: Attempting fallback window activation ===")
                if let window = NSApplication.shared.windows.first(where: { $0.title == "main" || $0.title.isEmpty }) {
                    print("=== MENU COMMANDS: Found window, bringing to front ===")
                    window.makeKeyAndOrderFront(nil)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                } else {
                    print("=== MENU COMMANDS: No window found for fallback ===")
                }
            }
        }
        Divider()
        Button("Debug Info") {
            print("=== MENU COMMANDS: Debug Info button clicked ===")
            print("Active windows: \(NSApplication.shared.windows.count)")
            for (index, window) in NSApplication.shared.windows.enumerated() {
                print("Window \(index): title='\(window.title)', isVisible=\(window.isVisible), isKey=\(window.isKeyWindow)")
            }
        }
        Divider()
        Button("Quit Dot-Dash") {
            print("=== MENU COMMANDS: Quit button clicked ===")
            NSApplication.shared.terminate(nil)
        }
    }
}
