
import SwiftUI

struct ContentView: View {
    @StateObject private var persistenceManager = PersistenceManager()
    @State private var newCommand = ""
    @State private var newReplacement = ""

    init() {
        print("=== CONTENTVIEW: ContentView initialized ===")
    }

    var body: some View {
        VStack {
            Text("Dot-Dash Commands")
                .font(.title)
                .padding()

            List {
                ForEach(persistenceManager.getRules()) { rule in
                    HStack {
                        Text(rule.command)
                            .font(.headline)
                        Text(rule.replacementText)
                            .font(.subheadline)
                        Spacer()
                        Button(action: {
                            persistenceManager.delete(rule: rule)
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                }
            }

            HStack {
                TextField("Command (e.g., .hello)", text: $newCommand)
                TextField("Replacement Text", text: $newReplacement)
                Button(action: {
                    let newRule = ExpansionRule(command: newCommand, replacementText: newReplacement)
                    persistenceManager.add(rule: newRule)
                    newCommand = ""
                    newReplacement = ""
                }) {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newCommand.isEmpty || newReplacement.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}
