import Foundation
import CoreTransferable
import UniformTypeIdentifiers

nonisolated struct ScreenshotShareItem: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { item in
            item.data
        }
    }
}
