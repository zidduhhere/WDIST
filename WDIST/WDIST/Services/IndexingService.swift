import Foundation
import Observation
import Photos

nonisolated struct IndexingState: Equatable, Sendable {
    var completed = 0
    var total = 0
    var currentSummary = ""
    var isRunning = false
    var error: AppError?

    var progress: Double { total == 0 ? 0 : Double(completed) / Double(total) }
}

@MainActor
@Observable
final class IndexingService {
    private let repository: any ScreenshotRepository
    private let photoLibrary: PhotoLibraryService
    private let thumbnailService: ThumbnailService
    private let ocrService: OCRService
    private let aiService: AIService
    private(set) var state = IndexingState()

    init(repository: any ScreenshotRepository, photoLibrary: PhotoLibraryService, thumbnailService: ThumbnailService, ocrService: OCRService, aiService: AIService) {
        self.repository = repository
        self.photoLibrary = photoLibrary
        self.thumbnailService = thumbnailService
        self.ocrService = ocrService
        self.aiService = aiService
    }

    func requestAccessAndIndex() async {
        let status = photoLibrary.authorizationStatus
        let granted = status == .authorized || status == .limited ? status : await photoLibrary.requestAccess()
        guard granted == .authorized || granted == .limited else {
            state.error = .photoAccessDenied
            try? seedDemoIfNeeded()
            return
        }
        await indexUnindexedScreenshots()
    }

    func indexUnindexedScreenshots() async {
        guard !state.isRunning else { return }
        state = IndexingState(isRunning: true)
        do {
            let knownIDs = try repository.existingAssetIdentifiers()
            let pending = photoLibrary.screenshotReferences().filter { !knownIDs.contains($0.id) }
            state.total = pending.count
            for reference in pending {
                state.currentSummary = "Reading a screenshot…"
                do { try await index(reference) }
                catch let error as AppError {
                    // A single unavailable or text-free screenshot should never stop a full library import.
                    if error != .ocrFailed && error != .imageUnavailable && error != .corruptedImage { state.error = error }
                } catch { state.error = .unknown(error.localizedDescription) }
                state.completed += 1
                await Task.yield()
            }
        } catch { state.error = .unknown(error.localizedDescription) }
        state.isRunning = false
        state.currentSummary = ""
    }

    func reindexLibrary() async {
        do { try repository.deleteAll() }
        catch { state.error = .unknown(error.localizedDescription); return }
        await requestAccessAndIndex()
    }

    private func index(_ reference: PhotoAssetReference) async throws {
        let sourceData = try await photoLibrary.imageData(for: reference.id)
        // The thumbnail service always produces JPEG, which keeps Gemini's inline MIME type accurate.
        let thumbnailData = try thumbnailService.thumbnail(from: sourceData)
        let ocrResult = try await ocrService.analyze(sourceData)
        let recognizedText = ocrResult.text.isEmpty ? "No readable text detected." : ocrResult.text
        let ocrText = ocrResult.qrPayloads.isEmpty ? recognizedText : [recognizedText, "QR code", ocrResult.qrPayloads.joined(separator: " ")].joined(separator: "\n")
        state.currentSummary = "Understanding what you saved…"
        let analysis: AIAnalysis
        do {
            let initialAnalysis = try await aiService.summarizeScreenshot(ocrText: ocrText, imageData: thumbnailData)
            if initialAnalysis.tags.isEmpty {
                let generatedTags = (try? await aiService.generateTags(for: ocrText)) ?? []
                analysis = AIAnalysis(summary: initialAnalysis.summary, category: initialAnalysis.category, tags: generatedTags, importantEntities: initialAnalysis.importantEntities)
            } else {
                analysis = initialAnalysis
            }
        }
        catch { analysis = LocalScreenshotAnalyzer.analyze(ocrText: ocrText) }
        let item = ScreenshotItem(assetIdentifier: reference.id, capturedAt: reference.capturedAt, thumbnailData: thumbnailData, ocrText: ocrText, analysis: analysis)
        try repository.save(item)
    }

    private func seedDemoIfNeeded() throws {
        guard try repository.all().isEmpty else { return }
        for sample in DemoContent.samples { try repository.save(sample) }
    }
}

enum LocalScreenshotAnalyzer {
    static func analyze(ocrText: String) -> AIAnalysis {
        let text = ocrText.lowercased()
        let category: ScreenshotCategory
        if text.contains("qr code") { category = .qrCode }
        else if text.contains("linkedin") || text.contains("apply") || text.contains("internship") || text.contains("job description") { category = .jobPost }
        else if text.contains("total") && (text.contains("order") || text.contains("receipt")) { category = .receipt }
        else if text.contains("recipe") || text.contains("ingredients") || text.contains("preheat") { category = .recipe }
        else if text.contains("ticket") || text.contains("boarding") || text.contains("gate") { category = .ticket }
        else if text.contains("otp") || text.contains("verification code") { category = .otp }
        else if text.contains("map") || text.contains("directions") { category = .map }
        else { category = .other }
        let tokens = text.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init).filter { $0.count > 3 }
        let tags = Array(NSOrderedSet(array: tokens).compactMap { $0 as? String }.prefix(8))
        let summary = ocrText == "No readable text detected." ? "A screenshot with no readable text." : String(ocrText.prefix(160)).replacingOccurrences(of: "\n", with: " ")
        return AIAnalysis(summary: summary, category: category.rawValue, tags: tags, importantEntities: [])
    }
}
