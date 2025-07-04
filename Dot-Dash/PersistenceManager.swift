

import Foundation
import Combine // Import Combine for ObservableObject

class PersistenceManager: ObservableObject { // Conform to ObservableObject
    @Published private var rules: [ExpansionRule] = [] // Mark rules as @Published
    private let storageURL: URL

    init() {
        // Get the URL for the Application Support directory.
        guard let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Unable to find application support directory.")
        }
        self.storageURL = appSupportDirectory.appendingPathComponent("Dot-Dash/rules.json")
        
        // Create the directory if it doesn't exist.
        let directoryURL = self.storageURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }

        // Load the rules from the JSON file.
        loadRules()
    }

    func getRules() -> [ExpansionRule] {
        return rules
    }

    func add(rule: ExpansionRule) {
        rules.append(rule)
        saveRules()
    }

    func delete(rule: ExpansionRule) {
        rules.removeAll { $0.id == rule.id }
        saveRules()
    }

    private func loadRules() {
        do {
            let data = try Data(contentsOf: storageURL)
            self.rules = try JSONDecoder().decode([ExpansionRule].self, from: data)
        } catch {
            // If the file doesn't exist or is corrupt, start with an empty list.
            self.rules = [
                ExpansionRule(command: ".hello", replacementText: "Hello, world!"),
                ExpansionRule(command: ".sig", replacementText: "Best,\nAugust Comstock")
            ]
        }
    }

    private func saveRules() {
        do {
            let data = try JSONEncoder().encode(rules)
            try data.write(to: storageURL, options: .atomicWrite)
        } catch {
            print("Failed to save rules: \(error)")
        }
    }
}

