import Foundation

struct SearchResult: Identifiable {
    let item: ScreenshotItem
    let score: Double
    let highlights: [String]
    var id: String { item.id }
}
