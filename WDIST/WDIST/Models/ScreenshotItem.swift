import Foundation
import SwiftData

@Model
final class ScreenshotItem {
    @Attribute(.unique) var assetIdentifier: String
    var capturedAt: Date
    @Attribute(.externalStorage) var thumbnailData: Data?
    var ocrText: String
    var summary: String
    var categoryValue: String
    var tagValues: [String]
    var entityValues: [String]
    @Transient var embedding: [Float]?
    var indexedAt: Date
    var isDemo: Bool

    init(assetIdentifier: String, capturedAt: Date, thumbnailData: Data? = nil, ocrText: String, analysis: AIAnalysis, embedding: [Float]? = nil, indexedAt: Date = .now, isDemo: Bool = false) {
        self.assetIdentifier = assetIdentifier
        self.capturedAt = capturedAt
        self.thumbnailData = thumbnailData
        self.ocrText = ocrText
        self.summary = analysis.summary
        self.categoryValue = analysis.category
        self.tagValues = analysis.tags
        self.entityValues = analysis.importantEntities
        self.embedding = embedding
        self.indexedAt = indexedAt
        self.isDemo = isDemo
    }

    var id: String { assetIdentifier }
    var category: ScreenshotCategory { ScreenshotCategory.resolved(categoryValue) }
    var tags: [Tag] { tagValues.map(Tag.init(value:)) }
    var searchCorpus: String { ([summary, ocrText, categoryValue] + tagValues + entityValues).joined(separator: " ") }
}
