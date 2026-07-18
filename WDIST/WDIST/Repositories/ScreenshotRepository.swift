import Foundation
import SwiftData

@MainActor
protocol ScreenshotRepository {
    func all() throws -> [ScreenshotItem]
    func recent(limit: Int) throws -> [ScreenshotItem]
    func existingAssetIdentifiers() throws -> Set<String>
    func save(_ item: ScreenshotItem) throws
    func deleteAll() throws
}

@MainActor
final class SwiftDataScreenshotRepository: ScreenshotRepository {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func all() throws -> [ScreenshotItem] {
        let descriptor = FetchDescriptor<ScreenshotItem>(sortBy: [SortDescriptor(\.capturedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func recent(limit: Int) throws -> [ScreenshotItem] {
        var descriptor = FetchDescriptor<ScreenshotItem>(sortBy: [SortDescriptor(\.indexedAt, order: .reverse)])
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func existingAssetIdentifiers() throws -> Set<String> { Set(try all().map(\.assetIdentifier)) }
    func save(_ item: ScreenshotItem) throws { context.insert(item); try context.save() }
    func deleteAll() throws { try context.delete(model: ScreenshotItem.self); try context.save() }
}
