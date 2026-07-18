import Foundation

@MainActor
final class SearchService {
    private let repository: any ScreenshotRepository
    private let aiService: AIService

    init(repository: any ScreenshotRepository, aiService: AIService) {
        self.repository = repository
        self.aiService = aiService
    }

    func search(query: String, category: ScreenshotCategory? = nil) async throws -> [SearchResult] {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return [] }
        let items = try repository.all().filter { category == nil || $0.category == category }
        let scores = await aiService.semanticSearch(query: cleanQuery, candidates: items.map(SearchCandidate.init(item:)))
        return items.compactMap { item in
            let score = scores[item.id] ?? 0
            guard score > 0 else { return nil }
            return SearchResult(item: item, score: score, highlights: highlights(for: cleanQuery, item: item))
        }
        .sorted { $0.score > $1.score }
    }

    func recent(limit: Int = 8) throws -> [ScreenshotItem] { try repository.recent(limit: limit) }
    func categoryCounts() throws -> [CategoryCount] {
        let items = try repository.all()
        return ScreenshotCategory.allCases.compactMap { category in
            let count = items.count { $0.category == category }
            return count == 0 ? nil : CategoryCount(category: category, count: count)
        }
    }

    private func highlights(for query: String, item: ScreenshotItem) -> [String] {
        query.lowercased().split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init).filter { item.searchCorpus.lowercased().contains($0) }
    }
}
