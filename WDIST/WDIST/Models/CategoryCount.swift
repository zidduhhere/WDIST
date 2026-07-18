import Foundation

nonisolated struct CategoryCount: Identifiable, Sendable {
    let category: ScreenshotCategory
    let count: Int
    var id: String { category.id }
}
