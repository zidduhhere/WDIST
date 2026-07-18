import Foundation

nonisolated enum SearchScorer {
    static func score(query: String, candidate: SearchCandidate) -> Double {
        let tokens = query.lowercased().split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init).filter { $0.count > 1 }
        guard !tokens.isEmpty else { return 0 }
        let fields: [(String, Double)] = [(candidate.summary.lowercased(), 5), (candidate.tags.joined(separator: " ").lowercased(), 4), (candidate.category.lowercased(), 3), (candidate.entities.joined(separator: " ").lowercased(), 3), (candidate.ocrText.lowercased(), 1)]
        let matched = tokens.reduce(0.0) { partial, token in partial + fields.reduce(0.0) { $0 + ($1.0.contains(token) ? $1.1 : 0) } }
        let intentBoost = categoryIntentBoost(query: query.lowercased(), category: candidate.category)
        let recency = max(0, 1 - Date().timeIntervalSince(candidate.capturedAt) / (180 * 86_400))
        return matched / Double(tokens.count) + intentBoost + recency * 0.15
    }

    private static func categoryIntentBoost(query: String, category: String) -> Double {
        let intentTerms: [ScreenshotCategory: Set<String>] = [
            .jobPost: ["job", "internship", "career", "hiring", "linkedin", "role"],
            .qrCode: ["qr", "scan", "code", "register"],
            .receipt: ["receipt", "bill", "order", "payment", "total"],
            .ticket: ["ticket", "boarding", "flight", "concert", "gate"],
            .recipe: ["recipe", "ingredients", "cook", "dinner", "food"],
            .meme: ["meme", "funny", "joke"],
            .note: ["note", "reminder", "list"],
            .map: ["map", "directions", "address", "route"],
            .otp: ["otp", "verification", "code", "password"],
            .eventPoster: ["event", "poster", "show", "workshop"],
            .shopping: ["shopping", "price", "product", "buy"],
            .other: []
        ]
        let category = ScreenshotCategory.resolved(category)
        return intentTerms[category, default: []].contains { query.contains($0) } ? 1.25 : 0
    }
}

nonisolated struct SearchCandidate: Sendable {
    let id: String
    let capturedAt: Date
    let summary: String
    let category: String
    let tags: [String]
    let entities: [String]
    let ocrText: String

    @MainActor
    init(item: ScreenshotItem) {
        id = item.id
        capturedAt = item.capturedAt
        summary = item.summary
        category = item.categoryValue
        tags = item.tagValues
        entities = item.entityValues
        ocrText = item.ocrText
    }
}
