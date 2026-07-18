import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let indexing: IndexingService
    private let searchService: SearchService
    var recent: [ScreenshotItem] = []
    var categories: [CategoryCount] = []
    var error: AppError?
    var hasLoaded = false

    init(indexing: IndexingService, searchService: SearchService) {
        self.indexing = indexing
        self.searchService = searchService
    }

    var indexingState: IndexingState { indexing.state }

    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await indexing.requestAccessAndIndex()
        refresh()
    }

    func refresh() {
        do {
            recent = try searchService.recent()
            categories = try searchService.categoryCounts()
            error = indexing.state.error
        } catch { self.error = .unknown(error.localizedDescription) }
    }

    func reindex() async { await indexing.reindexLibrary(); refresh() }

    func retryPhotoAccess() async {
        await indexing.requestAccessAndIndex()
        refresh()
    }
}
