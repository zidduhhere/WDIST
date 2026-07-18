import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    private let service: SearchService
    var query = "" { didSet { scheduleSearch() } }
    var selectedCategory: ScreenshotCategory?
    var results: [SearchResult] = []
    var isSearching = false
    var error: AppError?
    private var searchTask: Task<Void, Never>?

    init(service: SearchService) { self.service = service }
    func searchNow() async {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { results = []; return }
        isSearching = true
        defer { isSearching = false }
        do { results = try await service.search(query: query, category: selectedCategory) }
        catch { self.error = .unknown(error.localizedDescription) }
    }

    func chooseCategory(_ category: ScreenshotCategory?) {
        selectedCategory = category
        scheduleSearch()
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { results = []; return }
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(260))
            guard !Task.isCancelled else { return }
            await self?.searchNow()
        }
    }
}
