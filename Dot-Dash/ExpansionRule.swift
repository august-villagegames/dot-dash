
import Foundation

struct ExpansionRule: Codable, Identifiable {
    var id = UUID()
    var command: String
    var replacementText: String // For now, we'll use plain text. Rich text comes later.
}
