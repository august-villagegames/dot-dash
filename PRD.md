### **Product Requirements Document: "Dot-Dash" Text Expander**

**1. Introduction & Vision**

**Product Name:** Dot-Dash

**Vision:** To create a seamless, lightweight, and intuitive text expansion utility for macOS that reduces repetitive typing and boosts user productivity. Dot-Dash will allow users to create custom shortcuts (prefixed with a ".") that instantly expand into pre-defined blocks of text, including formatting, in any application or text field across the operating system.

**2. Target Audience**

*   **Professionals & Office Workers:** Individuals who frequently type repetitive emails, reports, or messages (e.g., sales outreach, meeting agendas, standard replies).
*   **Customer Support Agents:** Staff who need to quickly insert canned responses, troubleshooting steps, or links.
*   **Developers & Coders:** Programmers who want to insert common code snippets or boilerplate with a simple command.
*   **Students & Academics:** Users who need to cite sources, insert formulas, or write recurring phrases in their notes and papers.
*   **Anyone who values typing efficiency.**

**3. Core Features & User Stories**

The initial version (v1.0) of Dot-Dash will focus on the core functionality of creating, managing, and expanding text snippets.

*   **User Story 1: System-Wide Text Expansion**
    *   **As a user,** I want to type a command starting with a period (e.g., `.meetingAgenda`) into any text input field on my Mac.
    *   **So that,** the command is instantly deleted and replaced with the full, pre-configured text I have associated with it.

*   **User Story 2: Command Management GUI**
    *   **As a user,** I want a simple and clean graphical user interface (GUI).
    *   **So that,** I can easily view all my saved commands, add new ones, and edit or delete existing ones.

*   **User Story 3: Creating New Commands**
    *   **As a user,** I want to be able to define a new command (e.g., `.sig`) and its corresponding replacement text (e.g., my full email signature).
    *   **So that,** I can build my own personal library of shortcuts.

*   **User Story 4: Rich Text Support**
    *   **As a user,** I want the replacement text to support formatting (like bold, italics, bullet points, and line breaks).
    *   **So that,** my expanded text appears correctly formatted, such as in an email or document.

*   **User Story 5: Menu Bar Accessibility**
    *   **As a user,** I want the app to run quietly in the background and be accessible from the macOS menu bar.
    *   **So that,** I can quickly open the command management window or pause the service without it cluttering my dock.

**4. Design and User Experience (UI/UX)**

*   **Onboarding:** Upon first launch, the app will clearly explain that it requires **Accessibility** and **Input Monitoring** permissions from macOS to function. It will provide a button that takes the user directly to the relevant System Settings panel to grant these permissions. This is critical for user trust and functionality.

*   **Menu Bar Icon:**
    *   The app will be primarily housed in the macOS menu bar.
    *   A **left-click** on the icon will open the main "Command Editor" window.
    *   A **right-click** (or ctrl-click) will open a small menu with options: "Open Editor," "Disable/Enable Expansions," and "Quit."

*   **Command Editor Window:**
    *   A clean, single-window interface.
    *   **Layout:** A two-pane view.
        *   **Left Pane:** A searchable list of all saved commands (e.g., `.meetingAgenda`, `.sig`, `.replyThanks`).
        *   **Right Pane:** The editor for the selected command.
    *   **Editor Fields:**
        *   **Command:** A simple text field for the shortcut (e.g., `.meetingAgenda`). The app will enforce the "." prefix.
        *   **Replacement Text:** A rich text editing field that allows for basic formatting (bold, italic, underline, lists) and multiple lines.
    *   **Controls:** Simple `+` and `-` buttons to add a new command or delete the selected one. Changes are saved automatically.

**5. Non-Functional Requirements**

*   **Performance:** Expansion must feel instantaneous (<100ms latency from completing the command to replacement). The app must have a minimal CPU and memory footprint to avoid impacting system performance.
*   **Platform:** macOS 13.0 (Ventura) or newer.
*   **Technology:** To achieve system-wide integration, the app should be built using native macOS frameworks (Swift with AppKit/SwiftUI).
*   **Security & Privacy:**
    *   All user-defined commands and replacement text are stored locally on the user's machine and are never transmitted to any server.
    *   The app only monitors keyboard input to detect commands prefixed with ".". It should not log or store any other keystrokes. This must be clearly stated in a privacy policy.

**6. Assumptions and Dependencies**

*   The user must be willing and able to grant the necessary Accessibility and Input Monitoring permissions in System Settings. The app cannot function without them.
*   The expansion mechanism will work by simulating keystrokes: detecting the command, simulating backspaces to delete it, and then pasting or typing the replacement text. This may have compatibility issues with a small number of highly specialized applications (e.g., virtual machines, remote desktops), which should be noted as a potential limitation.

**7. Future Enhancements (Out of Scope for v1.0)**

*   **iCloud Sync:** Sync commands across multiple Macs.
*   **Dynamic Placeholders:** Allow for variables in snippets, such as `Hello {contact_name},` or `The date is {current_date}`.
*   **Team/Shared Libraries:** Ability to subscribe to or share libraries of commands with others.
*   **Custom Trigger Characters:** Allow users to choose a trigger other than ".".
*   **Expansion Statistics:** Show users how much time they've saved.

**8. Success Metrics**

*   High user adoption and positive reviews on the App Store (if distributed there).
*   Low rate of reported crashes or performance issues.
*   Qualitative feedback indicating that the app successfully saves users time and effort.
*   High retention rate (users continuing to use the app 30 days after install).
