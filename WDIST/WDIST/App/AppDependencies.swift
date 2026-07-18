import Foundation
import SwiftData

@MainActor
final class AppDependencies {
    let repository: any ScreenshotRepository
    let photoLibrary: PhotoLibraryService
    let indexing: IndexingService
    let search: SearchService
    let settings: SettingsStore

    init(modelContainer: ModelContainer) {
        let repository = SwiftDataScreenshotRepository(context: modelContainer.mainContext)
        let photoLibrary = PhotoLibraryService()
        let thumbnailService = ThumbnailService()
        let aiService = AIService()
        self.repository = repository
        self.photoLibrary = photoLibrary
        self.indexing = IndexingService(repository: repository, photoLibrary: photoLibrary, thumbnailService: thumbnailService, ocrService: OCRService(), aiService: aiService)
        self.search = SearchService(repository: repository, aiService: aiService)
        self.settings = SettingsStore()
    }
}
