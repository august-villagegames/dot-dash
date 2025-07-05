import SwiftUI

struct ShortcutFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State var command: String
    @State var replacementText: String
    let isEditing: Bool
    let onSubmit: (String, String) -> Void
    let onCancel: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(isEditing ? "Create/Edit Shortcut" : "Create Shortcut")
                .font(.largeTitle).bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 32)
            VStack(alignment: .leading, spacing: 8) {
                Text("Shortcut Input")
                    .font(.headline)
                TextField(".shortcutExample", text: $command)
                    .padding(6)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Shortcut output")
                    .font(.headline)
                TextEditor(text: $replacementText)
                    .frame(minHeight: 120)
                    .padding(6)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
            }
            Spacer()
            HStack {
                Button("Cancel") {
                    onCancel()
                    dismiss()
                }
                Spacer()
                Button("Submit") {
                    onSubmit(command, replacementText)
                    dismiss()
                }
                .disabled(command.trimmingCharacters(in: .whitespaces).isEmpty || replacementText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 32)
        .frame(minWidth: 600, minHeight: 400)
    }
} 