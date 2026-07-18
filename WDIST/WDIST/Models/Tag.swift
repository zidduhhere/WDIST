import Foundation

nonisolated struct Tag: Identifiable, Hashable, Codable, Sendable {
    let value: String
    var id: String { value.lowercased() }
}
