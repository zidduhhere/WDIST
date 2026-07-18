import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let settings: SettingsStore
    private let repository: any ScreenshotRepository
    private let indexing: IndexingService
    var provider: AIProvider
    var apiKey = ""
    var isWorking = false
    var confirmation: Confirmation?
    var error: AppError?
    var didSaveAPIKey = false

    enum Confirmation: Identifiable { case deleteIndex; var id: String { "delete-index" } }

    init(settings: SettingsStore, repository: any ScreenshotRepository, indexing: IndexingService) {
        self.settings = settings
        self.repository = repository
        self.indexing = indexing
        provider = settings.provider
        apiKey = settings.apiKey
    }

    func selectProvider(_ provider: AIProvider) {
        do {
            try settings.selectProvider(provider)
            self.provider = provider
            apiKey = settings.apiKey
        } catch let appError as AppError {
            error = appError
        } catch {
            error = .unknown(error.localizedDescription)
        }
    }

    func saveAPIKey() {
        do {
            try settings.saveAPIKey(apiKey)
            didSaveAPIKey = true
        }
        catch let appError as AppError { self.error = appError }
        catch { self.error = .unknown(error.localizedDescription) }
    }

    func reindex() async { isWorking = true; await indexing.reindexLibrary(); isWorking = false; error = indexing.state.error }
    func deleteIndex() {
        do { try repository.deleteAll() }
        catch { self.error = .unknown(error.localizedDescription) }
    }
}
