import SwiftUI

struct ContentView: View {
    @StateObject private var persistenceManager = PersistenceManager()
    @State private var showingForm = false
    @State private var editingRule: ExpansionRule? = nil

    init() {
        print("=== CONTENTVIEW: ContentView initialized ===")
    }

    var body: some View {
        VStack {
            Text("Dot Dash")
                .font(.largeTitle).bold()
                .padding(.top, 32)
            
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(persistenceManager.getRules()) { rule in
                        HStack(alignment: .center, spacing: 16) {
                            Text(rule.command)
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 220, alignment: .leading)
                            Text("\(rule.replacementText.prefix(60))\(rule.replacementText.count > 60 ? ",..." : "")")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                            Button("Edit") {
                                editingRule = rule
                                showingForm = true
                            }
                            Button("Delete") {
                                persistenceManager.delete(rule: rule)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            Spacer()
            Button(action: {
                editingRule = nil
                showingForm = true
            }) {
                Text("Create")
            }
            .padding(.horizontal, 200)
            .padding(.bottom, 32)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(24)
        .padding(24)
        .frame(minWidth: 900, minHeight: 600)
        .sheet(isPresented: $showingForm, onDismiss: { editingRule = nil }) {
            Group {
                if let rule = editingRule {
                    ShortcutFormView(
                        command: rule.command,
                        replacementText: rule.replacementText,
                        isEditing: true,
                        onSubmit: { command, replacement in
                            persistenceManager.delete(rule: rule)
                            let updated = ExpansionRule(command: command, replacementText: replacement)
                            persistenceManager.add(rule: updated)
                        },
                        onCancel: {
                            editingRule = nil
                        }
                    )
                    .id(rule.id)
                } else {
                    ShortcutFormView(
                        command: "",
                        replacementText: "",
                        isEditing: false,
                        onSubmit: { command, replacement in
                            let newRule = ExpansionRule(command: command, replacementText: replacement)
                            persistenceManager.add(rule: newRule)
                        },
                        onCancel: {}
                    )
                    .id("new")
                }
            }
        }
    }
}
