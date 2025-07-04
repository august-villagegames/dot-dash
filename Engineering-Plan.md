### **Engineering Plan: "Dot-Dash" Text Expander**

**1. Executive Summary**

This document details the technical plan for developing Dot-Dash, a native macOS text expansion utility. The goal is to create a lightweight, performant, and secure application that integrates deeply with the operating system to provide a seamless user experience. This plan covers the proposed technology stack, system architecture, development phases, and risk mitigation strategies.

**2. Technology Stack**

To meet the requirements of system-wide integration and a modern, maintainable codebase, the following technologies will be used:

*   **Language:** **Swift 5.x**. The standard for modern macOS development, offering safety, performance, and complete access to system APIs.
*   **UI Framework:** **SwiftUI**. For building the menu bar interface and the Command Editor window. SwiftUI allows for rapid, declarative UI development that is native to the Apple ecosystem.
*   **Core macOS Frameworks:**
    *   **AppKit:** Used alongside SwiftUI for application lifecycle management (`NSApplication`), creating the menu bar icon (`NSStatusBar`), and handling window management.
    *   **Core Graphics (`CGEvent`):** The cornerstone of the application. A `CGEvent.tapCreate` will be used to establish a low-level event tap that can monitor keyboard events system-wide without interfering with the active application.
    *   **Accessibility APIs:** To programmatically simulate keystrokes (backspace) and paste actions. This is essential for the text replacement functionality.
*   **Data Persistence:**
    *   **Local JSON File:** A simple and robust solution for storing the user's list of commands and replacements. The data will be stored as a JSON file in the user's `~/Library/Application Support/Dot-Dash/` directory. Swift's `Codable` protocol will be used for easy encoding and decoding of the data model. `UserDefaults` will be used for storing simple app settings (e.g., "start on login").
*   **Build Environment:** **Xcode 15** or newer.

**3. System Architecture**

The application will be architected into several distinct, decoupled components to ensure maintainability and testability.

1.  **Core Service (Event Monitor):**
    *   A singleton class (`KeyboardMonitorService`) that runs in the background.
    *   **Responsibility:**
        *   On app launch, it requests Accessibility and Input Monitoring permissions if not already granted.
        *   It sets up the `CGEvent` tap on the keyboard. This tap will run on a background thread to avoid blocking the main UI thread.
        *   It listens for all key-down events and maintains a small, rolling buffer of recent keystrokes.
        *   It contains the logic to detect a trigger sequence (e.g., a string starting with "." followed by a terminating character like a space or return).
    *   **Performance:** This service must be highly optimized to ensure zero perceivable input lag for the user.

2.  **Expansion Controller:**
    *   A controller (`TextExpansionController`) responsible for executing the text replacement.
    *   **Responsibility:**
        *   When the `KeyboardMonitorService` detects a valid command, it invokes this controller.
        *   The controller simulates the required number of `delete` key presses to erase the typed command.
        *   It then fetches the rich text replacement from the `PersistenceManager` and places it on the system clipboard (`NSPasteboard`).
        *   Finally, it simulates a `Cmd+V` (paste) keystroke to insert the content. This is the most reliable method for preserving rich text formatting across different applications.

3.  **Data Model & Persistence:**
    *   **Model:** A `Codable` Swift `struct` named `ExpansionRule` with properties like `id: UUID`, `command: String`, and `replacementText: Data` (to store RTF/attributed string data).
    *   **Persistence Manager:** A class (`PersistenceManager`) that handles all file I/O. It will be responsible for loading the JSON file into memory on app start and saving it back to disk whenever a change is made in the UI.

4.  **UI Layer (SwiftUI):**
    *   **Menu Bar Component:** An `AppDelegate` or `MenuBarExtra` scene that creates the menu bar icon and its associated menu (Open, Pause/Resume, Quit).
    *   **Command Editor View:** A SwiftUI view that displays the list of `ExpansionRule` objects. It will allow users to add, select, edit, and delete rules. It interacts directly with the `PersistenceManager` to reflect changes immediately.

**4. Development Phases & Milestones**

The project will be broken down into four distinct milestones.

*   **Milestone 1: Core Engine Proof-of-Concept (1 Week)**
    *   **Goal:** Validate the core text detection and replacement mechanism.
    *   **Tasks:**
        1.  Set up the Xcode project.
        2.  Implement the `KeyboardMonitorService` using `CGEvent.tapCreate`.
        3.  Hardcode 1-2 expansion rules directly in the code.
        4.  Implement the `TextExpansionController` to perform the backspace-and-paste action.
        5.  Manually grant permissions in System Settings to test functionality.
    *   **Outcome:** A "headless" app that runs in the background and correctly expands the hardcoded commands system-wide.

*   **Milestone 2: Data Persistence and Management (4 Days)**
    *   **Goal:** Make the expansion rules dynamic and persistent.
    *   **Tasks:**
        1.  Define the `ExpansionRule` `Codable` struct.
        2.  Build the `PersistenceManager` to handle saving and loading rules from a JSON file.
        3.  Refactor the Core Engine to use rules loaded from the `PersistenceManager`.
    *   **Outcome:** The app can now use a dynamic set of rules that persist between launches.

*   **Milestone 3: User Interface Development (1.5 Weeks)**
    *   **Goal:** Build the user-facing GUI for managing commands.
    *   **Tasks:**
        1.  Create the menu bar icon and menu.
        2.  Build the Command Editor window using SwiftUI (list view and detail/editor view).
        3.  Implement full CRUD (Create, Read, Update, Delete) functionality for expansion rules.
        4.  Integrate a basic rich text editor for the replacement text field.
        5.  Connect the UI to the `PersistenceManager` to reflect data changes.
    *   **Outcome:** A fully functional GUI where users can manage their personal library of text expansions.

*   **Milestone 4: Polishing, Permissions, and Packaging (1 Week)**
    *   **Goal:** Create a shippable, user-friendly application.
    *   **Tasks:**
        1.  Design and implement a smooth onboarding flow to guide users through granting permissions.
        2.  Implement robust error handling (e.g., if permissions are revoked).
        3.  Add an application icon.
        4.  Perform thorough QA testing across various macOS applications.
        5.  Archive, notarize the application with Apple, and package it in a `.dmg` for distribution.
    *   **Outcome:** A polished, stable, and distributable v1.0 of Dot-Dash.

**5. Key Technical Challenges & Mitigation**

*   **System Permissions:**
    *   **Challenge:** The app is non-functional without Accessibility and Input Monitoring permissions. Users may be hesitant to grant them.
    *   **Mitigation:** The first-launch experience must be transparent and helpful. Clearly explain *why* the permissions are needed (only to detect ".commands" and simulate keystrokes) and provide a direct button to the correct panel in System Settings.

*   **Performance of the Event Tap:**
    *   **Challenge:** Any latency in the keyboard monitor will make the entire OS feel sluggish.
    *   **Mitigation:** The code inside the `CGEvent` callback must be extremely fast. All heavy lifting (like file I/O or complex logic) must be dispatched to other threads. The buffer of recent keystrokes should be kept small and managed efficiently in memory.

*   **Compatibility:**
    *   **Challenge:** The simulate-paste method may not work in all contexts (e.g., password fields that block paste, terminal applications, virtual machines).
    *   **Mitigation:** This is a known limitation of this type of application. We will document the known incompatibilities. For plain-text-only fields, a fallback that simulates typing the replacement string character-by-character could be implemented.

*   **Rich Text Handling:**
    *   **Challenge:** Storing and pasting rich text is more complex than plain text.
    *   **Mitigation:** We will use `NSAttributedString` and store it as RTF data. The pasteboard approach (`NSPasteboard`) is the most reliable way to transfer this into other applications, as it's a standard system mechanism.

**6. Testing Strategy**

*   **Unit Testing:** The `PersistenceManager` and the command-detection logic within the `KeyboardMonitorService` will be covered by unit tests to ensure they are reliable.
*   **Manual QA:** Extensive manual testing is critical. The QA process will involve:
    *   Testing expansion in a wide range of applications (Safari, Chrome, Mail, Pages, Notes, VS Code, Messages, Slack).
    *   Verifying the permissions onboarding flow on a clean system.
    *   Testing edge cases: very long replacement text, text with special characters/emojis, rapid typing, etc.
    *   Verifying CPU/memory usage remains low during normal operation.

**7. Deployment**

The application will be distributed outside the Mac App Store to avoid sandboxing limitations that could interfere with the `CGEvent` tap. The release process will be:
1.  Archive the application in Xcode.
2.  Submit the build to Apple's automated notarization service.
3.  Package the notarized `.app` file into a signed `.dmg` file for user download.
