import Foundation
import Photos

nonisolated struct PhotoAssetReference: Identifiable, Sendable {
    let id: String
    let capturedAt: Date
}

@MainActor
final class PhotoLibraryService {
    var authorizationStatus: PHAuthorizationStatus { PHPhotoLibrary.authorizationStatus(for: .readWrite) }

    func requestAccess() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }

    func screenshotReferences() -> [PhotoAssetReference] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        let assets = PHAsset.fetchAssets(with: .image, options: options)
        var results: [PhotoAssetReference] = []
        results.reserveCapacity(assets.count)
        assets.enumerateObjects { asset, _, _ in
            results.append(PhotoAssetReference(id: asset.localIdentifier, capturedAt: asset.creationDate ?? .now))
        }
        return results
    }

    func imageData(for identifier: String) async throws -> Data {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = assets.firstObject else { throw AppError.imageUnavailable }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.version = .current
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, info in
                if let error = info?[PHImageErrorKey] as? Error { continuation.resume(throwing: error) }
                else if let data { continuation.resume(returning: data) }
                else { continuation.resume(throwing: AppError.imageUnavailable) }
            }
        }
    }
}
