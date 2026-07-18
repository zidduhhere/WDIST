import Foundation

nonisolated struct AIAnalysis: Codable, Sendable {
    let summary: String
    let category: String
    let tags: [String]
    let importantEntities: [String]

    static let empty = AIAnalysis(summary: "A saved screenshot.", category: ScreenshotCategory.other.rawValue, tags: [], importantEntities: [])
}
